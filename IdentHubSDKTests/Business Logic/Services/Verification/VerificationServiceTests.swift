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
        let expectedRequestPath = String(describing: "/\(token)/mobile_number/authorize")
        sut.authorizeMobileNumber(completionHandler: { _ in })

        XCTAssertTrue(apiClient.executeCommandCalled, "Mobile number authorization command was not executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .post, "Mobile number auth command request HTTP method is not POST")
        XCTAssertEqual(apiClient.inputRequest?.path, expectedRequestPath, "Mobile number auth command request path is not valid")
    }

    /// Method tested mobile number confirm process
    /// Request used fake token number
    /// Method tests:
    ///  - confirm method execution status
    ///  - type of request
    ///  - auth request path
    func testMmobileNumberTANRequest() {
        let sut = makeSUT()
        let reqPath = String(describing: "/\(token)/mobile_number/confirm")
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
        let reqPath = String(describing: "/\(token)/iban/verify")
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
        let request = String(describing: "/\(token)/sign_documents/\(iduid)/authorize")

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
        let request = String(describing: "/\(token)/sign_documents/\(iduid)/confirm")

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
        let request = String(describing: "/\(token)/identifications/\(iduid)")

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
        let request = String(describing: "/\(token)/sign_documents/\(docID)/download")

        sut.getDocument(documentId: docID, completionHandler: { _ in })

        XCTAssertTrue(apiClient.downloadCommandCalled, "Get identification download command wasn't executed")
        XCTAssertEqual(apiClient.inputRequest?.method, .get, "Get document request HTTP method is not correct")
        XCTAssertEqual(apiClient.inputRequest?.path, request, "Get document request path is not correct")
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
        return VerificationServiceImplementation(apiClient: apiClient, sessionInfoProvider: defaultStorage!)
    }

    /// Method reset all tested service properties
    func resetTestValues() {
        defaultStorage = StorageSessionInfoProvider(sessionToken: token)
        apiClient.inputRequest = nil
        apiClient.executeCommandCalled = false
        apiClient.downloadCommandCalled = false
    }
}

/// Mock class of Verificaiton service.
class VerificationServiceMock: VerificationService {
    
    // MARK: - Protocol methods -

    func defineIdentificationMethod(completionHandler: @escaping (Result<IdentificationMethod, APIError>) -> Void) {
        let responseJSON = [
            "first_step": "fourthline/simplified",
            "fallback_step": nil,
            "allowed_retries": 5,
            "fourthline_provider": "SolarisBankProvider",
            "partner_settings": nil
        ] as [String: Any?]
        
        completionHandler(mapResponse(responseJSON: responseJSON))
    }
    
    func obtainIdentificationInfo(completionHandler: @escaping (Result<IdentificationInfo, APIError>) -> Void) {
        let responseJSON = [
            "status": "created",
            "callback_url": nil,
            "language": nil,
            "terms_and_conditions_pre_accepted": true,
            "style": nil,
            "fourthline_provider": "SolarisBankProvider",
            "verified_mobile_number": false
        ] as [String: Any?]
        
        completionHandler(mapResponse(responseJSON: responseJSON))
    }
    
    func authorizeMobileNumber(completionHandler: @escaping (Result<MobileNumber, APIError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func verifyMobileNumberTAN(token: String, completionHandler: @escaping (Result<MobileNumber, APIError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func verifyIBAN(_ iban: String, completionHandler: @escaping (Result<Identification, APIError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func authorizeDocuments(completionHandler: @escaping (Result<Identification, APIError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func verifyDocumentsTAN(token: String, completionHandler: @escaping (Result<Identification, APIError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func getIdentification(completionHandler: @escaping (Result<Identification, APIError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func getFourthlineIdentification(completionHandler: @escaping (Result<FourthlineIdentification, APIError>) -> Void) {
        let responseJSON = [
            "id": "cdc6c40aff4191e89319e803b3ad8584cidt",
            "reference": "872508bc-865e-41be-9dc0-a4d75d8fca31",
            "url": nil,
            "status": "pending",
            "completed_at": nil,
            "method": "fourthline",
            "proof_of_address_type": nil,
            "proof_of_address_issued_at": nil,
            "iban": nil,
            "terms_and_conditions_signed_at": nil,
            "authorization_expires_at": nil,
            "confirmation_expires_at": nil,
            "provider_status_code": nil,
            "estimated_waiting_time": nil
        ] as [String: Any?]
        
        completionHandler(mapResponse(responseJSON: responseJSON))
    }
    
    func getDocument(documentId: String, completionHandler: @escaping (Result<URL?, APIError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func uploadKYCZip(fileURL: URL, completionHandler: @escaping (Result<UploadFourthlineZip, APIError>) -> Void) {
        
    }
    
    func fetchPersonData(completion: @escaping (Result<PersonData, APIError>) -> Void) {
        let responseJSON = [
            "first_name": "Pierre",
            "last_name": "de Maienfeld",
            "address": [
                "street": "Helvetiapl,",
                "street_number": "5",
                "city": "Bern",
                "country": "CHE",
                "postal_code": "3005"
            ],
            "email": "some-other-tester@mail.com",
            "mobile_number": "+1701234567",
            "nationality": "CHE",
            "birth_date": "1971-08-01",
            "place_of_birth": "Bern",
            "person_uid": "0a54c78df507d62639abd28efe3058bdcper",
            "supported_documents": [
                [
                    "type": "National ID Card",
                    "issuing_countries": [
                        "HU",
                        "IT",
                        "LV",
                        "CH"
                    ]
                ],
                [
                    "type": "Paper ID",
                    "issuing_countries": [
                        "IT"
                    ]
                ],
                [
                    "type": "Residence Permit",
                    "issuing_countries": [
                        "PL"
                    ]
                ],
                [
                    "type": "Passport",
                    "issuing_countries": [
                        "CH"
                    ]
                ]
            ],
            "gender": "male"
        ] as [String: Any?]
        
        completion(self.mapResponse(responseJSON: responseJSON))
    }
    
    func fetchIPAddress(completion: @escaping (Result<IPAddress, APIError>) -> Void) {
        let responseJSON = [
            "ip": "10.18.3.173"
        ] as [String: String]
        
        completion(mapResponse(responseJSON: responseJSON))
    }
    
    func obtainFourthlineIdentificationStatus(completion: @escaping (Result<FourthlineIdentificationStatus, APIError>) -> Void) {
        let responseJSON = [
            "id": "56bed515e5d3969f7a5e8e1368edb88bcidt",
            "url": nil,
            "status": "processed",
            "failure_reason": nil,
            "method": "fourthline",
            "authorization_expires_at": nil,
            "confirmation_expires_at": nil,
            "provider_status_code": "1035",
            "next_step": nil,
            "fallback_step": nil,
            "documents":
              [
                [
                  "id": "20bc1e2279a3e3d9bddb3ba5aef28b5acdoc",
                  "name": "56bed515e5d3969f7a5e8e1368edb88bcidt_prepared_for_signing_terms_and_conditions.pdf",
                  "content_type": "application/pdf",
                  "document_type": "QES_DOCUMENT",
                  "size": 87049,
                  "customer_accessible": false,
                  "created_at": "2021-11-24T11: 27: 46.000Z"
                ]
              ],
            "current_reference_token": nil,
            "reference": "c0932f9c-dac9-4f09-aebf-8c4c4584c4df"
        ] as [String: Any?]
        
        completion(mapResponse(responseJSON: responseJSON))
    }
    
    // MARK: - Internal methods -
    
    private func mapResponse<DataType: Decodable>(responseJSON: [String: Any?]) -> Result<DataType, APIError> {
        guard let data = responseJSON.jsonData else { return .failure(.malformedResponseJson) }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)

        do {
            let decodedData = try decoder.decode(DataType.self, from: data)
            return .success(decodedData)
        } catch let error {
            print("Error with encoding data: \(error.localizedDescription)")
            return .failure(.malformedResponseJson)
        }
    }
}

extension Dictionary {
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
}
