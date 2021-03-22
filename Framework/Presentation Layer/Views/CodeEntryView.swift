//
//  CodeEntryView.swift
//  IdentHubSDK
//

import UIKit

/// UITextFieldView which allows for a single digit input.
private class SingleDigitTextField: UITextField {

    enum Constants {
        static let height: CGFloat = 48
        static let width: CGFloat = 32
        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 1
    }

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        backgroundColor = .white
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        layer.borderColor = UIColor.sdkColor(.base10).cgColor
        textAlignment = .center
        keyboardType = .numberPad

        addConstraints { [
            $0.equalConstant(.height, Constants.height),
            $0.equalConstant(.width, Constants.width)
        ]
        }
    }
}

/// UIView representing the 6-digit code entry field.
internal class CodeEntryView: UIView {

    /// Possible code entry view states.
    enum State {
        case normal
        case error
        case disabled
    }

    /// The current state of the code entry view.
    var state: State = .normal {
        didSet {
            updateUI()
        }
    }

    private(set) var code: String?

    private enum Constants {
        enum Size {
            static let viewsSpacing: CGFloat = 8
        }

        enum FontSize {
            static let small: CGFloat = 11
        }
    }

    private lazy var containerView: UIView = {
        let view = UIView()
        return view
    }()

    private lazy var entryFieldsStackView: UIStackView = {
        let stackView = UIStackView()
        stackView.distribution = .fillEqually
        stackView.axis = .horizontal
        stackView.spacing = Constants.Size.viewsSpacing
        return stackView
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.small)
        label.textColor = .sdkColor(.error)
        label.text = Localizable.PhoneVerification.wrongTan
        return label
    }()

    override init(frame: CGRect) {
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        addSubviews([
            containerView
        ])

        containerView.addConstraints {
            $0.equalEdges()
        }

        containerView.addSubviews([
            entryFieldsStackView,
            errorLabel
        ])

        entryFieldsStackView.addConstraints { [
            $0.equal(.top),
            $0.equal(.leading),
            $0.equal(.trailing)
        ]
        }

        errorLabel.addConstraints { [
            $0.equalTo(entryFieldsStackView, .top, .bottom, constant: 8),
            $0.equalTo(entryFieldsStackView, .leading, .leading),
            $0.equalTo(entryFieldsStackView, .trailing, .trailing),
            $0.equal(.bottom)
        ]
        }

        errorLabel.isHidden = true

        addTextFields()
    }

    private func addTextFields() {
        for _ in 0..<6 {
            let textField = SingleDigitTextField()
            textField.delegate = self
            entryFieldsStackView.addArrangedSubview(textField)
        }
    }

    private func getCode() -> String {
        var code = ""
        for view in entryFieldsStackView.arrangedSubviews {
            if let textField = view as? UITextField,
               let text = textField.text {
                code.append(text)
            }
        }
        return code
    }

    private func updateUI() {
        DispatchQueue.main.async {
            self.updateTextFields(for: self.state)
            switch self.state {
            case .normal:
                self.errorLabel.isHidden = true
            case .error:
                self.errorLabel.isHidden = false
            case .disabled:
                self.errorLabel.isHidden = true
            }
        }
    }

    private func updateTextFields(for state: State) {
        typealias Properties = (backgroundColor: UIColor, borderColor: CGColor, isUserInteractionEnabled: Bool, textColor: UIColor)
        let textFieldProperties: Properties
        switch state {
        case .normal:
            textFieldProperties = (.white, UIColor.sdkColor(.base25).cgColor, true, .black)
        case .error:
            textFieldProperties = (.sdkColor(.black05), UIColor.sdkColor(.error).cgColor, false, .sdkColor(.black25))
        case .disabled:
            textFieldProperties = (.sdkColor(.black05), UIColor.sdkColor(.base25).cgColor, false, .sdkColor(.black25))
        }
        for view in self.entryFieldsStackView.arrangedSubviews {
            view.backgroundColor = textFieldProperties.backgroundColor
            view.layer.borderColor = textFieldProperties.borderColor
            if let textField = view as? UITextField {
                textField.isUserInteractionEnabled = textFieldProperties.isUserInteractionEnabled
                textField.textColor = textFieldProperties.textColor
            }
        }
    }

    /// Clear all code text fields.
    func clearCodeEntries() {
        for view in self.entryFieldsStackView.arrangedSubviews {
            if let textField = view as? UITextField {
                textField.text = ""
            }
        }
    }
}

// MARK: - UITextFieldDelegate methods

extension CodeEntryView: UITextFieldDelegate {

    func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
        textField.text = string
        if let currentTextFieldIndex = entryFieldsStackView.arrangedSubviews.firstIndex(of: textField) {
            if currentTextFieldIndex == entryFieldsStackView.arrangedSubviews.count - 1 {
                entryFieldsStackView.arrangedSubviews[currentTextFieldIndex].resignFirstResponder()
            } else {
                entryFieldsStackView.arrangedSubviews[currentTextFieldIndex + 1].becomeFirstResponder()
            }
            code = getCode()
        }
        return true
    }
}
