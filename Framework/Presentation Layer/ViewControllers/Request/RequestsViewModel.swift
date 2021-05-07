//
//  UploadViewModel.swift
//  IdentHubSDK
//

import UIKit
import FourthlineKYC

let progressCellID = "UploadProgressCellID"

enum RequestsType {
    case initateFlow
    case uploadData
    case confirmation
}

enum InitStep: Int {
    case defineMethod = 0, registerMethod, fetchPersonData
}

enum UploadSteps: Int {
    case zipFile = 0, uploadZip
}

enum VerificationSteps: Int {
    case verification = 0
}

final class RequestsViewModel: NSObject {

    // MARK: - Public attributes -
    var onTableUpdate: (() -> Void)?
    var onDisplayError: ((Error?) -> Void)?

    // MARK: - Private attributes -
    private var ddm: RequestsProgressDDM?
    private let verificationService: VerificationService
    private let sessionStorage: StorageSessionInfoProvider
    private let requestsType: RequestsType
    private let builder: RequestsProgressCellObjectBuilder
    private var requestsSteps: [ProgressCellObject] = []
    private var initStep: InitStep = .defineMethod
    private var fourthlineCoordinator: FourthlineIdentCoordinator?
    private var identCoordinator: IdentificationCoordinator?

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

        if let coordinator = identCoordinator {
            self.identCoordinator = coordinator
        } else if let coordinator = fourthlineCoordinator {
            self.fourthlineCoordinator = coordinator
        }
    }

    // MARK: - Public methods -

    /// Configuration table view method
    /// - Parameter table: table view for configuration
    func configure(of table: UITableView) {
        requestsSteps = builder.buildContent()
        ddm = RequestsProgressDDM()

        let cellNib = UINib(nibName: "ProgressCell", bundle: Bundle.current)

        table.register(cellNib, forCellReuseIdentifier: progressCellID)

        table.dataSource = ddm

        startProcess()
    }

    /// Method defines and returns request screen title text
    /// - Returns: title text
    func obtainScreenTitle() -> String {
        switch self.requestsType {
        case .initateFlow:
            return Localizable.Initial.title
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
        case .uploadData:
            return Localizable.Upload.description
        case .confirmation:
            return Localizable.Verification.description
        }
    }
}

// MARK: - Internal methods -

private extension RequestsViewModel {

    private func startProcess() {

        switch requestsType {
        case .initateFlow:
            startInitialProcess()
        case .uploadData:
            startUploadProcess()
        case .confirmation:
            startVerificationProcess()
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
                if response.fourthlineIdentification {
                    self.initiatedFourthlineIdentification()
                } else if response.bankIdentificaiton {
                    self.initiateBankIDIdentification()
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }

    private func initiateBankIDIdentification() {
        sessionStorage.identificationType = .bank
        DispatchQueue.main.async { [weak self] in
            self?.identCoordinator?.perform(action: .termsAndConditions)
        }
    }

    private func initiatedFourthlineIdentification() {
        sessionStorage.identificationType = .fourthline
        registerFourthlineMethod()
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

    private func fetchPersonalData() {
        startStep(number: InitStep.fetchPersonData.rawValue)
        initStep = .fetchPersonData

        verificationService.fetchPersonData { [weak self] result in
            guard let `self` = self else { return }

            switch result {
            case .success(let response):
                self.completeStep(number: InitStep.fetchPersonData.rawValue)
                KYCContainer.shared.update(person: response)

                DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                    self.identCoordinator?.perform(action: .termsAndConditions)
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }
        }
    }
}

// MARK: - Upload methods -

private extension RequestsViewModel {

    private func startUploadProcess() {
        zipUserData()
    }

    private func zipUserData() {
        startStep(number: UploadSteps.zipFile.rawValue)

        KYCZipService.createKYCZip { [unowned self] zipURL, err in
            guard let url = zipURL else {

                if let err = err {
                    self.onDisplayError?(err)
                }
                return
            }

            self.completeStep(number: UploadSteps.zipFile.rawValue)
            self.uploadZip(url)
        }
    }

    private func uploadZip(_ fileURL: URL) {
        startStep(number: UploadSteps.uploadZip.rawValue)

        verificationService.uploadKYCZip(fileURL: fileURL) { [unowned self] result in

            switch result {
            case .success(_):
                self.deleteFile(at: fileURL)
                DispatchQueue.main.asyncAfter(deadline: .now() + 1) {
                    self.fourthlineCoordinator?.perform(action: .confirmation)
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }

            self.completeStep(number: UploadSteps.uploadZip.rawValue)
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

            switch result {
            case .success(let response):
                if response.identificationStatus == .pending {
                    self.retryVerification()
                } else {
                    self.showResult(response)
                }
            case .failure(let error):
                self.onDisplayError?(error)
            }

            self.completeStep(number: VerificationSteps.verification.rawValue)
        }
    }

    private func retryVerification() {
        DispatchQueue.main.asyncAfter(deadline: .now() + 5) { [weak self] in
            guard let `self` = self else { return }

            self.startVerificationProcess()
        }
    }

    private func showResult(_ result: FourthlineIdentificationStatus) {
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            guard let `self` = self else { return }

            self.fourthlineCoordinator?.perform(action: .result(result: result))
        }
    }
}

extension RequestsViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        switch self.requestsType {
        case .initateFlow:
            return FourthlineSteps.selfie.rawValue
        case .uploadData:
            return FourthlineSteps.upload.rawValue
        case .confirmation:
            return FourthlineSteps.result.rawValue
        }
    }
}
