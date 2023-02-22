//
//  IdentificationCoordinatorTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKTestBase
import IdentHubSDKCore
@testable import IdentHubSDKQESTests

class IdentificationCoordinatorTests: BaseTestCase {
    var moduleFactory: ModuleFactoryMock!
    
    override func setUp() {
        moduleFactory = ModuleFactoryMock()
    }
    
    override func tearDown() {
        moduleFactory = nil
    }
    
    // MARK: - Test methods -
    
    func testStartAction() throws {
        let sut = try makeSUT()
        sut.start({ _ in })
        
        let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
        XCTAssertEqual(action, IdentificationCoordinator.Action.initialization.rawValue, "Initial coordinator inital step is not correct")
    }
    
    func testPerformInitAction() throws {
        let sut = try makeSUT()
        sut.start({ _ in })
        sut.perform(action: .initialization)
        
        executeAsyncTest {
            let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
            XCTAssertEqual(action, IdentificationCoordinator.Action.initialization.rawValue, "Initial coordinator inital step is not correct")
        }
    }

    func testPerformTermsAndConditionsAction() throws {
        let sut = try makeSUT()
        sut.start({ _ in })
        sut.perform(action: .termsAndConditions)
        
        executeAsyncTest {
            let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
            XCTAssertEqual(action, IdentificationCoordinator.Action.termsAndConditions.rawValue, "Initial coordinator inital step is not correct")
        }
    }

    func testPerformIdentificationAction() throws {
        let sut = try makeSUT()
        sut.start({ _ in })
        sut.perform(action: .identification)
        
        executeAsyncTest {
            let action = try XCTUnwrap(SessionStorage.obtainValue(for: StoredKeys.initialStep.rawValue) as? Int, "Initial action was not stored")
            XCTAssertEqual(action, IdentificationCoordinator.Action.identification.rawValue, "Initial coordinator inital step is not correct")
        }
    }

    func testValidateModulesSuccessful() throws {
        let modularizableMock = ModularizableMock(requiredModules: .init(arrayLiteral: .qes))
        let sut = try makeSUT()
        
        moduleFactory.coreMock = CoreCoordinatorFactoryMock()
        moduleFactory.qesMock = QESCoordinatorFactoryMock()
        
        assertAsync { expectation in
            expectation.isInverted = true
            sut.start({ result in
                expectation.fulfill()
            })
            sut.validateModules(for: modularizableMock)
        }
    }

    func testValidateModulesFailed() throws {
        let modularizableMock = ModularizableMock(requiredModules: .init(arrayLiteral: .qes))
        let sut = try makeSUT()

        moduleFactory.coreMock = CoreCoordinatorFactoryMock()
        
        assertAsync { expectation in
            sut.start({ result in
                XCTAssertEqual(result, .failure(.modulesNotFound(["qes"])))
                expectation.fulfill()
            })
            sut.validateModules(for: modularizableMock)
        }
    }

    func testValidateModulesFailedFallbackStepNotSupported() throws {
        let identificationMethod = IdentificationMethod(firstStep: .partnerFallback, fallbackStep: .fourthlineQES, retries: 1, fourthlineProvider: nil)
        let sut = try makeSUT()
        moduleFactory.coreMock = CoreCoordinatorFactoryMock()

        XCTAssertEqual(identificationMethod.firstStep.requiredModules, [])
        XCTAssertEqual(identificationMethod.fallbackStep?.requiredModules, [.fourthline, .qes])

        assertAsync { expectation in
            sut.start({ result in
                XCTAssertEqual(result, .failure(.modulesNotFound(["fourthline", "qes"])))
                expectation.fulfill()
            })
            
            sut.validateModules(for: identificationMethod)
        }
    }

    // MARK: - Internal methods -

    override func setUpWithError() throws {
        resetStorage()
    }

    override func tearDownWithError() throws {
        resetStorage()
    }
    
    private func makeSUT() throws -> IdentificationCoordinatorMock {
        return try IdentificationCoordinatorMock(moduleFactory: moduleFactory)
    }
}
