//
//  IdentificationCoordinatorTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class IdentificationCoordinatorTests: XCTestCase {
    
    // Test variable
    let appDependencies = AppDependencies(sessionToken: "")
    let router = IdentHubSDKRouter(rootViewController: UIViewController())
    var sut: IdentificationCoordinator?

    // MARK: - Test methods -
    
    func testStartAction() throws {
        sut?.start({ _ in })
        
        let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
        XCTAssertEqual(action, IdentificationCoordinator.Action.initialization.rawValue, "Initial coordinator inital step is not correct")
    }
    
    func testPerformInitAction() throws {
        sut?.perform(action: .initialization)
        
        XCTExpectFailure("Method failed because requires PR#145")
        let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
        XCTAssertEqual(action, IdentificationCoordinator.Action.initialization.rawValue, "Initial coordinator inital step is not correct")
    }
    
    func testPerformTermsAndConditionsAction() throws {
        sut?.perform(action: .termsAndConditions)
        
        XCTExpectFailure("Method failed because requires PR#145")
        let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
        XCTAssertEqual(action, IdentificationCoordinator.Action.termsAndConditions.rawValue, "Initial coordinator inital step is not correct")
    }
    
    func testPerformIdentificationAction() throws {
        sut?.perform(action: .identification)
        
        XCTExpectFailure("Method failed because requires PR#145")
        let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
        XCTAssertEqual(action, IdentificationCoordinator.Action.identification.rawValue, "Initial coordinator inital step is not correct")
    }

    
    // MARK: - Internal methods -

    override func setUpWithError() throws {
        resetStorage()
        sut = makeSUT()
    }

    override func tearDownWithError() throws {
        sut = nil
        resetStorage()
    }
    
    private func makeSUT() -> IdentificationCoordinator {
        return IdentificationCoordinator(appDependencies: appDependencies, presenter: router)
    }
    
    private func resetStorage() {
        // Identification steps stored to the user defaults and should be reset before test
        SessionStorage.updateValue("", for: StoredKeys.initialStep.rawValue)
    }
}
