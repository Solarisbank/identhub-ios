//
//  SelfieViewModel.swift
//  IdentHubSDK
//

import Foundation
import FourthlineVision

final internal class SelfieViewModel {

    // MARK: - Properties -
    private var flowCoordinator: FourthlineIdentCoordinator
    private var scannerResult: SelfieScannerResult?
    private var identificationMethod: IdentificationStep?

    // MARK: - Init -

    /// Init method with flow coordinator
    /// - Parameter flowCoordinator: identification process flow coordinator
    init(flowCoordinator: FourthlineIdentCoordinator, identMethod: IdentificationStep) {
        self.flowCoordinator = flowCoordinator
        self.identificationMethod = identMethod
    }

    // MARK: - Public methods -
    func setScannerResult(_ result: SelfieScannerResult) {
        scannerResult = result
    }

    func resetResult() {
        scannerResult = nil
    }

    func saveResult() -> Bool {
        guard let result = scannerResult else { return false }

        KYCContainer.shared.update(with: result)
        return true
    }

    func scannerConfig() -> SelfieScannerConfig {

        let config = SelfieScannerConfig()

        config.shouldRecordVideo = true
        config.livenessCheckType = .headTurn

        return config
    }

    func didTriggerCloseProcess() {
        flowCoordinator.perform(action: .quit)
    }

    func didTriggerConfirmStep() {
        if identificationMethod == .fourthline {
            flowCoordinator.perform(action: .documentPicker)
        } else {
            flowCoordinator.perform(action: .fetchData)
        }
    }
}
