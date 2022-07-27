//
//  RuntimeModuleFactoryTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKCore
import IdentHubSDKTestBase

class RuntimeModuleFactoryTests: XCTestCase {
    var sut: RuntimeModuleFactory!

    override func setUp() {
        sut = RuntimeModuleFactory()
    }
    
    func testModulesResolving() {
        XCTAssertNotNil(sut.makeQES(serviceLocator: ModuleServiceLocatorMock()))
    }
}
