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
    
    func getDocument(documentId: String, completionHandler: @escaping (Result<URL?, ResponseError>) -> Void) {
        XCTExpectFailure("Method will be used in \"bank_id\" or \"bank\" test coverage cases")
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
