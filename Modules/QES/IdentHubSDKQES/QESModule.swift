//
//  QESModule.swift
//  IdentHubSDKQES
//
import IdentHubSDKCore

final internal class QESModule: Module, QESCoordinatorFactory {
    private let serviceLocator: ModuleServiceLocator
    private let verificationService: VerificationService
    private let storage: Storage
    private let documentExporter: DocumentExporter
    private let configuration: Configuration

    init(
        serviceLocator: ModuleServiceLocator,
        verificationService: VerificationService,
        storage: Storage,
        documentExporter: DocumentExporter,
        configuration: Configuration
    ) {
        self.serviceLocator = serviceLocator
        self.verificationService = verificationService
        self.storage = storage
        self.documentExporter = documentExporter
        self.configuration = configuration
    }

    required convenience init(serviceLocator: ModuleServiceLocator) {
        self.init(
            serviceLocator: serviceLocator,
            verificationService: VerificationServiceImpl(
                apiClient: serviceLocator.apiClient,
                fileStorage: serviceLocator.fileStorage
            ),
            storage: serviceLocator.storage,
            documentExporter: DocumentExporterService(),
            configuration: serviceLocator.configuration
        )
    }

    func makeQESCoordinator() -> AnyFlowCoordinator<QESInput, QESOutput, APIError> {
        QESCoordinatorImpl(
            presenter: serviceLocator.presenter,
            actionFactory: ActionFactoryImpl(
                verificationService: verificationService,
                colors: configuration.colors,
                presenter: serviceLocator.presenter
            ),
            verificationService: verificationService,
            storage: storage,
            documentExporter: documentExporter,
            colors: configuration.colors
        ).asAnyFlowCoordinator()
    }
}
