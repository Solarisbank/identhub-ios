//
//  FourthlineCoordinatorFactory.swift
//  IdentHubSDKCore
//

/// Factory for Fourthline coordinators.
public protocol FourthlineCoordinatorFactory: CoordinatorFactory {
    func makeFourthlineCoordinator() -> AnyFlowCoordinator<FourthlineInput, FourthlineOutput, APIError>
}
