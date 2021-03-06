//
//  DocumentInfoViewController.swift
//  IdentHubSDK
//

import UIKit

class DocumentInfoViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var stepsProgressView: StepsProgressView!
    @IBOutlet var docInfoTable: UITableView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var continueBtn: UIButton!
    @IBOutlet var warningLbl: UILabel!

    // MARK: - Private attributes -
    private var viewModel: DocumentInfoViewModel

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: DocumentInfoViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "DocumentInfoViewController", bundle: Bundle.current)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()

        handleUIUpdates()
        configureUI()
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    // MARK: - Actions methods -

    @IBAction func didClickBack(_ sender: UIButton) {
        viewModel.didTriggerBack()
    }

    @IBAction func didClickContinue(_ sender: UIButton) {
        viewModel.didTriggerContinue()
    }
}

// MARK: - Internal methods -

extension DocumentInfoViewController {

    private func configureUI() {

        stepsProgressView.datasource = viewModel

        viewModel.configure(of: docInfoTable)

        typealias InfoText = Localizable.DocumentScanner.Information

        titleLbl.text = InfoText.title
        warningLbl.text = InfoText.warning
        quitBtn.titleLabel?.text = Localizable.Common.back
        continueBtn.titleLabel?.text = Localizable.Common.continueBtn
    }

    private func handleUIUpdates() {

        viewModel.didUpdatedContent = { [unowned self] enable in
            self.updateContinueBtnEnableState(enable: enable)
        }

        viewModel.reloadTable = { [weak self] in
            self?.docInfoTable.reloadData()
        }
    }

    private func updateContinueBtnEnableState(enable: Bool) {

        UIView.animate(withDuration: 0.4) { [weak self] in
            self?.continueBtn.alpha = enable ? 1.0 : 0.5
            self?.continueBtn.isEnabled = enable
        }
    }
}
