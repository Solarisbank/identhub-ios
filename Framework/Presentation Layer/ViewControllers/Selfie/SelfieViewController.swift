//
//  SelfieViewController.swift
//  IdentHubSDK
//

import UIKit

class SelfieViewController: SolarisViewController {

    // MARK: - Properties -
    @IBOutlet var selfieScreenContainer: UIView!

    private var viewModel: SelfieViewModel?

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: SelfieViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "SelfieViewController", bundle: Bundle(for: SelfieViewController.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    // MARK: - Internal methods -
    private func configureUI() {
        containerView.addSubview(selfieScreenContainer)

        containerView.addConstraints {
            [ $0.equalTo(selfieScreenContainer, .bottom, .bottom) ]
        }
    }

    // MARK: - Actions methods -
    @IBAction func didClickCloseBtn(_ sender: UIButton) {
        viewModel?.didTriggerCloseProcess()
    }
}
