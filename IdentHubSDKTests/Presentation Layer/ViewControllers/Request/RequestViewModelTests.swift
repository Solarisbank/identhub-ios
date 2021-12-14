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
    
    func testFourthlineInitial() throws {
        storage.identificationStep = .fourthline
        
        let sut = makeSUT(with: .initateFlow)
        
        XCTAssertNil(storage.identificationUID, "Identification has be to empty before creation request")

        sut.executeCommand()
        
        XCTAssertEqual(storage.identificationUID, "test_fourthline_identification_id", "Expected Fourthline ID is not match. Register fourthline flow failed")
        XCTAssertTrue(storage.acceptedTC, "Terms and conditions accepted. Returned value is invalid")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.name, "TestProvider", "Fourthline provider is not valid")
        XCTAssertEqual(KYCContainer.shared.kycInfo.person.firstName, "Test_First_Name", "Person data is not loaded")
        XCTAssertEqual(KYCContainer.shared.kycInfo.provider.clientNumber, "test_person_udid", "Person ID value is not valid")
    }
    
    func testFourthlineKYCUpload() throws {
        let fourthlineCoord = FourthlineIdentCoordinatorMock()
        let sut = makeSUT(with: .uploadData, fourthlineCoord: fourthlineCoord)
        
        // Value needs to be stored to the session storage for fake kyc zip service and prevent start zipping process, becuase during tests execution no scanned data is present
        SessionStorage.updateValue("test_kyc_file_name.zip", for: StoredKeys.kycZipData.rawValue)
        
        sut.executeCommand()

        XCTAssertEqual(fourthlineCoord.performAction, FourthlineStep.confirmation, "Fourthline flow step after uploading proccess is not correct")
    }
    
    func testFourthlineIdentificationStatus() throws {
        let fourthlineCoord = FourthlineIdentCoordinatorMock()
        let sut = makeSUT(with: .confirmation, fourthlineCoord: fourthlineCoord)
        
        sut.executeCommand()
        
        XCTAssertEqual(fourthlineCoord.performAction, FourthlineStep.abort)
    }

    
    // MARK: - Internal methods -
    
    override func setUpWithError() throws {
        storage = StorageSessionInfoProvider(sessionToken: "")
    }
    
    private func makeSUT(with type: RequestsType, bankCoord: IdentificationCoordinator? = nil, fourthlineCoord: FourthlineIdentCoordinator? = nil) -> RequestsViewModel {
        return RequestsViewModel(service, storage: storage, type: type, identCoordinator: bankCoord, fourthlineCoordinator: fourthlineCoord)
    }
}
