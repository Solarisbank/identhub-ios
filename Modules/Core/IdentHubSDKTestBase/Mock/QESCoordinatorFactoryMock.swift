//
//  QESCoordinatorFactoryMock.swift
//  IdentHubSDKQESTests
//
import IdentHubSDKCore

public struct QESCoordinatorFactoryMock: QESCoordinatorFactory {
    public init() {}

    public func makeQESCoordinator() -> AnyFlowCoordinator<QESInput, QESOutput, APIError> {
        return FlowCoordinatorMock<QESInput, QESOutput, APIError>().asAnyFlowCoordinator()
    }
}
