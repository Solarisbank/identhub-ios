//
//  FourthlineIdentCoordinatorMock.swift
//  IdentHubSDKTests
//

import UIKit
@testable import IdentHubSDK
import IdentHubSDKTestBase

class FourthlineIdentCoordinatorMock: FourthlineIdentCoordinator {
    
    /// Tested perform action value
    var performAction: FourthlineStep = .welcome
    
    // MARK: - Init methods -
    init() throws {
        let appDependencies = AppDependencies(sessionToken: "", presenter: PresenterMock())
        let rootViewController = UIViewController()
        let identHubSession = try IdentHubSession(rootViewController: rootViewController, sessionURL: "https://solarisssandbox.de/sesionToken-abcdefgHIJKlmnoprsTQUWXyz0123456789")
        let router = IdentHubSDKRouter(rootViewController: UIViewController(), identHubSession: identHubSession)
        
        super.init(appDependencies: appDependencies, presenter: router)
    }
    
    /// Mocked method for testing performed action in fourthline coordinator
    /// - Parameter action: simulated action
    override func perform(action: FourthlineStep) {
        performAction = action
    }
}
