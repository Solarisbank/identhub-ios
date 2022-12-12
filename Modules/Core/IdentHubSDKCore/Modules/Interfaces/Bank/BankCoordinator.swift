//
//  BankCoordinator.swift
//  IdentHubSDKCore
//

/// Coordinator presenting Bank flow.
public protocol BankCoordinator: FlowCoordinator {
    func start(input: BankInput, callback: @escaping (Result<BankOutput, APIError>) -> Void) -> Showable?
}
