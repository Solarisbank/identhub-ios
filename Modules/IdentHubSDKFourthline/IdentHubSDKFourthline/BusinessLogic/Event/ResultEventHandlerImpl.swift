//
//  ResultEventHandlerImpl.swift
//  IdentHubSDKFourthline
//

import Foundation
import IdentHubSDKCore
import UIKit

internal enum ResultOutput: Equatable {
    static func == (lhs: ResultOutput, rhs: ResultOutput) -> Bool {
        return true
    }
    
    case complete(result: FourthlineIdentificationStatus)
}

internal struct ResultInput {
    var result: FourthlineIdentificationStatus?
}

// MARK: - ResultOutput events logic -

typealias ResultCallback = (ResultOutput) -> Void

final internal class ResultEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<ResultEvent>, ViewController.ViewState == ResultState {
    
    weak var updatableView: ViewController?
    
    private let alertsService: AlertsService
    private var state: ResultState
    private var input: ResultInput
    internal var colors: Colors
    private var callback: ResultCallback
    
    var result: FourthlineIdentificationStatus?

    init(
        alertsService: AlertsService,
        input: ResultInput,
        colors: Colors,
        callback: @escaping ResultCallback
    ) {
        self.alertsService = alertsService
        self.input = input
        self.colors = colors
        self.callback = callback
        self.state = ResultState()
    }
    
    func handleEvent(_ event: ResultEvent) {
        switch event {
        case .showResult:
            result = input.result
            self.showResult()
        case .triggerDone: self.didTriggerDone()
        }
    }
    
    private func updateState(_ update: @escaping (inout ResultState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    func showResult() {
        updateState { state in
            state.title = self.obtainResultTitle()
            state.description = self.obtainResultDescription()
            state.image = self.obtainResultImage()
        }
    }
    
    /// Method returns title of the result screen depends on fourthline identification status
    /// - Returns: screen title string
    func obtainResultTitle() -> String {
        switch self.result?.identificationStatus {
        case .success:
            return Localizable.Result.successTitle
        case .failed:
            return Localizable.Result.failedTitle
        default:
            return ""
        }
    }

    /// Method returns description of the result screen depends on fourthline identification status
    /// - Returns: screen description string
    func obtainResultDescription() -> String {
        switch self.result?.identificationStatus {
        case .success:
            return Localizable.Result.successDescription
        case .failed:
            return Localizable.Result.failedDescription
        default:
            return ""
        }
    }

    /// Method returns result icon image depends on identification status
    /// - Returns: result image
    func obtainResultImage() -> UIImage? {
        switch self.result?.identificationStatus {
        case .success:
            return UIImage(named: "result_success", in: Bundle.current, compatibleWith: nil)
        case .failed:
            return UIImage(named: "result_failed", in: Bundle.current, compatibleWith: nil)
        default:
            return UIImage()
        }
    }

    func didTriggerDone() {
        if let identResult = result {
            self.callback(.complete(result: identResult))
        }
    }
    
}
