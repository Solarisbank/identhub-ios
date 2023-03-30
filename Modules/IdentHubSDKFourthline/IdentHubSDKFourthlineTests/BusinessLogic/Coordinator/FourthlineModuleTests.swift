//
//  FourthlineModuleTests.swift
//  IdentHubSDKFourthlineTests

import XCTest
@testable import IdentHubSDKFourthline
import IdentHubSDKTestBase

final class FourthlineModuleTests: XCTestCase {
    func testCoordinatorCreation() {
        let sut = makeSut()

        let fourthlineCoordinator = sut.makeFourthlineCoordinator()
        XCTAssertNotNil(fourthlineCoordinator)
        trackForMemoryLeaks(fourthlineCoordinator)
    }
    
    private func makeSut() -> FourthlineModule {
        let sut = FourthlineModule(serviceLocator: ModuleServiceLocatorMock())
        trackForMemoryLeaks(sut)
        return sut
    }
}
