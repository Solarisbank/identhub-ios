//
//  ActionPerformer.swift
//  IdentHubSDKCore
//

/// Performs actions and manages their lifecycle.
public class ActionPerformer {
    public private(set) var actions = [AnyObject]()
    
    public init() {}
    
    /// Performs an action
    /// - Parameter action: Action to perform
    /// - Parameter input: Input for the action
    /// - Parameter callback: Handles action's result. It should return true if action is completed and can be released from memory.
    public func performAction<A: Action>(
        _ action: A,
        input: A.ActionInput,
        callback: @escaping (A.ActionResult) -> Bool
    ) -> Showable? {

        if actions.filter({ $0 === action }).isEmpty {
            actions.append(action)
        } else {
            print("Warning! Duplicated action \(action) detected")
        }

        return action.perform(input: input) { [weak self] result in
            guard let self = self else {
                Assert.notNil(self)
                return
            }

            if callback(result) {
                self.actions.removeAll(where: { $0 === action })
            }
        }
    }
    
    public func performAction<A: Action>(
        _ action: A,
        callback: @escaping (A.ActionResult) -> Bool
    ) -> Showable? where A.ActionInput == Void {
        performAction(action, input: (), callback: callback)
    }
}
