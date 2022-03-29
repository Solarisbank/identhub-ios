//
//  ConfirmApplicationViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays screen with the documents to read and sign later.
final internal class ConfirmApplicationViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var currentStepView: IdentificationProgressView!
    @IBOutlet var progressViewHeight: NSLayoutConstraint!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var documentsTableView: UITableView!
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

        progressViewHeight.constant = ( viewModel.isInvisibleProgress() ) ? 0 : progressHeight
        currentStepView.isHidden = viewModel.isInvisibleProgress()
        currentStepView.setCurrentStep(.documents)

        let cellNib = UINib(nibName: "DocumentViewCell", bundle: Bundle(for: Self.self))
        documentsTableView.register(cellNib, forCellReuseIdentifier: DocumentViewCell.ReuseIdentifier)
        documentsTableView.estimatedRowHeight = rowHeight

        actionButton.setTitle(Localizable.SignDocuments.ConfirmApplication.sendCodeToSign, for: .normal)
        actionButton.currentAppearance = .dimmed
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
