//
//  PaymentVerificationViewController.swift
//  IdentHubSDK
//

import UIKit
import WebKit

/// UIViewController which displays screen to verify payment.
final internal class PaymentVerificationViewController: UIViewController {

    // MARK: - IBOutlets -

    @IBOutlet var currentStepView: IdentificationProgressView!
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
        super.init(coder: coder)
    }

    // MARK: - Life cycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {

        currentStepView.setCurrentStep( .bankVerification)
        setupSuccessView()

        viewModel.assemblyURLRequest()
    }

    private func setupSuccessView() {

        successContainerView.setTitle(Localizable.BankVerification.PaymentVerification.Success.title)
        successContainerView.setDescription(Localizable.BankVerification.PaymentVerification.Success.description)
        successContainerView.setActionButtonTitle(Localizable.BankVerification.PaymentVerification.Success.action)
        successContainerView.setAction { [weak self] in
            self?.viewModel.beginSignDocuments()
        }
    }

    private func updateUI() {
        switch state {
        case .establishingConnection:
            stateView.setStateImage(UIImage.sdkImage(.establishingSecureConnection, type: PaymentVerificationViewController.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.establishingSecureConnection)
        case .paymentInitiation:
            stateView.isHidden = true
            paymentWebView.isHidden = false
        case .processingVerification:
            paymentWebView.isHidden = true
            stateView.isHidden = false
            stateView.setStateImage(UIImage.sdkImage(.processingVerification, type: PaymentVerificationViewController.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.processingVerification)
        case .success:
            successContainerView.isHidden = false
            stateView.isHidden = true
        case .failed:
            print("Failed payment verification")
        }
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
