//
//  IBANVerificationViewController.swift
//  Bank
//

import UIKit
import InputMask
import IdentHubSDKCore

internal struct IBANVerificationState: Equatable {
    enum State: Equatable {
        case none
        case isIBANFormatValid
        case textFieldState
        case error
    }
    
    var state: State = .none
    var isIBANFormatValid: Bool = false
    var error: String = ""
}

internal enum IBANVerificationEvent {
    case verifyIBAN(iban: String?)
    case validateEnteredIBAN(iban: String?)
    case quit
}

/// UIViewController which displays screen for IBAN verification.
final internal class IBANVerificationViewController: UIViewController, Updateable, Quitable {

    typealias ViewState = IBANVerificationState
    
    // MARK: - Properties -

    var eventHandler: AnyEventHandler<IBANVerificationEvent>?
    private var colors: Colors
    
    // MARK: - IBOutlets -

    @IBOutlet var headerView: HeaderView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var accountHintLabel: UILabel!
    @IBOutlet var ibanLabel: UILabel!
    @IBOutlet var ibanVerificationTextField: VerificationTextField!
    @IBOutlet var maskTextFieldDelegate: MaskedTextFieldDelegate!
    @IBOutlet var initiatePaymentVerificationButton: ActionRoundedButton!
    @IBOutlet var errorLabel: UILabel!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<IBANVerificationEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Internal methods -
    
    func updateView(_ state: IBANVerificationState) {
        
        switch state.state {
        case .isIBANFormatValid:
            errorLabel.isHidden = state.isIBANFormatValid
            ibanVerificationTextField.currentState = state.isIBANFormatValid ? .verified : .error
            initiatePaymentVerificationButton.currentAppearance = state.isIBANFormatValid ? .verifying : .primary
        case .textFieldState:
            ibanVerificationTextField.currentState = state.isIBANFormatValid ? .verified : .normal
            initiatePaymentVerificationButton.currentAppearance = state.isIBANFormatValid ? .primary : .inactive
        case .error:
            errorLabel.text = state.error
        default:
            break
        }
    }
    
    // MARK: - Actions methods -
    
    @IBAction func initiatePaymentVerification(_: ActionRoundedButton) {
        ibanVerificationTextField.resignFirstResponder()
        let iban = ibanVerificationTextField.text?.replacingOccurrences(of: " ", with: "")
        eventHandler?.handleEvent(.verifyIBAN(iban: iban))
    }
    
    @IBAction func didEndEdigitn(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }
    
    func didClickQuit(_ sender: Any) {
        eventHandler?.handleEvent(.quit)
    }

}

// MARK: - Internal methods -

extension IBANVerificationViewController {
    
    private func configureUI() {
        
        headerView.setStyle(.quit(target: self))

        titleLabel.setLabelStyle(.title)
        titleLabel.text = Localizable.BankVerification.IBANVerification.title
        accountHintLabel.text = Localizable.BankVerification.IBANVerification.accountDisclaimer
        accountHintLabel.setLabelStyle(.subtitle)
        ibanLabel.text = Localizable.BankVerification.IBANVerification.IBANEncryptionInfo
        ibanLabel.font = UIFont.getBoldFont(size: FontSize.caption)
        errorLabel.text = Localizable.BankVerification.IBANVerification.wrongIBANFormat
        errorLabel.setLabelStyle(.error)

        let placeholderText = Localizable.BankVerification.IBANVerification.IBANplaceholder
        ibanVerificationTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: colors[.base25]])
        ibanVerificationTextField.placeholder = placeholderText

        initiatePaymentVerificationButton.setTitle(Localizable.Common.next, for: .normal)
        initiatePaymentVerificationButton.setAppearance(.inactive, colors: colors)

        ibanVerificationTextField.currentState = .normal
        ibanVerificationTextField.delegate = maskTextFieldDelegate

    }
    
}

extension IBANVerificationViewController: MaskedTextFieldDelegateListener {

    func textField(
        _ textField: UITextField,
        didFillMandatoryCharacters complete: Bool,
        didExtractValue value: String
    ) {
        textField.text = textField.text?.uppercased()
        eventHandler?.handleEvent(.validateEnteredIBAN(iban: value))
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}
