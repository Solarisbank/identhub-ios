//
//  SuccessView.swift
//  IdentHubSDK
//

import UIKit

/// UIView which displays a success message.
internal class SuccessView: UIView {

    private enum Constants {
        enum Constraints {
            static let extended: CGFloat = 40
            static let normal: CGFloat = 24
            static let side: CGFloat = 16
        }

        enum FontSize {
            static let big: CGFloat = 20
            static let medium: CGFloat = 14
        }
    }

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(Constants.FontSize.big)
        label.textColor = .sdkColor(.base100)
        label.numberOfLines = 0
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.textColor = .sdkColor(.base75)
        label.numberOfLines = 0
        return label
    }()

    private lazy var actionButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.currentAppearance = .orange
        return button
    }()

    private var action: (() -> Void)?

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        backgroundColor = .white

        addSubviews([
            titleLabel,
            descriptionLabel,
            actionButton
        ])

        titleLabel.addConstraints { [
            $0.equal(.top, constant: Constants.Constraints.extended),
            $0.equal(.leading, constant: Constants.Constraints.side),
            $0.equal(.trailing, constant: -Constants.Constraints.side)
        ]
        }

        descriptionLabel.addConstraints { [
            $0.equalTo(titleLabel, .top, .bottom, constant: Constants.Constraints.normal),
            $0.equal(.leading, constant: Constants.Constraints.side),
            $0.equal(.trailing, constant: -Constants.Constraints.side)
        ]
        }

        actionButton.addConstraints { [
            $0.equalTo(descriptionLabel, .top, .bottom, constant: Constants.Constraints.extended),
            $0.equal(.leading, constant: Constants.Constraints.side),
            $0.equal(.trailing, constant: -Constants.Constraints.side),
            $0.equal(.bottom, constant: -Constants.Constraints.extended)
        ]
        }

        actionButton.addTarget(self, action: #selector(pressed), for: .touchUpInside)
    }

    @objc private func pressed(_ sender: UIButton) {
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
}
