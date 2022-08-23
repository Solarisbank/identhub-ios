//
//  ActionFactory.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore

internal protocol ShowableFactory {
    func makeConfirmApplicationShowable(input: ConfirmApplicationInput, callback: @escaping ConfirmApplicationCallback) -> Showable?

    func makeSignDocumentsShowable(input: SignDocumentsInput, callback: @escaping SignDocumentsCallback) -> Showable?
}

internal struct ShowableFactoryImpl: ShowableFactory {
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

    func makeConfirmApplicationShowable(input: ConfirmApplicationInput, callback: @escaping ConfirmApplicationCallback) -> Showable? {
        let eventHandler = ConfirmApplicationEventHandlerImpl<ConfirmApplicationViewController>(verificationService: verificationService, documentExporter: documentExporter, input: input, callback: callback)
        let presenter = ConfirmApplicationViewController(colors: colors, eventHandler: eventHandler)
        
        eventHandler.updatableView = presenter
        
        return presenter
    }

    func makeSignDocumentsShowable(input: SignDocumentsInput, callback: @escaping SignDocumentsCallback) -> Showable? {
        let statusCheckService = StatusCheckServiceImpl(verificationService: verificationService, timerFactory: TimerFactoryImpl())
        
        let eventsHandler = SignDocumentsEventHandlerImpl<SignDocumentsViewController>(
            verificationService: verificationService,
            statusCheckService: statusCheckService,
            input: input,
            callback: callback
        )
        
        let presenter = SignDocumentsViewController(colors: colors, eventHandler: eventsHandler)
        
        eventsHandler.updatableView = presenter
        
        return presenter
    }
}
