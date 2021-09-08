//
//  ConfirmApplicationViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays screen with the documents to read and sign later.
final internal class ConfirmApplicationViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var currentStepView: IdentificationProgressView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var documentsTableView: UITableView!
    @IBOutlet var downloadAllDocumentsButton: DownloadDocumentsButton!
    @IBOutlet var actionButton: ActionRoundedButton!
    @IBOutlet var tableHeightConstraint: NSLayoutConstraint!

    // MARK: - Properties -

    var viewModel: ConfirmApplicationViewModel!

    private let documentExporter: DocumentExporter = DocumentExporterService()
    private var documentCell: DocumentTableViewCell?
    private let rowHeight: CGFloat = 54

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

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {

        titleLabel.text = Localizable.SignDocuments.ConfirmApplication.confirmYourApplication
        descriptionLabel.text = Localizable.SignDocuments.ConfirmApplication.description

        currentStepView.setCurrentStep(.documents)

        documentsTableView.register(DocumentTableViewCell.self, forCellReuseIdentifier: DocumentTableViewCell.ReuseIdentifier)

        actionButton.setTitle(Localizable.SignDocuments.ConfirmApplication.sendCodeToSign, for: .normal)
        actionButton.currentAppearance = .dimmed

        downloadAllDocumentsButton.downloadAllDocumentsAction = {
            self.viewModel.downloadAndSaveAllDocuments()
        }
    }

    // MARK: - Action methods -

    @IBAction func signDocuments() {
        viewModel.signDocuments()

        actionButton.isEnabled = false
    }
}

// MARK: ConfirmApplicationViewModelDelegate methods

extension ConfirmApplicationViewController: DocumentReceivable {

    func didFetchDocuments() {
        documentsTableView.reloadData()
        downloadAllDocumentsButton.isEnabled = true
        actionButton.currentAppearance = .primary
        let numberOfCells = CGFloat(viewModel.documents.count)
        tableHeightConstraint.constant = numberOfCells * rowHeight
    }

    func didFinishLoadingDocument() {
        documentCell?.stopActivityAnimation()
    }

    func didFinishLoadingAllDocuments() {
        downloadAllDocumentsButton.stopAnimation()
    }
}

// MARK: UITableViewDataSource methods

extension ConfirmApplicationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel?.documents.count != nil else { return 0 }
        return viewModel.documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentTableViewCell.ReuseIdentifier, for: indexPath) as? DocumentTableViewCell else {
            return UITableViewCell()
        }
        let document = viewModel.documents[indexPath.row]
        cell.setCell(document: document, isDocumentSigned: false)
        cell.previewAction = {[weak self] cell in

            self?.documentCell = cell
            self?.viewModel.previewDownloadedDocument(withId: document.id)
        }

        cell.downloadAction = {[weak self] cell in

            self?.documentCell = cell
            self?.viewModel.exportDocument(withId: document.id)
        }

        return cell
    }
}
