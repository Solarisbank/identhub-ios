//
//  VerificationTextField.swift
//  IdentHubSDKBank
//

import UIKit
import IdentHubSDKCore

/// UITextField which displays states of verification.
internal class VerificationTextField: UITextField {

    enum Constants {
        static let height: CGFloat = 48
        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 1
        static let paddingSides: CGFloat = 14
    }

    /// List of all the states of the text field.
    enum State {
        case normal
        case verified
        case error
    }

    /// Current state of the text field.
    var currentState: State = .normal {
        didSet {
            updateUI()
        }
    }
    
    // MARK: Padding for text

    private let padding = UIEdgeInsets(top: .zero, left: Constants.paddingSides, bottom: .zero, right: Constants.paddingSides)

    override func textRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func placeholderRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }

    override func editingRect(forBounds bounds: CGRect) -> CGRect {
        return bounds.inset(by: padding)
    }
    
    private var colors: Colors = ColorsImpl()

    // MARK: UI

    override init(frame: CGRect) {
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
        delegate = self
        backgroundColor = colors[.background]
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        returnKeyType = .done

        addConstraints { [
            $0.equalConstant(.height, Constants.height)
        ]
        }
    }

    private func updateUI() {
        let borderColor: CGColor
        switch currentState {
        case .normal:
            borderColor = colors[.labelText].cgColor
        case .verified:
            borderColor = colors[.success].cgColor
        case .error:
            borderColor = colors[.error].cgColor
        }
        layer.borderColor = borderColor
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUI()
    }
}

// MARK: - Delegate methods -

extension VerificationTextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}
