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
        let expectedRequestPath = String(describing: "/mobile_number/authorize")
        sut.authorizeMobileNumber(completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Mobile number authorization command was not executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .post, "Mobile number auth command request HTTP method is not POST")
        XCTAssertEqual(apiClient.inputRequest?.path, expectedRequestPath, "Mobile number auth command request path is not valid")
    }
    
    /// Method tested Get mobile number
    /// In request used fake token
    /// Method tests:
    ///  - Get mobile number method execution status
    ///  - type of request
    ///  - auth request path
    func testGetMobileNumberRequest() {
        let sut = makeSUT()
        let expectedRequestPath = String(describing: "/mobile_number")
        sut.getMobileNumber(completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Get Mobile number command was not executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .get, "Get Mobile number command request HTTP method is not GET")
        XCTAssertEqual(apiClient.inputRequest?.path, expectedRequestPath, "Get Mobile number command request path is not valid")
    }

    /// Method tested mobile number confirm process
    /// Request used fake token number
    /// Method tests:
    ///  - confirm method execution status
    ///  - type of request
    ///  - auth request path
    func testMmobileNumberTANRequest() {
        let sut = makeSUT()
        let reqPath = String(describing: "/mobile_number/confirm")
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
        let reqPath = String(describing: "/iban/verify")
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
        let request = String(describing: "/sign_documents/\(iduid)/authorize")

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
        let request = String(describing: "/sign_documents/\(iduid)/confirm")

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
        let request = String(describing: "/identifications/\(iduid)")

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
        let request = String(describing: "/sign_documents/\(docID)/download")

        sut.getDocument(documentId: docID, completionHandler: { _ in })

        XCTAssertTrue(apiClient.downloadCommandCalled, "Get identification download command wasn't executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .get, "Get document request HTTP method is not correct")
        XCTAssertEqual(apiClient.inputRequest?.path, request, "Get document request path is not correct")
    }
    
    /// Method tested fetching Fourthline simplified identification detail information request and modelf
    /// Method used mocked verification service object.
    /// Method tests:
    /// - First step of ident flow
    /// - Fourthline provider string
    func testFourthlineMethodDetail() {
        let sut = makeMockSUT()
        
        sut.testMethod = .fourthlineSimplified
        
        sut.defineIdentificationMethod { response in
            switch response {
            case .success(let method):
                XCTAssertEqual(method.firstStep, .fourthline, "First step in Fourthline simplified ident process is not correct.")
                XCTAssertEqual(method.fourthlineProvider, "FourthlineSimplifiedProvider", "Test fourthline provider is not correct")
            case .failure(let error):
                XCTFail("Mock response object is not valid for model IdentificationMethod. Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Method tested fetching Fourthline signing identification detail information request and modelf
    /// Method used mocked verification service object.
    /// Method tests:
    /// - First step of ident flow
    /// - Fourthline provider string
    func testFourthlineSigningMethodDetail() {
        let sut = makeMockSUT()
        
        sut.testMethod = .fourthlineSigning
        
        sut.defineIdentificationMethod { response in
            switch response {
            case .success(let method):
                XCTAssertEqual(method.firstStep, .fourthlineSigning, "First step in Fourthline simplified ident process is not correct.")
                XCTAssertEqual(method.fourthlineProvider, "FourthlineSigningProvider", "Test fourthline provider is not correct")
            case .failure(let error):
                XCTFail("Mock response object is not valid for model IdentificationMethod. Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Method tested fetching Bank identification detail information request and modelf
    /// Method used mocked verification service object.
    /// Method tests:
    /// - First step of ident flow
    /// - IBAN fail retries count
    /// - Fallback step for Bank flow
    func testBankMethodDetail() {
        let sut = makeMockSUT()
        
        sut.testMethod = .bank
        
        sut.defineIdentificationMethod { response in
            switch response {
            case .success(let method):
                XCTAssertEqual(method.firstStep, .bankIBAN, "First step in Fourthline simplified ident process is not correct.")
                XCTAssertEqual(method.retries, 5, "Test IBAN retries count is not correct.")
                XCTAssertEqual(method.fallbackStep, .fourthline, "Test IBAN fallback flow is not correct.")
            case .failure(let error):
                XCTFail("Mock response object is not valid for model IdentificationMethod. Error: \(error.localizedDescription)")
            }
        }
    }
    
    /// Method tested fetching BankID identification detail information request and modelf
    /// Method used mocked verification service object.
    /// Method tests:
    /// - First step of ident flow
    /// - IBAN fail retries count
    func testBankIDMethodDetail() {
        let sut = makeMockSUT()
        
        sut.testMethod = .bankID
        
        sut.defineIdentificationMethod { response in
            switch response {
            case .success(let method):
                XCTAssertEqual(method.firstStep, .bankIDIBAN, "First step in Fourthline simplified ident process is not correct.")
                XCTAssertEqual(method.retries, 5, "Test IBAN retries count is not correct.")
            case .failure(let error):
                XCTFail("Mock response object is not valid for model IdentificationMethod. Error: \(error.localizedDescription)")
            }
        }
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
        let service = VerificationServiceImplementation(apiClient: apiClient, sessionInfoProvider: defaultStorage!)
        
        trackForMemoryLeaks(service)
        
        return service
    }
    
    /// Method built mock verification service with mocked API client.
    /// - Returns: initialized verification service
    func makeMockSUT() -> VerificationServiceMock {
        return VerificationServiceMock()
    }

    /// Method reset all tested service properties
    func resetTestValues() {
        defaultStorage = StorageSessionInfoProvider(sessionToken: token)
        apiClient.inputRequest = nil
        apiClient.executeCommandCalled = false
        apiClient.downloadCommandCalled = false
    }
}
