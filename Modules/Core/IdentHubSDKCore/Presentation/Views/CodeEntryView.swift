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

    private var colors: Colors

    init(colors: Colors) {
        self.colors = colors
        super.init(frame: .zero)
        configureUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    private func configureUI() {
        layer.cornerRadius = Constants.cornerRadius
        layer.borderWidth = Constants.borderWidth
        textAlignment = .center
        keyboardType = .numberPad

        addConstraints { [
            $0.equalConstant(.height, Constants.height),
            $0.equalConstant(.width, Constants.width)
        ]
        }

        updateUI()
    }

    private func updateUI() {
        backgroundColor = colors[.background]
        textColor = colors[.base75]
        layer.borderColor = colors[.disableBtnBG].cgColor
    }

    override func deleteBackward() {
        super.deleteBackward()
        customDelegate?.textFieldDidDelete()
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUI()
    }
}

/// Code entry view delegate
public protocol CodeEntryViewDelegate: AnyObject {

    func didUpdateCode(_ digits: Int)
}

/// UIView representing the 6-digit code entry field.
public class CodeEntryView: UIView {

    /// Possible code entry view states.
    public enum State {
        case normal
        case error
        case disabled
    }

    /// The current state of the code entry view.
    public var state: State = .normal {
        didSet {
            updateUI()
        }
    }

    public private(set) var code: String? {
        didSet {
            self.delegate?.didUpdateCode(code?.count ?? 0)
        }
    }
    
    public weak var delegate: CodeEntryViewDelegate?

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
        view.backgroundColor = colors[.background]
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
        label.textColor = colors[.error]
        label.text = Localizable.Common.wrongTan
        return label
    }()
    
    private var colors: Colors = ColorsImpl()

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
            let textField = SingleDigitTextField(colors: colors)
            textField.delegate = self
            textField.returnKeyType = .done
            textField.customDelegate = self
            textField.backgroundColor = colors[.background]
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
            textFieldProperties = (colors[.background], colors[.labelText].cgColor, true, colors[.paragraph])
        case .error:
            textFieldProperties = (colors[.documentInfoBackground], colors[.error].cgColor, false, colors[.labelText])
        case .disabled:
            textFieldProperties = (colors[.documentInfoBackground], colors[.disableBtnBG].cgColor, false, colors[.disableBtnBG])
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
    public func clearCodeEntries() {
        for view in self.entryFieldsStackView.arrangedSubviews {
            if let textField = view as? UITextField {
                textField.text = ""
            }
        }
    }
    
    public override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUI()
    }
}

// MARK: - UITextFieldDelegate methods

extension CodeEntryView: UITextFieldDelegate {

    public func textField(_ textField: UITextField, shouldChangeCharactersIn range: NSRange, replacementString string: String) -> Bool {
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

    public func textFieldShouldReturn(_ textField: UITextField) -> Bool {
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
