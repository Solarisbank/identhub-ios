//
//  TermsViewEventHandlerImpl.swift
//  IdentHubSDKCore
//

import Foundation
import UIKit

let privacyLink = "https://www.solarisbank.com/en/privacy-policy/"
let termsLink = "https://www.solarisbank.com/en/customer-information/"

internal enum TermsViewOutput: Equatable {
    case termsVerified
    case abort
}

internal struct TermsViewInput {
    var identificationStep: IdentificationStep?
}

// MARK: - TermsView events logic -

typealias TermsViewCallback = (Result<TermsViewOutput, APIError>) -> Void

final class TermsViewEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<TermsViewEvent>, ViewController.ViewState == TermsViewState {
    
    weak var updateView: ViewController?
    
    private let verificationService: VerificationService
    private var state: TermsViewState
    internal var colors: Colors
    private var storage: Storage
    private var callback: TermsViewCallback
    let sessionInfoProvider: StorageSessionInfoProvider
    
    init(
        verificationService: VerificationService,
        colors: Colors,
        storage: Storage,
        session: StorageSessionInfoProvider,
        callback: @escaping TermsViewCallback
    ) {
        self.verificationService = verificationService
        self.colors = colors
        self.storage = storage
        self.callback = callback
        self.state = TermsViewState()
        self.sessionInfoProvider = session
    }
    
    func handleEvent(_ event: TermsViewEvent) {
        switch event {
        case .quit:
            self.quit()
        case .setupTermsText(let textView):
            setupTermsText(textView)
        case .continueProcess:
            self.callback(.success(.termsVerified))
        }
    }
    
    // MARK: - Internal methods -
    
    func setupTermsText(_ textView: UITextView) {
        textView.attributedText = buildTermsAttrText()
        textView.linkTextAttributes = [
            .foregroundColor: colors[.primaryAccent],
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textView.setTextViewStyle()
    }
    
    private func buildTermsAttrText() -> NSAttributedString {
        let fullText = String(format: Localizable.TermsConditions.agreementLinks, Localizable.TermsConditions.privacyText, Localizable.TermsConditions.termsText)
        let termsAttributeString = NSMutableAttributedString(string: fullText)
        
        if let privacyLinkRange = fullText.range(of: Localizable.TermsConditions.privacyText) {
            let attrRange = NSRange(privacyLinkRange, in: fullText)
            
            termsAttributeString.addAttribute(.link, value: privacyLink, range: attrRange)
        }
        
        if let termsLinkRange = fullText.range(of: Localizable.TermsConditions.termsText) {
            let attrRange = NSRange(termsLinkRange, in: fullText)
            
            termsAttributeString.addAttribute(.link, value: termsLink, range: attrRange)
        }
        
        return termsAttributeString
    }
    
    func quit() {
        callback(.success(.abort))
    }
    
}
