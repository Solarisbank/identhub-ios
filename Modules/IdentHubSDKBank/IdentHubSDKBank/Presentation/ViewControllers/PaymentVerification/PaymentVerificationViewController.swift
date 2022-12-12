//
//  PaymentVerificationViewController.swift
//  IdentHubSDKBank
//

import UIKit
import WebKit
import IdentHubSDKCore

internal struct PaymentVerificationState: Equatable {
    enum State: Equatable {
        case establishingConnection
        case paymentInitiation
        case processingVerification
        case success
        case failed
    }
    
    var state: State = .establishingConnection
    var urlRequest: URLRequest?
}

internal enum PaymentVerificationEvent {
    case assemblyURLRequest
    case checkIdentificationStatus
    case executeStep
    case quit
}

// UIViewController which displays screen for Payment verification.
final internal class PaymentVerificationViewController: UIViewController, Updateable, Quitable {
   
    typealias ViewState = PaymentVerificationState
    
    // MARK: - Properties -
    
    var eventHandler: AnyEventHandler<PaymentVerificationEvent>?
    private var colors: Colors
    
    // MARK: - IBOutlets -
   
    @IBOutlet var headerView: HeaderView!
    @IBOutlet var stateView: StateView!
    @IBOutlet var paymentWebView: WKWebView!
    @IBOutlet var successContainerView: SuccessView!
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<PaymentVerificationEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods -
    
    override func viewDidLoad() {
        super.viewDidLoad()
        configureUI()
    }
    
    // MARK: - Internal methods -
    
    func updateView(_ state: PaymentVerificationState) {
        switch state.state {
        case .establishingConnection:
            stateView.setStateImage(UIImage.sdkImage(.establishingSecureConnection, type: Self.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.establishingSecureConnection)
        case .paymentInitiation:
            guard let url = state.urlRequest else {
                return
            }
            stateView.isHidden = true
            paymentWebView.isHidden = false
            paymentWebView.load(url)
        case .processingVerification:
            paymentWebView.isHidden = true
            stateView.isHidden = false
            stateView.setStateImage(UIImage.sdkImage(.processingVerification, type: Self.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.processingVerification)
        case .success:
            successContainerView.isHidden = false
            stateView.isHidden = true
        case .failed:
            bankLog.warn("Failed payment verification")
        }
    }
    
    // MARK: - Actions methods -
    
    @IBAction func didClickQuit(_ sender: Any) {
        eventHandler?.handleEvent(.quit)
    }
}

// MARK: - Internal methods -

extension PaymentVerificationViewController {
    
    private func configureUI() {
        setupSuccessView()
        headerView.setStyle(.quit(target: self))
        eventHandler?.handleEvent(.assemblyURLRequest)
    }
    
    private func setupSuccessView() {
        successContainerView.setTitle(Localizable.BankVerification.PaymentVerification.Success.title)
        successContainerView.setDescription(Localizable.BankVerification.PaymentVerification.Success.description)
        successContainerView.setActionButtonTitle(Localizable.BankVerification.PaymentVerification.Success.action)
        successContainerView.setAction { [weak self] in
            self?.eventHandler?.handleEvent(.executeStep)
        }
    }
}
