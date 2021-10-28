//
//  DocumentScannerViewController.swift
//  IdentHubSDK
//

import UIKit

class DocumentPickerViewController: UIViewController {

    // MARK: - Init methods -
    @IBOutlet var stepsProgressView: StepsProgressView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var continueBtn: ActionRoundedButton!
    @IBOutlet var documentTypesTable: UITableView!
    @IBOutlet var tableViewConstraint: NSLayoutConstraint!
    private var viewModel: DocumentPickerViewModel!

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: DocumentPickerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "DocumentPickerViewController", bundle: Bundle(for: DocumentPickerViewController.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    // MARK: - Action methods -

    @IBAction func didClickContinue(_ sender: UIButton) {

        viewModel.startDocumentScanner()
    }

    @IBAction func didClickQuit(_ sender: UIButton) {

        viewModel.didTriggerQuit()
    }

    // MARK: - Internal methods -
    private func configureUI() {

        stepsProgressView.datasource = viewModel

        titleLbl.text = Localizable.DocumentScanner.title
        descriptionLbl.text = Localizable.DocumentScanner.description
        continueBtn.setTitle(Localizable.Common.continueBtn, for: .normal)
        continueBtn.currentAppearance = .inactive
        quitBtn.setTitle(Localizable.Common.quit, for: .normal)

        viewModel.configureDocumentsTable(for: documentTypesTable)

        tableViewConstraint.constant = viewModel.obtainTableHeight()

        viewModel.updateButtons = {[unowned self] in
            self.continueBtn.currentAppearance = .primary
        }
    }
}
