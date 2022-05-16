//
//  PhoneVerificationViewController.swift
//  IdentHubSDK
//

import UIKit

/// View of phone verificaiton scree
final internal class PhoneVerificationViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var mainContainer: UIView!
    @IBOutlet var currentStepView: IdentificationProgressView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var infoLabel: UILabel!
    @IBOutlet var codeEntryView: CodeEntryView!
    @IBOutlet var countDownTimeLabel: UILabel!
    @IBOutlet var requestNewCodeBtn: UIButton!
    @IBOutlet var errorLabel: UILabel!
    @IBOutlet var submitCodeBtn: ActionRoundedButton!
    @IBOutlet var quitBtn: ActionRoundedButton!
    @IBOutlet var quitBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet var errorMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet var successView: SuccessView!
    
    // MARK: - Properties -
    var viewModel: PhoneVerificationViewModel!
    
    private enum State {
        case normal
        case disabled
        case error
        case success
        case requestCode
    }

    private var state: State = .normal {
        didSet {
            updateScreenState()
        }
    }

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: PhoneVerificationViewModel) {
        self.viewModel = viewModel

        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
        
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        registerForKeyboardNotifications()
        viewModel.requestNewCode()
    }
    
    // MARK: - Actions methods -
    
    @IBAction func didClickSendNewCode(_ sender: UIButton) {
        viewModel.requestNewCode()
    }
    
    @IBAction func didClickQuit(_ sender: UIButton) {
        viewModel.quit()
    }
    
    
    @IBAction func didClickSubmitCode(_ sender: ActionRoundedButton) {
        viewModel.submitCode(codeEntryView.code)
    }
}

// MARK: - Internal methods -

extension PhoneVerificationViewController {
    private func configureUI() {
        
        currentStepView.setCurrentStep(.phoneVerification)
        
        titleLabel.text = Localizable.PhoneVerification.title
        infoLabel.text = Localizable.PhoneVerification.enterCode
        countDownTimeLabel.text = Localizable.PhoneVerification.requestNewCodeTimer
        errorLabel.text = Localizable.PhoneVerification.wrongTan
        errorLabel.textColor = .sdkColor(.error)
        
        requestNewCodeBtn.setTitle(Localizable.PhoneVerification.requestNewCode, for: .normal)
        requestNewCodeBtn.setTitleColor(.sdkColor(.secondaryAccent), for: .normal)
        
        submitCodeBtn.setTitle(Localizable.PhoneVerification.submitCode, for: .normal)
        submitCodeBtn.tintColor = .sdkColor(.primaryAccent)
        
        quitBtn.setTitle(Localizable.Common.quit, for: .normal)
        quitBtn.setTitleColor(.sdkColor(.primaryAccent), for: .normal)
        
        codeEntryView.delegate = self
        
        successView.setTitle(Localizable.PhoneVerification.Success.title)
        successView.setDescription(Localizable.PhoneVerification.Success.description)
        successView.setActionButtonTitle(Localizable.PhoneVerification.Success.action)
        
        successView.setAction { [weak self] in
            self?.viewModel.beginBankIdentification()
        }
    }
    
    // MARK: - Kyeboard hide/show methods

    func registerForKeyboardNotifications() {
        // Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            quitBtnBottomConstraint.constant = keyboardSize.height
        }
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        quitBtnBottomConstraint.constant = 30
    }
    
    // MARK: - Screen state -

    private func updateScreenState() {
        
        switch state {
        case .normal:
            countDownTimeLabel.isHidden = false
            requestNewCodeBtn.isHidden = true
            errorMessageHeightConstraint.constant = 0
            submitCodeBtn.currentAppearance = .inactive
            codeEntryView.state = .normal
            codeEntryView.clearCodeEntries()
        case .disabled:
            requestNewCodeBtn.isEnabled = false
            requestNewCodeBtn.alpha = 0.5
            submitCodeBtn.currentAppearance = .verifying
            codeEntryView.state = .disabled
            countDownTimeLabel.isHidden = true
        case .success:
            mainContainer.removeFromSuperview()
            successView.isHidden = false
        case .error:
            codeEntryView.state = .error
            errorMessageHeightConstraint.constant = 40
            errorLabel.isHidden = false
            requestNewCodeBtn.isEnabled = true
            requestNewCodeBtn.alpha = 1.0
        case .requestCode:
            countDownTimeLabel.isHidden = true
            requestNewCodeBtn.isHidden = false
            requestNewCodeBtn.alpha = 1.0
        }
    }
}

// MARK: - Code entry delegate methods -

extension PhoneVerificationViewController: CodeEntryViewDelegate {
    
    func didUpdateCode(_ digits: Int) {
        let isValidCode = ( digits == 6 )
        submitCodeBtn.isEnabled = isValidCode
        submitCodeBtn.currentAppearance = isValidCode ? .primary : .inactive
    }
}

// MARK: - View model delegate methods -

extension PhoneVerificationViewController: PhoneVerificationViewModelDelegate {
    
    func didGetPhoneNumber(_ phoneNumber: String) {
        infoLabel.attributedText = "\(Localizable.PhoneVerification.enterCode) \(phoneNumber)".withBoldText(phoneNumber, withColorForBoldText: .sdkColor(.base75))
    }

    func willGetNewCode() {
        state = .normal
    }
    
    func verificationStarted() {
        state = .disabled
    }

    func verificationSucceeded() {
        state = .success
    }

    func verificationFailed() {
        state = .error
    }
    
    func didUpdateTimerLabel(_ seconds: String) {
        countDownTimeLabel.attributedText = "\(Localizable.PhoneVerification.requestNewCodeTimer) 00:\(seconds)".withBoldText("00:\(seconds)")
    }
    
    func didEndTimerDelay() {
        state = .requestCode
    }
}
