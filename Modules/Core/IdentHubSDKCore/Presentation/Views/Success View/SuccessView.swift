//
//  SuccessView.swift
//  IdentHubSDKCore
//

import UIKit

/// UIView which displays a Phone verification success message.
public class SuccessView: NibView {

    // MARK: - Outlets -

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet var actionButton: ActionRoundedButton! {
        didSet {
            actionButton.currentAppearance = .primary
        }
    }
  
    // MARK: - Attributes -

    private var action: (() -> Void)?

    // MARK: - Override methods -

    public override func initUI() {
        super.initUI()

        addSubview(containerView)
        containerView.frame = bounds
        configureUI()
    }

    // MARK: - Action methods -

    @IBAction func pressed(_ sender: UIButton) {
        action?()

        sender.isEnabled = false
    }

    // MARK: Setters

    /// Set title text.
    public func setTitle(_ text: String) {
        titleLabel.text = text
    }

    /// Set description text.
    public func setDescription(_ text: String) {
        descriptionLabel.attributedText = String(format: text, Localizable.Common.IBAN, Localizable.PhoneVerification.Success.loginCredentials)
            .withBoldTexts([Localizable.Common.IBAN, Localizable.PhoneVerification.Success.loginCredentials], withColorForBoldText: colors[.header])
    }

    /// Set title for action button.
    public func setActionButtonTitle(_ title: String) {
        actionButton.setTitle(title, for: .normal)
    }

    /// Set button action.
    public func setAction(_ action: @escaping () -> Void) {
        self.action = action
    }

    public override func configureUI() {
        containerView.backgroundColor = colors[.background]
        titleLabel.setLabelStyle(.title)
        descriptionLabel.setLabelStyle(.subtitle)
        actionButton.setAppearance(.primary, colors: colors)
    }
}
