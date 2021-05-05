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
    func configure(of table: UITableView) {
        requestsSteps = builder.buildContent()
        ddm = RequestsProgressDDM()

        let cellNib = UINib(nibName: "ProgressCell", bundle: Bundle.current)

        table.register(cellNib, forCellReuseIdentifier: progressCellID)

        table.dataSource = ddm

        startProcess()
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
            print("Start confirmation flow")
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
                DispatchQueue.main.async {
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
            case .success(let response):
                print(response)
                self.deleteFile(at: fileURL)
                self.fourthlineCoordinator?.perform(action: .confirmation)
            case .failure(let error):
                onDisplayError?(error)
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

extension RequestsViewModel: StepsProgressViewDataSource {

    func currentStep() -> Int {
        switch self.requestsType {
        case .initateFlow:
            return FourthlineSteps.selfie.rawValue
        case .uploadData:
            return FourthlineSteps.location.rawValue
        case .confirmation:
            return FourthlineSteps.result.rawValue
        }
    }
}
