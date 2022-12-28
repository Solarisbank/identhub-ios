//
//  PhoneVerificationViewController.swift
//  IdentHubSDKCore
//

import UIKit

internal enum PhoneVerificationEvent {
    case requestNewCode
    case submitCode(_ code: String)
    case verificationSuccess
    case quit
}

internal struct PhoneVerificationState: Equatable {
    enum State: Equatable {
        case normal
        case disabled
        case error
        case success
        case requestCode
        case remainingTime
    }
    
    var mobileNumber: String?
    var state: State = .normal
    var seconds: Int = 0
}

/// UIViewController which displays screen for Phone verification.
final internal class PhoneVerificationViewController: UIViewController, Updateable, Quitable {
    
    typealias ViewState = PhoneVerificationState
    
    // MARK: - Properties -
    var eventHandler: AnyEventHandler<PhoneVerificationEvent>?
    var colors: Colors
    
    // MARK: - Outlets -
    
    @IBOutlet private var mainContainer: UIView!
    @IBOutlet private var headerView: HeaderView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var infoLabel: UILabel!
    @IBOutlet private var codeEntryView: CodeEntryView!
    @IBOutlet private var countDownTimeLabel: UILabel!
    @IBOutlet private var requestNewCodeBtn: UIButton!
    @IBOutlet private var errorLabel: UILabel!
    @IBOutlet private var submitCodeBtn: ActionRoundedButton!
    @IBOutlet private var submitCodeBtnBottomConstraint: NSLayoutConstraint!
    @IBOutlet private var errorMessageHeightConstraint: NSLayoutConstraint!
    @IBOutlet private var successView: SuccessView!
    
    private var state: PhoneVerificationState.State = .normal
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    public init(colors: Colors, eventHandler: AnyEventHandler<PhoneVerificationEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        configureUI()
        registerForKeyboardNotifications()
        eventHandler?.handleEvent(.requestNewCode)
    }
    
    // MARK: - Actions methods -
    
    @IBAction func didClickSendNewCode(_ sender: UIButton) {
        eventHandler?.handleEvent(.requestNewCode)
    }
    
    @IBAction func didClickQuit(_ sender: Any) {
        eventHandler?.handleEvent(.quit)
    }
    
    @IBAction func didClickSubmitCode(_ sender: ActionRoundedButton) {
        guard let code = codeEntryView.code else { return }
        eventHandler?.handleEvent(.submitCode(code))
    }
    
    // MARK: - Update -
    
    func updateView(_ state: PhoneVerificationState) {
        updateScreenState(state: state)
        updateMobileNumber(state: state)
    }
    
}

// MARK: - Internal methods -

extension PhoneVerificationViewController {
    
    private func updateScreenState(state: PhoneVerificationState) {
        
        switch state.state {
        case .normal:
            countDownTimeLabel.isHidden = false
            requestNewCodeBtn.isHidden = true
            errorMessageHeightConstraint.constant = 0
            submitCodeBtn.currentAppearance = .inactive
            codeEntryView.state = .normal
            codeEntryView.clearCodeEntries()
            errorLabel.isHidden = true
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
        case .remainingTime:
            updateRemainingTime(state: state)
        }        
    }
    
    private func updateMobileNumber(state: PhoneVerificationState) {
        let text = String(format: Localizable.PhoneVerification.enterCode, state.mobileNumber ?? "")
        guard let number = state.mobileNumber else {
            infoLabel.attributedText = NSAttributedString(string: text)
            return
        }
        infoLabel.attributedText = text.withBoldTexts([number], withColorForBoldText: colors[.base100])
    }
    
    private func updateRemainingTime(state: PhoneVerificationState) {
        let secondString = (state.seconds >= 10) ? String(describing: state.seconds) : "0\(String(describing: state.seconds))"
        countDownTimeLabel.attributedText = "\(Localizable.PhoneVerification.requestNewCodeTimer) 00:\(secondString)".withBoldTexts(["00:\(secondString)"])
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
    
    private func configureUI() {
        
        headerView.setStyle(.quit(target: self))
        
        titleLabel.text = Localizable.PhoneVerification.title
        countDownTimeLabel.text = Localizable.PhoneVerification.requestNewCodeTimer
        errorLabel.text = Localizable.PhoneVerification.wrongTan
        errorLabel.textColor = colors[.error]
        
        requestNewCodeBtn.setTitle(Localizable.PhoneVerification.requestNewCode, for: .normal)
        requestNewCodeBtn.setTitleColor(colors[.secondaryAccent], for: .normal)
        
        submitCodeBtn.setTitle(Localizable.Common.confirm, for: .normal)
        submitCodeBtn.tintColor = colors[.primaryAccent]
        submitCodeBtn.setAppearance(.inactive, colors: colors)
        
        codeEntryView.delegate = self
        codeEntryView.state = .disabled
        
        successView.configure(with: colors)
        successView.setTitle(Localizable.PhoneVerification.Success.title)
        successView.setDescription(Localizable.PhoneVerification.Success.description)
        successView.setActionButtonTitle(Localizable.Common.next)
        
        successView.setAction { [weak self] in
            self?.eventHandler?.handleEvent(.verificationSuccess)
        }
    }
    
}

// MARK: - Code entry delegate methods -

extension PhoneVerificationViewController: CodeEntryViewDelegate {
    
    public func didUpdateCode(_ digits: Int) {
        DispatchQueue.main.async {
            let isValidCode = ( digits == 6 )
            self.submitCodeBtn.isEnabled = isValidCode
            self.submitCodeBtn.currentAppearance = isValidCode ? .primary : .inactive
        }
    }
}
