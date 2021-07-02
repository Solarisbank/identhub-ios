//
//  SignDocumentsViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays the screen to sign the documents.
final internal class SignDocumentsViewController: SolarisViewController {

    var viewModel: SignDocumentsViewModel!

    private var timer: Timer?

    private enum State {
        case normal
        case veryfing
        case processing
        case success
        case error
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
        view.backgroundColor = .sdkColor(.black0)
        return view
    }()

    private lazy var mainContainerView: UIView = {
        let view = UIView()
        view.backgroundColor = .sdkColor(.black0)
        return view
    }()

    private lazy var enterCodeHintLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.textColor = UIColor.sdkColor(.base75)
        label.attributedText = "\(Localizable.PhoneVerification.enterCode) \(viewModel.mobileNumber)".withBoldText(viewModel.mobileNumber, withColorForBoldText: .black)
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

    private lazy var stateView: StateView = {
        let stateView = StateView(hasDescriptionLabel: true)
        stateView.setStateImage(UIImage.sdkImage(.processingVerification, type: SignDocumentsViewController.self))
        stateView.setStateTitle(Localizable.SignDocuments.Sign.applicationIsBeingProcessed)
        stateView.setStateDescription(Localizable.SignDocuments.Sign.downloadDocuments)
        return stateView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
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
            submitAndSignCodeButton
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
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended)
        ]
        }

        submitAndSignCodeButton.addTarget(self, action: #selector(submitCodeAndSign), for: .touchUpInside)
    }

    @objc private func submitCodeAndSign() {
        viewModel.submitCodeAndSign(codeEntryView.code)
    }

    private func updateUI() {
        DispatchQueue.main.async {
            switch self.state {
            case .normal:
                self.codeEntryView.state = .normal
                self.codeEntryView.clearCodeEntries()
                self.submitAndSignCodeButton.setTitle(Localizable.SignDocuments.Sign.submitAndSign, for: .normal)
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
                self.submitAndSignCodeButton.currentAppearance = .orange
            }
        }
    }

    @objc private func checkStatus() {
        viewModel.checkIdentificationStatus()
    }
}

// MARK: SignDocumentsViewModelDelegate methods

extension SignDocumentsViewController: SignDocumentsViewModelDelegate {
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

    func verificationFailed() { }
}

// MARK: - Code entry view delegate methods -

extension SignDocumentsViewController: CodeEntryViewDelegate {

    func didUpdateCode(_ digits: Int) {
        submitAndSignCodeButton.isEnabled = ( digits == 6 )
        submitAndSignCodeButton.currentAppearance = ( digits == 6 ) ? .orange : .inactive
    }
}
