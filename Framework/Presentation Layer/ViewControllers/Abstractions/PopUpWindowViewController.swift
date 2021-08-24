//
//  PopUpWindowViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays pop up window.
internal class PopUpWindowViewController: UIViewController {

    private enum Constants {
        enum FontSize {
            static let big: CGFloat = 20
            static let normal: CGFloat = 14
        }

        enum Constraints {
            static let sides: CGFloat = 16
            static let sidesExtended: CGFloat = 24
        }

        static let cornerRadius: CGFloat = 8
    }

    private lazy var popUpWindowView: UIView = {
        let view = UIView()
        view.backgroundColor = .sdkColor(.black0)
        let layer = view.layer
        layer.cornerRadius = Constants.cornerRadius
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.FontSize.big)
        label.numberOfLines = 0
        label.textAlignment = .center
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.FontSize.normal)
        label.textColor = .sdkColor(.base75)
        label.numberOfLines = 0
        return label
    }()

    private lazy var buttonsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.spacing = Constants.Constraints.sides
        stackView.axis = .horizontal
        return stackView
    }()

    private lazy var primaryButton: UIButton = {
        let button = ActionRoundedButton()
        button.currentAppearance = .dimmed
        return button
    }()

    private var primaryButtonAction: (() -> Void)?

    private lazy var secondaryButton: UIButton = {
        let button = ActionRoundedButton()
        button.currentAppearance = .orange
        return button
    }()

    private var secondaryButtonAction: (() -> Void)?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        view.backgroundColor = UIColor.black.withAlphaComponent(0.5)
        view.addSubview(popUpWindowView)

        popUpWindowView.addConstraints { [
            $0.equal(.centerY),
            $0.equal(.leading, constant: Constants.Constraints.sides),
            $0.equal(.trailing, constant: -Constants.Constraints.sides)
        ]
        }

        popUpWindowView.addSubviews([
            titleLabel,
            descriptionLabel,
            buttonsStackView
        ])

        titleLabel.addConstraints { [
            $0.equal(.top, constant: Constants.Constraints.sidesExtended),
            $0.equal(.leading, constant: Constants.Constraints.sidesExtended),
            $0.equal(.trailing, constant: -Constants.Constraints.sidesExtended)
        ]
        }

        descriptionLabel.addConstraints { [
            $0.equalTo(titleLabel, .top, .bottom, constant: Constants.Constraints.sidesExtended),
            $0.equal(.leading, constant: Constants.Constraints.sides),
            $0.equal(.trailing, constant: -Constants.Constraints.sides)
        ]
        }

        buttonsStackView.addConstraints { [
            $0.equalTo(descriptionLabel, .top, .bottom, constant: Constants.Constraints.sidesExtended),
            $0.equal(.leading, constant: Constants.Constraints.sides),
            $0.equal(.trailing, constant: -Constants.Constraints.sides),
            $0.equal(.bottom, constant: -Constants.Constraints.sidesExtended)
        ]
        }

        buttonsStackView.addArrangedSubview(primaryButton)
        buttonsStackView.addArrangedSubview(secondaryButton)

        primaryButton.addTarget(self, action: #selector(primaryAction), for: .touchUpInside)
        secondaryButton.addTarget(self, action: #selector(secondaryAction), for: .touchUpInside)
    }

    @objc private func primaryAction() {
        primaryButtonAction?()
    }

    @objc private func secondaryAction() {
        secondaryButtonAction?()
    }

    /// Set title.
    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    /// Set description.
    func setDescription(_ description: String) {
        descriptionLabel.text = description
    }

    /// Set title for the button on the left.
    func setPrimaryButtonTitle(_ title: String) {
        primaryButton.setTitle(title, for: .normal)
    }

    /// Set title for the button on the right.
    func setSecondaryButtonTitle(_ title: String) {
        secondaryButton.setTitle(title, for: .normal)
    }

    /// Set action for the primary button.
    func setPrimaryButtonAction(_ action: (() -> Void)?) {
        primaryButtonAction = action
    }

    /// Set action for the secondary button.
    func setSecondaryButtonAction(_ action: (() -> Void)?) {
        secondaryButtonAction = action
    }
}
