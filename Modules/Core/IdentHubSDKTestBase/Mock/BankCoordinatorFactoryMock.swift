//
//  BankCoordinatorFactoryMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public struct BankCoordinatorFactoryMock: BankCoordinatorFactory {
    public init() {}
    
    public func makeBankCoordinator() -> IdentHubSDKCore.AnyFlowCoordinator<IdentHubSDKCore.BankInput, IdentHubSDKCore.BankOutput, IdentHubSDKCore.APIError> {
        FlowCoordinatorMock<BankInput, BankOutput, APIError>().asAnyFlowCoordinator()
    }

}
