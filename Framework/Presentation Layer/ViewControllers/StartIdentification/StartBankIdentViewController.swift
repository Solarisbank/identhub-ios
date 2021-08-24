//
//  StartBankIdentViewController.swift
//  IdentHubSDK
//

import UIKit

class StartBankIdentViewController: SolarisViewController {

    // MARK: - Properties -
    @IBOutlet var startContainerView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!
    @IBOutlet var instructionsLabel: UILabel!
    @IBOutlet var detailLabel: UILabel!
    @IBOutlet var sendBtn: UIButton!
    @IBOutlet var quitBtn: UIButton!

    var viewModel: StartIdentificationViewModel!

    // MARK: - Init methods -

    init(_ viewModel: StartIdentificationViewModel) {
        super.init(nibName: "StartBankIdentViewController", bundle: Bundle(for: StartBankIdentViewController.self))

        self.viewModel = viewModel
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }

    // MARK: - Internal methods -

    private func configureUI() {

        containerView.addSubview(startContainerView)

        containerView.addConstraints {
            [ $0.equalTo(startContainerView, .bottom, .bottom) ]
        }

        titleLabel.text = Localizable.StartIdentification.startIdentification
        descriptionLabel.text = Localizable.StartIdentification.instructionDisclaimer
        instructionsLabel.text = Localizable.StartIdentification.instructionSteps
        detailLabel.text = Localizable.StartIdentification.followVerificationForNumber
        sendBtn.setTitle(Localizable.StartIdentification.sendVerificationCode, for: .normal)
        quitBtn.setTitle(Localizable.Common.quit, for: .normal)
    }

    // MARK: - Actions methods -

    @IBAction func didClickSendButton(_ sender: UIButton) {

        viewModel.startIdentification()
    }

    @IBAction func didClickQuitButton(_ sender: Any) {

        viewModel.quit()
    }

}
