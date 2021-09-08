//
//  ResultViewController.swift
//  IdentHubSDK
//

import UIKit

final class ResultViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    @IBOutlet var stepsProgressView: StepsProgressView!
    @IBOutlet var resultImage: UIImageView!
    @IBOutlet var quitBtn: ActionRoundedButton!

    // MARK: - Private attributes -

    private var viewModel: ResultViewModel!

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: ResultViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "ResultViewController", bundle: Bundle.current)
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

    // MARK: - Action methods -

    @IBAction func didClickQuit(_ sender: UIButton) {
        viewModel.didTriggerClose()
    }
}

// MARK: - Private methods -

private extension ResultViewController {

    private func configureUI() {

        titleLbl.text = viewModel.obtainResultTitle()
        descriptionLbl.text = viewModel.obtainResultDescription()
        resultImage.image = viewModel.obtainResultImage()

        stepsProgressView.datasource = viewModel
    }
}
