//
//  ShowableFactory.swift
//  Bank
//

import Foundation
import IdentHubSDKCore

internal protocol ShowableFactory {
    func makeIBANVerificationShowable(input: IBANVerificationInput, callback: @escaping IBANVerificationCallback) -> Showable?
    func makePaymentVerificationShowable(input: PaymentVerificationInput, callback: @escaping PaymentVerificationCallback) -> Showable?
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
    
    func makeIBANVerificationShowable(input: IBANVerificationInput, callback: @escaping IBANVerificationCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        
        let eventHandler = IBANVerificationEventHandlerImpl<IBANVerificationViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            input: input,
            storage: storage,
            callback: callback
        )
        
        let presenter = IBANVerificationViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updateView = presenter
        return presenter
    }
    
    func makePaymentVerificationShowable(input: PaymentVerificationInput, callback: @escaping PaymentVerificationCallback) -> Showable? {
        let alertsService = AlertsServiceImpl(presenter: presenter, colors: colors)
        
        let eventHandler = PaymentVerificationEventHandlerImpl<PaymentVerificationViewController>(
            verificationService: verificationService,
            alertsService: alertsService,
            input: input,
            storage: storage,
            callback: callback
        )
        
        let presenter = PaymentVerificationViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updateView = presenter
        return presenter
    }
    
}
