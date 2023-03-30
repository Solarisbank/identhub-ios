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

        let bankCoordinator = sut.makeBankCoordinator()
        XCTAssertNotNil(bankCoordinator)
        trackForMemoryLeaks(bankCoordinator)
    }
    
    private func makeSut() -> BankModule {
        let sut = BankModule(serviceLocator: ModuleServiceLocatorMock())
        trackForMemoryLeaks(sut)
        return sut
    }
}
