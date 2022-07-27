//
//  QESCoordinatorFactory.swift
//  IdentHubSDKCore
//

/// Factory for QES coordinators.
public protocol QESCoordinatorFactory: CoordinatorFactory {
    func makeQESCoordinator() -> AnyFlowCoordinator<QESInput, QESOutput, APIError>
}
