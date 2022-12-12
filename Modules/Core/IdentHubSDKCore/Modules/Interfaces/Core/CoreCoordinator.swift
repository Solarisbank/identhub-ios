//
//  CoreCoordinator.swift
//  IdentHubSDKCore
//

import Foundation

/// Coordinator presenting Core methods flow.
public protocol CoreCoordinator: FlowCoordinator {
    func start(input: CoreInput, callback: @escaping (Result<CoreOutput, APIError>) -> Void) -> Showable?
}
