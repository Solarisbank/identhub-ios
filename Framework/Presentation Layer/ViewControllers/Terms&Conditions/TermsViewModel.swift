//
//  TermsViewModel.swift
//  IdentHubSDK
//

import Foundation
import UIKit

let privacyLink = "https://www.solarisbank.com/en/privacy-policy/"
let termsLink = "https://www.solarisbank.com/en/customer-information/"

protocol TermsViewModelDelegate: AnyObject {
    func presentLinkViewer(_ url: URL)
}

/// ViewModel of the Terms and Condition screen
final internal class TermsViewModel: NSObject {

    // MARK: - Properties -
    weak var delegate: TermsViewModelDelegate?

    private weak var coordinator: IdentificationCoordinator?
    var onActionPerformed: (() -> Void)?
    
    // MARK: - Init -
    init(coordinator: IdentificationCoordinator) {
        self.coordinator = coordinator
    }

    // MARK: - Public methods -

    /// Build attributed string with links
    /// Added links handler
    func setupTermsText(_ textView: UITextView) {
        textView.delegate = self
        textView.attributedText = buildTermsAttrText()
        textView.linkTextAttributes = [
            .foregroundColor: UIColor.sdkColor(.primaryAccent),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        textView.textColor = UIColor.sdkColor(.base50)
    }

    /// Start Fourthline identification process
    func continueProcess() {
        onActionPerformed?()
    }

    /// Quit the flow
    func quit() {
        coordinator?.perform(action: .quit)
    }

    // MARK: - Internal methods -
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
}

extension TermsViewModel: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        delegate?.presentLinkViewer(URL)

        return false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
