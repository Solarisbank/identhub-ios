//
//  IBANVerificationViewController.swift
//  IdentHubSDK
//

import UIKit
import InputMask

/// UIViewController which displays screen to verify IBAN.
final internal class IBANVerificationViewController: UIViewController, Quitable {

    // MARK: - IBOutlets -

    @IBOutlet var headerView: HeaderView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var accountHintLabel: UILabel!
    @IBOutlet var ibanLabel: UILabel!
    @IBOutlet var ibanVerificationTextField: VerificationTextField!
    @IBOutlet var maskTextFieldDelegate: MaskedTextFieldDelegate!
    @IBOutlet var initiatePaymentVerificationButton: ActionRoundedButton!
    @IBOutlet var errorLabel: UILabel!

    // MARK: - Properties -

    private var viewModel: IBANVerificationViewModel!

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: IBANVerificationViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "IBANVerificationViewController", bundle: Bundle(for: IBANVerificationViewController.self))
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    // MARK: - Lifecycle -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {

        headerView.style = .quit(target: self)

        titleLabel.text = Localizable.BankVerification.IBANVerification.title
        accountHintLabel.text = Localizable.BankVerification.IBANVerification.accountDisclaimer
        ibanLabel.text = Localizable.BankVerification.IBANVerification.IBAN
        errorLabel.text = Localizable.BankVerification.IBANVerification.wrongIBANFormat

        let placeholderText = Localizable.BankVerification.IBANVerification.IBANplaceholder
        ibanVerificationTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.sdkColor(.base25)])
        ibanVerificationTextField.placeholder = placeholderText

        initiatePaymentVerificationButton.setTitle(Localizable.Common.next, for: .normal)
        initiatePaymentVerificationButton.currentAppearance = .primary

        ibanVerificationTextField.currentState = .normal
        ibanVerificationTextField.delegate = maskTextFieldDelegate
    }

    @IBAction func initiatePaymentVerification(_: ActionRoundedButton) {
        ibanVerificationTextField.resignFirstResponder()
        let iban = ibanVerificationTextField.text?.replacingOccurrences(of: " ", with: "")
        viewModel.initiatePaymentVerification(withIBAN: iban)
    }

    @IBAction func didEndEdigitn(_ sender: UITapGestureRecognizer) {
        view.endEditing(true)
    }

    @IBAction func didClickQuit(_ sender: Any) {
        viewModel.quit()
    }
}

extension IBANVerificationViewController: MaskedTextFieldDelegateListener {

    func textField(
        _ textField: UITextField,
        didFillMandatoryCharacters complete: Bool,
        didExtractValue value: String
    ) {
        textField.text = textField.text?.uppercased()

        let valid = viewModel.validateEnteredIBAN(withIBAN: value)
        ibanVerificationTextField.currentState = valid ? .verified : .normal
    }

    func textFieldShouldReturn(_ textField: UITextField) -> Bool {
        textField.resignFirstResponder()
        return true
    }
}

// MARK: IBANVerificationViewModelDelegate methods

extension IBANVerificationViewController: IBANVerificationViewModelDelegate {

    func isIBANFormatValid(_ valid: Bool) {
        errorLabel.isHidden = valid
        ibanVerificationTextField.currentState = valid ? .verified : .error
        initiatePaymentVerificationButton.currentAppearance = valid ? .verifying : .primary
    }

    func verificationIBANFailed(_ error: ResponseError) {
        var errorDetail: ErrorDetail?
        var message = ""
        
        switch error.apiError {
        case .clientError(let detail),
             .incorrectIdentificationStatus(let detail):
            message = Localizable.BankVerification.IBANVerification.notValidIBAN
            errorDetail = detail
        default:
            message = error.apiError.text()
        }
        
#if ENV_DEBUG
        message += "\n\(error.detailDescription)"
#endif
        showVerificationError(message, error: errorDetail)

        isIBANFormatValid(false)
    }
}

// MARK: - Internal methods -

private extension IBANVerificationViewController {

    private func showVerificationError(_ message: String?, error: ErrorDetail? = nil) {
        let alert = UIAlertController(title: Localizable.BankVerification.IBANVerification.failureAlertTitle, message: message, preferredStyle: .alert)

        if let errorDetail = error, let nextStep = errorDetail.nextStep {
            let reactionAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.retryOption, style: .default, handler: { [weak self] _ in
                self?.viewModel.performFlowStep(nextStep)
            })

            alert.addAction(reactionAction)
        }

        if let errorDetail = error, let fallbackStep = errorDetail.fallbackStep, fallbackStep != .abort {
            let fallbackAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.alternateOption, style: .default, handler: { [weak self] _ in
                self?.viewModel.performFlowStep(fallbackStep)
            })
            
            alert.addAction(fallbackAction)
        } else if viewModel.isExistFallbackOption() {
            let fallbackAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.alternateOption, style: .default, handler: { [weak self] _ in
                self?.viewModel.performFallbackIdent()
            })

            alert.addAction(fallbackAction)
        }

        let cancelAction = UIAlertAction(title: Localizable.Common.quit, style: .cancel, handler: { [weak self] _ in
            self?.viewModel.didTriggerQuit()
        })

        alert.addAction(cancelAction)

        present(alert, animated: true)
        
        errorLabel.text = message
    }
}
