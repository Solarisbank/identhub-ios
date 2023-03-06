//
//  FourthlineCoordinator.swift
//  IdentHubSDK
//

import UIKit
import AVFoundation
import IdentHubSDKCore

/// Fourthline identification process flow coordinator class
/// Used for navigating between screens and update process status
class FourthlineCoordinator: BaseCoordinator {
    
    // MARK: - Properties -
    private let appDependencies: AppDependencies
    var identificationStep: FourthlineStep = .welcome
    private var currentIdentStep: FourthlineStep = .welcome
    private var completionHandler: CompletionHandler?
    private var coordinatorPerformer: FlowCoordinatorPerformer
    internal var nextStepHandler: ((IdentificationStep) -> Void)?
    
    // MARK: - Init methods -
    
    init(appDependencies: AppDependencies, presenter: Router) {
        self.appDependencies = appDependencies
        self.coordinatorPerformer = FlowCoordinatorPerformer()
        
        super.init(
            presenter: presenter,
            appDependencies: appDependencies
        )
        
    }
    
    // MARK: - Coordinator methods -

    /// Method starts Fourthline identificaiton process
    /// - Parameter completion: completion handler with success or failure parameter, used for updating users UI
    override func start(_ completion: @escaping CompletionHandler) {
        fourthlineLog.info("Starting Fourthline identification coordinator")
        
        completionHandler = completion
        executeStep(step: identificationStep)
    }
    
    private func performActionWithCurrentIdentStep() {
        executeStep(step: currentIdentStep)
    }
    
    private func executeStep(step: FourthlineStep) {
        fourthlineLog.debug("executeStep \(step)")
        
        switch step {
        case .welcome:
            presentWelcomeScreen()
        case .selfie:
            presentSelfieScreen()
        case .fetchData:
            presentDataLoader()
        case .documentPicker:
            presentDocumentPicker()
        case let .documentScanner(type):
            presentDocumentScanner(type)
        case .documentInfo:
            presentDocumentInfoConfirmation()
        case .instruction:
            presentInstruction()
        case .upload:
            presentDataUploader()
        case .confirmation:
            presentDataVerification()
        case let .result(result):
            presentResult(result)
        case .quit:
            quit {[weak self] in
                self?.interruptIdentProcess(with: .unauthorizedAction)
            }
        case let .complete(result):
            completeIdent(with: result)
        case .nextStep(let step):
            nextStepHandler?(step)
        case .abort:
            interruptIdentProcess(with: .unauthorizedAction)
        case .close(let error):
            interruptIdentProcess(with: error)
        }
    }
    
    private func presentDataLoader() {
        presentFourthline(step: .fetchData)
    }
    
    private func presentWelcomeScreen() {
        presentFourthline(step: .welcome)
    }

    private func presentSelfieScreen() {
        self.presentFourthline(step: .selfie)
    }
    
    private func presentDocumentPicker() {
        presentFourthline(step: .documentPicker)
    }
    
    private func presentDocumentScanner(_ documentType: FourthlineDocumentType) {
        self.presentFourthline(step: .documentScanner(type: .undefined))
    }

    private func presentDocumentInfoConfirmation() {
        presentFourthline(step: .documentInfo)
    }
    
    private func presentInstruction() {
        presentFourthline(step: .instruction)
    }
    
    private func presentDataUploader() {
        presentFourthline(step: .upload)
    }

    private func presentDataVerification() {
        presentFourthline(step: .confirmation)
    }

    private func presentResult(_ result: FourthlineIdentificationStatus) {
        presentFourthline(step: .result(result: result))
    }

    private func presentFourthline(step: FourthlineStep) {
        guard let fourthline = appDependencies.moduleResolver.fourthline?.makeFourthlineCoordinator() else {
            completionHandler?(.failure(.modulesNotFound([ModuleName.fourthline.rawValue])))
            close()
            return
        }
        let fourthlineInput = FourthlineInput(
            step: step,
            sessionToken: appDependencies.sessionInfoProvider.sessionToken,
            identificationUID: appDependencies.sessionInfoProvider.identificationUID ?? "",
            identificationStep: appDependencies.sessionInfoProvider.identificationStep,
            provider: appDependencies.sessionInfoProvider.fourthlineProvider
        )
        coordinatorPerformer.startCoordinator(fourthline, input: fourthlineInput, callback: { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }
            
            switch result {
            case .success(let output):
                switch output {
                case .complete(let resultStaus):
                    self.completeIdent(with: resultStaus)
                case .nextStep(let nextStep, let identUID):
                    self.appDependencies.sessionInfoProvider.identificationUID = identUID
                    fourthlineLog.log("presentFourthline nextStep (\(nextStep))", level: .info)
                    self.nextStepHandler?(nextStep)
                case .abort:
                    self.completeIdentification(
                        result: .failure(.authorizationFailed),
                        shouldClearData: true
                    )
                case .close:
                    SessionStorage.clearData()
                    self.appDependencies.serviceLocator.modulesStorageManager.clearAllData()
                    self.close()
                }
            case .failure(let error):
                self.completeIdentification(result: .failure(error), shouldClearData: true)
            }
            return true
        })?.push(on: presenter)
    }
    
    private func completeIdent(with result: FourthlineIdentificationStatus) {
        let resultIsInfo = result.identificationStatus == .success || result.identificationStatus == .confirmed
        fourthlineLog.log(
            "Completed identification with \(result.identificationStatus)",
            level: resultIsInfo ? .info : .warn
        )
        
        switch result.identificationStatus {
        case .success:
            completeIdentification(result: .success(identification: result.identification), shouldClearData: true)
            close()
        case .identificationRequired:
            completeIdentification(result: .success(identification: result.identification), shouldClearData: true)
        case .failed:
            completeIdentification(result: .failure(.authorizationFailed), shouldClearData: true)
            close()
        case .confirmed:
            completeIdentification(result: .onConfirm(identification: result.identification), shouldClearData: true)
            SessionStorage.clearData()
            appDependencies.serviceLocator.modulesStorageManager.clearAllData()
            close()
        case .authorizationRequired:
            nextStepHandler?(.bankIDQES)
        default:
            fourthlineLog.warn("\(result.identificationStatus) not processed.")
        }
    }
    
    private func interruptIdentProcess(with error: APIError) {
        fourthlineLog.warn("Interupt ident process with error: \(error)")
        
        DispatchQueue.main.async { [weak self] in
            self?.completionHandler?(.failure(error))
            self?.close()
        }
    }
    
    private func completeIdentification(result: IdentificationSessionResult, shouldClearData: Bool) {
        if shouldClearData {
            SessionStorage.clearData()
            appDependencies.serviceLocator.modulesStorageManager.clearAllData()
        }
        close()
        completionHandler?(result)
    }
}
