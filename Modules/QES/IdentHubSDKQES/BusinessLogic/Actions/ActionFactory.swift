//
//  ActionFactory.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

internal protocol ActionFactory {
    func makeConfirmApplicationAction() -> AnyAction<ConfirmApplicationActionInput, ConfirmApplicationActionOutput>

    func makeSignDocumentsAction() -> AnyAction<SignDocumentsActionInput, Result<SignDocumentsActionOutput, APIError>>
    
    func makePreviewDocumentAction() -> AnyAction<URL, Bool>

    func makeDownloadDocumentAction() -> AnyAction<URL, Bool>
    
    func makeQuitAction() -> AnyAction<Void, Bool>
}

internal struct ActionFactoryImpl: ActionFactory {
    private let verificationService: VerificationService
    private let colors: Colors
    private let documentExporter: DocumentExporter
    private let presenter: Presenter
    
    init(
        verificationService: VerificationService,
        colors: Colors,
        documentExporter: DocumentExporter = DocumentExporterService(),
        presenter: Presenter
    ) {
        self.verificationService = verificationService
        self.colors = colors
        self.documentExporter = documentExporter
        self.presenter = presenter
    }

    func makeConfirmApplicationAction() -> AnyAction<ConfirmApplicationActionInput, ConfirmApplicationActionOutput> {
        let presenter = ConfirmApplicationViewController(colors: colors)
        let action = ConfirmApplicationAction(presenter: presenter, verificationService: verificationService)
        return action.asAnyAction()
    }

    func makeSignDocumentsAction() -> AnyAction<SignDocumentsActionInput, Result<SignDocumentsActionOutput, APIError>> {
        let presenter = SignDocumentsViewController(colors: colors)
        let statusCheckService = StatusCheckServiceImpl(
            verificationService: verificationService,
            timerFactory: TimerFactoryImpl()
        )
        let action = SignDocumentsAction(
            viewController: presenter,
            verificationService: verificationService,
            statusCheckService: statusCheckService
        )
        return action.asAnyAction()
    }
    
    func makePreviewDocumentAction() -> AnyAction<URL, Bool> {
        PreviewDocumentAction(
            documentExporter: documentExporter,
            viewController: presenter.topShowable.toShowable()
        ).asAnyAction()
    }
    
    func makeDownloadDocumentAction() -> AnyAction<URL, Bool> {
        DownloadDocumentAction(
            documentExporter: documentExporter,
            viewController: presenter.topShowable.toShowable()
        ).asAnyAction()
    }

    func makeQuitAction() -> AnyAction<Void, Bool> {
        QuitAction(colors: colors)
            .asAnyAction()
    }
}
