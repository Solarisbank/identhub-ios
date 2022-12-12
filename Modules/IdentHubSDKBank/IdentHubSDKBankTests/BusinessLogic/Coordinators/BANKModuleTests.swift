//
//  BANKModuleTests.swift
//  IdentHubSDKBankTests
//

import XCTest
@testable import IdentHubSDKBank
import IdentHubSDKTestBase

final class BANKModuleTests: XCTestCase {
    func testCoordinatorCreation() {
        let sut = makeSut()

        let qesCoordinator = sut.makeBankCoordinator()
        XCTAssertNotNil(qesCoordinator)
        trackForMemoryLeaks(qesCoordinator)
    }
    
    private func makeSut() -> BankModule {
        let sut = BankModule(serviceLocator: ModuleServiceLocatorMock())
        trackForMemoryLeaks(sut)
        return sut
    }
}
