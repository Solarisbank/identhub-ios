//
//  AlertsService.swift
//  IdentHubSDKCore
//

import UIKit

public protocol AlertsService {
    func presentQuitAlert(callback: @escaping (Bool) -> Void)
    func presentAlert(with title: String, message: String, okActionCallback: @escaping () -> Void, retryActionCallback: (() -> Void)?)
    func presentCustomAlert(alert: UIAlertController)
}

public final class AlertsServiceImpl: AlertsService {
    
    private let colors: Colors
    private let presenter: Presenter

    public init(presenter: Presenter, colors: Colors) {
        self.presenter = presenter
        self.colors = colors
    }
    
    public func presentQuitAlert(callback: @escaping (Bool) -> Void) {
        let quitPopUpViewController = QuitPopUpViewController(colors: colors)
        quitPopUpViewController.quitAction = {
            callback(true)
        }
        quitPopUpViewController.cancelAction = {
            callback(false)
        }
        quitPopUpViewController.modalPresentationStyle = .overFullScreen
        
        presenter.present(quitPopUpViewController, animated: false)
    }

    public func presentAlert(with title: String, message: String, okActionCallback: @escaping () -> Void, retryActionCallback: (() -> Void)?) {
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)

        if let retryActionCallback = retryActionCallback {
            let retryAction = UIAlertAction(title: Localizable.Common.tryAgain, style: .default, handler: { _ in
                retryActionCallback()
            })

            alert.addAction(retryAction)
        }

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel)

        alert.addAction(cancelAction)

        presenter.present(alert.toShowable(), animated: true)
    }
    
    public func presentCustomAlert(alert: UIAlertController) {
        presenter.present(alert.toShowable(), animated: true)
    }
}
