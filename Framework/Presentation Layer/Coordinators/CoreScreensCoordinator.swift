//
//  InitialScreensCoordinator.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

class CoreScreensCoordinator: BaseCoordinator {

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    private var currentIdentStep: CoreScreensStep = .phoneVerification
    private var completionHandler: CompletionHandler?
    private var coordinatorPerformer: FlowCoordinatorPerformer
    internal var coreScreensDoneHandler: (() -> Void)?

    // MARK: - Init methods -
    init(appDependencies: AppDependencies, presenter: Router) {

        self.appDependencies = appDependencies
        self.coordinatorPerformer = FlowCoordinatorPerformer()

        super.init(
            presenter: presenter,
            appDependencies: appDependencies
        )

        restoreStep()
    }

    // MARK: - Public methods -

    /// Performs a specified action.
    func perform(action: CoreScreensStep) {
        coreLog.info("Performing action: \(action)")
        
        switch action {
        case .phoneVerification:
            presentPhoneVerification()
        case .quit:
            quit { [weak self] in
                self?.completionHandler?(.failure(.unauthorizedAction))
                self?.close()
            }
        case .close:
            close()
        }
    }

    // MARK: - Coordinator methods -
    override func start(_ completion: @escaping CompletionHandler) {
        coreLog.info("Starting core screens coordinator")
        completionHandler = completion
        performActionBasedOnSession()
    }
}

// MARK: - Save / load ident data -

extension CoreScreensCoordinator {

    private func restoreStep() {
        guard let restoreData = SessionStorage.obtainValue(for: StoredKeys.coreScreensStep.rawValue) as? Data else {
            return
        }

        do {
            let step = try JSONDecoder().decode(CoreScreensStep.self, from: restoreData)
            currentIdentStep = step
        } catch {
            coreLog.warn("Stored coreScreensStep data decoding failed: \(error.localizedDescription).\nProcess would be started from beginning")
        }
    }

    private func updateCoreStep(step: CoreStep) {
        do {
            let stepData = try JSONEncoder().encode(step)
            SessionStorage.updateValue(stepData, for: StoredKeys.coreScreensStep.rawValue)
        } catch {
            coreLog.warn("Coding coreScreensStep data failed: \(error.localizedDescription)")
        }
    }
}

// MARK: - Perform Actions -

extension CoreScreensCoordinator {
    private func performActionBasedOnSession() {
        let session = appDependencies.sessionInfoProvider
        if !session.phoneVerified {
            presentPhoneVerification()
        }
    }
    
    private func performActionWithCurrentIdentStep() {
        perform(action: currentIdentStep)
    }
}

// MARK: - Navigation methods -

private extension CoreScreensCoordinator {
    
    // MARK: - PHONE

    private func presentPhoneVerification() {
        presentCore(step: .phoneVerification)
        updateCoreStep(step: .phoneVerification)
    }
    
    private func presentCore(step: CoreStep) {
        guard let core = appDependencies.moduleResolver.core?.makeCoreCoordinator() else {
            completionHandler?(.failure(.modulesNotFound([ModuleName.core.rawValue])))
            close()
            return
        }
        let coreInput = CoreInput(
            step: step,
            identificationUID: appDependencies.sessionInfoProvider.identificationUID ?? "",
            identificationStep: appDependencies.sessionInfoProvider.identificationStep
        )
        
        coordinatorPerformer.startCoordinator(core, input: coreInput, callback: { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }
            switch result {
            case let .success(output):
                switch output {
                case .phoneVerificationConfirm:
                    self.coreScreensDoneHandler?()
                case .abort:
                    self.completeIdentification(
                        result: .failure(.authorizationFailed),
                        shouldClearData: true
                    )
                }
            case let .failure(error):
                self.completeIdentification(result: .failure(error), shouldClearData: true)
            }
            return true
        })?.push(on: presenter)
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
