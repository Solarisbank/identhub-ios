//
//  IdentificationCoordinatorMock.swift
//  IdentHubSDKTests
//

import UIKit
@testable import IdentHubSDK

class IdentificationCoordinatorMock: IdentificationCoordinator {

    /// Tested perform action value
    var performAction: Action?
    
    // MARK: - Init methods -
    init() throws {
        let appDependencies = AppDependencies(sessionToken: "")
        let rootViewController = UIViewController()
        let identHubSession = try IdentHubSession(rootViewController: rootViewController, sessionURL: "https://solarisssandbox.de/sesionToken-abcdefgHIJKlmnoprsTQUWXyz0123456789")
        let router = IdentHubSDKRouter(rootViewController: rootViewController, identHubSession: identHubSession)
        
        super.init(appDependencies: appDependencies, presenter: router)
    }
    
    /// Mocked method for testing performed action in fourthline coordinator
    /// - Parameter action: simulated action
    override func perform(action: Action) {
        performAction = action
        super.perform(action: action)
    }
}
