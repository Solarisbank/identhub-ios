//
//  CoreCoordinatorFactory.swift
//  IdentHubSDKCore
//

import Foundation

/// Factory for Core coordinators.
public protocol CoreCoordinatorFactory: CoordinatorFactory {
    func makeCoreCoordinator() -> AnyFlowCoordinator<CoreInput, CoreOutput, APIError>
}
