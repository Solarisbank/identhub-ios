//
//  VerificationTextField.swift
//  IdentHubSDK
//

import UIKit

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
        backgroundColor = .sdkColor(.background)
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
            borderColor = UIColor.sdkColor(.base50).cgColor
        case .verified:
            borderColor = UIColor.sdkColor(.success).cgColor
        case .error:
            borderColor = UIColor.sdkColor(.error).cgColor
        }
        layer.borderColor = borderColor
    }
}

// MARK: - Delegate methods -

extension VerificationTextField: UITextFieldDelegate {

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {

        textField.resignFirstResponder()
        return true
    }
}
