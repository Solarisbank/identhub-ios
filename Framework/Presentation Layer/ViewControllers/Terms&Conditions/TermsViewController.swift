//
//  TermsViewController.swift
//  IdentHubSDK
//

import UIKit
import SafariServices

class TermsViewController: UIViewController {

    // MARK: - Properties -
    @IBOutlet var descLabel: UILabel!
    @IBOutlet var termsText: UITextView!
    @IBOutlet var continueBtn: ActionRoundedButton!
    @IBOutlet var quitBtn: UIButton!
    @IBOutlet var termsContainerView: UIView!

    var viewModel: TermsViewModel!

    // MARK: - Init methods -

    init(_ viewModel: TermsViewModel) {
        super.init(nibName: "TermsViewController", bundle: Bundle(for: TermsViewController.self))

        self.viewModel = viewModel
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

        descLabel.text = Localizable.TermsConditions.description
        continueBtn.currentAppearance = .inactive
        viewModel.delegate = self

        viewModel.setupTermsText(termsText)
    }

    // MARK: - Action methods -
    @IBAction func didClickCheckmark(_ sender: UIButton) {
        if sender.isSelected {
            sender.isSelected = false
            continueBtn.currentAppearance = .inactive
        } else {
            sender.isSelected = true
            continueBtn.currentAppearance = .primary
        }
    }

    @IBAction func didClickContinue(_ sender: UIButton) {
        viewModel.continueProcess()
    }

    @IBAction func didClickQuit(_ sender: UIButton) {
        viewModel.quit()
    }
}

extension TermsViewController: TermsViewModelDelegate {
    func presentLinkViewer(_ url: URL) {
        let svc = SFSafariViewController(url: url)
        present(svc, animated: true, completion: nil)
    }
}
