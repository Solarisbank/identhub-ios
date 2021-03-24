//
//  PaymentVerificationViewController.swift
//  IdentHubSDK
//

import UIKit
import WebKit

/// UIViewController which displays screen to verify payment.
final internal class PaymentVerificationViewController: SolarisViewController {

    var viewModel: PaymentVerificationViewModel!

    private var timer: Timer?

    enum Constants {
        enum FontSize {
            static let big: CGFloat = 20
        }

        enum ConstraintsOffset {
            static let massive: CGFloat = 64
            static let extended: CGFloat = 40
            static let normal: CGFloat = 24
            static let sidesExtended: CGFloat = 32
            static let sidesNormal: CGFloat = 16
            static let size: CGFloat = 72
        }

        enum Size {
            static let cornerRadius: CGFloat = 8
            static let paymentViewHeight: CGFloat = 391
        }
    }

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

    private lazy var currentStepView: IdentificationProgressView = {
        let view = IdentificationProgressView(currentStep: .bankVerification)
        return view
    }()

    private lazy var stateView: StateView = {
        let stateView = StateView(hasDescriptionLabel: false)
        return stateView
    }()

    private lazy var paymentWebView: WKWebView = {
        let webView = WKWebView()
        let layer = webView.layer
        layer.cornerRadius = Constants.Size.cornerRadius
        layer.masksToBounds = true
        return webView
    }()

    private lazy var successContainerView: SuccessView = {
        let view = SuccessView()
        view.setTitle(Localizable.BankVerification.PaymentVerification.Success.title)
        view.setDescription(Localizable.BankVerification.PaymentVerification.Success.description)
        view.setActionButtonTitle(Localizable.BankVerification.PaymentVerification.Success.action)
        view.setAction { [weak self] in
            self?.viewModel.beginSignDocuments()
        }
        return view
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        containerView.addSubviews([
            currentStepView,
            stateView
        ])

        currentStepView.addConstraints {
            [
                $0.equal(.top),
                $0.equal(.leading),
                $0.equal(.trailing)
            ]
        }

        stateView.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom),
            $0.equal(.leading),
            $0.equal(.trailing),
            $0.equal(.bottom)
        ]
        }
    }

    private func setUpPaymentWebView() {
        containerView.addSubview(paymentWebView)
        paymentWebView.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.sidesNormal),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sidesNormal),
            $0.equal(.bottom, constant: -Constants.ConstraintsOffset.extended),
            $0.equalConstant(.height, Constants.Size.paymentViewHeight)
        ]
        }
    }

    private func setUpSuccessContainerView() {
        containerView.addSubview(successContainerView)
        successContainerView.addConstraints { [
            $0.equalTo(currentStepView, .top, .bottom),
            $0.equal(.leading),
            $0.equal(.trailing),
            $0.equal(.bottom)
        ]
        }
    }

    private func updateUI() {
        switch state {
        case .establishingConnection:
            stateView.setStateImage(UIImage.sdkImage(.establishingSecureConnection, type: PaymentVerificationViewController.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.establishingSecureConnection)
        case .paymentInitiation:
            stateView.isHidden = true
            setUpPaymentWebView()
        case .processingVerification:
            paymentWebView.removeFromSuperview()
            stateView.isHidden = false
            stateView.setStateImage(UIImage.sdkImage(.processingVerification, type: PaymentVerificationViewController.self))
            stateView.setStateTitle(Localizable.BankVerification.PaymentVerification.processingVerification)
        case .success:
            stateView.removeFromSuperview()
            setUpSuccessContainerView()
        case .failed:
            print("Failed payment verification")
        }
    }

    @objc private func checkStatus() {
        viewModel.checkIdentificationStatus()
    }
}

// MARK: PaymentVerificationViewModelDelegate methods

extension PaymentVerificationViewController: PaymentVerificationViewModelDelegate {
    func verificationStarted() {
        state = .establishingConnection
    }

    func verificationRecivedURLRequest(_ urlRequest: URLRequest) {
        paymentWebView.load(urlRequest)
        timer = Timer.scheduledTimer(timeInterval: 3.0, target: self, selector: #selector(checkStatus), userInfo: nil, repeats: true)
        state = .paymentInitiation
    }

    func verificationIsBeingProcessed() {
        timer?.invalidate()
        state = .processingVerification
    }

    func verificationSucceeded() {
        state = .success
    }

    func verificationFailed() {
        state = .failed
    }
}
