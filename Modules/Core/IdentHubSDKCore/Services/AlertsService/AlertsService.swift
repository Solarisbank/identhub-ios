//
//  AlertsService.swift
//  IdentHubSDKCore
//

public protocol AlertsService {
    func presentQuitAlert(callback: @escaping (Bool) -> Void)
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
}
