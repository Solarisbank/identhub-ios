//
//  SignDocumentsViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays the screen to sign the documents.
final internal class SignDocumentsViewController: SolarisViewController {

    var viewModel: SignDocumentsViewModel!

    private var timer: Timer?

    private var codeTimer: Timer?

    private enum State {
        case normal
        case veryfing
        case processing
        case success
        case error
        case expire
    }

    private var state: State = .normal {
        didSet {
            updateUI()
        }
    }

    enum Constants {
        enum FontSize {
            static let medium: CGFloat = 14
            static let small: CGFloat = 12
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let big: CGFloat = 24
            static let normal: CGFloat = 16
            static let small: CGFloat = 12
        }

        enum Size {
            static let cornerRadius: CGFloat = 4
            static let height: CGFloat = 14
            static let width: CGFloat = 14
        }
    }

    private lazy var currentStepView: IdentificationProgressView = {
        let view = IdentificationProgressView(currentStep: .documents)
        view.backgroundColor = .sdkColor(.background)
        return view
    }()

    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .sdkColor(.background)
        return view
    }()

    private lazy var enterCodeHintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.textColor = .sdkColor(.base75)
        label.attributedText = "\(Localizable.PhoneVerification.enterCode) \(viewModel.mobileNumber)".withBoldText(viewModel.mobileNumber, withColorForBoldText: UIColor.sdkColor(.base100))
        return label
    }()

    private lazy var codeEntryView: CodeEntryView = {
        let codeEntryView = CodeEntryView(delegate: self)
        return codeEntryView
    }()

    private lazy var transactionInfoView: UIView = {
        let view = UIView()
        view.layer.cornerRadius = Constants.Size.cornerRadius
        return view
    }()

    private lazy var transactionInfoLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = .sdkColor(.black75)
        label.font = label.font.withSize(Constants.FontSize.small)
        label.text = "\(Localizable.SignDocuments.Sign.transactionInfoPartOne) \(Localizable.SignDocuments.Sign.transactionInfoPartTwo)"
        return label
    }()

    private lazy var transactionInfoImageView: UIImageView = {
        let imageView = UIImageView()
        imageView.image = UIImage.sdkImage(.info, type: SignDocumentsViewController.self)
        return imageView
    }()

    private lazy var submitAndSignCodeButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.SignDocuments.Sign.submitAndSign, for: .normal)
        button.currentAppearance = .inactive
        return button
    }()

    private lazy var quitButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.Common.quit, for: .normal)
        button.currentAppearance = .dimmed
        button.addTarget(self, action: #selector(quit), for: .touchUpInside)
        return button
    }()

    private lazy var stateView: StateView = {
        let stateView = StateView()
        stateView.hasDescriptionLabel = true
        stateView.setStateImage(UIImage.sdkImage(.processingVerification, type: SignDocumentsViewController.self))
        stateView.setStateTitle(Localizable.SignDocuments.Sign.applicationIsBeingProcessed)
        stateView.setStateDescription(Localizable.SignDocuments.Sign.downloadDocuments)
        return stateView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        containerView.addSubviews([
            currentStepView,
            mainContainerView,
            stateView
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

        stateView.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom),
            $0.equal(.leading),
            $0.equal(.trailing),
            $0.equal(.bottom)
        ]
        }

        stateView.isHidden = true

        mainContainerView.addSubviews([
            enterCodeHintLabel,
            transactionInfoView,
            codeEntryView,
            submitAndSignCodeButton,
            quitButton
        ])

        enterCodeHintLabel.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        codeEntryView.addConstraints { [
            $0.equalTo(enterCodeHintLabel, .top, .bottom, constant: Constants.ConstraintsOffset.big),
            $0.equal(.centerX)
        ]
        }

        transactionInfoView.addConstraints { [
            $0.equalTo(codeEntryView, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        transactionInfoView.addSubviews([
            transactionInfoImageView,
            transactionInfoLabel
        ])

        transactionInfoImageView.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.small),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.small),
            $0.equalConstant(.height, Constants.Size.height),
            $0.equalConstant(.width, Constants.Size.width)
        ]
        }

        transactionInfoLabel.addConstraints { [
            $0.equalTo(transactionInfoImageView, .top, .top),
            $0.equalTo(transactionInfoImageView, .leading, .trailing, constant: Constants.ConstraintsOffset.small),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.small),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.small)
        ]
        }

        submitAndSignCodeButton.addConstraints { [
            $0.equalTo(transactionInfoView, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equalTo(quitButton, .bottom, .top, constant: -Constants.ConstraintsOffset.small)
        ]
        }

        quitButton.addConstraints { [
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.small)
        ]
        }

        codeTimer = Timer.scheduledTimer(timeInterval: 30.0, target: self, selector: #selector(expireCode), userInfo: nil, repeats: false)
    }

    @objc private func submitCodeAndSign() {
        viewModel.submitCodeAndSign(codeEntryView.code)
    }

    @objc private func requestNewCode() {
        viewModel.requestNewCode()
    }

    @objc private func quit() {
        viewModel.quit()
    }

    @objc private func expireCode() {
        state = .expire
    }

    private func updateUI() {
        DispatchQueue.main.async {
            switch self.state {
            case .normal:
                self.codeEntryView.state = .normal
                self.codeEntryView.clearCodeEntries()
                self.submitAndSignCodeButton.currentAppearance = .inactive
                self.submitAndSignCodeButton.isEnabled = false
                self.submitAndSignCodeButton.setTitle(Localizable.SignDocuments.Sign.submitAndSign, for: .normal)
                self.submitAndSignCodeButton.removeTarget(self, action: #selector(self.requestNewCode), for: .touchUpInside)
                self.submitAndSignCodeButton.addTarget(self, action: #selector(self.submitCodeAndSign), for: .touchUpInside)
            case .veryfing:
                self.codeEntryView.state = .disabled
                self.submitAndSignCodeButton.currentAppearance = .inactive
            case .processing:
                self.mainContainerView.removeFromSuperview()
                self.stateView.isHidden = false
            case .success:
                self.viewModel.finishIdentification()
            case .error:
                self.codeEntryView.state = .error
                self.submitAndSignCodeButton.currentAppearance = .primary
                self.submitAndSignCodeButton.setTitle(Localizable.SignDocuments.Sign.requestCode, for: .normal)
                self.submitAndSignCodeButton.removeTarget(self, action: #selector(self.submitCodeAndSign), for: .touchUpInside)
                self.submitAndSignCodeButton.addTarget(self, action: #selector(self.requestNewCode), for: .touchUpInside)
            case .expire:
                self.submitAndSignCodeButton.currentAppearance = .primary
                self.submitAndSignCodeButton.setTitle(Localizable.SignDocuments.Sign.requestCode, for: .normal)
                self.submitAndSignCodeButton.removeTarget(self, action: #selector(self.submitCodeAndSign), for: .touchUpInside)
                self.submitAndSignCodeButton.addTarget(self, action: #selector(self.requestNewCode), for: .touchUpInside)
                self.codeTimer?.invalidate()
            }
        }
    }

    @objc private func checkStatus() {
        viewModel.checkIdentificationStatus()
    }
}

// MARK: SignDocumentsViewModelDelegate methods

extension SignDocumentsViewController: SignDocumentsViewModelDelegate {

    func didSubmitNewCodeRequest() {
        state = .normal
    }

    func verificationStarted() {
        state = .veryfing
    }

    func verificationIsBeingProcessed() {
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: true)
        state = .processing
    }

    func verificationSucceeded() {
        timer?.invalidate()
        state = .success
    }

    func verificationFailed() {
        state = .error
    }
}

// MARK: - Code entry view delegate methods -

extension SignDocumentsViewController: CodeEntryViewDelegate {

    func didUpdateCode(_ digits: Int) {
        submitAndSignCodeButton.isEnabled = ( digits == 6 )
        submitAndSignCodeButton.currentAppearance = ( digits == 6 ) ? .primary : .inactive
    }
}
