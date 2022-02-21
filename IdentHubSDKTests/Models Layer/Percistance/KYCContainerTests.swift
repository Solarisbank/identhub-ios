//
//  KYCContainerTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class KYCContainerTests: BaseTestCase {
    
    /// Method tested mocked person data request and stored person data to the KYC container
    /// Method verified stored person address with typical street number (numeric)
    func testPersonDataNormalAddress() {
        let container = makeSUT()
        let verificationMock = makeVerficationService(.numericStreetNumberAddress)
        verificationMock.fetchPersonData { result in
            
            switch result {
            case .success(let person):
                container.update(person: person)
            case .failure(_):
                XCTFail("Parse mock person data object failed")
            }
        }
        
        executeAsyncTest({
            let address = try? XCTUnwrap(container.kycInfo.address, "Address data object has to be not nil")
            
            XCTAssertEqual(address?.city, "Bern", "Stored city name is not equal to expected")
            XCTAssertEqual(address?.street, "Test_Street", "Stored street name is not equal to the expected")
            XCTAssertEqual(address?.streetNumber, 5, "Stored street number is not equal to expectable")
            XCTAssertEqual(address?.postalCode, "3005", "Stored postal code is not equal to expectable")
        }, 0.1)
    }
    
    /// Method tested mocked person data request and stored person data to the KYC container
    /// Method verified stored person address with composite street number
    func testPersonDataCompositeStreetNumberAddress() {
        let container = makeSUT()
        let verificationMock = makeVerficationService(.compositeStreetNumberAddress)
        verificationMock.fetchPersonData { result in
            switch result {
            case .success(let person):
                container.update(person: person)
            case .failure(_):
                XCTFail("Parse mock person data object failed")
            }
        }
        
        executeAsyncTest({
            let address = try? XCTUnwrap(container.kycInfo.address, "Address data object has to be not nil")
            
            XCTAssertEqual(address?.street, "Test_Street", "Stored street name is not equal to the expected")
            XCTAssertEqual(address?.streetNumber, 5, "Stored street number is not equal to expectable")
            XCTAssertEqual(address?.streetNumberSuffix, "a", "Stored street number suffix is not correct. Expected value is 'a'")
        }, 0.1)
    }
    
    /// Method tested mocked person data request and stored person data to the KYC container
    /// Method tested empty street number value
    func testPersonDataEmptyStreetNumberAddress() {
        let container = makeSUT()
        let verificationMock = makeVerficationService(.emptyStreetNumberAddress)
        
        verificationMock.fetchPersonData { result in
            
            switch result {
            case .success(let person):
                container.update(person: person)
            case .failure(_):
                XCTFail("Parse mock person data object failed")
            }
        }
        
        executeAsyncTest({
            let address = try? XCTUnwrap(container.kycInfo.address, "Address data object has to be not nil")
            
            XCTAssertEqual(address?.street, "Test_Street", "Stored street name is not equal to the expected")
            XCTAssertEqual(address?.streetNumber, 0, "Stored street number is not equal to expectable")
            XCTAssertNil(address?.streetNumberSuffix, "Street number suffix has to be nil for empty value")
        }, 0.1)
    }
    
    // MARK: - Internal methods -
    
    func makeSUT() -> KYCContainer {
        return KYCContainer.shared
    }
    
    /// Method builds mocked verification service object with specific type of test address
    /// - Parameter testAddressType: test address with custom street number value
    /// - Returns: Mock object of the verification service class
    func makeVerficationService(_ testAddressType: TestPersonAddress) -> VerificationServiceMock {
        let verificationMock = VerificationServiceMock()
        verificationMock.personAddress = testAddressType
        return verificationMock
    }
    
    override func setUpWithError() throws {
        KYCContainer.shared.clearPresonData()
    }
}
