//
//  ConfirmApplicationViewController.swift
//  IdentHubSDK
//

import UIKit
import SafariServices
import IdentHubSDKCore

/// UIViewController which displays screen with the documents to read and sign later.
final internal class ConfirmApplicationViewController: UIViewController, Quitable, Updateable {
    
    typealias ViewState = ConfirmApplicationState
    typealias EventHandler = ConfirmApplicationEventHandler

    // MARK: - Properties -

    var eventHandler: ConfirmApplicationEventHandler?

    private let rowHeight: CGFloat = 61
    private let progressHeight: CGFloat = 89
    private var dataSource: TableViewDataSource<LoadableDocument, DocumentViewCell>!
    private var colors: Colors

    // MARK: - Outlets -
    @IBOutlet private var headerView: HeaderView!
    @IBOutlet private var titleLabel: UILabel!
    @IBOutlet private var descriptionLabel: UILabel!
    @IBOutlet private var documentsTableView: UITableView!
    @IBOutlet private var termsAndConditionsLabel: UITextView!
    @IBOutlet private var actionButton: ActionRoundedButton!
    @IBOutlet private var tableHeightConstraint: NSLayoutConstraint!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: ConfirmApplicationEventHandler) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
        eventHandler?.loadDocuments()
    }

    // MARK: - Update -
    func updateView(_ state: ConfirmApplicationState) {
        loadViewIfNeeded()

        dataSource.elements = state.documents

        headerView.setStyle(state.hasQuitButton ? .quit(target: self) : .none)
        actionButton.setAppearance(state.documents.isEmpty ? .dimmed : .primary, colors: colors)

        updateTermsAndConditionsLink(
            hasTermsAndConditionsLink: state.hasTermsAndConditionsLink,
            colors: colors
        )
    }

    private func updateTermsAndConditionsLink(
        hasTermsAndConditionsLink: Bool,
        colors: Colors
    ) {
        /// Note: This line will only be here in the case of 'method_bank')
        if hasTermsAndConditionsLink {
            termsAndConditionsLabel.delegate = self
            termsAndConditionsLabel.isHidden = false
            termsAndConditionsLabel.attributedText = buildTermsConditionsText()
            termsAndConditionsLabel.linkTextAttributes = [
                .foregroundColor: colors[.primaryAccent]
            ]
            termsAndConditionsLabel.textColor = colors[.base75]
        }
    }

    private func configureUI() {
        configureTableView()

        titleLabel.text = Localizable.SignDocuments.ConfirmApplication.confirmYourApplication
        descriptionLabel.text = Localizable.SignDocuments.ConfirmApplication.description
                
        actionButton.setTitle(Localizable.Common.next, for: .normal)
    }
    
    private func configureTableView() {
        dataSource = TableViewDataSource<LoadableDocument, DocumentViewCell>(configure: { [weak self] loadableDocument, cell in
            guard let self = self else {
                Assert.notNil(self)
                return
            }

            cell.configure(with: loadableDocument.document)
            
            cell.previewAction = { [weak self] in
                self?.eventHandler?.previewDocument(withId: loadableDocument.document.id)
            }
            cell.downloadAction = { [weak self] in
                self?.eventHandler?.downloadDocument(withId: loadableDocument.document.id)
            }
            cell.state = loadableDocument.isLoading ? .downloading : .normal
        })
        dataSource.register(on: documentsTableView, bundle: Bundle(for: Self.self))
        documentsTableView.estimatedRowHeight = rowHeight
    }

    private func buildTermsConditionsText() -> NSAttributedString {
        let fullText = Localizable.SignDocuments.ConfirmApplication.termsAndConditionsFootnote
        let attributedString = NSMutableAttributedString(string: fullText)
        let font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        
        if let termsRange = fullText.range(of: "Swisscom") {
            let attrRange = NSRange(termsRange, in: fullText)
            attributedString.addAttribute(.link, value: Constants.termsLink, range: attrRange)
            let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
            attributedString.addAttributes(boldFontAttribute, range: attrRange)
        }

        return attributedString
    }

    // MARK: - Action methods -

    @IBAction func signDocuments() {
        eventHandler?.signDocuments()
        actionButton.isEnabled = false
    }
    
    @IBAction func didClickQuit(_ sender: Any) {
        eventHandler?.quit()
    }
}

private extension ConfirmApplicationViewController {
    enum Constants {
        static var termsLink: String {
            "https://www.solarisbank.com/en/customer-information/"
        }
    }
}

// MARK: UITableViewDataSource methods

extension ConfirmApplicationViewController: UITextViewDelegate {
    func textView(_ textView: UITextView, shouldInteractWith URL: URL, in characterRange: NSRange, interaction: UITextItemInteraction) -> Bool {

        let safariViewController = SFSafariViewController(url: URL)
        present(safariViewController, animated: true, completion: nil)

        return false
    }

    func textViewDidChangeSelection(_ textView: UITextView) {
        textView.selectedTextRange = nil
    }
}
