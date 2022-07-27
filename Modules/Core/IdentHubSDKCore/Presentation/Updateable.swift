//
//  Updateable.swift
//  IdentHubSDKCore
//

public typealias UpdateableShowable = Updateable & Showable

public protocol Updateable {
    associatedtype ViewState
    associatedtype EventHandler
    var eventHandler: EventHandler? { get set }
    func updateView(_ state: ViewState)
}
