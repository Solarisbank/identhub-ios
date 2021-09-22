//
//  SuccessView.swift
//  IdentHubSDK
//

import UIKit

/// UIView which displays a success message.
internal class SuccessView: NibView {

    // MARK: - Outlets -
    @IBOutlet var containerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var actionButton: ActionRoundedButton! {
        didSet {
            actionButton.currentAppearance = .primary
        }
    }

    // MARK: - Attributes -

    private var action: (() -> Void)?

    // MARK: - Override methods -

    override func initUI() {
        super.initUI()

        addSubview(containerView)
        containerView.frame = bounds
        configureUIColors()
    }

    // MARK: - Action methods -

    @IBAction func pressed(_ sender: UIButton) {
        action?()

        sender.isEnabled = false
    }

    // MARK: Setters

    /// Set title text.
    func setTitle(_ text: String) {
        titleLabel.text = text
    }

    /// Set description text.
    func setDescription(_ text: String) {
        descriptionLabel.text = text
    }

    /// Set title for action button.
    func setActionButtonTitle(_ title: String) {
        actionButton.setTitle(title, for: .normal)
    }

    /// Set button action.
    func setAction(_ action: @escaping () -> Void) {
        self.action = action
    }

    // MARK: - Private methods -
    private func configureUIColors() {
        containerView.backgroundColor = .sdkColor(.background)
        titleLabel.textColor = .sdkColor(.base100)
        descriptionLabel.textColor = .sdkColor(.base75)
        actionButton.currentAppearance = .primary
    }
}
