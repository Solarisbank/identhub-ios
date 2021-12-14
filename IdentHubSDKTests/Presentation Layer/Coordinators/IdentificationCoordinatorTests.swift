//
//  IdentificationCoordinatorTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class IdentificationCoordinatorTests: BaseTestCase {
    
    // Test variable
    var sut: IdentificationCoordinatorMock?

    // MARK: - Test methods -
    
    func testStartAction() throws {
        sut?.start({ _ in })
        
        let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
        XCTAssertEqual(action, IdentificationCoordinator.Action.initialization.rawValue, "Initial coordinator inital step is not correct")
    }
    
    func testPerformInitAction() throws {
        sut?.perform(action: .initialization)
        
        executeAsyncTest {
            let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
            XCTAssertEqual(action, IdentificationCoordinator.Action.initialization.rawValue, "Initial coordinator inital step is not correct")
        }
    }

    func testPerformTermsAndConditionsAction() throws {
        sut?.perform(action: .termsAndConditions)
        
        executeAsyncTest {
            let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
            XCTAssertEqual(action, IdentificationCoordinator.Action.termsAndConditions.rawValue, "Initial coordinator inital step is not correct")
        }
    }

    func testPerformIdentificationAction() throws {
        sut?.perform(action: .identification)
        
        executeAsyncTest {
            let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
            XCTAssertEqual(action, IdentificationCoordinator.Action.identification.rawValue, "Initial coordinator inital step is not correct")
        }
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
    
    private func makeSUT() -> IdentificationCoordinatorMock {
        return IdentificationCoordinatorMock()
    }
}
