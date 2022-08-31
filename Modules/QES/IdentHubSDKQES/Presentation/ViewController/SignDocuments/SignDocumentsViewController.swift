//
//  SignDocumentsViewController.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

internal enum SignDocumentsEvent {
    case requestNewCode
    case submitCodeAndSign(_ code: String)
    case quit
}

internal struct SignDocumentsState: Equatable {
    enum State: Equatable {
        case requestingCode
        case codeAvailable
        case codeUnavailable
        case verifyingCode
        case codeInvalid
        case processingIdentfication
        case identificationSuccessful
    }

    var mobileNumber: String?
    var state: State = .requestingCode
    var newCodeRemainingTime: Int = 0
    var transactionId: String?
}

final internal class SignDocumentsViewController: UIViewController, Quitable, Updateable {
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
    var eventHandler: AnyEventHandler<SignDocumentsEvent>?

    private var colors: Colors
    private var state: SignDocumentsState.State = .requestingCode
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<SignDocumentsEvent>) {
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
        registerForKeyboardNotifications()
        eventHandler?.handleEvent(.requestNewCode)
    }
    
    // MARK: - Internal methods -

    func updateView(_ state: SignDocumentsState) {
        loadViewIfNeeded()
        
        updateCodeEntryHint(withMobileNumber: state.mobileNumber?.withStarFormat())

        updateScreenState(state: state.state)
        updateTransactionInfo(withId: state.transactionId, isHidden: state.state != .codeAvailable)
        updateNewCodeRemainingTime(state.newCodeRemainingTime, state: state.state)
    }

    @IBAction func didClickSendNewCode(_ sender: UIButton) {
        eventHandler?.handleEvent(.requestNewCode)
    }
    
    @IBAction func didClickSubmitCode(_ sender: Any) {
        if let code = codeEntryView.code {
            eventHandler?.handleEvent(.submitCodeAndSign(code))
        }
    }
    
    @IBAction func didClickQuit(_ sender: Any) {
        eventHandler?.handleEvent(.quit)
    }
}

// MARK: - Private methods -

extension SignDocumentsViewController {
    
    private func configureUI() {
        headerView.setStyle(.quit(target: self))
        
        titleLabel.text = Localizable.SignDocuments.Sign.title
        
        codeEntryView.delegate = self
        codeEntryView.state = .disabled
        
        requestCodeTimerLabel.text = Localizable.PhoneVerification.requestNewCodeTimer
        errorCodeLabel.text = Localizable.PhoneVerification.wrongTan
        errorCodeLabel.textColor = colors[.error]
        
        sendNewCodeBtn.setTitle(Localizable.PhoneVerification.sendNewCode, for: .normal)
        sendNewCodeBtn.setTitleColor(colors[.secondaryAccentDarken], for: .normal)
        
        submitCodeBtn.setTitle(Localizable.Common.confirm, for: .normal)
        submitCodeBtn.setAppearance(.inactive, colors: colors)

        stateView.hasDescriptionLabel = true
        stateView.setStateImage(Bundle.core.image(named: "processing_verification"))
        stateView.setStateTitle(Localizable.SignDocuments.Sign.applicationIsBeingProcessed)
        stateView.setStateDescription(Localizable.SignDocuments.Sign.downloadDocuments)
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
        submitCodeBtnBottomConstraint.constant = Constants.bottomMargin
    }
    
    // MARK: - Screen state -
    private func updateSendNewCodeButton(isHidden: Bool, isEnabled: Bool) {
        sendNewCodeBtn.isHidden = isHidden
        sendNewCodeBtn.isEnabled = isEnabled
        sendNewCodeBtn.alpha = isEnabled ? Constants.fullyVisible : Constants.halfTransparent
    }

    private func updateScreenState(state: SignDocumentsState.State) {
        guard self.state != state else {
            return
        }

        switch state {
        case .requestingCode:
            errorCodeLabel.isHidden = true
            requestCodeTimerLabel.isHidden = true
            codeEntryView.state = .disabled
        case .codeAvailable:
            errorLabelHeightConstraint.constant = 0
            submitCodeBtn.setAppearance(.inactive, colors: colors)
            codeEntryView.state = .normal
            codeEntryView.clearCodeEntries()
        case .codeInvalid:
            updateSendNewCodeButton(isHidden: false, isEnabled: true)
            codeEntryView.state = .error
            submitCodeBtn.setAppearance(.inactive, colors: colors)
            errorLabelHeightConstraint.constant = Constants.errorLabelHeight
            errorCodeLabel.isHidden = false
            requestCodeTimerLabel.isHidden = true
            errorCodeLabel.text = Localizable.PhoneVerification.wrongTan
        case .processingIdentfication:
            mainContainer.removeFromSuperview()
            stateView.isHidden = false
        case .verifyingCode:
            updateSendNewCodeButton(isHidden: false, isEnabled: false)
            codeEntryView.state = .disabled
            submitCodeBtn.setAppearance(.verifying, colors: colors)
            requestCodeTimerLabel.isHidden = true
        case .codeUnavailable:
            updateSendNewCodeButton(isHidden: false, isEnabled: true)
            codeEntryView.state = .normal
            codeEntryView.clearCodeEntries()
            submitCodeBtn.setAppearance(.inactive, colors: colors)
            requestCodeTimerLabel.isHidden = true
            errorLabelHeightConstraint.constant = Constants.errorLabelHeight
            errorCodeLabel.isHidden = false
            errorCodeLabel.text = Localizable.PhoneVerification.Error.requestCodeError
        default:
            break
        }
        
        self.state = state
    }
    
    private func updateCodeEntryHint(withMobileNumber mobileNumber: String?) {
        let text = String(format: Localizable.PhoneVerification.enterCode, mobileNumber ?? "")
        if let mobileNumber = mobileNumber {
            codeEntryHint.attributedText = text.withBoldTexts([mobileNumber], withColorForBoldText: colors[.base100])
        } else {
            codeEntryHint.attributedText = NSAttributedString(string: text)
        }
    }

    private func updateTransactionInfo(withId id: String?, isHidden: Bool) {
        transactionDetailView.isHidden = id == nil || isHidden
        if let id = id {
            transactionInfoLabel.attributedText = "\(Localizable.SignDocuments.Sign.transactionInfoPartOne) \(id) \(Localizable.SignDocuments.Sign.transactionInfoPartTwo)".withBoldTexts([id], withColorForBoldText: colors[.black100])
        }
    }

    private func updateNewCodeRemainingTime(_ time: Int, state: ViewState.State) {
        requestCodeTimerLabel.attributedText = "\(Localizable.PhoneVerification.requestNewCodeTimer) \(time.secondsDescription)".withBoldTexts([time.secondsDescription])
        requestCodeTimerLabel.isHidden = time <= 0 || state == .codeUnavailable
        updateSendNewCodeButton(isHidden: time > 0 && state != .codeUnavailable, isEnabled: state != .verifyingCode)
    }
}

private extension SignDocumentsViewController {
    enum Constants {
        static var fullyVisible: CGFloat { 1.0 }
        static var halfTransparent: CGFloat { 0.5 }
        static var bottomMargin: CGFloat { 30 }
        static var errorLabelHeight: CGFloat { 40 }
    }
}

// MARK: - Code entry view delegate methods -

extension SignDocumentsViewController: CodeEntryViewDelegate {
    
    func didUpdateCode(_ digits: Int) {
        let isValidCode = ( digits == 6 )
        submitCodeBtn.isEnabled = isValidCode
        submitCodeBtn.setAppearance(isValidCode ? .primary : .inactive, colors: colors)
    }
}

private extension Int {
    var secondsDescription: String {
        "00: " + (self >= 10 ? String(describing: self) : "0\(String(describing: self))")
    }
}
