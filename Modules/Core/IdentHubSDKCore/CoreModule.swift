//
//  CoreModule.swift
//  IdentHubSDKCore
//

import Foundation

final internal class CoreModule: Module, CoreCoordinatorFactory {

    private let serviceLocator: ModuleServiceLocator
    private let verificationService: VerificationService
    private let storage: Storage
    private var configuration: Configuration

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
                apiClient: serviceLocator.apiClient
            ),
            storage: serviceLocator.storage,
            configuration: serviceLocator.configuration
        )
    }
    
    func makeCoreCoordinator() -> AnyFlowCoordinator<CoreInput, CoreOutput, APIError> {
        CoreCoordinatorImpl(presenter: serviceLocator.presenter,
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

    func updateColors(colors: Colors) {
        self.configuration = Configuration(colors: colors)
    }
}
