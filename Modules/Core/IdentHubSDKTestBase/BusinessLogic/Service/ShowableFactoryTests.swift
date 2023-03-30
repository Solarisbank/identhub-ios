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
        XCTAssertNotNil(sut.makeRequestsShowable(input: .init(requestsType: .fetchData, initStep: .defineMethod), session: .init(sessionToken: "sessionMock"), callback: { _ in }))
        XCTAssertNotNil(sut.makePhoneVerificationShowable(session: .init(sessionToken: "sessionMock"), callback: { _ in }))
        XCTAssertNotNil(sut.makeTermsShowable(session: .init(sessionToken: "sessionMock"), callback: { _ in }))
    }

}
