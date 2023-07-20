//
//  RequestsEventHandlerImpl.swift
//  IdentHubSDKFourthline
//

import Foundation
import FourthlineKYC
import IdentHubSDKCore
import UIKit

// MARK: - Fourthline Requests event logic -

typealias RequestsCallback = (RequestsOutput) -> Void

final internal class RequestsEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<RequestsEvent>, ViewController.ViewState == RequestsState {
    
    weak var updatableView: ViewController?
    
    // MARK: - Properties -
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    public var input: RequestsInput
    private var storage: Storage
    internal var colors: Colors
    public var state: RequestsState
    public var callback: RequestsCallback
    
    private var prepareData: DataFetchStep = .fetchPersonData
    private var uploadStep: UploadSteps = .prepareData
    private var uploadFileURL: URL = URL(fileURLWithPath: "")
    private var willEnterForegroundObserver: AnyObject?
    
    let sessionInfoProvider: StorageSessionInfoProvider
    
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: RequestsInput,
        storage: Storage,
        colors: Colors,
        session: StorageSessionInfoProvider,
        callback: @escaping RequestsCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.storage = storage
        self.colors = colors
        self.callback = callback
        self.state = RequestsState(title: "", description: "", type: input.requestsType)
        self.sessionInfoProvider = session
        
        setupNotifications()
    }
    
    deinit {
        if let willEnterForegroundObserver = willEnterForegroundObserver {
            NotificationCenter.default.removeObserver(willEnterForegroundObserver)
        }
    }
    
    private func setupNotifications() {
        willEnterForegroundObserver = NotificationCenter.default.addObserver(forName: UIApplication.willEnterForegroundNotification, object: nil, queue: .main) { [weak self] notification in
            self?.restartFetchLocationIfNeeded()
        }
    }
    
    private func restartFetchLocationIfNeeded() {
        switch (input.requestsType, input.initStep, prepareData) {
        case (.fetchData, .fetchLocation, _), (.fetchData, _, .location):
            fetchLocationData()
        default:
            break
        }
    }
    
    func handleEvent(_ event: RequestsEvent) {
        switch event {
        case .identifyEvent: self.identifyEvent()
        case .initateFlow: self.registerFourthlineMethod()
        case .fetchData: self.fetchPersonalData()
        case .uploadData: self.uploadData()
        case .verification: self.verification()
        case .reTry(let status): self.didTriggerRetry(status: status)
        case .zipFailedReTry(let error):
            switch error {
            case .invalidDocument:
                self.callback(.fourthline(.documentPicker))
            case .invalidSelfie:
                self.callback(.fourthline(.selfie))
            case .invalidData:
                self.callback(.fourthline(.welcome))
            case .none:
                quit()
            }
        case .close(let error): self.callback(.fourthline(.close(error: error)))
        case .restart: self.restartProcess()
        case .quit: self.quit()
        }
    }
    
    private func identifyEvent() {
        self.input.requestsType = input.requestsType
        updateState { state in
            state.identifyEvent = true
        }
    }
    
    private func registerFourthlineMethod() {
        input.initStep = .registerMethod
        input.requestsType = .fetchData
        updateStateDetails()

        verificationService.getFourthlineIdentification { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.storage[.identificationUID] = response.identificationID
                self.sessionInfoProvider.identificationUID = response.identificationID
                FileManager.default.deleteFourthlineFiles()
                self.fetchPersonalData()
            case .failure(let error):
                self.updateState { state in
                    state.onDisplayError = error
                    state.loading = false
                }
            }
        }
    }
    
    private func updateState(_ update: @escaping (inout RequestsState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    private func fetchPersonalData() {
        input.initStep = .fetchPersonData
        input.requestsType = .fetchData
        updateStateDetails()
        fourthlineLog.info("Requesting fetch PersonalData...")
        
        guard let _ = self.sessionInfoProvider.identificationUID else {
            self.stateFailed()
            return
        }
        verificationService.fetchPersonData(isOrca: self.sessionInfoProvider.orcaEnabled) { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.storage[.documentsList] = response.supportedDocuments
                self.storage[.orcaCountryList] = response.supportedDocumentsRaw
                KYCContainer.shared.update(person: response)

                DispatchQueue.main.async {
                    self.fetchLocationData()
                }
            case .failure(let error):
                self.updateState { state in
                    state.onDisplayError = error
                    state.loading = false
                }
            }
        }
    }
    
    private func fetchLocationData() {
        input.initStep = .fetchLocation
        fourthlineLog.info("Requesting location permissions...")
        LocationManager.shared.resetLocationManager()
        LocationManager.shared.requestLocationAuthorization { [weak self] status, error in
            
            LocationManager.shared.releaseLocationAuthorizationCompletionHandler()
            if status {
                fourthlineLog.info("Location permissions are granted")
            } else {
                fourthlineLog.warn("Location permissions are not granted with error \(String(describing: error?.localizedDescription))")
            }
            
            guard let self = self else { return }
            guard status else {
                if let locationErr = error as? APIError {
                    self.updateState { state in
                        state.onDisplayError = locationErr
                        state.loading = false
                    }
                }
                return
            }
            
            fourthlineLog.info("Requesting device location...")
            self.updateState { state in
                state.onDisplayError = nil
                state.loading = true
            }
            LocationManager.shared.requestDeviceLocation { [weak self] location, error in
                guard let self = self else { return }
                
                LocationManager.shared.releaseCompletionHandler()
                guard let location = location else {
                    fourthlineLog.warn("Device location not updated. Error: \(String(describing: error?.localizedDescription))")
                    
                    self.updateState { state in
                        state.onDisplayError = APIError.locationError
                        state.loading = false
                    }
                    return
                }
                KYCContainer.shared.update(location: location)
                fourthlineLog.info("Updated device location")
                
                self.fetchIPAddress()
            }
        }
    }
    
    private func fetchIPAddress() {
        input.initStep = .fetchIPAddress
        self.updateState { state in
            state.onDisplayError = nil
            state.loading = true
        }
        verificationService.fetchIPAddress { [weak self] result in
            guard let self = self else { return }
            self.updateState { state in
                state.loading = false
            }

            switch result {
            case .success(let response):
                KYCContainer.shared.update(ipAddress: response.ip)
                if(self.sessionInfoProvider.identificationStep == .fourthlineSigning) {
                    self.fetchNamirialTermsConditions()
                } else {
                    DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                        self.callback(.finishInitialFetch())
                    }
                }
            case .failure(let error):
                self.updateState { state in
                    state.onDisplayError = error
                    state.loading = false
                }
            }
        }
    }
    func fetchNamirialTermsConditions() {
        input.initStep = .fetchNamirialTermsConditions
        self.updateState { state in
            state.onDisplayError = nil
            state.loading = true
        }
        verificationService.getNamirialTermsConditions { [weak self] result in
            guard let self = self else { return }
            self.updateState { state in
                state.loading = false
            }

            switch result {
            case .success(let response):
                KYCContainer.shared.update(namirialTermsConditions: response)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                    self.callback(.finishInitialFetch())
                }
            case .failure(let error):
                self.updateState { state in
                    state.onDisplayError = error
                    state.loading = false
                }
            }
        }
    }
    private func uploadData() {
        input.requestsType = .uploadData
        updateStateDetails()
        
        switch uploadStep {
        case .prepareData:
            #if AUTOMATION
                zipMockUserData()
            #else
                zipUserData()
            #endif
        case .uploadData:
            uploadZip(uploadFileURL)
        }
    }
    
    private func verification() {
        input.requestsType = .confirmation
        updateStateDetails()
        startVerificationProcess()
    }
    
    func onDisplayError(error: APIError) {
        self.updateState { state in
            state.onDisplayError = error
            state.loading = false
        }
    }
    
    func quit() {
        callback(.quit)
    }
    
    func updateStateDetails() {
        updateState { state in
            state.title = self.obtainScreenTitle()
            state.description = self.obtainScreenDescription()
            state.waitingInstruction = self.obtainScreenWaitingDescription()
            state.loading = true
            state.identifyEvent = false
        }
    }
    
    func stateFailed() {
        updateState { state in
            state.onDisplayError = ResponseError(.unknownError)
            state.loading = false
        }
    }
    
    /// Method defines and returns request screen title text
    /// - Returns: title text
    func obtainScreenTitle() -> String {
        switch self.input.requestsType {
        case .initateFlow:
            return Localizable.Initial.title
        case .fetchData:
            return Localizable.FetchData.title
        case .uploadData:
            return Localizable.Upload.title
        case .confirmation:
            return Localizable.Verification.title
        }
    }

    /// Method defines and returns request screen description text
    /// - Returns: description text
    func obtainScreenDescription() -> String {
        switch self.input.requestsType {
        case .initateFlow:
            return Localizable.Initial.description
        case .fetchData:
            return Localizable.FetchData.person
        case .uploadData:
            return Localizable.Upload.description
        case .confirmation:
            return Localizable.Verification.description
        }
    }
    
    func obtainScreenWaitingDescription() -> String {
        switch self.input.requestsType {
        case .uploadData:
            return Localizable.Upload.bottomInstruction
        case .confirmation:
            return Localizable.Upload.bottomInstruction
        default:
            return ""
        }
    }
    /// Method trigger retry logic of the Fourthline or Fourthline signing flow
    /// - Parameter status: response of the failed ident result
    func didTriggerRetry(status: FourthlineIdentificationStatus) {
        guard let step = status.nextStep else {
            if let fallbackstep = sessionInfoProvider.fallbackIdentificationStep {
                self.callback(.fourthline(.nextStep(step: fallbackstep)))
            }
            return
        }

        self.callback(.fourthline(.nextStep(step: step)))
    }
    
}

// MARK: - Upload methods -

extension RequestsEventHandlerImpl {

    private func startUploadProcess() {
        zipUserData()
    }

    private func zipUserData() {
        uploadStep = .prepareData

        kycLog.info("Creating zip file...")
        KYCZipService.createKYCZip { [weak self] zipURL, err in
            guard let url = zipURL else {

                if let err = err {
                    self?.manageZipFailed(with: err as! ZipperError)
                }
                return
            }
            self?.uploadZip(url)
        }
    }
    
    private func zipMockUserData() {
        uploadStep = .prepareData
        updateStateDetails()
        
        let filePath = Bundle.current.path(forResource: "kyc", ofType: "zip")
        let fileManager : FileManager   = FileManager.default
        
        if fileManager.fileExists(atPath: filePath ?? ""){
            let zipURL = URL(fileURLWithPath: filePath ?? "")
            
            if zipURL.isFileURL {
                self.uploadZip(zipURL)
            }
        } else {
            updateState { state in
                state.onDisplayError = ResponseError(.kycZipNotFound)
                state.loading = false
            }
        }
    }

    func uploadZip(_ fileURL: URL) {
        uploadStep = .uploadData
        uploadFileURL = fileURL
        kycLog.info("Uploading zip file...")
        
        guard let _ = self.sessionInfoProvider.identificationUID else {
            self.stateFailed()
            return
        }
        verificationService.uploadKYCZip(fileURL: fileURL) { [unowned self] result in
            switch result {
            case .success:
                kycLog.info("Zip file sucessfully uploaded")
                self.updateState { state in
                    state.loading = false
                }
                DispatchQueue.main.asyncAfter(deadline: .now() + 2.0) {
                    self.verification()
                }
                self.deleteFile(at: fileURL)
            case .failure(let error):
                kycLog.error("Error uploading zip file \(error.statusCode) - \(error.localizedDescription)")
                if Int(error.statusCode) == 409 {
                    self.verification()
                    self.deleteFile(at: fileURL)
                } else {
                    self.updateState { state in
                        state.onDisplayError = error
                        state.loading = false
                    }
                }
            }
        }
    }

    private func deleteFile(at url: URL) {
        if(FileManager.default.fileExists(atPath: url.relativePath)) {
            do {
                try FileManager.default.removeItem(at: url)
            } catch let error as NSError {
                kycLog.warn("Error occurs during removing uploaded zip file: \(error.localizedDescription)")
            }
        }
    }
    
    private func manageZipFailed(with error: ZipperError) {
        let message = KYCZipService.text(for: error)
        let errorType = KYCZipService.zipErrorType(for: error)
        var errorDetails = ZipFailedError(title: Localizable.Zipper.Error.alertTitle, description: message, type: .none, isRetry: false)
        
        switch errorType {
        case .invalidData:
            errorDetails.type = .invalidData
        case .invalidDocument:
            errorDetails.type = .invalidDocument
        case .invalidSelfie:
            errorDetails.type = .invalidSelfie
        }

        updateState { state in
            state.zipError = errorDetails
            state.loading = false
            state.identifyEvent = false
        }
    }

}

// MARK: - Verification methods -

private extension RequestsEventHandlerImpl {

    private func startVerificationProcess() {
        guard let _ = self.sessionInfoProvider.identificationUID else {
            self.stateFailed()
            return
        }
        verificationService.obtainFourthlineIdentificationStatus { [weak self] result in
            guard let self = self else { return }
            switch result {
            case .success(let response):
                switch response.identificationStatus {
                case .pending,
                     .processed:
                    self.retryVerification()
                default:
                    self.manageResponseStatus(response)
                }
            case .failure(let error):
                self.updateState { state in
                    state.onDisplayError = error
                    state.loading = false
                }
            }
        }
    }

    private func retryVerification() {
        DispatchQueue.main.asyncAfter(deadline: 5.seconds.fromNow) { [weak self] in
            guard let self = self else { return }

            self.startVerificationProcess()
        }
    }

    private func showResult(_ result: FourthlineIdentificationStatus) {
        if let nextStep = result.nextStep {
            self.callback(.fourthline(.nextStep(step: nextStep)))
        } else {
            if result.identificationMethod == .bankID {
                self.callback(.fourthline(.complete(result: result)))
            } else {
                self.callback(.fourthline(.result(result: result)))
            }
        }
    }

    private func manageResponseStatus(_ status: FourthlineIdentificationStatus) {
        self.updateState { state in
            state.loading = false
            state.identifyEvent = false
        }

        switch status.identificationStatus {
        case .rejected,
             .fraud:
            self.callback(.fourthline(.abort))
        case .authorizationRequired:
            if status.identificationMethod == .fourthlineSigning {
                self.callback(.fourthline(.nextStep(step: .fourthlineQES)))
            } else if status.identificationMethod == .bankID {
                self.callback(.fourthline(.nextStep(step: .bankQES)))
            } else {
                self.showResult(status)
            }
        case .confirmed:
            if status.identificationMethod == .fourthlineSigning {
                self.callback(.fourthline(.complete(result: status)))
            }
        case .failed:
            guard let statusCode = status.providerStatusCode, let providerCode = Int(statusCode) else {
                if let fallbackStep = status.fallbackStep {
                    self.callback(.fourthline(.nextStep(step: fallbackStep)))
                } else {
                    self.callback(.fourthline(.abort))
                }
                return
            }

            switch providerCode {
            case 1001...3999:
                self.updateState { state in
                    state.onRetry = status
                }
                return /// Don't remove SessionStorage data in case of retry.
            case 4000...5000:
                self.callback(.fourthline(.abort))
            default:
                self.callback(.fourthline(.abort))
            }
        default:
            DispatchQueue.main.async {
                self.showResult(status)
            }
        }

        FileManager.default.deleteFourthlineFiles()
        SessionStorage.clearData()
    }
}

// MARK: - Restart Process -

private extension RequestsEventHandlerImpl {
    
    private func restartProcess() {
        
        switch self.input.requestsType {
        case .initateFlow:
            switch input.initStep {
            case .registerMethod:
                registerFourthlineMethod()
            case .fetchPersonData:
                fetchPersonalData()
            case .fetchLocation:
                fetchLocationData()
            case .fetchIPAddress:
                fetchIPAddress()
            case .fetchNamirialTermsConditions:
                fetchNamirialTermsConditions()
            default:
                break
            }
        case .fetchData:
            switch prepareData {
            case .fetchPersonData:
                fetchPersonalData()
            case .location:
                fetchLocationData()
            case .fetchIPAddress:
                fetchIPAddress()
            case .fetchNamirialTermsConditions:
                fetchNamirialTermsConditions()
            }
        case .uploadData:
            switch uploadStep {
            case .prepareData:
                zipUserData()
            case .uploadData:
                uploadZip(uploadFileURL)
            }
        case .confirmation:
            startVerificationProcess()
        }
    }
    
}
