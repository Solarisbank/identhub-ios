//
//  TermsConditionsViewController.swift
//  IdentHubSDK
//

import UIKit

 final internal class TermsConditionsViewController: SolarisViewController {

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

    // MARK: - Properties -
    private lazy var quitButton: UIButton = {
        let button = ActionRoundedButton()
        button.setTitle(Localizable.Common.quit, for: .normal)
        button.currentAppearance = .dimmed
        return button
    }()

    // MARK: - Life cycle methods -
    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        containerView.addSubviews([
            quitButton
        ])

        quitButton.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.normal),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended)
        ]
        }

        quitButton.addTarget(self, action: #selector(quit), for: .touchUpInside)
    }

    @objc private func quit() {
        self.parent?.dismiss(animated: true, completion: nil)
    }

}
