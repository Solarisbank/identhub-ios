//
//  QuitAction.swift
//  IdentHubSDKCore
//

public class QuitAction: Action {
    private let colors: Colors

    public init(colors: Colors) {
        self.colors = colors
    }

    public func perform(input: Void, callback: @escaping (Bool) -> Void) -> Showable? {
        let quitPopUpViewController = QuitPopUpViewController(colors: colors)
        quitPopUpViewController.quitAction = {
            callback(true)
        }
        quitPopUpViewController.cancelAction = {
            callback(false)
        }
        quitPopUpViewController.modalPresentationStyle = .overFullScreen
        return quitPopUpViewController
    }
}
