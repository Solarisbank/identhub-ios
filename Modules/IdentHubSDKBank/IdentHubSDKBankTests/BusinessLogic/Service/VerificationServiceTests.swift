//
//  VerificationServiceTests.swift
//  IdentHubSDKBankTests
//

import XCTest
@testable import IdentHubSDKBank
import IdentHubSDKCore
import IdentHubSDKTestBase

final class VerificationServiceTests: XCTestCase {
    private let iban: String = "test_DE11111111111111111111"
    private let identUID: String = "someIdentId"
    
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
    
    func test_verify_BankIDIBAN_apiCompletesWithSuccess() throws {
        let expectedRequest = try BankIDIBANRequest(iban: iban)
        let expectedValue = Identification.mock()

        let sut = makeSut()
        apiClient.expectSuccess(.identification, for: expectedRequest)

        assertAsync { expectation in
            sut.verifyIBAN(iban, .bankIDIBAN) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)

                expectation.fulfill()
            }
        }
    }
    
    func test_verify_bankIBAN_apiCompletesWithSuccess() throws {
        let expectedRequest = try IBANRequest(iban: iban)
        let expectedValue = Identification.mock()

        let sut = makeSut()
        apiClient.expectSuccess(.identification, for: expectedRequest)

        assertAsync { expectation in
            sut.verifyIBAN(iban, .bankIBAN) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)

                expectation.fulfill()
            }
        }
    }
    
    func test_verifyIBAN_apiCompletesWithFailure() throws {
        let expectedRequest = try BankIDIBANRequest(iban: iban)
        let expectedError = ResponseError(.ibanVerfificationFailed)

        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.verifyIBAN(iban, .bankIDIBAN) { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)

                expectation.fulfill()
            }
        }
    }
    
    func test_getIdentification_apiCompletesWithSuccess() throws {
        let expectedRequest = try IdentificationRequest(identificationUID: identUID)
        let expectedValue = Identification.mock()

        let sut = makeSut()
        apiClient.expectSuccess(.identification, for: expectedRequest)

        assertAsync { expectation in
            sut.getIdentification(for: identUID) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)

                expectation.fulfill()
            }
        }
    }
    
    func test_getIdentification_apiCompletesWithFailure() throws {
        let expectedRequest = try IdentificationRequest(identificationUID: identUID)
        let expectedError = ResponseError(.unknownError)

        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)

        assertAsync { expectation in
            sut.getIdentification(for: identUID) { result in
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

internal extension Identification {
    static func mock() -> Identification {
        return RequestFileMock.identification.decode(type: Identification.self)
    }
}
