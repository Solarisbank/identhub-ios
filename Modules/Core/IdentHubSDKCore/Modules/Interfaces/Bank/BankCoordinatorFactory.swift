//
//  BankCoordinatorFactory.swift
//  IdentHubSDKCore
//

/// Factory for Bank coordinators.
public protocol BankCoordinatorFactory: CoordinatorFactory {
    func makeBankCoordinator() -> AnyFlowCoordinator<BankInput, BankOutput, APIError>
}
