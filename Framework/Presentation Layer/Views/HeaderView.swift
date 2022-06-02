//
//  HeaderView.swift
//  IdentHubSDK
//

import UIKit

/// Depending on style presents empty view, view with quit button or progress view.
///
/// Using in Interface Builder please ensure that you allow this view to determine the view's height (use intrinsic size placeholder instead of constraining height).
final class HeaderView: UIView {
    enum Style {
        case progress(currentStep: CurrentStep)
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

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI(with: Style.none)
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI(with: Style.none)
    }

    override var intrinsicContentSize: CGSize {
        subviews.first?.intrinsicContentSize ?? .zero
    }

    /// Display style
    /// * progress - shows progress steps
    /// * quit - shows only quit button
    /// * none - empty header
    func setStyle(_ style: Style) {
        configureUI(with: style)
    }

    private func configureUI(with style: Style) {
        var view: UIView?

        subviews.forEach { $0.removeFromSuperview() }

        switch style {
        case .progress(let currentStep):
            progressView.setCurrentStep(currentStep)
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
