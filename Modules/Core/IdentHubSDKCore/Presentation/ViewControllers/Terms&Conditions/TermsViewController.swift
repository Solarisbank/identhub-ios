//
//  TermsViewController.swift
//  IdentHubSDKCore
//

import UIKit
import SafariServices

internal enum TermsViewEvent {
    case setupTermsText(_ textView: UITextView)
//    case termsChecked
    case continueProcess
    case quit
}

internal struct TermsViewState: Equatable {
    enum State: Equatable {
        case normal
    }
    
    var mobileNumber: String?
    var state: State = .normal
}

/// UIViewController which displays screen for Terms and Conditions.
final internal class TermsViewController: UIViewController, Updateable, Quitable {
    
    typealias ViewState = TermsViewState
    
    // MARK: - Properties -
    var eventHandler: AnyEventHandler<TermsViewEvent>?
    var colors: Colors
    
    // MARK: - Outlets -
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var termsText: UITextView!
    @IBOutlet var continueBtn: ActionRoundedButton!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var termsContainerView: UIView!
    @IBOutlet var checkBoxBtn: Checkbox!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    public init(colors: Colors, eventHandler: AnyEventHandler<TermsViewEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
        eventHandler?.handleEvent(.setupTermsText(termsText))
    }
    
    // MARK: - Update -
    
    func updateView(_ state: TermsViewState) {
        
    }
    
    @IBAction func didClickQuit(_ sender: Any) {
        eventHandler?.handleEvent(.quit)
    }
    
    // MARK: - Internal methods -
    
    private func configureUI() {
        termsText.delegate = self
        descLabel.text = Localizable.TermsConditions.description
        continueBtn.setAppearance(.inactive, colors: colors)
        checkBoxBtn.setAppearance(colors)
    }
    
    // MARK: - Action methods -
    @IBAction func didClickCheckmark(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            continueBtn.currentAppearance = .inactive
        } else {
            sender.isSelected = true
            continueBtn.currentAppearance = .primary
        }
    }
    
    @IBAction func didClickContinue(_ sender: UIButton) {
        eventHandler?.handleEvent(.continueProcess)
    }

}

extension TermsViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        let safariViewController = SFSafariViewController(url: URL)
        present(safariViewController, animated: true, completion: nil)

        return false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
