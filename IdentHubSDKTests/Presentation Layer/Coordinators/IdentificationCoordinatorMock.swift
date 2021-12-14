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
    init() {
        let appDependencies = AppDependencies(sessionToken: "")
        let router = IdentHubSDKRouter(rootViewController: UIViewController())
        
        super.init(appDependencies: appDependencies, presenter: router)
    }
    
    /// Mocked method for testing performed action in fourthline coordinator
    /// - Parameter action: simulated action
    override func perform(action: Action) {
        performAction = action
        super.perform(action: action)
    }
}
