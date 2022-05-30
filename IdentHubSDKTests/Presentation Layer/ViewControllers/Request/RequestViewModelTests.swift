//
//  RequestViewModelTests.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDK

class RequestViewModelTests: XCTestCase {
    
    // Test mock variables
    let service = VerificationServiceMock()
    var storage: StorageSessionInfoProvider!
    
    // MARK: - Test methods -
    
    /// Method tested initial flow of the Fourthline simplified flow
    /// Tested parameters:
    /// - Created identification ID
    /// - Flow first step
    /// - Fourthline provider name
    /// - Accepted Terms and conditions state
    /// - Idnetified test person name
    /// - Identified test person UDID
    func testFourthlineInitial() throws {
        service.testMethod = .fourthlineSimplified
        
        let sut = makeSUT(with: .initateFlow)
        
        XCTAssertNil(storage.identificationUID, "Identification has be to empty before creation request")

        sut.executeCommand()
        
        XCTAssertEqual(storage.identificationStep, .fourthline, "Identification first flow step is not correct.")
        XCTAssertEqual(storage.identificationUID, "test_fourthline_identification_id", "Expected Fourthline ID is not match. Register fourthline flow failed")
        XCTAssertTrue(storage.acceptedTC, "Terms and conditions accepted. Returned value is invalid")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.name, "FourthlineSimplifiedProvider", "Fourthline provider is not valid")
        XCTAssertEqual(KYCContainer.shared.kycInfo.person.firstName, "Test_First_Name", "Person data is not loaded")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.clientNumber, "test_person_udid", "Person ID value is not valid")
    }
    
    /// Method tested initial flow of the Fourthline signing flow
    /// Tested parameters:
    /// - Created identification ID
    /// - Flow first step
    /// - Fourthline provider name
    /// - Accepted Terms and conditions state
    /// - Idnetified test person name
    /// - Identified test person UDID
    func testFourthlineSigningInitiate() throws {
        service.testMethod = .fourthlineSigning
        
        let sut = makeSUT(with: .initateFlow)
        
        XCTAssertNil(storage.identificationUID, "Identification has be to empty before creation request.")

        sut.executeCommand()
        
        XCTAssertEqual(storage.identificationStep, .fourthlineSigning, "Identification first flow step is not correct.")
        XCTAssertEqual(storage.identificationUID, "test_fourthline_signing_identification_id", "Expected Fourthline ID is not match. Register fourthline flow failed.")
        XCTAssertTrue(storage.acceptedTC, "Terms and conditions accepted. Returned value is invalid.")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.name, "FourthlineSigningProvider", "Fourthline provider is not valid.")
        XCTAssertEqual(KYCContainer.shared.kycInfo.person.firstName, "Test_First_Name", "Person data is not loaded.")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.clientNumber, "test_person_udid", "Person ID value is not valid.")
    }
    
    /// Method tested initial flow of the Bank flow
    /// Tested parameters:
    /// - Flow first step
    /// - Fallback step in Bank ident process
    /// - Fourthline provider name
    /// - Accepted Terms and conditions state
    /// - Idnetified test person name, has to be nil
    func testBankInitiate() throws {
        service.testMethod = .bank
        
        let sut = makeSUT(with: .initateFlow)
        
        sut.executeCommand()
        
        XCTAssertEqual(storage.identificationStep, .bankIBAN, "Identification first flow step is not correct.")
        XCTAssertEqual(storage.fallbackIdentificationStep, .fourthline, "BANK identification fallback flow step is not correct.")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.name, "BANKProvider", "Fourthline provider is not valid.")
        XCTAssertTrue(storage.acceptedTC, "Terms and conditions accepted. Returned value is invalid.")
        XCTAssertNil(KYCContainer.shared.kycInfo.person.firstName, "Person data has to be empty because never used in Bank flow.")
    }

    /// Method tested initial flow of the Bank flow
    /// Tested parameters:
    /// - Flow first step
    /// - Fallback step in Bank ident process - has to be nil
    /// - Accepted Terms and conditions state
    /// - Idnetified test person name, has to be nil
    func testBankIDInitiate() throws {
        service.testMethod = .bankID
        
        let sut = makeSUT(with: .initateFlow)
        
        sut.executeCommand()
        
        XCTAssertEqual(storage.identificationStep, .bankIDIBAN, "Identification first flow step is not correct.")
        XCTAssertNil(storage.fallbackIdentificationStep, "Fallback flow step in BankID flow is absent.")
        XCTAssertTrue(storage.acceptedTC, "Terms and conditions accepted. Returned value is invalid.")
        XCTAssertNil(KYCContainer.shared.kycInfo.person.firstName, "Person data has to be empty because never used in BankID flow.")
        XCTAssertNil(KYCContainer.shared.kycInfo.provider.name, "Fourthline provider data has to be empty because never used in BankID flow.")
    }
    
    func testFourthlineIdentificationStatus() throws {
        let fourthlineCoord = try FourthlineIdentCoordinatorMock()
        let sut = makeSUT(with: .confirmation, fourthlineCoord: fourthlineCoord)
        
        sut.executeCommand()
        
        XCTAssertEqual(fourthlineCoord.performAction, FourthlineStep.abort)
    }

    
    // MARK: - Internal methods -
    
    override func setUpWithError() throws {
        SessionStorage.clearData()
        KYCContainer.shared.clearPresonData()
        storage = StorageSessionInfoProvider(sessionToken: "")
    }
    
    private func makeSUT(with type: RequestsType, bankCoord: IdentificationCoordinator? = nil, fourthlineCoord: FourthlineIdentCoordinator? = nil) -> RequestsViewModel {
        return RequestsViewModel(service, storage: storage, type: type, identCoordinator: bankCoord, fourthlineCoordinator: fourthlineCoord)
    }
}
