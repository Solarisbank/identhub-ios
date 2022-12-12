//
//  VerificationServiceMock.swift
//  IdentHubSDKTests
//

import UIKit
import XCTest
@testable import IdentHubSDK
import IdentHubSDKCore

enum TestIdentMethod {
    case fourthlineSimplified
    case fourthlineSigning
    case bank
    case bankID
}

enum TestPersonAddress {
    case numericStreetNumberAddress
    case compositeStreetNumberAddress
    case emptyStreetNumberAddress
}

/// Mock class of Verificaiton service.
class VerificationServiceMock: VerificationService {
    
    // MARK: - Public properties -
    var testMethod: TestIdentMethod?
    
    var personAddress: TestPersonAddress?
    
    var mockResoponse = [String: Any?]()
    
    // MARK: - Protocol methods -

    func defineIdentificationMethod(completionHandler: @escaping (Result<IdentificationMethod, ResponseError>) -> Void) {
        completionHandler(mapResponse(responseJSON: buildIdentMethodResponse()))
    }
    
    func defineBankIdentMethod(completionHandler: @escaping (Result<IdentificationMethod, ResponseError>) -> Void) {
        completionHandler(mapResponse(responseJSON: buildIdentMethodResponse()))
    }
    
    func defineBankIDIdentMethod(completionHandler: @escaping (Result<IdentificationMethod, ResponseError>) -> Void) {
        completionHandler(mapResponse(responseJSON: buildIdentMethodResponse()))
    }
    
    func defineFourthlineSigningIdentMethod(completionHandler: @escaping (Result<IdentificationMethod, ResponseError>) -> Void) {
        completionHandler(mapResponse(responseJSON: buildIdentMethodResponse()))
    }
    
    func obtainIdentificationInfo(completionHandler: @escaping (Result<IdentificationInfo, ResponseError>) -> Void) {
        let responseJSON = [
            "status": "created",
            "callback_url": nil,
            "language": nil,
            "terms_and_conditions_pre_accepted": true,
            "style": nil,
            "fourthline_provider": obtainFourthlineProvider(),
            "verified_mobile_number": false,
            "sdk_logging": false
        ] as [String: Any?]
        
        completionHandler(mapResponse(responseJSON: responseJSON))
    }
    
    func authorizeMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func getMobileNumber(completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func verifyMobileNumberTAN(token: String, completionHandler: @escaping (Result<MobileNumber, ResponseError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func verifyIBAN(_ iban: String, completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func getIdentification(completionHandler: @escaping (Result<Identification, ResponseError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func getFourthlineIdentification(completionHandler: @escaping (Result<FourthlineIdentification, ResponseError>) -> Void) {
        let responseJSON = [
            "id": obtainTestMethodID(),
            "reference": "reference1",
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
    
    func getDocument(documentId: String, completionHandler: @escaping (Result<URL?, ResponseError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
    }
    
    func uploadKYCZip(fileURL: URL, completionHandler: @escaping (Result<UploadFourthlineZip, ResponseError>) -> Void) {
        let responseJSON = [
            "id": "kycZIPID",
            "name": "KYC_zip_file_name.zip",
            "content_type": "application/zip",
            "document_type": "OTHER",
            "size": 38404089,
            "customer_accessible": false,
            "created_at": "2021-11-25T12:58:40.000Z",
            "partner_accessible": true
        ] as [String: Any]
        
        completionHandler(mapResponse(responseJSON: responseJSON))
    }
    
    func fetchPersonData(completion: @escaping (Result<PersonData, ResponseError>) -> Void) {
        
        let responseJSON = [
            "first_name": "Test_First_Name",
            "last_name": "Test_Last_Name",
            "address": [
                "street": "Test_Street",
                "street_number": obtainTestStreetNumber(),
                "city": "Bern",
                "country": "CHE",
                "postal_code": "3005"
            ],
            "email": "some-other-tester@mail.com",
            "mobile_number": "+1701234567",
            "nationality": "CHE",
            "birth_date": "1971-08-01",
            "place_of_birth": "Bern",
            "person_uid": "test_person_udid",
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
    
    func fetchIPAddress(completion: @escaping (Result<IPAddress, ResponseError>) -> Void) {
        let responseJSON = [
            "ip": "0.0.0.1"
        ] as [String: String]
        
        completion(mapResponse(responseJSON: responseJSON))
    }
    
    func obtainFourthlineIdentificationStatus(completion: @escaping (Result<FourthlineIdentificationStatus, ResponseError>) -> Void) {
        completion(mapResponse(responseJSON: self.mockResoponse))
    }
    
    // MARK: - Internal methods -
    
    private func mapResponse<DataType: Decodable>(responseJSON: [String: Any?]) -> Result<DataType, ResponseError> {
        guard let data = responseJSON.jsonData else { return .failure(ResponseError(.malformedResponseJson)) }
        
        let decoder = JSONDecoder()
        
        decoder.dateDecodingStrategy = .formatted(DateFormatter.yyyyMMdd)

        do {
            let decodedData = try decoder.decode(DataType.self, from: data)
            return .success(decodedData)
        } catch let error {
            print("Error with encoding data: \(error.localizedDescription)")
            return .failure(ResponseError(.malformedResponseJson))
        }
    }
}

extension VerificationServiceMock {

    func buildIdentMethodResponse() -> [String: Any?] {
        guard let method = testMethod else { return [:] }
        
        switch method {
        case .fourthlineSimplified:
            return [
                "first_step": "fourthline/simplified",
                "fallback_step": nil,
                "allowed_retries": 5,
                "fourthline_provider": obtainFourthlineProvider(),
                "partner_settings": nil
            ]
        case .fourthlineSigning:
            return [
                "first_step": "fourthline_signing",
                "fallback_step": nil,
                "allowed_retries": 5,
                "fourthline_provider": obtainFourthlineProvider(),
                "partner_settings": nil
            ]
        case .bank:
            return [
                "first_step": "bank/iban",
                "fallback_step": "fourthline/simplified",
                "allowed_retries": 5,
                "fourthline_provider": obtainFourthlineProvider(),
                "partner_settings": nil
            ]
        case .bankID:
            return [
                "first_step": "bank_id/iban",
                "fallback_step": nil,
                "allowed_retries": 5,
                "fourthline_provider": "",
                "partner_settings": nil
            ]
        }
    }
    
    func obtainTestMethodID() -> String {
        guard let method = testMethod else { return "" }
        
        switch method {
        case .fourthlineSimplified:
            return "test_fourthline_identification_id"
        case .fourthlineSigning:
            return "test_fourthline_signing_identification_id"
        case .bank:
            return "test_bank_identification_id"
        case .bankID:
            return "test_bank_id_identification_id"
        }
    }
    
    func obtainFourthlineProvider() -> String? {
        guard let method = testMethod else { return "" }
        
        switch method {
        case .fourthlineSimplified:
            return "FourthlineSimplifiedProvider"
        case .fourthlineSigning:
            return "FourthlineSigningProvider"
        case .bank:
            return "BANKProvider"
        case .bankID:
            return nil
        }
    }
    
    func obtainTestStreetNumber() -> String {
        switch personAddress {
        case .compositeStreetNumberAddress:
            return "5a"
        case .emptyStreetNumberAddress:
            return ""
        case .numericStreetNumberAddress,
             .none:
            return "5"
        }
    }
}

extension Dictionary {
    var jsonData: Data? {
        return try? JSONSerialization.data(withJSONObject: self, options: [.prettyPrinted])
    }
}
