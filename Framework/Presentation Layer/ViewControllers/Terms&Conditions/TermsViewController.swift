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
    @IBOutlet var continueBtn: UIButton!
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
        continueBtn.isEnabled = false
        viewModel.delegate = self

        viewModel.setupTermsText(termsText)
        updateContinueBtnDisplay()
    }

    private func updateContinueBtnDisplay() {

        switch continueBtn.isEnabled {
        case true:
            continueBtn.backgroundColor = UIColor.sdkColor(.primaryAccent)
        case false:
            continueBtn.backgroundColor = UIColor.sdkColor(.black25)
        }
    }

    // MARK: - Action methods -
    @IBAction func didClickCheckmark(_ sender: UIButton) {
        sender.isSelected.toggle()
        continueBtn.isEnabled.toggle()

        updateContinueBtnDisplay()
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
