//
//  QESCoordinator.swift
//  IdentHubSDKCore
//

/// Coordinator presenting application signing view and performing signing upon user interaction (used in IBAN authentication flow).
public protocol QESCoordinator: FlowCoordinator {
    func start(input: QESInput, callback: @escaping (Result<QESOutput, APIError>) -> Void) -> Showable?
}
