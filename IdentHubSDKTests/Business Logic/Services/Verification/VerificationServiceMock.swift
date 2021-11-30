//
//  VerificationServiceMock.swift
//  IdentHubSDKTests
//

import UIKit
import XCTest
@testable import IdentHubSDK

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
        let responseJSON = [
            "id": "63346da5eeb5ac5f8382ed3d6a31a4e8cdoc",
            "name": "RackMultipart20211125-7-16mreoi.zip",
            "content_type": "application/zip",
            "document_type": "OTHER",
            "size": 38404089,
            "customer_accessible": false,
            "created_at": "2021-11-25T12:58:40.000Z",
            "partner_accessible": true
        ] as [String: Any]
        
        completionHandler(mapResponse(responseJSON: responseJSON))
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
            "status": "rejected",
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
