//
//  ActionRoundedButton.swift
//  IdentHubSDK
//

import UIKit

/// UIButton which has three adoptable appearances.
@available(*, deprecated, message: "Moved to the Core module")
class ActionRoundedButton: UIButton {

    enum Constants {
        enum FontSize {
            static let medium: CGFloat = 14
        }

        enum ConstraintsSize {
            static let height: CGFloat = 50
        }
    }

    enum Appearance {
        case primary
        case dimmed
        case inactive
        case verifying
    }

    /// Current button appearance.
    var currentAppearance = Appearance.primary {
        didSet {
            updateAppearance()
        }
    }

    // On iOS 12, the colors set in xib files are set after the initialization of view
    // So we're disabling the setter of `backgroundColor` and replace it with `actualBackgroundColor`
    override var backgroundColor: UIColor? {
        get {
            return actualBackgroundColor
        }
        set {
            updateAppearance()
        }
    }

    var actualBackgroundColor: UIColor? {
        get {
            return super.backgroundColor
        }
        set {
            super.backgroundColor = newValue
        }
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        titleLabel?.font = .systemFont(ofSize: Constants.FontSize.medium, weight: .bold)
        layer.cornerRadius = 4

        addConstraints { [
            $0.equalConstant(.height, Constants.ConstraintsSize.height)
        ]
        }
        updateAppearance()
    }

    func updateAppearance() {
        let colors: (background: UIColor, text: UIColor)
        switch currentAppearance {
        case .primary:
            isEnabled = true
            colors = (UIColor.sdkColor(.primaryAccent), .white)
        case .dimmed:
            isEnabled = true
            colors = (UIColor.sdkColor(.base05), .sdkColor(.base100))
        case .inactive:
            isEnabled = false
            setTitle(self.title(for: .normal), for: .disabled)
            colors = (UIColor.sdkColor(.base25), .sdkColor(.base100))
        case .verifying:
            isEnabled = false
            setTitle(Localizable.Common.verifying, for: .disabled)
            colors = (UIColor.sdkColor(.base25), .white)
        }

        actualBackgroundColor = colors.background
        setTitleColor(colors.text, for: .normal)
    }
}
