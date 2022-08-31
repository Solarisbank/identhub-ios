//
//  EventHandler.swift
//  IdentHubSDKCore
//

/// Handles events triggered from the UI. Used by UIViewController implementations.
public protocol EventHandler: AnyObject {
    associatedtype Event

    /// Handles event
    /// - Parameter event: event to handle
    func handleEvent(_ event: Event)
}

/// Type erased EventHandler
public class AnyEventHandler<Event>: EventHandler {
    private let handleEventBlock: (Event) -> Void

    public init<SomeEventHandler: EventHandler>(eventHandler: SomeEventHandler) where SomeEventHandler.Event == Event {
        handleEventBlock = eventHandler.handleEvent
    }

    public func handleEvent(_ event: Event) {
        handleEventBlock(event)
    }
}

public extension EventHandler {
    func asAnyEventHandler() -> AnyEventHandler<Event> {
        AnyEventHandler(eventHandler: self)
    }
}
