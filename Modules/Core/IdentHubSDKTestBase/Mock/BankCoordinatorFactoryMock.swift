//
//  BankCoordinatorFactoryMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public struct BankCoordinatorFactoryMock: BankCoordinatorFactory {
    public init() {}
    
    public func makeBankCoordinator() -> AnyFlowCoordinator<BankInput, BankOutput, APIError> {
        FlowCoordinatorMock<BankInput, BankOutput, APIError>().asAnyFlowCoordinator()
    }

}
