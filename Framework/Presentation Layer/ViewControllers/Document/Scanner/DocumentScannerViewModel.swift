//
//  DocumentScannerViewModel.swift
//  IdentHubSDK
//

import Foundation

/// Document scanner view model
/// Class used for saving scanned data
final class DocumentScannerViewModel {

    // MARK: - Properties -
    private var flowCoordinator: FourthlineIdentCoordinator

    /// Init method with flow coordinator
    /// - Parameter flowCoordinator: identification process flow coordinator
    init(flowCoordinator: FourthlineIdentCoordinator) {
        self.flowCoordinator = flowCoordinator
    }

    // MARK: - Public methods -

    func dismissScanner() {
        flowCoordinator.perform(action: .quit)
    }
}
