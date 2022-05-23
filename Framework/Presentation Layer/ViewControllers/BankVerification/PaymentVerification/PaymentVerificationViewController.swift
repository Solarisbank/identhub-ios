//
//  PaymentVerificationViewController.swift
//  IdentHubSDK
//

import UIKit
import WebKit

/// UIViewController which displays screen to verify payment.
final internal class PaymentVerificationViewController: UIViewController, Quitable {

    // MARK: - IBOutlets -

    @IBOutlet var headerView: HeaderView!
    @IBOutlet var stateView: StateView!
    @IBOutlet var paymentWebView: WKWebView!
    @IBOutlet var successContainerView: SuccessView!

    // MARK: - Properties -

    var viewModel: PaymentVerificationViewModel!

    private enum State {
        case establishingConnection
        case paymentInitiation
        case processingVerification
        case success
        case failed
    }

    private var state: State = .establishingConnection {
        didSet {
            updateUI()
        }
    }

    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(_ viewModel: PaymentVerificationViewModel) {
        self.viewModel = viewModel

        super.init(nibName: "PaymentVerificationViewController", bundle: Bundle(for: PaymentVerificationViewController.self))
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    // MARK: - Life cycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }

    private func configureUI() {
        headerView.style = .quit(target: self)

        setupSuccessView()

        viewModel.assemblyURLRequest()
    }

    private func setupSuccessView() {

        successContainerView.setTitle(Localizable.BankVerification.PaymentVerification.Success.title)
        successContainerView.setDescription(Localizable.BankVerification.PaymentVerification.Success.description)
        successContainerView.setActionButtonTitle(Localizable.BankVerification.PaymentVerification.Success.action)
        successContainerView.setAction { [weak self] in
            self?.viewModel.executeStep()
        }
    }

    private func updateUI() {
        switch state {
        case .establishingConnection:
            stateView.setStateImage(UIImage.sdkImage(.establishingSecureConnection, type: Self.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.establishingSecureConnection)
        case .paymentInitiation:
            stateView.isHidden = true
            paymentWebView.isHidden = false
        case .processingVerification:
            paymentWebView.isHidden = true
            stateView.isHidden = false
            stateView.setStateImage(UIImage.sdkImage(.processingVerification, type: Self.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.processingVerification)
        case .success:
            successContainerView.isHidden = false
            stateView.isHidden = true
        case .failed:
            print("Failed payment verification")
        }
    }

    @IBAction func didClickQuit(_ sender: Any) {
        viewModel.quit()
    }
}

// MARK: PaymentVerificationViewModelDelegate methods

extension PaymentVerificationViewController: PaymentVerificationViewModelDelegate {
    func verificationStarted() {
        state = .establishingConnection
    }

    func verificationRecivedURLRequest(_ urlRequest: URLRequest) {
        paymentWebView.load(urlRequest)
        state = .paymentInitiation
    }

    func verificationIsBeingProcessed() {
        state = .processingVerification
    }

    func verificationSucceeded() {
        state = .success
    }

    func verificationFailed() {
        state = .failed
    }
}
