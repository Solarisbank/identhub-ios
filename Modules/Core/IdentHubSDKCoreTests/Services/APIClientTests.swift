//
//  APIClientTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

/// API client mock tests class
class APIClientTests: XCTestCase {

    // MARK: - Tests methods -

    /// Method tested calling execution request method status
    /// Test parameters:
    ///  - execution status (Bool)
    ///  - execution request
    func testExecutionCommand() {
        let sut = APIClientMock()
        let request = RequestMOCK()

        sut.execute(request: request, answerType: ModelMock.self) { _ in }

        XCTAssertTrue(sut.executeCommandCalled, "Execute command not called")
        XCTAssertNotNil(sut.inputRequest, "Execute request doesn't correct")
    }

    /// Method tested download method calling
    /// For test used mock api client and request object
    /// Test parameters:
    ///  - downloading status (Bool)
    ///  - load request object (if not nil)
    func testDownloadCommand() {
        let sut = APIClientMock()
        let request = RequestMOCK()

        sut.download(request: request, completion: { _ in })

        XCTAssertTrue(sut.downloadCommandCalled, "Download command wasn't called")
        XCTAssertNotNil(sut.inputRequest, "Execute request doesn't correct")
    }

    /// Method tested successful result of loading document request
    /// Tested object:
    ///   - response result value is the same as expected
    func testSuccessDownload() {
        let sut = APIClientMock()
        let request = RequestMOCK()
        let downloadURL = URL(string: "test_url")
        var result: Result<URL?, ResponseError>?

        sut.downloadResult = .success(downloadURL)
        sut.download(request: request) { result = $0 }

        XCTAssertEqual(try result?.get(), downloadURL, "Download request result URL is not equal with expected value")
    }

    /// Method tested failed loading result
    /// Tested object:
    ///   - response result with failure reason: resourceNotFound
    func testFailedDownload() {
        let sut = APIClientMock()
        let request = RequestMOCK()
        var result: Result<URL?, ResponseError>?

        sut.downloadResult = .failure(ResponseError(.resourceNotFound))
        sut.download(request: request) { result = $0 }

        guard case let .failure(responseError) = result, case .resourceNotFound = responseError.apiError else {
            XCTFail("Failed download request result should return error APIError.resourceNotFound")
            return
        }
    }
    
    /*
     TODO: This method relies on internal method in DefafultAPIClient which is in different module
    func testLoggingHelperCompletionCalled() throws {
        
        /// `completionCalled` takes a result and a completion, logs the result and
        /// executes the completion with the result.
        /// We need to make sure that the completion is always called.
        /// Don't bother to test the log output.
        
        let aResult: Result<String, MockError> = .failure(.test)
        
        var completionCalled = false, receivedResult: Result<String, MockError>?
        let completion: (Result<String, MockError>) -> Void = { result in
            completionCalled = true
            receivedResult = result
        }
        
        completeWithResult(aResult, completion: completion)
        XCTAssertTrue(completionCalled)
        XCTAssertEqual(receivedResult, aResult)
    }
     */
}

enum MockError: Error, Equatable {
    case test
}
