//
//  ShowableFactoryTests.swift
//  IdentHubSDKQESTests
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKTestBase
import IdentHubSDKCore

final class ShowableFactoryTests: XCTestCase {
    var sut: ShowableFactoryImpl!
    
    override func setUp() {
        sut = ShowableFactoryImpl(
            verificationService: VerificationServiceMock(),
            colors: ColorsImpl(),
            presenter: PresenterMock()
        )
    }

    func testActionsCreation() {
        XCTAssertNotNil(sut.makeSignDocumentsShowable(input: .init(identificationUID: "UIDMock", mobileNumber: nil), callback: { _ in }))
        XCTAssertNotNil(sut.makeConfirmApplicationShowable(input: .init(identificationUID: "UIDMock"), callback: { _ in }))
    }
}
