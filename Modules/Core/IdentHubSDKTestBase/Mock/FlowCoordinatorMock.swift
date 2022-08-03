//
//  FlowCoordinatorMock.swift
//  IdentHubSDKQESTests
//

import IdentHubSDKCore

public class FlowCoordinatorMock<Input, Output, Failure: Error>: FlowCoordinator {
    public init() {}

    public func start(input: Input, callback: @escaping (Result<Output, Failure>) -> Void) -> Showable? {
        return nil
    }
}
