//
//  CoreModuleTests.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

final class CoreModuleTests: XCTestCase {

    func testCoordinatorCreation() {
        let sut = makeSut()

        let qesCoordinator = sut.makeCoreCoordinator()
        XCTAssertNotNil(qesCoordinator)
        trackForMemoryLeaks(qesCoordinator)
    }
    
    private func makeSut() -> CoreModule {
        let sut = CoreModule(serviceLocator: ModuleServiceLocatorMock())
        trackForMemoryLeaks(sut)
        return sut
    }

}
