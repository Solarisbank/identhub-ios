//
//  WelcomeViewController.swift
//  Fourthline
//

import UIKit
import IdentHubSDKCore
import SafariServices

private let fourthlinePrivacyLink = "https://api.fourthline.com/v1/qualifiedElectronicSignature/legal/PrivacyStatement_SafeNedFourthline_1.0.pdf"

internal struct WelcomeState: Equatable {
    static func == (lhs: WelcomeState, rhs: WelcomeState) -> Bool {
        return true
    }
    
    enum State: Equatable {
        case none
        case loadScreen
        case namirialTCAccepted
        case error
    }
    var onDisplayError: Error? = .none
    var state: State = .loadScreen
    var isDisplayNamirialTerms: Bool = false
    var isORCA: Bool = false
}

internal enum WelcomeEvent {
    case loadScreen
    case triggerStart
    case configurePageScroller(_ pageScroller: UICollectionView)
    case setPageController(_ pageController: UIPageControl)
    case setLogoAnimator(_ animator: WelcomeLogoAnimator)
    case close(error: APIError)
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
    @IBOutlet var termsContainerView: UIView!
    @IBOutlet var checkBoxBtn: Checkbox!
    @IBOutlet var namirialTermsLabel: UITextView!
    @IBOutlet private var termsHeightConstraint: NSLayoutConstraint!
    @IBOutlet var orcaView: UIView!
    @IBOutlet var orcaDescriptionLabel: UILabel!
    @IBOutlet var cameraInfoLabel: UILabel!
    @IBOutlet var locationInfoLabel: UILabel!
    
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
    
    // MARK: - Action methods -
    @IBAction func didClickCheckmark(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            startBtn.currentAppearance = .inactive
        } else {
            sender.isSelected = true
            startBtn.currentAppearance = .primary
        }
    }
    
    // MARK: - Internal methods -
    
    func updateView(_ state: WelcomeState) {
        switch state.state {
        case .loadScreen:
            
            if state.isORCA {
                self.setOrcaUI()
            } else {
                orcaView.isHidden = true
                eventHandler?.handleEvent(.configurePageScroller(pageScroller))
                eventHandler?.handleEvent(.setPageController(pageController))
                eventHandler?.handleEvent(.setLogoAnimator(logoAnimator))
            }
            
            if state.isDisplayNamirialTerms {
                termsHeightConstraint.constant = 45
                termsContainerView.isHidden = false
            } else {
                startBtn.setAppearance(.primary, colors: colors)
            }
        case .namirialTCAccepted:
            startBtn.currentAppearance = .verifying
        case .error:
            startBtn.setTitle(Localizable.Welcome.startBtn, for: .normal)
            startBtn.currentAppearance = .primary
            if let error = state.onDisplayError as? ResponseError {
                requestFailed(with: error)
            }
        default:
            startBtn.setTitle(Localizable.Welcome.startBtn, for: .normal)
            startBtn.currentAppearance = .primary
        }
        
    }
    
    private func setOrcaUI() {
        pageController.isHidden = true
        pageScroller.isHidden = true
        logoBackground.isHidden = true
        logoImage.isHidden = true
        logoFrame.isHidden = true
        orcaView.isHidden = false
        
        welcomeLabel.text = Localizable.OrcaWelcome.pageTitle
        orcaDescriptionLabel.text = Localizable.OrcaWelcome.description
        orcaDescriptionLabel.setLabelStyle(.subtitle)
        cameraInfoLabel.text = Localizable.OrcaWelcome.cameraInfo
        cameraInfoLabel.setLabelStyle(.subtitle)
        locationInfoLabel.text = Localizable.OrcaWelcome.locationInfo
        locationInfoLabel.setLabelStyle(.subtitle)
    }
    
    private func requestFailed(with error: ResponseError) {
        var message = error.apiError.text()
        
        #if ENV_DEBUG
        message += "\n\(error.detailDescription)"
        #endif
        
        presentAlert(with: Localizable.APIErrorDesc.requestError, message: message, action: Localizable.Common.tryAgain, error: error.apiError) {
        }
    }
    
    private func presentAlert(with title: String, message: String, action: String, error: APIError, callback: @escaping () -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let reactionAction = UIAlertAction(title: action, style: .default, handler: {_ in
            callback()
        })
        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.eventHandler?.handleEvent(.close(error: error))
        })
        
        alert.addAction(reactionAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
}

extension WelcomeViewController {
    
    private func configureUI() {
        
        pageController.subviews.forEach {
            $0.transform = CGAffineTransform(scaleX: 1.5, y: 1.5)
        }
        
        welcomeLabel.text = Localizable.Welcome.pageTitle
        welcomeLabel.setLabelStyle(.title)
        startBtn.setTitle(Localizable.Welcome.startBtn, for: .normal)
        startBtn.setAppearance(.inactive, colors: colors)
        acknowledgementLabel.attributedText = buildAcknowledgementText()
        acknowledgementLabel.linkTextAttributes = [
            .foregroundColor: colors[.primaryAccent],
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        acknowledgementLabel.setTextViewStyle()
        acknowledgementLabel.delegate = self
        configureCustomUI()
        
        termsContainerView.isHidden = true
        checkBoxBtn.setAppearance(colors)
        namirialTermsLabel.translatesAutoresizingMaskIntoConstraints = true
        namirialTermsLabel.isScrollEnabled = false
        namirialTermsLabel.attributedText = buildNamirialTermsText()
        namirialTermsLabel.linkTextAttributes = [
            .foregroundColor: colors[.primaryAccent],
            .underlineStyle: NSUnderlineStyle.single.rawValue
        ]
        namirialTermsLabel.setTextViewStyle()
        namirialTermsLabel.delegate = self
        namirialTermsLabel.sizeToFit()
    }

    private func configureCustomUI() {
        logoBackground.layer.masksToBounds = true
        logoBackground.backgroundColor = colors[.primaryAccent]
        pageController.pageIndicatorTintColor = colors[.labelText]
        pageController.currentPageIndicatorTintColor = colors[.primaryAccent]
    }
    
    private func buildAcknowledgementText() -> NSAttributedString {
        let fullText = Localizable.Welcome.acknowledgement
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [NSAttributedString.Key.font: namirialTermsLabel.font!])

        let linkRange: NSRange
        if let privacyLinkRange = fullText.range(of: Localizable.Welcome.fourthlinePrivacy) {
            linkRange = NSRange(privacyLinkRange, in: fullText)
        } else {
            linkRange = NSRange(location: 0, length: fullText.count)
        }
        attributedString.addAttribute(.link, value: fourthlinePrivacyLink, range: linkRange)

        return attributedString
    }
    
    private func buildNamirialTermsText() -> NSAttributedString {
        let fullText = Localizable.Welcome.namirialTerms
        let attributedString = NSMutableAttributedString(string: fullText, attributes: [NSAttributedString.Key.font: acknowledgementLabel.font!])

        let linkRange: NSRange
        if let termsLinkRange = fullText.range(of: Localizable.Welcome.termsConditions) {
            linkRange = NSRange(termsLinkRange, in: fullText)
        } else {
            linkRange = NSRange(location: 0, length: fullText.count)
        }
        let namirialTCurl = KYCContainer.shared.getNamirialTermsConditions()?.url ?? ""
        attributedString.addAttribute(.link, value: namirialTCurl, range: linkRange)

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
