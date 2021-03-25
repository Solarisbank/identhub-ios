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
    private let flowCoordinator: FourthlineIdentCoordinator
    weak var delegate: TermsViewModelDelegate?

    // MARK: - Init -
    init(flowCoordinator: FourthlineIdentCoordinator) {
        self.flowCoordinator = flowCoordinator
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
    }

    /// Start Fourthline identification process
    func continueProcess() {
        flowCoordinator.perform(action: .onboarding)
    }

    /// Quit the flow
    func quit() {
        flowCoordinator.perform(action: .quit)
    }

    // MARK: - Internal methods -
    private func buildTermsAttrText() -> NSAttributedString {
        let fullText = Localizable.TermsConditions.agreementLinks
        let termsAttributeString = NSMutableAttributedString(string: Localizable.TermsConditions.agreementLinks)

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
