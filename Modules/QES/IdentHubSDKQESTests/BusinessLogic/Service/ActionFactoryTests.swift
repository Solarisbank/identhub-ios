//
//  ActionFactoryTests.swift
//  IdentHubSDKQESTests
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKTestBase
import IdentHubSDKCore

final class ActionFactoryTests: XCTestCase {
    var sut: ActionFactoryImpl!
    
    override func setUp() {
        sut = ActionFactoryImpl(
            verificationService: VerificationServiceMock(),
            colors: ColorsImpl(),
            presenter: PresenterMock()
        )
    }

    func testActionsCreation() {
        XCTAssertNotNil(sut.makeQuitAction())
        XCTAssertNotNil(sut.makeSignDocumentsAction())
        XCTAssertNotNil(sut.makePreviewDocumentAction())
        XCTAssertNotNil(sut.makeDownloadDocumentAction())
        XCTAssertNotNil(sut.makeSignDocumentsAction())
    }
}
