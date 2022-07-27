//
//  Action.swift
//  IdentHubSDKCore
//
import Foundation

/// Represents an action that can be performed resulting in creating a new presentable UI.
///
/// Returned presentable should be presented by the action's caller.
/// Upon completion action should call the callback block providing it's result.
public protocol Action: AnyObject {
    /// Action specific input
    associatedtype ActionInput
    /// Action specific result
    associatedtype ActionResult

    /// Performs the action.
    /// - Parameter input: Required input
    /// - Parameter callback: Called by the action upon completion providing the result
    /// - Returns: UI that should be presented by a presenter
    func perform(input: ActionInput, callback: @escaping (ActionResult) -> Void) -> Showable?
}

/// Type erased Action
public class AnyAction<ActionInput, ActionResult>: Action {
    private var performBlock: (ActionInput, @escaping (ActionResult) -> Void) -> Showable?

    init<A: Action>(_ action: A) where A.ActionInput == ActionInput, A.ActionResult == ActionResult {
        self.performBlock = action.perform
    }

    public func perform(input: ActionInput, callback: @escaping (ActionResult) -> Void) -> Showable? {
        performBlock(input, callback)
    }
}

public extension Action {
    func asAnyAction() -> AnyAction<ActionInput, ActionResult> {
        AnyAction(self)
    }
}
