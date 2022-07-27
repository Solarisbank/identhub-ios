//
//  PresenterMock.swift
//  IdentHubSDKTestBase
//
import IdentHubSDKCore
import UIKit

public struct PresenterMock: Presenter {
    public var topShowable: Showable = UIViewController()
    
    public init() {}

    public func push(_ showable: Showable, animated: Bool, completion: (() -> Void)?) {}
    
    public func present(_ showable: Showable, animated: Bool) {}
}
