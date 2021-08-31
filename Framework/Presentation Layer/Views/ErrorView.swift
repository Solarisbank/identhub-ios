//
//  ErrorView.swift
//  IdentHubSDK
//

import UIKit

/// UIView which displays an error and its description and button to handle the current state.
final internal class ErrorView: UIView {

    private enum Constants {
        enum FontSize {
            static let big: CGFloat = 20
            static let small: CGFloat = 12
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let normal: CGFloat = 16
            static let small: CGFloat = 12
            static let tiny: CGFloat = 8
        }

        enum Size {
            static let height: CGFloat = 13
            static let width: CGFloat = 13
            static let cornerRadius: CGFloat = 4
        }
    }

    private var primaryAction: (() -> Void)?
    private var quitAction: (() -> Void)?

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(Constants.FontSize.big)
        label.textColor = .sdkColor(.base100)
        label.numberOfLines = 0
        return label
    }()

    private lazy var detailsContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .sdkColor(.errorTint)
        view.layer.cornerRadius = Constants.Size.cornerRadius
        return view
    }()

    private lazy var warningImageView: UIImageView = {
        let imageView = UIImageView()
        let warningImage = UIImage.sdkImage(.warning, type: ErrorView.self)?.withRenderingMode(.alwaysTemplate)
        imageView.tintColor = .sdkColor(.error)
        imageView.image = warningImage
        return imageView
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.small)
        label.textColor = .sdkColor(.base100)
        return label
    }()

    private lazy var primaryButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.currentAppearance = .orange
        return button
    }()

    private lazy var quitButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.currentAppearance = .dimmed
        button.setTitle(Localizable.Common.quit, for: .normal)
        return button
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        backgroundColor = .sdkColor(.background)

        addSubviews([
            titleLabel,
            detailsContainerView,
            primaryButton,
            quitButton
        ])

        titleLabel.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        detailsContainerView.addConstraints { [
            $0.equalTo(titleLabel, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        primaryButton.addConstraints { [
            $0.equalTo(detailsContainerView, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        quitButton.addConstraints { [
            $0.equalTo(primaryButton, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended)
        ]
        }

        primaryButton.addTarget(self, action: #selector(primaryButtonAction), for: .touchUpInside)
        quitButton.addTarget(self, action: #selector(quitButtonAction), for: .touchUpInside)

        setUpDetailsContainerView()
    }

    @objc private func primaryButtonAction() {
        primaryAction?()
    }

    @objc private func quitButtonAction() {
        quitAction?()
    }

    private func setUpDetailsContainerView() {
        detailsContainerView.addSubviews([
            warningImageView,
            descriptionLabel
        ])

        warningImageView.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.small),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.small),
            $0.equalConstant(.height, Constants.Size.height),
            $0.equalConstant(.width, Constants.Size.width)
        ]
        }

        descriptionLabel.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.small),
            $0.equalTo(warningImageView, .leading, .trailing, constant: Constants.ConstraintsOffset.tiny),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.small),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.small)
        ]
        }
    }

    /// Set error title label.
    func setTitle(_ title: String) {
        titleLabel.text = title
    }

    /// Set error description label.
    func setDescription(_ description: String) {
        descriptionLabel.text = description
    }

    /// Set title for primary button, the one on the top.
    func setPrimaryButtonTitle(_ title: String) {
        primaryButton.setTitle(title, for: .normal)
    }

    /// Set action for primary button.
    func setPrimaryButtonAction(_ action: (() -> Void)?) {
        primaryAction = action
    }

    /// Set action for quit button.
    func setQuitButtonAction(_ action: (() -> Void)?) {
        quitAction = action
    }
}
