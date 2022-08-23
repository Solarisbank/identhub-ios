//
//  AlertsServiceMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public class AlertsServiceMock: AlertsService {
    public var quitAlertCallback: ((Bool) -> Void)?

    private var recorder: TestRecorder

    public init(recorder: TestRecorder) {
        self.recorder = recorder
    }

    public func presentQuitAlert(callback: @escaping (Bool) -> Void) {
        recorder.record(event: .ui, in: #function, caller: self)
        quitAlertCallback = { result in
            self.recorder.record(event: .ui, value: "AlertsServiceMock.presentQuitAlert.callback(\(result))")
            callback(result)
        }
    }
}
