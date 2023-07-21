//
//  FourthlineCoordinatorImpl.swift
//  Fourthline
//

import UIKit
import IdentHubSDKCore
import FourthlineCore
import AVFoundation
import FourthlineKYC
import FourthlineSDK

final internal class FourthlineCoordinatorImpl: FourthlineCoordinator {
    
    private let presenter: Presenter
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private let showableFactory: ShowableFactory
    private let colors: Colors
    private var storage: Storage
    
    private var input: FourthlineInput!
    private var callback: ((Result<FourthlineOutput, APIError>) -> Void)!
    
    var sessionInfoProvider: StorageSessionInfoProvider!
    
    init(
        presenter: Presenter,
        showableFactory: ShowableFactory,
        verificationService: VerificationService,
        alertsService: AlertsService,
        storage: Storage,
        colors: Colors
    ) {
        self.presenter = presenter
        self.showableFactory = showableFactory
        self.verificationService = verificationService
        self.storage = storage
        self.colors = colors
        self.alertsService = alertsService
    }
    
    deinit {
        fourthlineLog.info("KYCContainer remove shared container")
        KYCContainer.removeSharedContainer()
    }
    
    func start(input: FourthlineInput, callback: @escaping (Result<FourthlineOutput, APIError>) -> Void) -> Showable? {
        self.input = input
        self.callback = callback
       
        resetToken()
        self.sessionInfoProvider = StorageSessionInfoProvider(sessionToken: input.sessionToken ?? "")
        updateKYCContainer()
        
        return self.performSteps(step: input.step)
    }
    
    private func resetToken() {
        if let token = storage[.token] {
            if input.sessionToken != token {
                storage.clear()
            }
        } else {
            storage.clear()
        }
        storage[.token] = input.sessionToken
    }
    
    private func updateKYCContainer() {
        KYCContainer.shared.restoreData(sessionInfoProvider)
        KYCContainer.shared.update(provider: input.provider ?? "")
    
        storage[.identificationStep] = input.identificationStep ?? .unspecified
    }
    
    private func performSteps(step: FourthlineStep) -> Showable? {
        switch step {
        case .welcome: return welcome()
        case .fetchData: return fetchData()
        case .documentPicker: return documentPicker()
        case .documentScanner(type: .undefined): return documentScanner(.undefined, false)
        case .documentInfo: return documentInfoConfirmation()
        case .instruction: return instructionScreen()
        case .selfie: return selfieScreen()
        case .upload: return upload()
        case .confirmation: return presentDataVerification()
        case .quit:
            self.callback(.failure(.unauthorizedAction)); return nil
        case let .complete(result):
            self.callback(.success(.complete(result: result))); return nil
        case .nextStep(let step):
            let identUID = self.sessionInfoProvider.identificationUID ?? ""
            self.callback(.success(.nextStep(step: step, identUID)))
            return nil
        case .abort:
            self.callback(.failure(.unauthorizedAction)); return nil
        case .close(let error):
            self.callback(.failure(error)); return nil
        default: return nil
        }
    }
    
    private func requestsView(input: RequestsInput) -> Showable? {
        return showableFactory.makeRequestsShowable(input: input, session: sessionInfoProvider) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch result {
            case .finishInitialFetch:
                DispatchQueue.main.async {
                    if self.input.identificationStep == .fourthline || self.input.identificationStep == .fourthlineSigning {
                        self.welcome()?.push(on: self.presenter)
                    } else {
                        self.documentPickerDisplay()
                    }
                }
            case .fourthline(let step):
                switch step {
                case let .result(result):
                    DispatchQueue.main.async {
                        self.presentResult(result)?.push(on: self.presenter)
                    }
                case .welcome:
                    DispatchQueue.main.async {
                        self.welcome()?.push(on: self.presenter)
                    }
                case .selfie:
                    self.selfieScreenDisplay()
                case .documentPicker:
                    self.documentPickerDisplay()
                default:
                    _ = self.performSteps(step: step)
                }
            case .failure(let error):
                self.callback(.failure(error))
            case .quit:
                self.quit()
            }
        }
    }
    
    private func fetchData() -> Showable? {
        let input = RequestsInput(requestsType: .initateFlow, initStep: .registerMethod)
        
        return requestsView(input: input)
    }
    
    private func welcome() -> Showable? {
        let input = WelcomeInput(identificationStep: self.sessionInfoProvider.identificationStep, isDisplayNamirialTerms: (self.sessionInfoProvider.identificationStep == .fourthlineSigning),
            isOrca: self.sessionInfoProvider.orcaEnabled)

        return showableFactory.makeWelcomeShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch result {
            case .nextStep(let step):
                switch step {
                case .documentPicker:
                    if self.sessionInfoProvider.orcaEnabled {
                        DispatchQueue.main.async {
                            self.presentOrca()
                        }
                    } else {
                        self.documentPickerDisplay()
                    }
                case .fetchData:
                    DispatchQueue.main.async {
                        self.fetchData()?.push(on: self.presenter)
                    }
                case .close(let error):
                    self.callback(.failure(error))
                default:
                    return
                }
            }
        }
    }
    
    private func documentPicker() -> Showable? {
        let input = DocumentPickerInput(identificationStep: self.input.identificationStep, documentsList: self.storage[.documentsList])
        
        return showableFactory.makeDocumentPickerShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch result {
            case .documentScanner(type: let type):
                
                KYCContainer.shared.isSecondDocRequire = (type != .idCard)
                self.documentScannerPresent(type: type, isSecondDocument: false)
            case .quit:
                self.quit()
            }
        }
    }
    
    private func documentPickerDisplay() {
        DispatchQueue.main.async {
            self.documentPicker()?.push(on: self.presenter)
        }
    }
    
    private func documentScanner(_ documentType: DocumentType, _ isSecondDocument: Bool) -> Showable? {
        let input = DocumentScannerInput(documentScannerType: documentType, isSecondDocument: isSecondDocument)
        
        return showableFactory.makeDocumentScannerShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch result {
            case .documentInfo:
                fourthlineLog.warn("open documentInfo")
                self.documentInfoConfirmation()?.push(on: self.presenter)
            case .selfieScreen:
                self.selfieScreenDisplay()
            case .quit:
                self.quit()
            }
        }
    }
    
    private func documentScannerPresent(type: DocumentType, isSecondDocument: Bool) {
        self.requestPermissions { [weak self] isPassed in
            guard isPassed, let self = self else { return }
            self.documentScanner(type, isSecondDocument)?.present(on: self.presenter)
        }
    }
    
    private func documentInfoConfirmation() -> Showable? {
        let isSecondaryDocumentRequired = (self.sessionInfoProvider.secondaryDocument && KYCContainer.shared.isSecondDocRequire)

        let input = DocumentInfoInput(isSecondDocument: isSecondaryDocumentRequired)
        return showableFactory.makeDocumentInfoShowable(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }

            switch result {
            case .selfieScreen:
                self.selfieScreenDisplay()
            case .instructionScreen:
                self.instructionScreen()?.push(on: self.presenter)
            case .fallBackStep:
                fourthlineLog.warn("DocumentInfo to DocumentPicker fallback")
                self.documentPickerDisplay()
            case .quit:
                self.quit()
            }
        }
    }
    
    private func instructionScreen() -> Showable? {
        return showableFactory.makeInstructionShowable() { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }

            switch result {
            case .nextStep:
                self.documentScannerPresent(type: .tinReferenceDocument, isSecondDocument: true)
            case .quit:
                self.quit()
            }
        }
    }
    
    private func selfieScreen() -> Showable? {
        
        return showableFactory.makeSelfieShowable() { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch result {
            case .dataUpload:
                self.dataUpload()
            case .quit:
                self.quit()
            }
        }
    }
    
    private func selfieScreenDisplay() {
        DispatchQueue.main.async {
            self.requestPermissions { [weak self] isPassed in
                guard isPassed, let self = self else { return }
                self.selfieScreen()?.push(on: self.presenter)
            }
        }
    }
    
    private func upload() -> Showable? {
        let input = RequestsInput(requestsType: .uploadData, initStep: .defineMethod)
        return requestsView(input: input)
    }
    
    private func presentDataVerification() -> Showable? {
        let input = RequestsInput(requestsType: .confirmation, initStep: .defineMethod)
        return requestsView(input: input)
    }
    
    private func presentResult(_ result: FourthlineIdentificationStatus) -> Showable? {
        let input = ResultInput(result: result)

        return showableFactory.makeResultShowable(input: input) { [weak self] output in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            switch output {
            case .complete(let data):
                self.callback(.success(.complete(result: data)))
            }
        }
    }
    
    private func dataUpload() {
        DispatchQueue.main.async {
            self.upload()?.push(on: self.presenter)
        }
    }
    
    private func quit() {
        alertsService.presentQuitAlert { [weak self] shouldClose in
            guard let self = self else {
                Assert.notNil(self)
                return
            }
            
            if shouldClose {
                self.callback(.success(.abort))
            }
        }
    }
    
    /// Method defined if in navigation stack is exist controller. Used for cases, when user dismissed SDK controller and wants return to the previous step
    /// - Returns: bool value of emptinest of navigation controllers stack
    private func isLastController() -> Bool {
        return presenter.isNavigationControllersEmpty()
    }
    
    private func isFourthlineFlow() -> Bool {
        return (self.sessionInfoProvider.identificationStep == .fourthline ||
                self.sessionInfoProvider.identificationStep == .fourthlineSigning)
    }
    
}

// MARK: - ORCA methods -

private extension FourthlineCoordinatorImpl {
    
    private func presentOrca() {
        var supportedCountries: [CountryNetworkModel] = []
        if let rawCountry = self.storage[.orcaCountryList] {
            let data = rawCountry.data(using: .utf8)!
            do {
                let countryData = try JSONDecoder().decode([CountryNetworkModel].self,
                                                           from: data)
                supportedCountries = countryData.isEmpty ? [] : countryData
            } catch _ as NSError {
                supportedCountries = []
            }
        }
        
        var flavor = OrcaFlavor()
        var colorPalette = OrcaPalette()
        colorPalette.primary = self.colors[.primaryAccent]
        flavor.colors = OrcaColors(colorPalette: colorPalette)
        
        /// Passing language for ORCA SDK
        let languageCode: FourthlineSDK.OrcaLocalization.LanguageType = OrcaLocalization.LanguageType(rawValue: CommandLine.locale?.languageCode ?? Locale.preferredLanguageCode) ?? .en
        flavor.localization.fixedLanguage = languageCode
        
        let documentConfig = KycDocumentFlowConfig(
            includeNfcFlow: false,
            supportedCountries: supportedCountries
        )
        let tinConfig = KycTinFlowConfig(taxationCountry: .it)
        let kycConfig = KycConfig(
            flows: [
                .location,
                .document(documentConfig),
                .tin(tinConfig),
                .selfie
            ])
        
        let kycCustomization = KycCustomizationConfig(flavor: flavor, kycInfo: KYCContainer.shared.kycInfo)
        
        Orca.kyc
            .configure(with: kycConfig)
            .customize(with: kycCustomization)
            .present { [weak self] result in
                switch result {
                case let .success(kycInfo):
                    KYCContainer.shared.kycInfo = kycInfo
                    self?.dataUpload()
                case let .failure(kycError):
                    self?.handleKycError(kycError)
                }
            }
    }
    
    private func handleKycError(_ error: KycError) {
                
        switch error {
        case .nationalityNotSupported:
            print("Handle nationality not supported.")
        case .documentExpired:
            print("Handle document expired. Example: Redirect to document type screen.")
        case .documentTypeInvalid:
            print("Invalid document type. Can occur if user scanned a document type that is disabled.")
        case .documentTypeNotSupported:
            print("Handle document type not supported. Example: Redirect to Document type screen.")
        case .issuingCountryNotSupported:
            print("Handle issuing country not supported. Example: Redirect to Issuing country screen.")
        case .personNotAdult:
            print("Handle person not adult. Example: Stop flow.")
        case .canceled:
            print("User canceled Orca")
        case let .unexpected(erroMessage):
            print("Unexpected error: \(erroMessage)")
        @unknown default:
            fatalError("KycError: Unhandled case")
        }
        
        fourthlineLog.log("ORCA failure: (\(error))", level: .error)
        self.callback(.failure(.authorizationFailed))
    }
}

// MARK: - Permission methods -

private extension FourthlineCoordinatorImpl {
    
    private func requestPermissions(completionHandler: @escaping ((_ isPassed: Bool) -> Void)) {
        fourthlineLog.info("Requesting permissions for camera...")
        
        #if AUTOMATION
            completionHandler(true)
        #else
        AVCaptureDevice.requestAccess(for: .video) { granted in
            guard granted else {
                fourthlineLog.warn("Permissions for camera not granted")
                
                DispatchQueue.main.async { [weak self] in
                    guard let self = self else { return }
                    
                    self.showPermissionAlert(with: Localizable.Camera.permissionErrorAlertTitle, message: Localizable.Camera.permissionErrorAlertMessage)
                    completionHandler(false)
                }
                return
            }
            
            fourthlineLog.info("Permissions for camera granted")
            DispatchQueue.main.async {
                fourthlineLog.info("Requesting location permissions...")
                
                LocationManager.shared.requestLocationAuthorization { [weak self] status, error in
                    if status {
                        fourthlineLog.info("Location permissions are granted")
                    } else {
                        fourthlineLog.warn("Location permissions are not granted with error: \(String(describing: error?.localizedDescription))")
                    }
                    
                    if let locationError = error as? APIError {
                        self?.showPermissionAlert(with: Localizable.Location.Error.title, message: locationError.text())
                    }
                    completionHandler(status)
                }
            }
        }
        #endif
    }
    
    private func showPermissionAlert(with title: String, message: String) {
        fourthlineLog.info("Showing permissions alert \(title)")
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        let tryAgainAction = UIAlertAction(title: Localizable.Common.settings, style: .default, handler: { _ in
            fourthlineLog.warn("User choose showing iOS settings")
            
            if let url = URL(string: UIApplication.openSettingsURLString),
               UIApplication.shared.canOpenURL(url) {
                UIApplication.shared.open(url)
                self.close()
            }
        })

        let cancelAction = UIAlertAction(title: Localizable.Common.cancel, style: .cancel) { _ in
            fourthlineLog.warn("Canceled granting permissions by user")
            
            switch self.input.step {
            case .documentScanner(_),
                 .selfie:
                self.close()
            default:
                break
            }
            
        }
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)

        presenter.present(alert, animated: true)
    }
    
    func close() {
        self.callback(.success(.close))
    }
    
}
