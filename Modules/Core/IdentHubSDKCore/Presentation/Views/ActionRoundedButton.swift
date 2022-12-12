//
//  ActionRoundedButton.swift
//  IdentHubSDKCore
//

import UIKit

/// UIButton which has three adoptable appearances.
public class ActionRoundedButton: UIButton {

    public enum Appearance {
        case primary
        case dimmed
        case inactive
        case verifying
    }

    // On iOS 12, the colors set in xib files are set after the initialization of view
    // So we're disabling the setter of `backgroundColor` and replace it with `actualBackgroundColor`
    public override var backgroundColor: UIColor? {
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

    private var colors: Colors = ColorsImpl()
    public var currentAppearance = Appearance.primary {
        didSet {
            updateAppearance()
        }
    }

    public override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    public func setAppearance(_ apperance: Appearance, colors: Colors) {
        self.currentAppearance = apperance
        self.colors = colors
        updateAppearance()
    }

    public func configure(witColors colors: Colors) {
        self.colors = colors
        updateAppearance()
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

    private func updateAppearance() {
        let colorsPair: (background: UIColor, text: UIColor)
        switch currentAppearance {
        case .primary:
            isEnabled = true
            colorsPair = (colors[.primaryAccent], .white)
        case .dimmed:
            isEnabled = true
            colorsPair = (colors[.base05], colors[.base100])
        case .inactive:
            isEnabled = false
            setTitle(self.title(for: .normal), for: .disabled)
            colorsPair = (colors[.base25], colors[.base100])
        case .verifying:
            isEnabled = false
            setTitle(Localizable.Common.verifying, for: .disabled)
            colorsPair = (colors[.base25], .white)
        }

        actualBackgroundColor = colorsPair.background
        setTitleColor(colorsPair.text, for: .normal)
    }
}

private extension ActionRoundedButton {
    enum Constants {
        enum FontSize {
            static let medium: CGFloat = 14
        }

        enum ConstraintsSize {
            static let height: CGFloat = 50
        }
    }
}
