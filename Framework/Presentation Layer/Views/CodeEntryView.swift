//
//  CodeEntryView.swift
//  IdentHubSDK
//

import UIKit

protocol SingleDigitTextFieldDelegate: AnyObject {
    func textFieldDidDelete()
}

/// UITextFieldView which allows for a single digit input.
private class SingleDigitTextField: UITextField {

    enum Constants {
        static let height: CGFloat = 48
        static let width: CGFloat = 32
        static let cornerRadius: CGFloat = 4
        static let borderWidth: CGFloat = 1
    }

    weak var customDelegate: SingleDigitTextFieldDelegate?

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
        textColor = .sdkColor(.base75)
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

    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.textFieldDidDelete()
    }
}

/// Code entry view delegate
protocol CodeEntryViewDelegate: AnyObject {

    func didUpdateCode(_ digits: Int)
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

    private(set) var code: String? {
        didSet {
            self.delegate?.didUpdateCode(code?.count ?? 0)
        }
    }
    
    weak var delegate: CodeEntryViewDelegate?

    private var currentIndex = 0

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
        view.backgroundColor = .sdkColor(.background)
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

    init(delegate: CodeEntryViewDelegate) {
        super.init(frame: .zero)
        self.delegate = delegate
        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    private func configureUI() {
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
            $0.equalTo(entryFieldsStackView, .top, .bottom, constant: 0),
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
            textField.returnKeyType = .done
            textField.customDelegate = self
            textField.backgroundColor = .sdkColor(.background)
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
            textFieldProperties = (.sdkColor(.background), UIColor.sdkColor(.base25).cgColor, true, .sdkColor(.base100))
        case .error:
            textFieldProperties = (.sdkColor(.base05), UIColor.sdkColor(.error).cgColor, true, .sdkColor(.base25))
        case .disabled:
            textFieldProperties = (.sdkColor(.base05), UIColor.sdkColor(.base25).cgColor, false, .sdkColor(.base25))
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
        if state == .error {
            state = .normal
        }
        
        textField.text = string
        if let currentTextFieldIndex = entryFieldsStackView.arrangedSubviews.firstIndex(of: textField), string.isEmpty == false {
            currentIndex = currentTextFieldIndex
            if currentIndex == entryFieldsStackView.arrangedSubviews.count - 1 {
                entryFieldsStackView.arrangedSubviews[currentIndex].resignFirstResponder()
            } else {
                entryFieldsStackView.arrangedSubviews[currentIndex + 1].becomeFirstResponder()
            }
            code = getCode()
        }
        return true
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

extension CodeEntryView: SingleDigitTextFieldDelegate {

    func textFieldDidDelete() {

        if let textField = entryFieldsStackView.arrangedSubviews[currentIndex] as? SingleDigitTextField {
            textField.text = ""
            textField.becomeFirstResponder()

            if currentIndex > 0 {
                currentIndex -= 1
            }
        }
    }
}
