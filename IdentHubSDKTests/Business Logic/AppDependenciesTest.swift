//
//  AppDependenciesTest.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK
import IdentHubSDKTestBase

class AppDependenciesTest: XCTestCase {

    /// Test session token, used just for the tests execution
    let sessionToken = "b79244907a97f325b83207443b29af84cpar;9536e7a3da5a00f15670ef5f459984e4cper;7cff7e6cf4e431c1fc99d15cc30b2652ises"

    // MARK: - Tests methods methods -

    /// Method tested if app dependencies instance contained session token from the box
    func testSessionToken() {
        let sut = makeSut()

        XCTAssertEqual(sut.sessionInfoProvider.sessionToken, sessionToken, "Session provider initialized with nil session token")
    }

    /// Method tested case if app dependencies contained empty session token if init method take empty string
    func testEmptyToken() {
        let sut = AppDependencies(sessionToken: "", presenter: PresenterMock())

        XCTAssertTrue(sut.sessionInfoProvider.sessionToken.isEmpty, "Session token is not empty by default")
    }

    /// Test default values of the initialized AppDependencies object
    /// Tested parameters:
    ///     - Session info provider (provider stored values like: session token, mobile number, ID, doc id, etc.
    ///     - APIClient, service for making server requests
    ///     - Verification service, used for calling server request and process responses
    func testMainPropertiesNotNil() {
        let sut = makeSut()

        XCTAssertNotNil(sut.sessionInfoProvider, "Session info provider not initialized properly")
        XCTAssertNotNil(sut.serviceLocator.apiClient, "API client property not initialized properly")
        XCTAssertNotNil(sut.verificationService, "Verification service is not initialized properly")
    }

    // MARK: - Internal methods -
    func makeSut() -> AppDependencies {
        return AppDependencies(sessionToken: sessionToken, presenter: PresenterMock())
    }
}
