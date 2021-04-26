//
//  UploadViewController.swift
//  IdentHubSDK
//

import UIKit

class UploadViewController: UIViewController {

    // MARK: - Outlets -
    @IBOutlet var stepProgressView: StepsProgressView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!

    // MARK: - Private attributes -
    private var viewModel: UploadViewModel

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: UploadViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "UploadViewController", bundle: Bundle.current)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Lifecycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()

        stepProgressView.datasource = viewModel
    }

    override var prefersStatusBarHidden: Bool {
        true
    }

    // MARK: - Action methods -

    @IBAction func didClickQuit(_ sender: UIButton) {

        viewModel.didTriggerQuit()
    }
}
