//
//  ShowableFactoryTests.swift
//  IdentHubSDKBankTests
//

import XCTest
@testable import IdentHubSDKBank
import IdentHubSDKTestBase
import IdentHubSDKCore

final class ShowableFactoryTests: XCTestCase {
    var sut: ShowableFactoryImpl!
    
    override func setUp() {
        sut = ShowableFactoryImpl(
            verificationService: VerificationServiceMock(),
            colors: ColorsImpl(),
            storage: StorageMock(),
            presenter: PresenterMock()
        )
    }
    
    func testActionsCreation() {
        XCTAssertNotNil(sut.makeIBANVerificationShowable(input: .init(identificationStep: .bankIBAN), callback: { _ in }))
        XCTAssertNotNil(sut.makePaymentVerificationShowable(input: .init(identificationStep: .bankIBAN), callback: { _ in }))
    }
}
