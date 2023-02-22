//
//  Presenter.swift
//  IdentHubSDKCore
//

/// Manages display of presentables.
public protocol Presenter {
    /// - Returns: Currently displayed showable
    var topShowable: Showable { get }

    /// Pushes showable to the presented stack
    /// - Parameter showable: Showable to show
    func push(_ showable: Showable, animated: Bool, completion: (() -> Void)?)

    /// Presents showable
    func present(_ showable: Showable, animated: Bool)
    
    /// Pop showable
    func pop(_ showable: Showable, animated: Bool)
    
    /// - Returns: Navigation stack has only available controller?
    func isNavigationControllersEmpty() -> Bool
}
