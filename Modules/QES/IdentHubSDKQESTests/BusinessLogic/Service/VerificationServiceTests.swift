//
//  VerificationServiceTests.swift
//  IdentHubSDKQESTests
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKCore
import IdentHubSDKTestBase

final class VerificationServiceTests: XCTestCase {
    private let token: String = "test_token_b79244907a97f325b83207443b29af84cpar;"
    private let uid = "c4bd19319a6f4b258c03687be2773a14avi"
    private let documentToken = "7cff7e6cf4e431c1fc99d15cc30b2652ises"
    
    private var apiClient: APIClientMock!
    private var fileStorage: FileStorageMock!

    override func setUp() {
        super.setUp()
        
        apiClient = APIClientMock()
        fileStorage = FileStorageMock()
    }
    
    override func tearDown() {
        super.tearDown()
        
        apiClient = nil
        fileStorage = nil
    }

    // MARK: - authorizeDocuments
    
    func test_authorizeDocuments_invokesRequestWithExpectedParameters() throws {
        let expectedRequest = try DocumentsAuthorizeRequest(identificationUID: uid)
        
        let sut = makeSut()

        sut.authorizeDocuments(identificationUID: uid, completionHandler: { _ in })

        XCTAssertEqual(apiClient.executeCallsCount, 1)
        XCTAssertEqual(apiClient.executeRequestArguments.last as? DocumentsAuthorizeRequest, expectedRequest)
    }
    
    func test_authorizeDocuments_apiCompletesWithSuccess_completesWithExpectedResponse() throws {
        let expectedRequest = try DocumentsAuthorizeRequest(identificationUID: uid)
        let expectedValue = Identification.mock()
        
        let sut = makeSut()

        apiClient.expectSuccess(value: expectedValue, for: expectedRequest)
        
        assertAsync { expectation in
            sut.authorizeDocuments(identificationUID: uid) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_authorizeDocuments_apiCompletesWithFailure_completesWithExpectedResponse() throws {
        let expectedRequest = try DocumentsAuthorizeRequest(identificationUID: uid)
        let expectedError = ResponseError(.unknownError)
                
        let sut = makeSut()
        
        apiClient.expectFailure(Identification.self, error: expectedError, for: expectedRequest)
        
        assertAsync { expectation in
            sut.authorizeDocuments(identificationUID: uid) { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    // MARK: - verifyDocumentsTAN

    func test_verifyDocumentsTAN_invokesRequestWithExpectedParameters() throws {
        let expectedRequest = try DocumentsTANRequest(identificationUID: uid, token: documentToken)

        let sut = makeSut()

        sut.verifyDocumentsTAN(identificationUID: uid, token: documentToken, completionHandler: { _ in })

        XCTAssertEqual(apiClient.executeCallsCount, 1)
        XCTAssertEqual(apiClient.executeRequestArguments.last as? DocumentsTANRequest, expectedRequest)
    }
    
    func test_verifyDocumentsTAN_apiCompletesWithSuccess_completesWithExpectedResponse() throws {
        let expectedValue = Identification.mock()
        let expectedRequest = try DocumentsTANRequest(identificationUID: uid, token: documentToken)
        
        let sut = makeSut()
        
        apiClient.expectSuccess(value: expectedValue, for: expectedRequest)
        
        assertAsync { expectation in
            sut.verifyDocumentsTAN(identificationUID: uid, token: documentToken) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_verifyDocumentsTAN_apiCompletesWithFailure_completesWithExpectedResponse() throws {
        let expectedError = ResponseError.init(.unknownError)
        let expectedRequest = try DocumentsTANRequest(identificationUID: uid, token: documentToken)
        
        let sut = makeSut()
        
        apiClient.expectFailure(Identification.self, error: expectedError, for: expectedRequest)
        
        assertAsync { expectation in
            sut.verifyDocumentsTAN(identificationUID: uid, token: documentToken) { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    // MARK: - getIdentification

    func test_getIdentification_invokesRequestWithExpectedParameters() throws {
        let expectedRequest = try IdentificationRequest(identificationUID: uid)
        let sut = makeSut()

        sut.getIdentification(for: uid, completionHandler: { _ in })

        XCTAssertEqual(apiClient.executeCallsCount, 1)
        XCTAssertEqual(apiClient.executeRequestArguments.last as? IdentificationRequest, expectedRequest)
    }
    
    func test_getIdentification_apiCompletesWithSuccess_completesWithExpectedResponse() throws {
        let expectedRequest = try IdentificationRequest(identificationUID: uid)
        let expectedValue = Identification.mock()
        let sut = makeSut()
        
        apiClient.expectSuccess(value: expectedValue, for: expectedRequest)

        assertAsync { expectation in
            sut.getIdentification(for: uid) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_getIdentification_apiCompletesWithFailure_completesWithExpectedResponse() throws {
        let expectedRequest = try IdentificationRequest(identificationUID: uid)
        let expectedError = ResponseError.init(.unknownError)
        let sut = makeSut()
        
        apiClient.expectFailure(Identification.self, error: expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.getIdentification(for: uid) { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    // MARK: - getMobileNumberRequest

    func test_getMobileNumberRequest_invokesRequestWithExpectedParameters() {
        let expectedRequest = MobileNumberRequest()
        
        let sut = makeSut()

        sut.getMobileNumber(completionHandler: { _ in })

        XCTAssertEqual(apiClient.executeCallsCount, 1)
        XCTAssertEqual(apiClient.executeRequestArguments.last as? MobileNumberRequest, expectedRequest)
    }
    
    func test_getMobileNumberRequest_apiCompletesWithSuccess_completesWithExpectedResponse() {
        let expectedRequest = MobileNumberRequest()
        let expectedValue = MobileNumber.mock()
        
        let sut = makeSut()
        
        apiClient.expectSuccess(value: expectedValue, for: expectedRequest)

        assertAsync { expectation in
            sut.getMobileNumber { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_getMobileNumberRequest_apiCompletesWithFailure_completesWithExpectedResponse() {
        let expectedRequest = MobileNumberRequest()
        let expectedError = ResponseError.init(.unknownError)
        
        let sut = makeSut()
        
        apiClient.expectFailure(MobileNumber.self, error: expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.getMobileNumber { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    // MARK: - downloadAndSaveDocument
    
    func test_downloadAndSaveDocument_invokesRequestWithExpectedParameters() throws {
        let expectedRequest = try DocumentDownloadRequest(documentUID: documentToken)
        
        let sut = makeSut()
        
        sut.downloadAndSaveDocument(withId: documentToken) { _ in }
        
        XCTAssertEqual(apiClient.downloadCallsCount, 1)
        XCTAssertEqual(apiClient.downloadRequestArguments.last as? DocumentDownloadRequest, expectedRequest)
    }
    
    func test_downloadAndSaveDocument_apiCompletesWithSuccessWithURLNotNil_completesWithExpectedResponse() throws {
        let expectedValue = URL(string: "https://solarisbank.de/filename")
        let sut = makeSut()
        
        apiClient.downloadResult = .success(expectedValue)
        
        assertAsync { expectation in
            sut.downloadAndSaveDocument(withId: documentToken) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_downloadAndSaveDocument_apiCompletesWithSuccessWithURLNil_completesWithExpectedResponse() throws {
        let expectedValue: URL? = nil
        let sut = makeSut()
        
        apiClient.downloadResult = .success(expectedValue)
        
        assertAsync { expectation in
            sut.downloadAndSaveDocument(withId: documentToken) { result in
                XCTAssertResultIsFailure(result) { error in
                    if case .fileDownloadError(let actualError) = error {
                        if let apiError = actualError as? APIError,
                            apiError == APIError.resourceNotFound {

                            expectation.fulfill()
                        } else {
                            XCTFail("Wrong actual error \(String(describing: actualError))")
                        }
                    } else {
                        XCTFail("Wrong error \(error)")
                    }
                }
            }
        }
    }

    private func makeSut() -> VerificationService {
        VerificationServiceImpl(
            apiClient: apiClient,
            fileStorage: fileStorage
        )
    }
}

// TODO: Merge two APIClientMock implementations
private class APIClientMock: APIClient {
    private struct _Decodable: Decodable {}

    typealias AnyDecodableResult = Result<Decodable, ResponseError>
    
    var executeCallsCount = 0
    var executeRequestArguments: [Request] = []
    
    var downloadCallsCount = 0
    var downloadRequestArguments: [Request] = []
    var downloadResult: Result<URL?, ResponseError>?
    
    private var expectations = [(id: String, result: AnyDecodableResult)]()
    
    func execute<DataType>(request: Request, answerType: DataType.Type, completion: @escaping (Result<DataType, ResponseError>) -> Void) where DataType: Decodable {
        executeCallsCount += 1
        
        executeRequestArguments.append(request)
        
        if let result: Result<DataType, ResponseError> = popFirstMatchingExpectationResult(for: request) {
            completion(result)
        }
    }
    
    func download(request: Request, completion: @escaping (Result<URL?, ResponseError>) -> Void) {
        downloadCallsCount += 1
        
        downloadRequestArguments.append(request)
        
        if let result = downloadResult {
            completion(result)
        }
    }
    
    func expectSuccess<T: Decodable>(value: T, for request: Request) {
        let result = Result<T, ResponseError>.success(value)
        
        expectResult(result, for: request)
    }
    
    func expectFailure<T: Decodable>(_ type: T.Type, error: ResponseError, for request: Request) {
        let result = Result<T, ResponseError>.failure(error)
        
        expectResult(result, for: request)
    }
    
    private func expectResult<T: Decodable>(_ result: Result<T, ResponseError>, for request: Request) {
        expectations.append((request.id, result.map { $0 as Decodable }))
    }
    
    private func popFirstMatchingExpectationResult<T: Decodable>(for request: Request) -> Result<T, ResponseError>? {
        guard expectations.first?.id == request.id else {
            return nil
        }
        
        let expecationResult = expectations.removeFirst().result.map { $0 as! T }
        
        return expecationResult
    }
}
