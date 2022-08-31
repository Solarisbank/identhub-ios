//
//  EventHandlerMock.swift
//  IdentHubSDKTestBase
//
import IdentHubSDKCore

public final class EventHandlerMock<Event>: EventHandler {
    public init() {}
    public func handleEvent(_ event: Event) {}
}
