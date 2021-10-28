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
    @IBOutlet var continueBtn: ActionRoundedButton!
    @IBOutlet var circleBackground: UIImageView!

    // MARK: - Private attributes -
    private var viewModel: LocationViewModel!

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

        configureUI()
    }

    override func viewDidLayoutSubviews() {
        super.viewDidLayoutSubviews()

        circleBackground.layer.cornerRadius = circleBackground.frame.width / 2
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

        continueBtn.setTitle(Localizable.Common.continueBtn, for: .normal)
        quitBtn.setTitle(Localizable.Common.quit, for: .normal)
        titleLbl.text = Localizable.Location.title
        descriptionLbl.text = Localizable.Location.description

        configureCustomUI()
    }

    private func configureCustomUI() {

        continueBtn.currentAppearance = .primary
        circleBackground.layer.masksToBounds = true
        circleBackground.backgroundColor = .sdkColor(.primaryAccent)
    }
}
