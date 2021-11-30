//
//  FourthlineIdentCoordinatorMock.swift
//  IdentHubSDKTests
//

import UIKit
@testable import IdentHubSDK



class FourthlineIdentCoordinatorMock: FourthlineIdentCoordinator {
    
    /// Tested perform action value
    var performAction: FourthlineStep = .welcome
    
    // MARK: - Init methods -
    init() {
        let appDependencies = AppDependencies(sessionToken: "")
        let router = IdentHubSDKRouter(rootViewController: UIViewController())
        
        super.init(appDependencies: appDependencies, presenter: router)
    }
    
    /// Mocked method for testing performed action in fourthline coordinator
    /// - Parameter action: simulated action
    override func perform(action: FourthlineStep) {
        performAction = action
    }
}
