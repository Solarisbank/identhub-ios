//
//  PhoneVerificationViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays screen to verify phone number with TAN.
final internal class PhoneVerificationViewController: SolarisViewController {

    var viewModel: PhoneVerificationViewModel!

    private enum State {
        case normal
        case disabled
        case error
        case success
    }

    private var state: State = .normal {
        didSet {
            updateUI()
        }
    }

    private enum Constants {
        enum FontSize {
            static let medium: CGFloat = 14
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let normal: CGFloat = 16
        }
    }

    private lazy var currentStepView: IdentificationProgressView = {
        let view = IdentificationProgressView(currentStep: .phoneVerification)
        return view
    }()

    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .sdkColor(.base05)
        return view
    }()

    private lazy var enterCodeHintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.text = Localizable.PhoneVerification.enterCode
        label.textColor = UIColor.sdkColor(.base75)
        return label
    }()

    private lazy var codeEntryView: CodeEntryView = {
        let codeEntryView = CodeEntryView(delegate: self)
        codeEntryView.backgroundColor = .sdkColor(.base05)
        return codeEntryView
    }()

    private lazy var submitCodeButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.PhoneVerification.submitCode, for: .normal)
        button.currentAppearance = .orange
        button.isEnabled = false
        button.currentAppearance = .inactive
        return button
    }()

    private lazy var successContainerView: SuccessView = {
        let view = SuccessView()
        view.setTitle(Localizable.PhoneVerification.Success.title)
        view.setDescription(Localizable.PhoneVerification.Success.description)
        view.setActionButtonTitle(Localizable.PhoneVerification.Success.action)
        view.setAction { [weak self] in
            self?.viewModel.beginBankIdentification()
        }
        return view
    }()

    private lazy var errorView: ErrorView = {
        let view = ErrorView()
        view.setTitle(Localizable.PhoneVerification.Error.title)
        view.setDescription(Localizable.PhoneVerification.Error.description)
        view.setPrimaryButtonTitle(Localizable.PhoneVerification.Error.action)
        view.setPrimaryButtonAction {
            self.viewModel.requestNewCode()
            self.state = .normal
        }
        view.setQuitButtonAction {
            self.viewModel.quit()
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        containerView.addSubviews([
            currentStepView,
            mainContainerView
        ])

        currentStepView.addConstraints { [
            $0.equal(.top),
            $0.equal(.leading),
            $0.equal(.trailing)
        ]
        }

        mainContainerView.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom),
            $0.equal(.leading),
            $0.equal(.trailing),
            $0.equal(.bottom)
        ]
        }

        mainContainerView.addSubviews([
            enterCodeHintLabel,
            codeEntryView,
            submitCodeButton
        ])

        enterCodeHintLabel.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        codeEntryView.addConstraints { [
            $0.equalTo(enterCodeHintLabel, .top, .bottom, constant: 24),
            $0.equal(.centerX)
        ]
        }

        submitCodeButton.addConstraints { [
            $0.equalTo(codeEntryView, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended)
        ]
        }

        submitCodeButton.addTarget(self, action: #selector(submitCode), for: .touchUpInside)
    }

    @objc private func submitCode(_ sender: UIButton) {
        if let code = codeEntryView.code, code.count == 6 {
            viewModel.submitCode(codeEntryView.code)
        }
    }

    @objc private func requestNewCode() {
        viewModel.requestNewCode()
    }

    private func setUpSuccessView() {
        containerView.addSubview(successContainerView)

        successContainerView.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom),
            $0.equal(.leading),
            $0.equal(.trailing),
            $0.equal(.bottom)
        ]
        }
    }

    private func setUpErrorView() {
        containerView.addSubview(errorView)

        errorView.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom),
            $0.equal(.leading),
            $0.equal(.trailing),
            $0.equal(.bottom)
        ]
        }
    }

    private func updateUI() {
        DispatchQueue.main.async {
            switch self.state {
            case .normal:
                self.codeEntryView.state = .normal
                self.codeEntryView.clearCodeEntries()
                self.submitCodeButton.setTitle(Localizable.PhoneVerification.submitCode, for: .normal)
                self.submitCodeButton.removeTarget(self, action: #selector(self.requestNewCode), for: .touchUpInside)
                self.submitCodeButton.addTarget(self, action: #selector(self.submitCode), for: .touchUpInside)
            case .disabled:
                self.codeEntryView.state = .disabled
                self.submitCodeButton.currentAppearance = .verifying
            case .error:
                self.codeEntryView.state = .error
                self.submitCodeButton.currentAppearance = .orange
                self.submitCodeButton.setTitle(Localizable.PhoneVerification.requestNewCode, for: .normal)
                self.submitCodeButton.removeTarget(self, action: #selector(self.submitCode), for: .touchUpInside)
                self.submitCodeButton.addTarget(self, action: #selector(self.requestNewCode), for: .touchUpInside)
            case .success:
                self.mainContainerView.removeFromSuperview()
                self.setUpSuccessView()
            }
        }
    }
}

// MARK: PhoneVerificationViewModelDelegate methods

extension PhoneVerificationViewController: PhoneVerificationViewModelDelegate {
    func verificationStarted() {
        state = .disabled
    }

    func verificationSucceeded() {
        state = .success
    }

    func verificationFailed() {
        state = .error
    }

    func didGetPhoneNumber(_ phoneNumber: String) {
        enterCodeHintLabel.attributedText = "\(Localizable.PhoneVerification.enterCode) \(phoneNumber)".withBoldText(phoneNumber, withColorForBoldText: .black)
    }

    func willGetNewCode() {
        state = .normal
    }
}

// MARK: - Code entry view delegate methods -

extension PhoneVerificationViewController: CodeEntryViewDelegate {

    func didUpdateCode(_ digits: Int) {
        submitCodeButton.isEnabled = ( digits == 6 )
        submitCodeButton.currentAppearance = ( digits == 6 ) ? .orange : .inactive
    }
}
