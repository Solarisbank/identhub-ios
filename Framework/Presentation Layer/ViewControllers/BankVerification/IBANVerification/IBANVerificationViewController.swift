//
//  IBANVerificationViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays screen to verify IBAN.
final internal class IBANVerificationViewController: SolarisViewController {

    var viewModel: IBANVerificationViewModel!

    enum Constants {
        enum FontSize {
            static let medium: CGFloat = 14
            static let small: CGFloat = 12
            static let tiny: CGFloat = 11
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let heightNormal: CGFloat = 24
            static let normal: CGFloat = 16
            static let small: CGFloat = 8
        }
    }

    private lazy var currentStepView: IdentificationProgressView = {
        let view = IdentificationProgressView(currentStep: .bankVerification)
        return view
    }()

    private lazy var personalAccountHintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.text = Localizable.BankVerification.IBANVerification.personalAccountDisclaimer
        label.textColor = .sdkColor(.base75)
        return label
    }()

    private lazy var joinedAccountsHintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.text = Localizable.BankVerification.IBANVerification.joinedAccountsDisclaimer
        label.textColor = .sdkColor(.base75)
        return label
    }()

    private lazy var ibanLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(Constants.FontSize.small)
        label.text = Localizable.BankVerification.IBANVerification.IBAN
        label.textColor = .sdkColor(.base75)
        return label
    }()

    private lazy var ibanVerificationTextField: VerificationTextField = {
        let textField = VerificationTextField()
        textField.placeholder = Localizable.BankVerification.IBANVerification.IBANplaceholder
        textField.textColor = .sdkColor(.base75)
        return textField
    }()

    private lazy var errorLabel: UILabel = {
        let label = UILabel()
        label.font = label.font.withSize(Constants.FontSize.tiny)
        label.text = Localizable.BankVerification.IBANVerification.wrongIBANFormat
        label.textColor = .sdkColor(.error)
        return label
    }()

    private lazy var initiatePaymentVerificationButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.BankVerification.IBANVerification.initiatePaymentVerification, for: .normal)
        button.currentAppearance = .orange
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        containerView.addSubviews([
            currentStepView,
            personalAccountHintLabel,
            joinedAccountsHintLabel,
            ibanLabel,
            ibanVerificationTextField,
            errorLabel,
            initiatePaymentVerificationButton
        ])

        errorLabel.isHidden = true

        currentStepView.addConstraints { [
            $0.equal(.top),
            $0.equal(.leading),
            $0.equal(.trailing)
        ]
        }

        personalAccountHintLabel.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        joinedAccountsHintLabel.addConstraints { [
            $0.equalTo(personalAccountHintLabel, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        ibanLabel.addConstraints { [
            $0.equalTo(joinedAccountsHintLabel, .top, .bottom, constant: Constants.ConstraintsOffset.heightNormal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        ibanVerificationTextField.addConstraints { [
            $0.equalTo(ibanLabel, .top, .bottom, constant: Constants.ConstraintsOffset.small),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        errorLabel.addConstraints { [
            $0.equalTo(ibanVerificationTextField, .top, .bottom, constant: Constants.ConstraintsOffset.small),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        initiatePaymentVerificationButton.addConstraints { [
            $0.equalTo(errorLabel, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended)
        ]
        }

        initiatePaymentVerificationButton.addTarget(self, action: #selector(initiatePaymentVerification), for: .touchUpInside)
    }

    @objc private func initiatePaymentVerification() {
        viewModel.initiatePaymentVerification(withIBAN: ibanVerificationTextField.text)
    }
}

// MARK: IBANVerificationViewModelDelegate methods

extension IBANVerificationViewController: IBANVerificationViewModelDelegate {

    func isIBANFormatValid(_ valid: Bool) {
        errorLabel.isHidden = valid
        ibanVerificationTextField.currentState = valid ? .verified : .error
        initiatePaymentVerificationButton.currentAppearance = valid ? .verifying : .orange
    }

    func verificationIBANFailed(_ error: APIError) {
        isIBANFormatValid(false)
        errorLabel.text = error.text()
        showVerificationError(error)
    }
}

// MARK: - Internal methods -

private extension IBANVerificationViewController {

    private func showVerificationError(_ error: APIError) {

        let alert = UIAlertController(title: "IBAN verification failed", message: error.text(), preferredStyle: .alert)

        let reactionAction = UIAlertAction(title: "Try again", style: .default, handler: { [weak self] _ in
            self?.ibanVerificationTextField.text = ""
        })

        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] _ in
            self?.viewModel.didTriggerQuit()
        })

        alert.addAction(reactionAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
