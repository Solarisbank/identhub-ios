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
    private var viewModel: RequestsViewModel!

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

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        progressView.configureUI()
    }
}

// MARK: - Inernal methods -

private extension RequestsViewController {

    private func configureUI() {

        stepProgressView.datasource = viewModel
        progressView.defaultProgress = 0.15

        viewModel.configure(of: progressTableView)

        viewModel.onTableUpdate = { [weak self] in
            guard let `self` = self else { return }

            DispatchQueue.main.async {
                self.progressTableView.reloadData()
                self.progressTableView.scrollToBottom()
            }
        }

        viewModel.onDisplayError = { [weak self] error in
            guard let `self` = self else { return }

            DispatchQueue.main.async {
                if let zipError = error as? ZipperError {
                    self.zipFailed(with: zipError)
                } else if let err = error as? APIError {
                    self.displayError(err)
                }
            }
        }

        viewModel.onRetry = { [weak self] status in
            guard let `self` = self else { return }

            DispatchQueue.main.async {
                self.presentAlert(with: Localizable.Verification.title, message: Localizable.APIErrorDesc.unprocessableEntity, action: Localizable.Common.tryAgain, error: .unprocessableEntity) { [weak self] in
                    self?.viewModel.didTriggerRetry(status: status)
                }
            }
        }

        self.titleLbl.text = viewModel.obtainScreenTitle()
        self.descriptionLbl.text = viewModel.obtainScreenDescription()
    }

    private func displayError(_ error: APIError) {

        switch error {
        case .locationError,
             .locationAccessError:
            self.locationFailed(with: error)
        case .identificationDataInvalid(_):
            identificationFailed(with: error)
        case .fraudData(let err):
            viewModel.abortIdentProcess(.fraudData(error: err))
        default:
            self.requestFailed(with: error)
        }
    }

    private func zipFailed(with error: ZipperError) {
        let message = KYCZipService.text(for: error)
        let alert = UIAlertController(title: Localizable.Zipper.Error.alertTitle, message: message, preferredStyle: .alert)

        let errorType = KYCZipService.zipErrorType(for: error)

        if errorType == .invalidDocument || errorType == .invalidSelfie {
            let retryAction = UIAlertAction(title: Localizable.Common.tryAgain, style: .default) { [weak self] _ in
                self?.viewModel.didTriggerRetry(errorType: errorType)
            }

            alert.addAction(retryAction)
        }

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.viewModel.didTriggerQuit()
        })

        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func locationFailed(with error: APIError) {
        presentAlert(with: Localizable.Location.Error.title, message: error.text(), action: Localizable.Common.settings, error: error) {
            UIApplication.openAppSettings()
        }
    }

    private func identificationFailed(with error: APIError) {
        let alert = UIAlertController(title: Localizable.Verification.processTitle, message: error.text(), preferredStyle: .alert)

        let retryAction = UIAlertAction(title: Localizable.Common.tryAgain, style: .default) { [weak self] _ in
            self?.viewModel.didTriggerRetry(errorType: .invalidData)
        }

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.viewModel.didTriggerQuit()
        })

        alert.addAction(retryAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }

    private func requestFailed(with error: APIError) {
        presentAlert(with: Localizable.APIErrorDesc.requestError, message: error.text(), action: Localizable.Common.tryAgain, error: error) { [weak self] in
            self?.viewModel.restartRequests()
        }
    }

    private func presentAlert(with title: String, message: String, action: String, error: APIError, callback: @escaping () -> Void) {

        let alert = UIAlertController(title: title, message: error.text(), preferredStyle: .alert)

        let reactionAction = UIAlertAction(title: action, style: .default, handler: {_ in
            callback()
        })

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.viewModel.abortIdentProcess(error)
        })

        alert.addAction(reactionAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
