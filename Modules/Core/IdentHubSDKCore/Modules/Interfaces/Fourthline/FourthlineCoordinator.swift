//
//  FourthlineCoordinator.swift
//  IdentHubSDKCore
//

/// Coordinator presenting Fourthline application.
public protocol FourthlineCoordinator: FlowCoordinator {
    func start(input: FourthlineInput, callback: @escaping (Result<FourthlineOutput, APIError>) -> Void) -> Showable?
}
