//
//  QESModuleTests.swift
//  IdentHubSDKQES
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKCore
import IdentHubSDKTestBase

final class QESModuleTests: XCTestCase {
    func testCoordinatorCreation() {
        let sut = makeSut()

        let qesCoordinator = sut.makeQESCoordinator()
        XCTAssertNotNil(qesCoordinator)
        trackForMemoryLeaks(qesCoordinator)
    }
    
    private func makeSut() -> QESModule {
        let sut = QESModule(serviceLocator: ModuleServiceLocatorMock())
        trackForMemoryLeaks(sut)
        return sut
    }
}
