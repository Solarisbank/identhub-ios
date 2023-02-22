//
//  SelfieEventHandlerImpl.swift
//  IdentHubSDKFourthline
//

import Foundation
import UIKit
import IdentHubSDKCore
import FourthlineVision

internal enum SelfieOutput: Equatable {
    case dataUpload
    case quit
}

// MARK: - Fourthline Selfie event logic -

typealias SelfieCallback = (SelfieOutput) -> Void

final internal class SelfieEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<SelfiEvent>, ViewController.ViewState == SelfieState {
    
    weak var updatableView: ViewController?
    
    private var scannerResult: SelfieScannerResult?
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var state: SelfieState
    internal var colors: Colors
    private var callback: SelfieCallback
    
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        colors: Colors,
        callback: @escaping SelfieCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.colors = colors
        self.callback = callback
        self.state = SelfieState()
    }
    
    func handleEvent(_ event: SelfiEvent) {
        
        switch event {
        case .scannerConfig:
            scannerConfig()
        case .setScannerResult(let result):
            setScannerResult(result)
        case .saveResult:
            saveResult()
        case .confirmStep:
            confirmStep()
        case .resetResult:
            scannerResult = nil
        case .closeProcess:
            quit()
        }
    }
    
    private func scannerConfig() {
        let config = SelfieScannerConfig()
        
        config.recordingType = RecordingType.videoOnly
        config.livenessCheckType = .headTurn
        
        updateState { state in
            state.state = .scannerConfig
            state.scannerConfig = config
        }
    }
    
    private func setScannerResult(_ result: SelfieScannerResult) {
        self.scannerResult = result
    }
    
    private func saveResult() {
        updateState { state in
            guard let result = self.scannerResult else { return }
            
            KYCContainer.shared.update(with: result)
            state.state = .save
            state.saveResult = true
        }
    }
    
    private func updateState(_ update: @escaping (inout SelfieState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    private func confirmStep() {
        updateState { state in
            if state.saveResult {
                self.callback(.dataUpload)
            }
        }
    }
    
    func quit() {
        callback(.quit)
    }
}
