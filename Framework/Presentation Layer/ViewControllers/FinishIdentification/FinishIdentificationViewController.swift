//
//  FinishIdentificationViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which displays finish indetification screen.
final internal class FinishIdentificationViewController: SolarisViewController {

    var viewModel: FinishIdentificationViewModel!

    enum Constants {
        enum FontSize {
            static let big: CGFloat = 26
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

    private lazy var titleLabel: UILabel = {
        let label = UILabel()
        label.textColor = .black
        label.font = label.font.withSize(Constants.FontSize.big)
        label.text = Localizable.FinishIdentification.identificationSuccessful
        return label
    }()

    private lazy var descriptionLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.textColor = UIColor.sdkColor(.base75)
        label.font = label.font.withSize(Constants.FontSize.normal)
        label.text = Localizable.FinishIdentification.description
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
        button.setTitle(Localizable.FinishIdentification.finish, for: .normal)
        button.currentAppearance = .dimmed
        button.isEnabled = false
        return button
    }()

    private var documentCell: DocumentTableViewCell?

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        containerView.addSubviews([
            titleLabel,
            descriptionLabel,
            documentsTableView,
            downloadAllDocumentsButton,
            actionButton
        ])

        titleLabel.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.extended),
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

        actionButton.addTarget(self, action: #selector(finish), for: .touchUpInside)
    }

    @objc private func finish() {
        viewModel.finish()
    }
}

// MARK: DocumentReceivable methods

extension FinishIdentificationViewController: DocumentReceivable {
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

extension FinishIdentificationViewController: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        guard viewModel?.documents.count != nil else { return 0 }
        return viewModel.documents.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        guard let cell = tableView.dequeueReusableCell(withIdentifier: DocumentTableViewCell.ReuseIdentifier, for: indexPath) as? DocumentTableViewCell else {
            return UITableViewCell()
        }
        let document = viewModel.documents[indexPath.row]
        cell.setCell(document: document, isDocumentSigned: true)
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
