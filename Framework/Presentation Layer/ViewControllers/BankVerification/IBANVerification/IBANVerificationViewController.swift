//
//  IBANVerificationViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays screen to verify IBAN.
final internal class IBANVerificationViewController: UIViewController {

    // MARK: - IBOutlets -

    @IBOutlet var currentStepView: IdentificationProgressView!
    @IBOutlet var personalAccountHintLabel: UILabel!
    @IBOutlet var joinedAccountsHintLabel: UILabel!
    @IBOutlet var ibanLabel: UILabel!
    @IBOutlet var ibanVerificationTextField: VerificationTextField!
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

        currentStepView.setCurrentStep(.bankVerification)

        personalAccountHintLabel.text = Localizable.BankVerification.IBANVerification.personalAccountDisclaimer
        joinedAccountsHintLabel.text = Localizable.BankVerification.IBANVerification.joinedAccountsDisclaimer
        ibanLabel.text = Localizable.BankVerification.IBANVerification.IBAN
        errorLabel.text = Localizable.BankVerification.IBANVerification.wrongIBANFormat

        let placeholderText = Localizable.BankVerification.IBANVerification.IBANplaceholder
        ibanVerificationTextField.attributedPlaceholder = NSAttributedString(string: placeholderText, attributes: [NSAttributedString.Key.foregroundColor: UIColor.sdkColor(.base25)])
        ibanVerificationTextField.placeholder = placeholderText

        initiatePaymentVerificationButton.setTitle(Localizable.BankVerification.IBANVerification.initiatePaymentVerification, for: .normal)
        initiatePaymentVerificationButton.currentAppearance = .primary

        ibanVerificationTextField.currentState = .normal
    }

    @IBAction func initiatePaymentVerification(_: ActionRoundedButton) {
        ibanVerificationTextField.resignFirstResponder()
        viewModel.initiatePaymentVerification(withIBAN: ibanVerificationTextField.text)
    }
}

// MARK: IBANVerificationViewModelDelegate methods

extension IBANVerificationViewController: IBANVerificationViewModelDelegate {

    func isIBANFormatValid(_ valid: Bool) {
        errorLabel.isHidden = valid
        ibanVerificationTextField.currentState = valid ? .verified : .error
        initiatePaymentVerificationButton.currentAppearance = valid ? .verifying : .primary
    }

    func verificationIBANFailed(_ error: APIError) {
        
        switch error {
        case .clientError:
            errorLabel.text = Localizable.BankVerification.IBANVerification.notValidIBAN
        default:
            errorLabel.text = error.text()
        }

        isIBANFormatValid(false)
        showVerificationError(errorLabel.text)
    }
}

// MARK: - Internal methods -

private extension IBANVerificationViewController {

    private func showVerificationError(_ message: String?) {

        let alert = UIAlertController(title: Localizable.BankVerification.IBANVerification.failureAlertTitle, message: message, preferredStyle: .alert)

        let reactionAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.retryOption, style: .default, handler: { _ in })

        alert.addAction(reactionAction)

        if viewModel.isExistFallbackOption() {
            let fallbackAction = UIAlertAction(title: Localizable.BankVerification.IBANVerification.alternateOption, style: .default, handler: { [weak self] _ in
                self?.viewModel.performFallbackIdent()
            })

            alert.addAction(fallbackAction)
        }

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.viewModel.didTriggerQuit()
        })

        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
