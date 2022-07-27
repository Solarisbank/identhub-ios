//
//  CoordinatorPerformer.swift
//  IdentHubSDKCore
//

/// Invokes coordinators and manages their life cycle
public class FlowCoordinatorPerformer {
    private var coordinators = [AnyObject]()
    
    public init() {}

    /// Performs a flow with coordinator.
    /// - Parameter coordinator: Coordinator to perform
    /// - Parameter input: Input for the coordinator
    /// - Parameter callback: Handles coordinator's result. It should return true if coordinator is completed and can be released from memory.
    public func startCoordinator<T: FlowCoordinator>(
        _ coordinator: T,
        input: T.Input,
        callback: @escaping (Result<T.Output, T.Failure>) -> Bool
    ) -> Showable? {

        coordinators.append(coordinator)
        return coordinator.start(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }

            if callback(result) {
                self.coordinators.removeAll(where: { $0 === coordinator })
            }
        }
    }
}
