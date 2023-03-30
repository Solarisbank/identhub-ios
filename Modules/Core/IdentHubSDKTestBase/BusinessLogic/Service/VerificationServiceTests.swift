//
//  VerificationServiceTests.swift
//  IdentHubSDKCoreTests
//

import XCTest
@testable import IdentHubSDKCore
import IdentHubSDKTestBase

final class VerificationServiceTests: XCTestCase {
    private let token: String = "test_token_b79244907a97f325b83207443b29af84cpar;"
    
    var apiClient: APIClientMock!

    override func setUp() {
        super.setUp()

        apiClient = APIClientMock()
    }

    override func tearDown() {
        super.tearDown()

        apiClient = nil
    }

    // MARK: - API methods
    
    func test_defineIdentificationMethod_apiCompletesWithSuccess() throws {
        let expectedRequest = IdentificationMethodRequest()
        let expectedValue = IdentificationMethod.mock()

        let sut = makeSut()
        apiClient.expectSuccess(.identificationMethod, for: expectedRequest)

        assertAsync { expectation in
            sut.defineIdentificationMethod() { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)

                expectation.fulfill()
            }
        }
    }
    
    func test_defineIdentificationMethod_apiCompletesWithFailure() throws {
        let expectedRequest = IdentificationMethodRequest()
        let expectedError = ResponseError(.unknownError)

        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.defineIdentificationMethod() { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)

                expectation.fulfill()
            }
        }
    }
    
    func test_obtainIdentificationInfo_apiCompletesWithSuccess() throws {
        let expectedRequest = IdentificationInfoRequest()
        let expectedValue = IdentificationInfo.mock()

        let sut = makeSut()
        apiClient.expectSuccess(.identificationInfo, for: expectedRequest)

        assertAsync { expectation in
            sut.obtainIdentificationInfo() { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)

                expectation.fulfill()
            }
        }
    }

    func test_obtainIdentificationInfo_apiCompletesWithFailure() throws {
        let expectedRequest = IdentificationInfoRequest()
        let expectedError = ResponseError(.unknownError)

        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.obtainIdentificationInfo() { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)

                expectation.fulfill()
            }
        }
    }
    
    func test_authorizeMobileNumber_apiCompletesWithSuccess() throws {
        let expectedRequest = MobileNumberAuthorizeRequest()
        let expectedValue = MobileNumber.mock()

        let sut = makeSut()
        apiClient.expectSuccess(.mobileNumber, for: expectedRequest)

        assertAsync { expectation in
            sut.authorizeMobileNumber() { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)

                expectation.fulfill()
            }
        }
    }
    
    func test_authorizeMobileNumber_apiCompletesWithFailure() throws {
        let expectedRequest = MobileNumberAuthorizeRequest()
        let expectedError = ResponseError(.unknownError)

        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.authorizeMobileNumber() { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)

                expectation.fulfill()
            }
        }
    }
    
    func test_verifyMobileNumberTAN_apiCompletesWithSuccess() throws {
        let expectedRequest = try MobileNumberTANRequest(token: token)
        let expectedValue = MobileNumber.mock()

        let sut = makeSut()
        apiClient.expectSuccess(.mobileNumber, for: expectedRequest)

        assertAsync { expectation in
            sut.verifyMobileNumberTAN(token: token) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)

                expectation.fulfill()
            }
        }
    }
    
    func test_verifyMobileNumberTAN_apiCompletesWithFailure() throws {
        let expectedRequest = try MobileNumberTANRequest(token: token)
        let expectedError = ResponseError(.unknownError)

        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.verifyMobileNumberTAN(token: token) { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)

                expectation.fulfill()
            }
        }
    }

    private func makeSut() -> VerificationService {
        VerificationServiceImpl(
            apiClient: apiClient
        )
    }
}

internal extension IdentificationMethod {
    static func mock() -> IdentificationMethod {
        return RequestFileMock.identificationMethod.decode(type: IdentificationMethod.self)
    }
}

internal extension IdentificationInfo {
    static func mock() -> IdentificationInfo {
        return RequestFileMock.identificationInfo.decode(type: IdentificationInfo.self)
    }
}

internal extension MobileNumber {
    static func mock() -> MobileNumber {
        return RequestFileMock.mobileNumber.decode(type: MobileNumber.self)
    }
}
