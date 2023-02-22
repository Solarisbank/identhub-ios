//
//  InitialScreensCoordinator.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

class CoreScreensCoordinator: BaseCoordinator {

    // MARK: - Properties -
    private let appDependencies: AppDependencies
    public var currentIdentStep: CoreStep = .initateFlow
    private var completionHandler: CompletionHandler?
    private var coordinatorPerformer: FlowCoordinatorPerformer
    internal var nextStepHandler: ((CoreOutput) -> Void)?

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
    func perform(action: CoreStep,  _ completion: @escaping CompletionHandler) {
        coreLog.info("Performing action: \(action)")
        
        completionHandler = completion
        
        switch action {
        case .initateFlow:
            presentInitialflow()
        case .termsConditions:
            presentTerms()
        case .phoneVerification:
            presentPhoneVerification()
        }
    }

    // MARK: - Coordinator methods -
    
    override func start(_ completion: @escaping CompletionHandler) {
        coreLog.info("Starting core screens coordinator")
        completionHandler = completion
        performActionWithCurrentIdentStep()
    }
}

// MARK: - Save / load ident data -

extension CoreScreensCoordinator {

    private func restoreStep() {
        guard let restoreData = SessionStorage.obtainValue(for: StoredKeys.coreScreensStep.rawValue) as? Data else {
            return
        }

        do {
            let step = try JSONDecoder().decode(CoreStep.self, from: restoreData)
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

private extension CoreScreensCoordinator {
    
    private func performActionWithCurrentIdentStep() {
        guard let completionHandler = completionHandler else {
            coreLog.error("Cannot handle performActionWithCurrentIdentStep. CoreScreensCoordinator completionHandler is nil.")
            
            return
        }
        perform(action: currentIdentStep, completionHandler)
    }
    
    private func presentPhoneVerification() {
        presentCore(step: .phoneVerification)
        updateCoreStep(step: .phoneVerification)
    }
    
    private func presentTerms(){
        presentCore(step: .termsConditions)
        updateCoreStep(step: .termsConditions)
    }
    
    private func presentInitialflow() {
        presentCore(step: .initateFlow)
        updateCoreStep(step: .initateFlow)
    }
    
    private func presentCore(step: CoreStep) {
        guard let core = appDependencies.moduleResolver.core?.makeCoreCoordinator() else {
            completionHandler?(.failure(.modulesNotFound([ModuleName.core.rawValue])))
            close()
            return
        }
                
        let coreInput = CoreInput(
            step: step,
            sessionToken: appDependencies.sessionInfoProvider.sessionToken
        )
        coordinatorPerformer.startCoordinator(core, input: coreInput, callback: { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return true
            }
            
            switch result {
            case .success(let output):

                switch output {
                case .startIdentification(let session, let response):
                    if let res = response {
                        session.acceptedTC = res.acceptedTC
                        session.phoneVerified = res.phoneVerificationStatus ?? false
                        session.setStyleColors(res.style?.colors)
                        session.remoteLogging = res.remoteLogging ?? false
                    }
                    self.appDependencies.sessionInfoProvider = session
                default:
                    break
                }
                
                self.nextStepHandler?(output)
            case .failure(let error):
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
