//
//  ConfirmApplicationViewController.swift
//  IdentHubSDK
//

import UIKit
import SafariServices

/// UIViewController which displays screen with the documents to read and sign later.
final internal class ConfirmApplicationViewController: UIViewController, Quitable {

    // MARK: - Outlets -
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var documentsTableView: UITableView!
    @IBOutlet var termsAndConditionsLabel: UITextView!
    @IBOutlet var actionButton: ActionRoundedButton!
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!
    
    // MARK: - Properties -

    var viewModel: ConfirmApplicationViewModel!

    private let documentExporter: DocumentExporter = DocumentExporterService()
    private var documentCell: DocumentViewCell?
    private let rowHeight: CGFloat = 61
    private let progressHeight: CGFloat = 89

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: ConfirmApplicationViewModel) {
        self.viewModel = viewModel

        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -
    
    override func loadView() {
        super.loadView()
        
        viewModel.loadDocuments()
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {

        titleLabel.text = Localizable.SignDocuments.ConfirmApplication.confirmYourApplication
        descriptionLabel.text = Localizable.SignDocuments.ConfirmApplication.description

        headerView.style = viewModel.isInvisibleProgress() ? .none : .quit(target: self)

        let cellNib = UINib(nibName: "DocumentViewCell", bundle: Bundle(for: Self.self))
        documentsTableView.register(cellNib, forCellReuseIdentifier: DocumentViewCell.ReuseIdentifier)
        documentsTableView.estimatedRowHeight = rowHeight
        
        /// Note: This line will only be here in the case of 'method_bank')
        if viewModel.hasTermsAndConditionsLink {
            termsAndConditionsLabel.delegate = self
            termsAndConditionsLabel.isHidden = false
            termsAndConditionsLabel.attributedText = buildTermsConditionsText()
            termsAndConditionsLabel.linkTextAttributes = [
                .foregroundColor: UIColor.sdkColor(.primaryAccent)
            ]
            termsAndConditionsLabel.textColor = .sdkColor(.base75)
        }
        
        actionButton.setTitle(Localizable.Common.next, for: .normal)
        actionButton.currentAppearance = .dimmed
    }
    
    private func buildTermsConditionsText() -> NSAttributedString {
        let fullText = Localizable.SignDocuments.ConfirmApplication.termsAndConditionsFootnote
        let attributedString = NSMutableAttributedString(string: fullText)
        let font = UIFont.systemFont(ofSize: UIFont.systemFontSize, weight: .regular)
        
        if let termsRange = fullText.range(of: "Swisscom") {
            let attrRange = NSRange(termsRange, in: fullText)
            attributedString.addAttribute(.link, value: termsLink, range: attrRange)
            let boldFontAttribute: [NSAttributedString.Key: Any] = [NSAttributedString.Key.font: UIFont.boldSystemFont(ofSize: font.pointSize)]
            attributedString.addAttributes(boldFontAttribute, range: attrRange)
        }

        return attributedString
    }

    // MARK: - Action methods -

    @IBAction func signDocuments() {
        viewModel.signDocuments()

        actionButton.isEnabled = false
    }
    
    @IBAction func didClickQuit(_ sender: Any) {
        viewModel.quit()
    }
}

// MARK: ConfirmApplicationViewModelDelegate methods

extension ConfirmApplicationViewController: DocumentReceivable {

    func didFetchDocuments() {
        documentsTableView.reloadData()
        actionButton.currentAppearance = .primary
        let numberOfCells = CGFloat(viewModel.documents.count)
        tableHeightConstraint.constant = numberOfCells * rowHeight
    }

    func didFinishLoadingDocument() {
        documentCell?.didFinishDownloading()
    }
}

// MARK: UITableViewDataSource methods

extension ConfirmApplicationViewController: UITableViewDataSource {
    
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel?.documents.count != nil else { return 0 }
        return viewModel.documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentViewCell.ReuseIdentifier, for: indexPath) as? DocumentViewCell else {
            return UITableViewCell()
        }
        let document = viewModel.documents[indexPath.row]
        cell.previewAction = {[weak self] cell in

            self?.documentCell = cell
            self?.viewModel.previewDownloadedDocument(withId: document.id)
        }

        cell.downloadAction = {[weak self] cell in

            self?.documentCell = cell
            self?.viewModel.exportDocument(withId: document.id)
        }
        
        cell.configure(with: document)

        return cell
    }
}

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
