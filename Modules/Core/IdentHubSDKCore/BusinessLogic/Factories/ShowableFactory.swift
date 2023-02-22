//
//  ShowableFactory.swift
//  IdentHubSDKCore
//

import Foundation

internal protocol ShowableFactory {
    func makeRequestsShowable(input: RequestsInput, session: StorageSessionInfoProvider, callback: @escaping RequestsCallback) -> Showable?
    func makePhoneVerificationShowable(session: StorageSessionInfoProvider, callback: @escaping PhoneVerificationCallback) -> Showable?
    func makeTermsShowable(session: StorageSessionInfoProvider, callback: @escaping TermsViewCallback) -> Showable?
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
            colors: colors,
            storage: storage,
            session: session,
            callback: callback
        )
        
        let presenter = RequestsViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updatableView = presenter
        return presenter
    }
    
    func makePhoneVerificationShowable(session: StorageSessionInfoProvider, callback: @escaping PhoneVerificationCallback) -> Showable? {
        let eventHandler = PhoneVerificationEventHandlerImpl<PhoneVerificationViewController>(
            verificationService: verificationService,
            storage: storage,
            session: session,
            callback: callback
        )
        
        let presenter = PhoneVerificationViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updateView = presenter
        return presenter
    }
    
    func makeTermsShowable(session: StorageSessionInfoProvider, callback: @escaping TermsViewCallback) -> Showable? {
        let eventHandler = TermsViewEventHandlerImpl<TermsViewController>(
            verificationService: verificationService,
            colors: colors,
            storage: storage,
            session: session,
            callback: callback
        )
        
        let presenter = TermsViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updateView = presenter
        return presenter
    }
}
