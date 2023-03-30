//
//  VerificationServiceTests.swift
//  IdentHubSDKFourthlineTests
//


import XCTest
@testable import IdentHubSDKFourthline
import IdentHubSDKCore
import IdentHubSDKTestBase

final class VerificationServiceTests: XCTestCase {
    
    private var apiClient: APIClientMock!
    private var storage: StorageMock!
    
    private let identUID: String = "someIdentId"
    
    override func setUp() {
        super.setUp()
        
        apiClient = APIClientMock()
        storage = StorageMock()
        
        storage[.identificationUID] = identUID
    }
    
    override func tearDown() {
        super.tearDown()
        
        apiClient = nil
        storage = nil
    }
    
    // MARK: - API methods
    
    func test_getFourthlineIdentification_apiCompletesWithSuccess() throws {
        let expectedRequest = try FourthlineIdentificationRequest(method: .fourthline)
        let expectedValue = FourthlineIdentification.mock()
        
        let sut = makeSut()
        apiClient.expectSuccess(.fourthlineIdentification, for: expectedRequest)
        
        assertAsync { expectation in
            sut.getFourthlineIdentification() { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_getFourthlineIdentification_apiCompletesWithFailure() throws {
        let expectedRequest = try FourthlineIdentificationRequest(method: .fourthline)
        let expectedError = ResponseError(.unknownError)
        
        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)
        
        assertAsync { expectation in
            sut.getFourthlineIdentification() { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_fetchPersonData_apiCompletesWithSuccess() throws {
        let expectedRequest = try PersonDataRequest(uid: identUID)
        let expectedValue = PersonData.mock()
        
        let sut = makeSut()
        apiClient.expectSuccess(.personData, for: expectedRequest)
        
        assertAsync { expectation in
            sut.fetchPersonData() { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_fetchPersonData_apiCompletesWithFailure() throws {
        let expectedRequest = try PersonDataRequest(uid: storage[.identificationUID] ?? identUID)
        let expectedError = ResponseError(.unknownError)
        
        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)
        
        assertAsync { expectation in
            sut.fetchPersonData() { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_fetchIPAddress_apiCompletesWithSuccess() throws {
        let expectedRequest = IPAddressRequest()
        let expectedValue = IPAddress.mock()
        
        let sut = makeSut()
        apiClient.expectSuccess(.ipAddress, for: expectedRequest)
        
        assertAsync { expectation in
            sut.fetchIPAddress() { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_fetchIPAddress_apiCompletesWithFailure() throws {
        let expectedRequest = IPAddressRequest()
        let expectedError = ResponseError(.unknownError)
        
        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)
        
        assertAsync { expectation in
            sut.fetchIPAddress() { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_uploadKYCZip_apiCompletesWithSuccess() throws {
        let fileURL = URL(string: "file://path")!
        let expectedRequest = try UploadKYCRequest(sessionID: storage[.identificationUID] ?? identUID, fileURL: fileURL)
        let expectedValue = UploadFourthlineZip.mock()
        
        let sut = makeSut()
        apiClient.expectSuccess(.uploadFourthlineZip, for: expectedRequest)
        
        assertAsync { expectation in
            sut.uploadKYCZip(fileURL: fileURL) { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_uploadKYCZip_apiCompletesWithFailure() throws {
        let fileURL = URL(string: "file://path")!
        let expectedRequest = try UploadKYCRequest(sessionID: storage[.identificationUID] ?? identUID, fileURL: fileURL)
        let expectedError = ResponseError(.unknownError)
        
        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)
        
        assertAsync { expectation in
            sut.uploadKYCZip(fileURL: fileURL) { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_obtainFourthlineIdentificationStatus_apiCompletesWithSuccess() throws {
        let expectedRequest = try FourthlineIdentificationStatusRequest(uid: storage[.identificationUID] ?? identUID)
        let expectedValue = FourthlineIdentificationStatus.mock()
        
        let sut = makeSut()
        apiClient.expectSuccess(.fourthlineIdentificationStatus, for: expectedRequest)
        
        assertAsync { expectation in
            sut.obtainFourthlineIdentificationStatus() { result in
                XCTAssertResultIsSuccess(result, expectedValue: expectedValue)
                
                expectation.fulfill()
            }
        }
    }
    
    func test_obtainFourthlineIdentificationStatus_apiCompletesWithFailure() throws {
        let expectedRequest = try FourthlineIdentificationStatusRequest(uid: storage[.identificationUID] ?? identUID)
        let expectedError = ResponseError(.unknownError)
        
        let sut = makeSut()
        apiClient.expectError(expectedError, for: expectedRequest)
        
        assertAsync { expectation in
            sut.obtainFourthlineIdentificationStatus() { result in
                XCTAssertResultIsFailure(result, expectedError: expectedError)
                
                expectation.fulfill()
            }
        }
    }
    
    private func makeSut() -> VerificationService {
        VerificationServiceImpl(
            apiClient: apiClient,
            storage: storage
        )
    }
}

internal extension FourthlineIdentification {
    static func mock() -> FourthlineIdentification {
        return RequestFileMock.fourthlineIdentification.decode(type: FourthlineIdentification.self)
    }
}

internal extension PersonData {
    static func mock() -> PersonData {
        return RequestFileMock.personData.decode(type: PersonData.self)
    }
}

internal extension IPAddress {
    static func mock() -> IPAddress {
        return RequestFileMock.ipAddress.decode(type: IPAddress.self)
    }
}

internal extension UploadFourthlineZip {
    static func mock() -> UploadFourthlineZip {
        return RequestFileMock.uploadFourthlineZip.decode(type: UploadFourthlineZip.self)
    }
}

internal extension FourthlineIdentificationStatus {
    static func mock() -> FourthlineIdentificationStatus {
        return RequestFileMock.fourthlineIdentificationStatus.decode(type: FourthlineIdentificationStatus.self)
    }
}
