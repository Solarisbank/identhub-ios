//
//  RequestViewModelTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class RequestViewModelTests: XCTestCase {
    
    // Test mock variables
    let service = VerificationServiceMock()
    let storage = StorageSessionInfoProvider(sessionToken: "")
    
    // MARK: - Test methods -
    
    func testFourthlineInitial() throws {
        storage.identificationStep = .fourthline
        
        let sut = makeSUT(with: .initateFlow)
        
        XCTAssertNil(storage.identificationUID, "Identification has be to empty before creation request")
        
        sut.configure(of: UITableView())
        
        XCTAssertEqual(storage.identificationUID, "cdc6c40aff4191e89319e803b3ad8584cidt", "Expected Fourthline ID is not match. Register fourthline flow failed")
        XCTAssertTrue(storage.acceptedTC, "Terms and conditions accepted. Returned value is invalid")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.name, "SolarisBankProvider", "Fourthline provider is not valid")
        XCTAssertEqual(KYCContainer.shared.kycInfo.person.firstName, "Pierre", "Person data is not loaded")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.clientNumber, "0a54c78df507d62639abd28efe3058bdcper", "Person ID value is not valid")
    }

    
    // MARK: - Internal methods -
    
    private func makeSUT(with type: RequestsType) -> RequestsViewModel {
        return RequestsViewModel(service, storage: storage, type: type)
    }
}
