//
//  FourthlineCoordinatorFactoryMock.swift
//  IdentHubSDKTestBase
//

import IdentHubSDKCore

public struct FourthlineCoordinatorFactoryMock: FourthlineCoordinatorFactory {
    public init() {}
    
    public func makeFourthlineCoordinator() -> AnyFlowCoordinator<FourthlineInput, FourthlineOutput, APIError> {
        FlowCoordinatorMock<FourthlineInput, FourthlineOutput, APIError>().asAnyFlowCoordinator()
    }

}
