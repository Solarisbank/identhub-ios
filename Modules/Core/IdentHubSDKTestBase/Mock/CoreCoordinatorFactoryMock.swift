//
//  CoreCoordinatorFactoryMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public struct CoreCoordinatorFactoryMock: CoreCoordinatorFactory {
    public init() {}
    
    public func makeCoreCoordinator() -> AnyFlowCoordinator<CoreInput, CoreOutput, APIError> {
        return FlowCoordinatorMock<CoreInput, CoreOutput, APIError>().asAnyFlowCoordinator()
    }
    
}
