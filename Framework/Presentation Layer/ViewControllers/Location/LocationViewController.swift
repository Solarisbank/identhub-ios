//
//  LocationViewController.swift
//  IdentHubSDK
//

import UIKit
import FourthlineKYC

class LocationViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var stepsProgressView: StepsProgressView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var continueBtn: UIButton!

    // MARK: - Private attributes -
    private var viewModel: LocationViewModel

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: LocationViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "LocationViewController", bundle: Bundle.current)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()

        handleActivities()
        configureUI()
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    // MARK: - Action methods -

    @IBAction func didClickQuit(_ sender: UIButton) {
        viewModel.didTriggerQuit()
    }

    @IBAction func didClickContinue(_ sender: UIButton) {
        viewModel.didTriggerContinue()
    }
}

// MARK: - Internal methods -

extension LocationViewController {

    private func configureUI() {

        stepsProgressView.datasource = viewModel

        continueBtn.titleLabel?.text = Localizable.Common.continueBtn
        quitBtn.titleLabel?.text = Localizable.Common.quit
        titleLbl.text = Localizable.Location.title
        descriptionLbl.text = Localizable.Location.description
    }

    private func handleActivities() {

        viewModel.onUpdateLocation = { [unowned self] enable in

            self.continueBtn.isEnabled = enable
            self.continueBtn.alpha = enable ? 1.0 : 0.5
        }

        viewModel.onDisplayError = { [unowned self] error in
            self.displayLocationTrackerError()
        }

        viewModel.startLocationHandler()
    }

    private func displayLocationTrackerError() {
        let alert = UIAlertController(title: Localizable.Location.Error.title, message: Localizable.Location.Error.message, preferredStyle: .alert)

        let tryAgainAction = UIAlertAction(title: "Settings", style: .default, handler: {_ in
            UIApplication.openAppSettings()
        })

        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: { [weak self] _ in
            self?.viewModel.didTriggerQuit()
        })

        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)

        present(alert, animated: true)
    }
}
