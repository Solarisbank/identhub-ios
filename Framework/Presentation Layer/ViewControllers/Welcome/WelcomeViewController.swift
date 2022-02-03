//
//  WelcomeViewController.swift
//  IdentHubSDK
//

import UIKit
import SafariServices

private let fourthlinePrivacyLink = "https://api.fourthline.com/v1/qualifiedElectronicSignature/legal/PrivacyStatement_SafeNedFourthline_1.0.pdf"

/// Class for managing welcome screen UI components
/// Class based on SolarisViewController, because used company copyrights view
class WelcomeViewController: UIViewController {

    // MARK: - Properties -
    @IBOutlet var welcomeLabel: UILabel!
    @IBOutlet var pageController: UIPageControl!
    @IBOutlet var pageScroller: UICollectionView!
    @IBOutlet var logoBackground: UIImageView!
    @IBOutlet var logoImage: UIImageView!
    @IBOutlet var logoFrame: UIImageView!
    @IBOutlet var startBtn: ActionRoundedButton!
    @IBOutlet var acknowledgementLabel: UITextView!
    
    private var viewModel: WelcomeViewModel!
    private lazy var logoAnimator: WelcomeLogoAnimator = {
        return WelcomeLogoAnimator(logoImage, logoFrameImage: logoFrame)
    }()

    // MARK: - Init methods -

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: WelcomeViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "WelcomeViewController", bundle: Bundle(for: WelcomeViewController.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -
    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        logoBackground.layer.cornerRadius = logoBackground.frame.width / 2
    }

    // MARK: - Internal methods -

    private func configureUI() {

        pageController.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 2, y: 2)
        }

        viewModel.configurePageScroller(pageScroller)
        viewModel.setPageController(pageController)
        viewModel.setLogoAnimator(logoAnimator)

        welcomeLabel.text = Localizable.Welcome.pageTitle
        startBtn.setTitle(Localizable.Welcome.startBtn, for: .normal)
        acknowledgementLabel.attributedText = buildAcknowledgementText()
        acknowledgementLabel.linkTextAttributes = [
            .foregroundColor: UIColor.sdkColor(.primaryAccent),
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        acknowledgementLabel.textColor = UIColor.sdkColor(.base50)
        acknowledgementLabel.delegate = self
        configureCustomUI()
    }

    private func configureCustomUI() {

        startBtn.currentAppearance = .primary
        logoBackground.layer.masksToBounds = true
        logoBackground.backgroundColor = .sdkColor(.primaryAccent)
        pageController.pageIndicatorTintColor = .sdkColor(.black25)
        pageController.currentPageIndicatorTintColor = .sdkColor(.primaryAccent)
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

    // MARK: - Actions methods -

    @IBAction func didClickStartBtn(_ sender: UIButton) {
        viewModel.didTriggerStart()
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
