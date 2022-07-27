//
//  HeaderView.swift
//  IdentHubSDKCore
//

import UIKit

/// Depending on style presents empty view, view with quit button or progress view.
///
/// Using in Interface Builder please ensure that you allow this view to determine the view's height (use intrinsic size placeholder instead of constraining height).
public final class HeaderView: UIView {
    public enum Style {
        case progress(currentStep: CurrentStep, activeColor: UIColor)
        case quit(target: Quitable)
        case none
    }

    private lazy var progressView: IdentificationProgressView = {
        let progressView = IdentificationProgressView(frame: .zero)
        return progressView
    }()

    private lazy var quitView: QuitView = {
        let quitView = QuitView()
        return quitView
    }()

    public required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI(with: Style.none)
    }

    public override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI(with: Style.none)
    }

    public override var intrinsicContentSize: CGSize {
        subviews.first?.intrinsicContentSize ?? .zero
    }

    /// Display style
    /// * progress - shows progress steps
    /// * quit - shows only quit button
    /// * none - empty header
    public func setStyle(_ style: Style) {
        configureUI(with: style)
    }

    private func configureUI(with style: Style) {
        var view: UIView?

        subviews.forEach { $0.removeFromSuperview() }

        switch style {
        case .progress(let currentStep, let activeColor):
            progressView.setCurrentStep(currentStep, activeColor: activeColor)
            view = progressView
        case .quit(let quitable):
            quitView.setTarget(quitable)
            view = quitView
        case .none:
            break
        }

        if let view = view {
            addSubview(view)
            view.addFillParentConstraints()
        }
    }
}

// MARK: - Utilities -

private extension UIView {
    func addFillParentConstraints() {
        self.addConstraints { [
            $0.equal(.top, constant: .zero),
            $0.equal(.bottom, constant: .zero),
            $0.equal(.leading, constant: .zero),
            $0.equal(.trailing, constant: .zero)
        ]
        }
    }
}
