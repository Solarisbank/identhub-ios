//
//  ShowableFactory.swift
//  Fourthline
//

import Foundation
import IdentHubSDKCore

internal protocol ShowableFactory {
    func makeWelcomeShowable(input: WelcomeInput, callback: @escaping WelcomeCallback) -> Showable?
    func makeDocumentPickerShowable(input: DocumentPickerInput, callback: @escaping DocumentPickerCallback) -> Showable?
    func makeDocumentScannerShowable(input: DocumentScannerInput, callback: @escaping DocumentScannerCallback) -> Showable?
    func makeDocumentInfoShowable(callback: @escaping DocumentInfoCallback) -> Showable?
    func makeSelfieShowable(callback: @escaping SelfieCallback) -> Showable?
    func makeRequestsShowable(input: RequestsInput, session: StorageSessionInfoProvider, callback: @escaping RequestsCallback) -> Showable?
    func makeResultShowable(input: ResultInput, callback: @escaping ResultCallback) -> Showable?
}

internal struct ShowableFactoryImpl: ShowableFactory {
    
    private let verificationService: VerificationService
    private let colors: Colors
    private let presenter: Presenter
    
    private var storage: Storage
    
    init(
        verificationService: VerificationService,
        colors: Colors,
        storage: Storage,
        presenter: Presenter
    ) {
        self.verificationService = verificationService
        self.colors = colors
        self.storage = storage
        self.presenter = presenter
    }
    
    func makeRequestsShowable(input: RequestsInput, session: StorageSessionInfoProvider, callback: @escaping RequestsCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        let eventHandler = RequestsEventHandlerImpl<RequestsViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            input: input,
            storage: storage,
            colors: colors,
            session: session,
            callback: callback
        )
        
        let presenter = RequestsViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updatableView = presenter
        return presenter
    }
    
    func makeWelcomeShowable(input: WelcomeInput, callback: @escaping WelcomeCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        let eventHandler = WelcomeEventHandlerImpl<WelcomeViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            input: input,
            callback: callback
        )
        
        let presenter = WelcomeViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updatableView = presenter
        return presenter
    }
    
    func makeDocumentPickerShowable(input: DocumentPickerInput, callback: @escaping DocumentPickerCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        let eventHandler = DocumentPickerEventHandlerImpl<DocumentPickerViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            input: input,
            colors: colors,
            storage: storage,
            callback: callback
        )
        
        let presenter = DocumentPickerViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updatableView = presenter
        return presenter
    }
    
    func makeDocumentScannerShowable(input: DocumentScannerInput, callback: @escaping DocumentScannerCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        let eventHandler = DocumentScannerEventHandlerImpl<DocumentScannerViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            input: input,
            colors: colors,
            callback: callback
        )
        
        let presenter = DocumentScannerViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        presenter.modalPresentationStyle = .fullScreen
        eventHandler.updatableView = presenter
        return presenter
    }
    
    func makeDocumentInfoShowable(callback: @escaping DocumentInfoCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        let eventHandler = DocumentInfoEventHandlerImpl<DocumentInfoViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            colors: colors,
            callback: callback
        )
        
        let presenter = DocumentInfoViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updatableView = presenter
        return presenter
    }
    
    func makeSelfieShowable(callback: @escaping SelfieCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        let eventHandler = SelfieEventHandlerImpl<SelfieViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            colors: colors,
            callback: callback
        )
        
        let presenter = SelfieViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updatableView = presenter
        return presenter
    }
    
    func makeResultShowable(input: ResultInput, callback: @escaping ResultCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        let eventHandler = ResultEventHandlerImpl<ResultViewController>(
            alertsService: alertsService,
            input: input,
            colors: colors,
            callback: callback
        )
        
        let presenter = ResultViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updatableView = presenter
        return presenter
    }
    
}
