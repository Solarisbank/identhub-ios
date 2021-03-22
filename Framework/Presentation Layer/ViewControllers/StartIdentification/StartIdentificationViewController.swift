//
//  StartIdentificationViewController.swift
//  IdentHubSDK
//

import UIKit

/// ViewController which displays start identification screen.
final internal class StartIdentificationViewController: SolarisViewController {

    var viewModel: StartIdentificationViewModel!

    enum Constants {
        enum FontSize {
            static let big: CGFloat = 22
            static let medium: CGFloat = 14
        }

        enum ConstraintsOffset {
            static let extended: CGFloat = 40
            static let normal: CGFloat = 16
        }
    }

    private lazy var startIdentificationLabel: UILabel = {
        let label = UILabel()
        label.font = UIFont.systemFont(ofSize: Constants.FontSize.big)
        label.textColor = .black
        label.text = Localizable.StartIdentification.startIdentification
        return label
    }()

    private lazy var instructionsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.textColor = UIColor.sdkColor(.black75)
        label.text = Localizable.StartIdentification.instructionDisclaimer
        return label
    }()

    private lazy var instructionsStepsLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.textColor = UIColor.sdkColor(.black75)
        label.text = Localizable.StartIdentification.instructionSteps
        return label
    }()

    private lazy var phoneNumberLabel: UILabel = {
        let label = UILabel()
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.medium)
        label.text = Localizable.StartIdentification.followVerificationForNumber
        label.textColor = UIColor.sdkColor(.black75)
        return label
    }()

    private lazy var sendVerificationCodeButton: UIButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.StartIdentification.sendVerificationCode, for: .normal)
        button.currentAppearance = .orange
        return button
    }()

    private lazy var quitButton: UIButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.Common.quit, for: .normal)
        button.currentAppearance = .dimmed
        return button
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        containerView.addSubviews([
            startIdentificationLabel,
            instructionsLabel,
            instructionsStepsLabel,
            phoneNumberLabel,
            sendVerificationCodeButton,
            quitButton
        ])

        startIdentificationLabel.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: Constants.ConstraintsOffset.normal)
        ]
        }

        instructionsLabel.addConstraints { [
            $0.equalTo(startIdentificationLabel, .top, .bottom, constant: 24),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        instructionsStepsLabel.addConstraints { [
            $0.equalTo(instructionsLabel, .top, .bottom, constant: 14),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        phoneNumberLabel.addConstraints { [
            $0.equalTo(instructionsStepsLabel, .top, .bottom, constant: 14),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        sendVerificationCodeButton.addConstraints { [
            $0.equalTo(phoneNumberLabel, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal)
        ]
        }

        quitButton.addConstraints { [
            $0.equalTo(sendVerificationCodeButton, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended)
        ]
        }

        sendVerificationCodeButton.addTarget(self, action: #selector(sendCode), for: .touchUpInside)
        quitButton.addTarget(self, action: #selector(quit), for: .touchUpInside)
    }

    @objc private func sendCode() {
        viewModel.sendCode()
    }

    @objc private func quit() {
        viewModel.quit()
    }
}
