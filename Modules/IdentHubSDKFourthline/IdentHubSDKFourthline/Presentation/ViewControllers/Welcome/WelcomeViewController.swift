//
//  WelcomeViewController.swift
//  Fourthline
//

import UIKit
import IdentHubSDKCore
import SafariServices

private let fourthlinePrivacyLink = "https://api.fourthline.com/v1/qualifiedElectronicSignature/legal/PrivacyStatement_SafeNedFourthline_1.0.pdf"

internal struct WelcomeState: Equatable {
    enum State: Equatable {
        case loadScreen
    }
    var state: State = .loadScreen
}

internal enum WelcomeEvent {
    case loadScreen
    case triggerStart
    case configurePageScroller(_ pageScroller: UICollectionView)
    case setPageController(_ pageController: UIPageControl)
    case setLogoAnimator(_ animator: WelcomeLogoAnimator)
}

/// UIViewController for managing welcome screen UI components for Fourthline flow.
/// Class based on SolarisViewController, because used company copyrights view
final internal class WelcomeViewController: UIViewController, Updateable {

    typealias ViewState = WelcomeState
    
    // MARK: - Properties -

    var eventHandler: AnyEventHandler<WelcomeEvent>?
    private var colors: Colors
    
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var pageScroller: UICollectionView!
    @IBOutlet var logoBackground: UIImageView!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var logoFrame: UIImageView!
    @IBOutlet var startBtn: ActionRoundedButton!
    @IBOutlet var acknowledgementLabel: UITextView!
    
    private lazy var logoAnimator: WelcomeLogoAnimator = {
        return WelcomeLogoAnimator(logoImage, logoFrameImage: logoFrame)
    }()
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<WelcomeEvent>) {
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
        eventHandler?.handleEvent(.loadScreen)
    }
    
    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoBackground.layer.cornerRadius = logoBackground.frame.width / 2
    }

    // MARK: - Actions methods -

    @IBAction func didClickStartBtn(_ sender: UIButton) {
        eventHandler?.handleEvent(.triggerStart)
    }
    
    // MARK: - Internal methods -
    
    func updateView(_ state: WelcomeState) {
        eventHandler?.handleEvent(.configurePageScroller(pageScroller))
        eventHandler?.handleEvent(.setPageController(pageController))
        eventHandler?.handleEvent(.setLogoAnimator(logoAnimator))
    }

}

extension WelcomeViewController {
    
    private func configureUI() {
        
        pageController.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 2, y: 2)
        }
        
        welcomeLabel.text = Localizable.Welcome.pageTitle
        startBtn.setTitle(Localizable.Welcome.startBtn, for: .normal)
        startBtn.setAppearance(.primary, colors: colors)
        acknowledgementLabel.attributedText = buildAcknowledgementText()
        acknowledgementLabel.linkTextAttributes = [
            .foregroundColor: colors[.primaryAccent],
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        acknowledgementLabel.textColor = colors[.base50]
        acknowledgementLabel.delegate = self
        configureCustomUI()
    }

    private func configureCustomUI() {
        startBtn.currentAppearance = .primary
        logoBackground.layer.masksToBounds = true
        logoBackground.backgroundColor = colors[.primaryAccent]
        pageController.pageIndicatorTintColor = colors[.black25]
        pageController.currentPageIndicatorTintColor = colors[.primaryAccent]
    }
    
    private func buildAcknowledgementText() -> NSAttributedString {
        let fullText = Localizable.Welcome.acknowledgement
        let attributedString = NSMutableAttributedString(string: fullText)

        let linkRange: NSRange
        if let privacyLinkRange = fullText.range(of: Localizable.Welcome.fourthlinePrivacy) {
            linkRange = NSRange(privacyLinkRange, in: fullText)
        } else {
            linkRange = NSRange(location: 0, length: fullText.count)
        }
        attributedString.addAttribute(.link, value: fourthlinePrivacyLink, range: linkRange)

        return attributedString
    }
}

extension WelcomeViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        let safariViewController = SFSafariViewController(url: URL)
        present(safariViewController, animated: true, completion: nil)

        return false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}