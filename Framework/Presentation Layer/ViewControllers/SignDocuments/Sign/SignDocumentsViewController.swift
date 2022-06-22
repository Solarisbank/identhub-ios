//
//  SignDocumentsViewController.swift
//  IdentHubSDK
//

import UIKit

final internal class SignDocumentsViewController: UIViewController, Quitable {
    // MARK: - Outlets -
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var mainContainer: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var codeEntryHint: UILabel!
    @IBOutlet var codeEntryView: CodeEntryView!
    @IBOutlet var requestCodeTimerLabel: UILabel!
    @IBOutlet var errorCodeLabel: UILabel!
    @IBOutlet var sendNewCodeBtn: UIButton!
    @IBOutlet var transactionDetailView: UIView!
    @IBOutlet var transactionInfoLabel: UILabel!
    @IBOutlet var submitCodeBtn: ActionRoundedButton!
    @IBOutlet var submitCodeBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet var errorLabelHeightConstraint: NSLayoutConstraint!
    @IBOutlet var stateView: StateView!
    
    // MARK: - Properties -
    private var viewModel: SignDocumentsViewModel!
    
    private enum State {
        case normal
        case veryfing
        case processing
        case success
        case error
        case requestCodeError
        case requestCode
    }

    private var state: State = .normal {
        didSet {
            updateScreenState()
        }
    }

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: SignDocumentsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
        
        self.viewModel.delegate = self
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        registerForKeyboardNotifications()
        viewModel.viewLoaded()
    }

    @IBAction func didClickSendNewCode(_ sender: UIButton) {
        viewModel.requestNewCode()
        state = .normal
    }
    
    @IBAction func didClickSubmitCode(_ sender: Any) {
        viewModel.submitCodeAndSign(codeEntryView.code)
    }
    
    @IBAction func didClickQuit(_ sender: Any) {
        viewModel.quit()
    }
}

// MARK: - Private methods -

extension SignDocumentsViewController {
    
    private func configureUI() {
        headerView.setStyle(.quit(target: self))
        
        titleLabel.text = Localizable.SignDocuments.Sign.title
        codeEntryView.delegate = self
        
        requestCodeTimerLabel.text = Localizable.PhoneVerification.requestNewCodeTimer
        errorCodeLabel.text = Localizable.PhoneVerification.wrongTan
        errorCodeLabel.textColor = .sdkColor(.error)
        
        sendNewCodeBtn.setTitle(Localizable.PhoneVerification.sendNewCode, for: .normal)
        sendNewCodeBtn.setTitleColor(.sdkColor(.secondaryAccentDarken), for: .normal)
        
        submitCodeBtn.setTitle(Localizable.Common.confirm, for: .normal)
                
        stateView.hasDescriptionLabel = true
        stateView.setStateImage(UIImage.sdkImage(.processingVerification, type: Self.self))
        stateView.setStateTitle(Localizable.SignDocuments.Sign.applicationIsBeingProcessed)
        stateView.setStateDescription(Localizable.SignDocuments.Sign.downloadDocuments)
        
        state = .normal
    }
    
    // MARK: - Kyeboard hide/show methods

    func registerForKeyboardNotifications() {
        // Adding notifies on keyboard appearing
        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWasShown(_:)), name: UIResponder.keyboardWillShowNotification, object: nil)

        NotificationCenter.default.addObserver(self, selector: #selector(keyboardWillBeHidden(_:)), name: UIResponder.keyboardWillHideNotification, object: nil)
    }
    
    @objc func keyboardWasShown(_ notification: Notification) {
        if let keyboardSize = (notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue)?.cgRectValue {
            submitCodeBtnBottomConstraint.constant = keyboardSize.height
        }
    }

    @objc func keyboardWillBeHidden(_ notification: Notification) {
        submitCodeBtnBottomConstraint.constant = 30
    }
    
    // MARK: - Screen state -

    private func updateScreenState() {
        
        switch state {
        case .normal:
            transactionInfoLabel.text = "\(Localizable.SignDocuments.Sign.transactionInfoPartOne) \(Localizable.SignDocuments.Sign.transactionInfoPartTwo)"
            requestCodeTimerLabel.isHidden = false
            sendNewCodeBtn.isHidden = true
            errorLabelHeightConstraint.constant = 0
            submitCodeBtn.currentAppearance = .inactive
            codeEntryView.state = .normal
            codeEntryView.clearCodeEntries()
        case .requestCode:
            requestCodeTimerLabel.isHidden = true
            sendNewCodeBtn.isHidden = false
            sendNewCodeBtn.isEnabled = true
            sendNewCodeBtn.alpha = 1.0
        case .error:
            codeEntryView.state = .error
            submitCodeBtn.currentAppearance = .inactive
            errorLabelHeightConstraint.constant = 40
            errorCodeLabel.isHidden = false
            requestCodeTimerLabel.isHidden = true
            sendNewCodeBtn.isHidden = false
            sendNewCodeBtn.isEnabled = true
            sendNewCodeBtn.alpha = 1.0
            errorCodeLabel.text = Localizable.PhoneVerification.wrongTan
        case .success:
            viewModel.finishIdentification()
        case .processing:
            mainContainer.removeFromSuperview()
            stateView.isHidden = false
        case .veryfing:
            codeEntryView.state = .disabled
            submitCodeBtn.currentAppearance = .verifying
            sendNewCodeBtn.isEnabled = false
            sendNewCodeBtn.alpha = 0.5
            requestCodeTimerLabel.isHidden = true
        case .requestCodeError:
            codeEntryView.state = .normal
            codeEntryView.clearCodeEntries()
            submitCodeBtn.currentAppearance = .inactive
            errorLabelHeightConstraint.constant = 40
            errorCodeLabel.isHidden = false
            errorCodeLabel.text = Localizable.PhoneVerification.Error.requestCodeError
        }
    }
}


// MARK: - View model delegate methods -

extension SignDocumentsViewController: SignDocumentsViewModelDelegate {
    
    func didEndTimerDelay() {
        state = .requestCode
    }
    
    func didUpdateTimerLabel(_ seconds: String) {
        requestCodeTimerLabel.attributedText = "\(Localizable.PhoneVerification.requestNewCodeTimer) 00:\(seconds)".withBoldTexts(["00:\(seconds)"])
    }
    
    func didSubmitNewCodeRequest(_ token: String) {
        state = .normal

        transactionDetailView.isHidden = token.isEmpty
        transactionInfoLabel.attributedText = "\(Localizable.SignDocuments.Sign.transactionInfoPartOne) \(token) \(Localizable.SignDocuments.Sign.transactionInfoPartTwo)".withBoldTexts([token], withColorForBoldText: .sdkColor(.black100))
    }

    func verificationStarted() {
        state = .veryfing
    }

    func verificationIsBeingProcessed() {
        state = .processing
    }

    func verificationSucceeded() {
        viewModel.expireVerificationStatusTimer()
        state = .success
    }

    func verificationFailed() {
        state = .error
    }
    
    func requestNewCodeFailed() {
        state = .requestCodeError
    }
    
    func didUpdateMobileNumber(_ phoneNumber: String?) {
        guard let number = phoneNumber else {
            codeEntryHint.text = String(format: Localizable.PhoneVerification.enterCode, "")
            return
        }
        codeEntryHint.attributedText = String(format: Localizable.PhoneVerification.enterCode, number).withBoldTexts([number], withColorForBoldText: UIColor.sdkColor(.base100))
    }
}

// MARK: - Code entry view delegate methods -

extension SignDocumentsViewController: CodeEntryViewDelegate {
    
    func didUpdateCode(_ digits: Int) {
        let isValidCode = ( digits == 6 )
        submitCodeBtn.isEnabled = isValidCode
        submitCodeBtn.currentAppearance = isValidCode ? .primary : .inactive
    }
}
