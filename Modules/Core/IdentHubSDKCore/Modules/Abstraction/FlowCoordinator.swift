//
//  FlowCoordinator.swift
//  IdentHubSDKCore
//

/// Represents a part of the flow that can be performed resulting in creating a new presentable UI.
///
/// Returned presentable should be presented by the caller.
/// Upon completion coordinator should call the callback block providing it's result.
public protocol FlowCoordinator: AnyObject {
    /// Coordinator's specific input
    associatedtype Input
    /// Coordinator's specific output
    associatedtype Output
    /// Failure type
    associatedtype Failure: Error

    /// Starts the flow.
    /// - Parameter input: Required input
    /// - Parameter callback: Called by the coordinator upon completion providing the result
    /// - Returns: UI that should be presented by a presenter
    func start(input: Input, callback: @escaping (Result<Output, Failure>) -> Void) -> Showable?
}

/// Type erased version of FlowCoordinator
public class AnyFlowCoordinator<Input, Output, Failure: Error>: FlowCoordinator {
    private var startBlock: (Input, (@escaping (Result<Output, Failure>) -> Void)) -> Showable?

    public init<C: FlowCoordinator>(_ coordinator: C) where C.Input == Input, C.Output == Output, C.Failure == Failure {
        self.startBlock = coordinator.start
    }
    
    public func start(input: Input, callback: @escaping (Result<Output, Failure>) -> Void) -> Showable? {
        return startBlock(input, callback)
    }
}

public extension FlowCoordinator {
    func asAnyFlowCoordinator() -> AnyFlowCoordinator<Input, Output, Failure> {
        AnyFlowCoordinator(self)
    }
}
