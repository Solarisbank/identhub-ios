//
//  ShowableFactoryTests.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

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
        XCTAssertNotNil(sut.makePhoneVerificationShowable(input: .init(identificationStep: .mobileNumber), callback: { _ in }))
    }

}
