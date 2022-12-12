//
//  ShowableFactory.swift
//  IdentHubSDKCore
//

import Foundation

internal protocol ShowableFactory {
    func makePhoneVerificationShowable(input: PhoneVerificationInput, callback: @escaping PhoneVerificationCallback) -> Showable?
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
    
    func makePhoneVerificationShowable(input: PhoneVerificationInput, callback: @escaping PhoneVerificationCallback) -> Showable? {
        let eventHandler = PhoneVerificationEventHandlerImpl<PhoneVerificationViewController>(
            verificationService: verificationService,
            input: input,
            storage: storage,
            callback: callback
        )
        
        let presenter = PhoneVerificationViewController(colors: colors, eventHandler: eventHandler.asAnyEventHandler())
        eventHandler.updateView = presenter
        return presenter
    }
}
