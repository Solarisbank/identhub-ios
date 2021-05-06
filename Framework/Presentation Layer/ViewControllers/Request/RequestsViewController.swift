//
//  UploadViewController.swift
//  IdentHubSDK
//

import UIKit
import FourthlineKYC

class RequestsViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var stepProgressView: StepsProgressView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var progressTableView: UITableView!
    @IBOutlet var progressView: CircleProgressView!

    // MARK: - Private attributes -
    private var viewModel: RequestsViewModel

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: RequestsViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "RequestsViewController", bundle: Bundle.current)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    override var prefersStatusBarHidden: Bool {
        true
    }
}

// MARK: - Inernal methods -

extension RequestsViewController {

    private func configureUI() {

        stepProgressView.datasource = viewModel
        progressView.defaultProgress = 0.15

        viewModel.configure(of: progressTableView)

        viewModel.onTableUpdate = { [weak self] in
            guard let `self` = self else { return }

            DispatchQueue.main.async {
                self.progressTableView.reloadData()
            }
        }

        viewModel.onDisplayError = { [weak self] error in
            guard let `self` = self else { return }

            DispatchQueue.main.async {
                if let zipError = error as? ZipperError {
                    self.zipFailed(with: zipError)
                }
            }
        }

        self.titleLbl.text = viewModel.obtainScreenTitle()
        self.descriptionLbl.text = viewModel.obtainScreenDescription()
    }

    private func zipFailed(with error: ZipperError) {
        let message = KYCZipService.text(for: error)
        let alert = UIAlertController(title: Localizable.Zipper.Error.alertTitle, message: message, preferredStyle: .alert)
        alert.addAction(UIAlertAction(title: "OK", style: .cancel))

        present(alert, animated: true)
    }
}
