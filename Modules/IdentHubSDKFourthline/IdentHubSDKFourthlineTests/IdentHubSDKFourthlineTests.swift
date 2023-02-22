//
//  IdentHubSDKFourthlineTests.swift
//  IdentHubSDKFourthlineTests
//

import XCTest
@testable import IdentHubSDKFourthline
import IdentHubSDKTestBase
import IdentHubSDKCore

final class IdentHubSDKFourthlineTests: XCTestCase {

    func testCoordinatorCreation() {
        let sut = makeSut()

        let coordinator = sut.makeFourthlineCoordinator()
        XCTAssertNotNil(coordinator)
        trackForMemoryLeaks(coordinator)
    }
    
    private func makeSut() -> FourthlineModule {
        let sut = FourthlineModule(serviceLocator: ModuleServiceLocatorMock())
        trackForMemoryLeaks(sut)
        return sut
    }

}
