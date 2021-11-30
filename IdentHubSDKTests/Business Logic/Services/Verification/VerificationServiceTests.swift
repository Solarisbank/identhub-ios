//
//  VerificationServiceTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class VerificationServiceTests: XCTestCase {

    /// Test token value, used in APIClientMock class for internal testing
    let token: String = "test_token_b79244907a97f325b83207443b29af84cpar;"
    let apiClient = APIClientMock()
    var defaultStorage: StorageSessionInfoProvider?

    // MARK: - Tests methods -

    /// Test authentication of mobile number with mock API client.
    /// In request used fake token
    /// Method tests:
    ///  - auth method execution status
    ///  - type of request
    ///  - auth request path
    func testAuthMobileNumberRequest() {
        let sut = makeSUT()
        let expectedRequestPath = String(describing: "/\(token)/mobile_number/authorize")
        sut.authorizeMobileNumber(completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Mobile number authorization command was not executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .post, "Mobile number auth command request HTTP method is not POST")
        XCTAssertEqual(apiClient.inputRequest?.path, expectedRequestPath, "Mobile number auth command request path is not valid")
    }

    /// Method tested mobile number confirm process
    /// Request used fake token number
    /// Method tests:
    ///  - confirm method execution status
    ///  - type of request
    ///  - auth request path
    func testMmobileNumberTANRequest() {
        let sut = makeSUT()
        let reqPath = String(describing: "/\(token)/mobile_number/confirm")
        let token = "7cff7e6cf4e431c1fc99d15cc30b2652ises"

        sut.verifyMobileNumberTAN(token: token, completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Mobile number TAN verification command was not executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .post, "Mobile number TAN verification command request HTTP method is not POST")
        XCTAssertEqual(apiClient.inputRequest?.path, reqPath, "Mobile number TAN verification command request path is not valid")
    }

    /// Method tested IBAN verification request
    /// Used fake iban value for building mock request path
    /// Method tests:
    ///  - verify method execution status
    ///  - type of request
    ///  - custom request path
    func testIBANVerification() {
        let sut = makeSUT()
        let reqPath = String(describing: "/\(token)/iban/verify")
        let iban = "DE11231231231231"

        sut.verifyIBAN(iban, completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "IBAN verification request wasn't executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .post, "IBAN verification request HTTP method is not correct")
        XCTAssertEqual(apiClient.inputRequest?.path, reqPath, "IBAN verification request path is not correct")
    }

    /// Method tested documents authorize mock request
    /// Used fake identifierUID value
    /// Method tests:
    ///  - doc auth method execution status
    ///  - type of request
    ///  - custom request path
    func testAuthorizeDocuments() {
        let iduid = "c4bd19319a6f4b258c03687be2773a14avi"

        defaultStorage?.identificationUID = iduid

        let sut = makeSUT()
        let request = String(describing: "/\(token)/sign_documents/\(iduid)/authorize")

        sut.authorizeDocuments(completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Documents authorize request wasn't executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .patch, "Documents authorize request HTTP method is not correct")
        XCTAssertEqual(apiClient.inputRequest?.path, request, "Documents authorize request path is not correct")
    }

    /// Method tested document TAN value verification
    /// Used fake identificationUID and doc token value
    /// Method tests:
    ///  - verification document TAN value method execution status
    ///  - type of request
    ///  - custom request path
    func testVerifyDocumentsTAN() {
        let iduid = "c4bd19319a6f4b258c03687be2773a14avi"
        let docToken = "7cff7e6cf4e431c1fc99d15cc30b2652ises"

        defaultStorage?.identificationUID = iduid

        let sut = makeSUT()
        let request = String(describing: "/\(token)/sign_documents/\(iduid)/confirm")

        sut.verifyDocumentsTAN(token: docToken, completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Documents verification request wasn't executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .patch, "Documents verification request HTTP method is not correct")
        XCTAssertEqual(apiClient.inputRequest?.path, request, "Documents verification request path is not correct")
    }

    /// Method tested fetching identification value request
    /// Used fake identificationUID value for building request path
    /// Method tests:
    ///  - get identification method execution status
    ///  - type of request
    ///  - custom request path
    func testGetIdentification() {
        let iduid = "c4bd19319a6f4b258c03687be2773a14avi"

        defaultStorage?.identificationUID = iduid

        let sut = makeSUT()
        let request = String(describing: "/\(token)/identifications/\(iduid)")

        sut.getIdentification(completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Get identification request wasn't executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .get, "Get identification request HTTP method is not correct")
        XCTAssertEqual(apiClient.inputRequest?.path, request, "Get identification request path is not correct")
    }

    /// Method download document task
    /// Method used fake doc identifier value for building custom request path
    /// Method tests:
    ///  - downloading method status
    ///  - type of request
    ///  - loading server path
    func testGetDocument() {
        let sut = makeSUT()
        let docID = "9536e7a3da5a00f15670ef5f459984e4cper"
        let request = String(describing: "/\(token)/sign_documents/\(docID)/download")

        sut.getDocument(documentId: docID, completionHandler: { _ in })

        XCTAssertTrue(apiClient.downloadCommandCalled, "Get identification download command wasn't executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .get, "Get document request HTTP method is not correct")
        XCTAssertEqual(apiClient.inputRequest?.path, request, "Get document request path is not correct")
    }

    // MARK: - Internal methods -

    /// Method executed before starting every test
    /// Used for reseting validation and storage values
    /// - Throws: - method can throw fail error
    override func setUpWithError() throws {
        resetTestValues()
    }

    /// Method built verification service object wtih mock api client. SUT - service under test
    /// - Returns: initialized verification service
    func makeSUT() -> VerificationService {
        return VerificationServiceImplementation(apiClient: apiClient, sessionInfoProvider: defaultStorage!)
    }

    /// Method reset all tested service properties
    func resetTestValues() {
        defaultStorage = StorageSessionInfoProvider(sessionToken: token)
        apiClient.inputRequest = nil
        apiClient.executeCommandCalled = false
        apiClient.downloadCommandCalled = false
    }
}
