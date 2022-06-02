//
//  UploadViewModel.swift
//  IdentHubSDK
//

import UIKit
import FourthlineKYC

let progressCellID = "UploadProgressCellID"

enum RequestsType {
    case initateFlow
    case fetchData
    case uploadData
    case confirmation
}

enum InitStep: Int {
    case defineMethod = 0, obtainInfo, registerMethod, fetchPersonData, fetchLocation, fetchIPAddress
}

enum DataFetchStep: Int {
    case fetchPersonData = 0, location, fetchIPAddress
}

enum UploadSteps: Int {
    case prepareData = 0, uploadData
}

enum VerificationSteps: Int {
    case verification = 0
}

final class RequestsViewModel: NSObject {

    // MARK: - Public attributes -
    var onTableUpdate: (() -> Void)?
    var onDisplayError: ((Error?) -> Void)?
    var onRetry: ((FourthlineIdentificationStatus) -> Void)?

    // MARK: - Private attributes -
    private var ddm: RequestsProgressDDM?
    private let verificationService: VerificationService
    private let sessionStorage: StorageSessionInfoProvider
    private let requestsType: RequestsType
    private let builder: RequestsProgressCellObjectBuilder
    private var requestsSteps: [ProgressCellObject] = []
    private var initStep: InitStep = .defineMethod
    private var prepareData: DataFetchStep = .fetchPersonData
    private var uploadStep: UploadSteps = .prepareData
    private var uploadFileURL: URL = URL(fileURLWithPath: "")
    private weak var fourthlineCoordinator: FourthlineIdentCoordinator?
    private weak var identCoordinator: IdentificationCoordinator?

    // MARK: - Init methods -

    /// Initial setup request screen view model
    /// - Parameters:
    ///   - service: send request service
    ///   - storage: identification storage
    ///   - type: type of the request
    ///   - identCoordinator: identification coordinator
    ///   - fourthlineCoordinator: fourthline identification session flow
    init(_ service: VerificationService, storage: StorageSessionInfoProvider, type: RequestsType, identCoordinator: IdentificationCoordinator? = nil, fourthlineCoordinator: FourthlineIdentCoordinator? = nil) {

        self.verificationService = service
        self.sessionStorage = storage
        self.requestsType = type
        self.builder = RequestsProgressCellObjectBuilder(type: type)
        self.requestsSteps = self.builder.buildContent()

        if let coordinator = identCoordinator {
            self.identCoordinator = coordinator
        } else if let coordinator = fourthlineCoordinator {
            self.fourthlineCoordinator = coordinator
        }
    }

    // MARK: - Public methods -
    
    /// Method returns table view data source
    /// - Returns: display data manager
    func obtainTableDDM() -> RequestsProgressDDM? {
        ddm = RequestsProgressDDM()
        return ddm
    }

    /// Method defines and returns request screen title text
    /// - Returns: title text
    func obtainScreenTitle() -> String {
        switch self.requestsType {
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
        switch self.requestsType {
        case .initateFlow:
            return Localizable.Initial.description
        case .fetchData:
            return Localizable.FetchData.description
        case .uploadData:
            return Localizable.Upload.description
        case .confirmation:
            return Localizable.Verification.description
        }
    }
    
    /// Method triggers chain of request methods based on type
    func executeCommand() {
        switch requestsType {
        case .initateFlow:
            startInitialProcess()
        case .fetchData:
            startFetchDataProcess()
        case .uploadData:
            startUploadProcess()
        case .confirmation:
            startVerificationProcess()
        }
    }
    
    /// Method triggers quit from SDK proccess
    func didTriggerQuit() {
        if let coordinator = fourthlineCoordinator {
            coordinator.perform(action: .abort)
        } else {
            identCoordinator?.perform(action: .abort)
        }
    }

    /// Method restart Fourthline step depends on error type
    /// - Parameter errorType: KYC zipping error type
    func didTriggerRetry(errorType: KYCZipErrorType) {
        switch errorType {
        case .invalidDocument:
            fourthlineCoordinator?.perform(action: .documentPicker)
        case .invalidSelfie:
            fourthlineCoordinator?.perform(action: .selfie)
        case .invalidData:
            fourthlineCoordinator?.perform(action: .welcome)
        }
    }

    /// Method should interrupt identification process with failure reason
    /// - Parameter reason: API error type
    func abortIdentProcess(_ reason: APIError) {
        if let coordinator = fourthlineCoordinator {
            coordinator.perform(action: .close(error: reason))
        } else {
            identCoordinator?.perform(action: .abort)
        }
    }

    /// Method calls latest identification step again
    func restartRequests() {
        restartProcess()
    }

    /// Method trigger retry logic of the Fourthline or Fourthline signing flow
    /// - Parameter status: response of the failed ident result
    func didTriggerRetry(status: FourthlineIdentificationStatus) {

        guard let step = status.nextStep else {
            if let fallbackstep = sessionStorage.fallbackIdentificationStep {
                self.fourthlineCoordinator?.perform(action: .nextStep(step: fallbackstep))
            }
            return
        }

        self.fourthlineCoordinator?.perform(action: .nextStep(step: step))
    }
}

// MARK: - Internal methods -

private extension RequestsViewModel {

    private func restartProcess() {
        switch requestsType {
        case .initateFlow:
            switch initStep {
            case .defineMethod:
                defineIdentificationMethod()
            case .obtainInfo:
                obtainIdentificationInfo()
            case .registerMethod:
                registerFourthlineMethod()
            case .fetchPersonData:
                fetchPersonalData()
            case .fetchLocation:
                fetchLocationData()
            case .fetchIPAddress:
                fetchIPAddress()
            }
        case .fetchData:
            switch prepareData {
            case .fetchPersonData:
                fetchPersonalData()
            case .location:
                fetchLocationData()
            case .fetchIPAddress:
                fetchIPAddress()
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

    private func startNextStep(initStep: InitStep, dataStep: DataFetchStep) {
        if isFourthlineFlow() {
            startStep(number: initStep.rawValue)
            self.initStep = initStep
        } else {
            startStep(number: dataStep.rawValue)
            prepareData = dataStep
            SessionStorage.updateValue(dataStep.rawValue, for: StoredKeys.fetchDataStep.rawValue)
        }
    }

    private func startStep(number step: Int) {
        requestsSteps[step].updateLoadingStatus(true)
        updateContent()
    }

    private func completeStep(number step: Int) {
        requestsSteps[step].updateCompletionStatus(true)
        updateContent()
    }

    private func updateContent() {
        ddm?.updateContent(requestsSteps)
        onTableUpdate?()
    }
}

// MARK: - Initial ident flow methods -

private extension RequestsViewModel {

    private func startInitialProcess() {
        defineIdentificationMethod()
    }

    private func defineIdentificationMethod() {
        startStep(number: InitStep.defineMethod.rawValue)
        initStep = .defineMethod

        verificationService.defineIdentificationMethod { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                self.completeStep(number: InitStep.defineMethod.rawValue)
                self.sessionStorage.identificationStep = response.firstStep
                self.sessionStorage.fallbackIdentificationStep = response.fallbackStep
                self.sessionStorage.retries = response.retries

                if let provider = response.fourthlineProvider, provider.isEmpty == false {
                    KYCContainer.shared.update(provider: provider)
                }

                self.obtainIdentificationInfo()
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }

    private func obtainIdentificationInfo() {
        startStep(number: InitStep.obtainInfo.rawValue)
        initStep = .obtainInfo

        verificationService.obtainIdentificationInfo { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                self.completeStep(number: InitStep.obtainInfo.rawValue)
                self.sessionStorage.acceptedTC = response.acceptedTC
                self.sessionStorage.phoneVerified = response.phoneVerificationStatus ?? false
                self.sessionStorage.setStyleColors(response.style?.colors)

                if let provider = response.fourthlineProvider {
                    KYCContainer.shared.update(provider: provider)
                }

                if self.isFourthlineFlow() {
                    if response.status == .rejected {
                        self.fourthlineCoordinator?.perform(action: .abort)
                    } else {
                        self.registerFourthlineMethod()
                    }
                } else {
                    self.finishInitialization()
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }

    private func registerFourthlineMethod() {
        startStep(number: InitStep.registerMethod.rawValue)
        initStep = .registerMethod

        verificationService.getFourthlineIdentification { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                self.sessionStorage.identificationUID = response.identificationID
                self.completeStep(number: InitStep.registerMethod.rawValue)
                self.fetchPersonalData()
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }

    private func finishInitialization() {
        if self.sessionStorage.acceptedTC {
            self.identCoordinator?.perform(action: .identification)
        } else {
            self.identCoordinator?.perform(action: .termsAndConditions)
        }
    }
}

// MARK: - Fetch data methods -

private extension RequestsViewModel {

    private func startFetchDataProcess() {
        fetchPersonalData()
    }

    private func fetchPersonalData() {
        startNextStep(initStep: .fetchPersonData, dataStep: .fetchPersonData)

        verificationService.fetchPersonData { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                self.sessionStorage.documentsList = response.supportedDocuments

                KYCContainer.shared.update(person: response)

                if self.isFourthlineFlow() {
                    self.completeStep(number: InitStep.fetchPersonData.rawValue)
                } else {
                    self.completeStep(number: DataFetchStep.fetchPersonData.rawValue)
                }
                DispatchQueue.main.async {
                    self.fetchLocationData()
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }

    private func fetchLocationData() {
        startNextStep(initStep: .fetchLocation, dataStep: .location)

        LocationManager.shared.requestLocationAuthorization { [weak self] status, error in
            guard status else {
                if let locationErr = error as? APIError, let errorHandler = self?.onDisplayError {
                    errorHandler(locationErr)
                }
                return
            }
            LocationManager.shared.requestDeviceLocation { [weak self] location, error in
                guard let `self` = self else { return }
                guard let location = location else {

                    if let errorHandler = self.onDisplayError {
                        errorHandler(APIError.locationError)
                    }
                    return
                }

                KYCContainer.shared.update(location: location)

                if self.isFourthlineFlow() {
                    self.completeStep(number: InitStep.fetchLocation.rawValue)
                } else {
                    self.completeStep(number: DataFetchStep.location.rawValue)
                }

                self.fetchIPAddress()
            }
        }
    }

    private func fetchIPAddress() {
        startNextStep(initStep: .fetchIPAddress, dataStep: .fetchIPAddress)

        verificationService.fetchIPAddress { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                KYCContainer.shared.update(ipAddress: response.ip)

                if self.isFourthlineFlow() {
                    self.completeStep(number: InitStep.fetchIPAddress.rawValue)
                    self.finishInitialization()
                } else {
                    self.completeStep(number: DataFetchStep.fetchIPAddress.rawValue)
                    self.fourthlineCoordinator?.perform(action: .documentPicker)
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }

    private func isFourthlineFlow() -> Bool {
        return ( sessionStorage.identificationStep == .fourthline || sessionStorage.identificationStep == .fourthlineSigning )
    }
}

// MARK: - Upload methods -

private extension RequestsViewModel {

    private func startUploadProcess() {
        zipUserData()
    }

    private func zipUserData() {
        startStep(number: UploadSteps.prepareData.rawValue)
        uploadStep = .prepareData

        KYCZipService.createKYCZip { [weak self] zipURL, err in
            guard let url = zipURL else {

                if let err = err {
                    self?.onDisplayError?(err)
                }
                return
            }

            self?.completeStep(number: UploadSteps.prepareData.rawValue)
            self?.uploadZip(url)
        }
    }

    private func uploadZip(_ fileURL: URL) {
        startStep(number: UploadSteps.uploadData.rawValue)
        uploadStep = .uploadData
        uploadFileURL = fileURL

        verificationService.uploadKYCZip(fileURL: fileURL) { [unowned self] result in

            switch result {
            case .success(_):
                self.fourthlineCoordinator?.perform(action: .confirmation)
                self.deleteFile(at: fileURL)
            case .failure(let error):
                self.onDisplayError?(error)
            }

            self.completeStep(number: UploadSteps.uploadData.rawValue)
        }
    }

    private func deleteFile(at url: URL) {
        do {
            try FileManager.default.removeItem(at: url)
        } catch let error as NSError {
            print("Error occurs during removing uploaded zip file: \(error.localizedDescription)")
        }
    }
}

// MARK: - Verification methods -

private extension RequestsViewModel {

    private func startVerificationProcess() {
        startStep(number: VerificationSteps.verification.rawValue)

        verificationService.obtainFourthlineIdentificationStatus { [unowned self] result in
            self.completeStep(number: VerificationSteps.verification.rawValue)

            switch result {
            case .success(let response):
                switch response.identificationStatus {
                case .pending,
                     .processed:
                    retryVerification()
                default:
                    self.manageResponseStatus(response)
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }

    private func retryVerification() {
        DispatchQueue.main.asyncAfter(deadline: 5.seconds.fromNow) { [weak self] in
            guard let `self` = self else { return }

            self.startVerificationProcess()
        }
    }

    private func showResult(_ result: FourthlineIdentificationStatus) {
        if let nextStep = result.nextStep {
            self.fourthlineCoordinator?.perform(action: .nextStep(step: nextStep))
        } else {
            if result.identificationMethod == .bankID {
                self.fourthlineCoordinator?.perform(action: .complete(result: result))
            } else {
                self.fourthlineCoordinator?.perform(action: .result(result: result))
            }
        }
    }

    private func manageResponseStatus(_ status: FourthlineIdentificationStatus) {

        switch status.identificationStatus {
        case .rejected,
             .fraud:
            self.fourthlineCoordinator?.perform(action: .abort)
        case .authorizationRequired:
            if status.identificationMethod == .fourthlineSigning {
                self.fourthlineCoordinator?.perform(action: .nextStep(step: .fourthlineQES))
            } else if status.identificationMethod == .bankID {
                self.fourthlineCoordinator?.perform(action: .nextStep(step: .bankIDQES))
            } else {
                self.showResult(status)
            }
        case .confirmed:
            if status.identificationMethod == .fourthlineSigning {
                self.fourthlineCoordinator?.perform(action: .complete(result: status))
            }
        case .failed:
            guard let statusCode = status.providerStatusCode, let providerCode = Int(statusCode) else {
                if let fallbackStep = status.fallbackStep {
                    self.fourthlineCoordinator?.perform(action: .nextStep(step: fallbackStep))
                } else {
                    self.fourthlineCoordinator?.perform(action: .abort)
                }
                return
            }

            switch providerCode {
            case 1001...3999:
                    self.onRetry?(status)
            case 4000...5000:
                self.fourthlineCoordinator?.perform(action: .abort)
            default:
                self.fourthlineCoordinator?.perform(action: .abort)
            }
        default:
            self.showResult(status)
        }

        SessionStorage.clearData()
    }
}

extension RequestsViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        switch self.requestsType {
        case .initateFlow:
            return FourthlineProgressStep.selfie.rawValue
        case .fetchData:
            return FourthlineProgressStep.document.rawValue
        case .uploadData:
            return FourthlineProgressStep.upload.rawValue
        case .confirmation:
            return FourthlineProgressStep.result.rawValue
        }
    }
}
