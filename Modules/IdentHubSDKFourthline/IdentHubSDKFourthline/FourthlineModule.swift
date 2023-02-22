//
//  FourthlineModule.swift
//  Fourthline
//

import IdentHubSDKCore

final internal class FourthlineModule: Module, FourthlineCoordinatorFactory {
   
    private let serviceLocator: ModuleServiceLocator
    private let verificationService: VerificationService
    private let storage: Storage
    private let configuration: Configuration

    init(
        serviceLocator: ModuleServiceLocator,
        verificationService: VerificationService,
        storage: Storage,
        configuration: Configuration
    ) {
        self.serviceLocator = serviceLocator
        self.verificationService = verificationService
        self.storage = storage
        self.configuration = configuration
    }

    required convenience init(serviceLocator: ModuleServiceLocator) {
        self.init(
            serviceLocator: serviceLocator,
            verificationService: VerificationServiceImpl(
                apiClient: serviceLocator.apiClient,
                storage: serviceLocator.storage
            ),
            storage: serviceLocator.storage,
            configuration: serviceLocator.configuration
        )
    }
        
    func makeFourthlineCoordinator() -> AnyFlowCoordinator<FourthlineInput, FourthlineOutput, APIError> {
        FourthlineCoordinatorImpl(presenter: serviceLocator.presenter,
            showableFactory: ShowableFactoryImpl(
                verificationService: verificationService,
                colors: configuration.colors,
                storage: storage,
                presenter: serviceLocator.presenter
            ),
            verificationService: verificationService,
            alertsService: AlertsServiceImpl(
                presenter: serviceLocator.presenter,
                colors: configuration.colors
            ),
            storage: storage,
            colors: configuration.colors
        ).asAnyFlowCoordinator()
    }

}
