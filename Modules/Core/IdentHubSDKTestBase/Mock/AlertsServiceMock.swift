//
//  AlertsServiceMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore
import UIKit

public class AlertsServiceMock: AlertsService {
    
    public var quitAlertCallback: ((Bool) -> Void)?
    public var okActionCallback: (() -> Void)?
    public var retryActionCallback: (() -> Void)?

    public var presentAlertCallsCount = 0
    public var presentAlertArguments: [(title: String, message: String)] = []
    public var presentAlertLastArguments: (title: String, message: String)? { presentAlertArguments.last }

    private var recorder: TestRecorder?

    public init(recorder: TestRecorder? = nil) {
        self.recorder = recorder
    }

    public func presentQuitAlert(callback: @escaping (Bool) -> Void) {
        recorder?.record(event: .ui, in: #function, caller: self)

        quitAlertCallback = { result in
            self.recorder?.record(event: .ui, value: "AlertsServiceMock.presentQuitAlert.callback(\(result))")
            callback(result)
        }
    }

    public func presentAlert(with title: String, message: String, okActionCallback: @escaping () -> Void, retryActionCallback: (() -> Void)?) {
        presentAlertCallsCount += 1
        presentAlertArguments.append((title, message))

        recorder?.record(event: .ui, in: #function, caller: self)

        self.okActionCallback = {
            self.recorder?.record(event: .ui, value: "AlertsServiceMock.presentAlert.okActionCallback")
            okActionCallback()
        }

        self.retryActionCallback = {
            self.recorder?.record(event: .ui, value: "AlertsServiceMock.presentAlert.retryActionCallback")
            retryActionCallback?()
        }
    }
    
    public func presentCustomAlert(alert: UIAlertController) {
        presentAlertCallsCount += 1
        recorder?.record(event: .ui, in: #function, caller: self)
    }
    
}
