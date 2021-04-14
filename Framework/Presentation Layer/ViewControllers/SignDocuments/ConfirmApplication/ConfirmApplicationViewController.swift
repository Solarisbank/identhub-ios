//
//  ConfirmApplicationViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays screen with the documents to read and sign later.
final internal class ConfirmApplicationViewController: SolarisViewController {

    var viewModel: ConfirmApplicationViewModel!

    enum Constants {
        enum FontSize {
            static let big: CGFloat = 20
            static let normal: CGFloat = 14
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let normal: CGFloat = 24
            static let sides: CGFloat = 16
        }

        enum Size {
            static let rowHeight: CGFloat = 54
        }
    }

    private lazy var currentStepView: IdentificationProgressView = {
        let view = IdentificationProgressView(currentStep: .documents)
        return view
    }()

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = UIColor.sdkColor(.base100)
        label.font = label.font.withSize(Constants.FontSize.big)
        label.text = Localizable.SignDocuments.ConfirmApplication.confirmYourApplication
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.sdkColor(.base75)
        label.font = label.font.withSize(Constants.FontSize.normal)
        label.text = Localizable.SignDocuments.ConfirmApplication.description
        return label
    }()

    private lazy var documentsTableView: UITableView = {
        let tableView = UITableView()
        tableView.separatorStyle = .none
        tableView.rowHeight = UITableView.automaticDimension
        tableView.estimatedRowHeight = Constants.Size.rowHeight
        tableView.allowsSelection = false
        tableView.showsVerticalScrollIndicator = false
        tableView.isScrollEnabled = false
        tableView.dataSource = self
        tableView.register(DocumentTableViewCell.self, forCellReuseIdentifier: DocumentTableViewCell.ReuseIdentifier)
        return tableView
    }()

    private lazy var downloadAllDocumentsButton: DownloadDocumentsButton = {
        let button = DownloadDocumentsButton()
        button.downloadAllDocumentsAction = { self.viewModel.downloadAndSaveAllDocuments() }
        button.isEnabled = false
        return button
    }()

    private lazy var actionButton: ActionRoundedButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.SignDocuments.ConfirmApplication.sendCodeToSign, for: .normal)
        button.currentAppearance = .dimmed
        button.isEnabled = false
        return button
    }()

    private let documentExporter: DocumentExporter = DocumentExporterService()
    private var documentCell: DocumentTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        containerView.addSubviews([
            currentStepView,
            titleLabel,
            descriptionLabel,
            documentsTableView,
            downloadAllDocumentsButton,
            actionButton
        ])

        currentStepView.addConstraints { [
            $0.equal(.top),
            $0.equal(.leading),
            $0.equal(.trailing)
        ]
        }

        titleLabel.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.sides),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sides)
        ]
        }

        descriptionLabel.addConstraints { [
            $0.equalTo(titleLabel, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.sides),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sides)
        ]
        }

        documentsTableView.addConstraints { [
            $0.equalTo(descriptionLabel, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading),
            $0.equal(.trailing)
        ]
        }

        downloadAllDocumentsButton.addConstraints { [
            $0.equalTo(documentsTableView, .top, .bottom, constant: Constants.ConstraintsOffset.sides),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sides)
        ]
        }

        actionButton.addConstraints { [
            $0.equalTo(downloadAllDocumentsButton, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.sides),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sides),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended)
        ]
        }

        actionButton.addTarget(self, action: #selector(signDocuments), for: .touchUpInside)
    }

    @objc private func signDocuments() {
        viewModel.signDocuments()

        actionButton.isEnabled = false
    }
}

// MARK: ConfirmApplicationViewModelDelegate methods

extension ConfirmApplicationViewController: DocumentReceivable {
    func didFetchDocuments() {
        documentsTableView.reloadData()
        downloadAllDocumentsButton.isEnabled = true
        actionButton.currentAppearance = .orange
        let numberOfCells = CGFloat(viewModel.documents.count)
        documentsTableView.addConstraints { [
            $0.equalConstant(.height, Constants.Size.rowHeight * numberOfCells)
        ]
        }
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
