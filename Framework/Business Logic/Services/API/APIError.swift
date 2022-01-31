//
//  APIError.swift
//  IdentHubSDK
//

import Foundation

/// Common api error encountered throughout the app.
///
/// - malformedResponseJson:  indicates that string received in the response couldn't been parsed.
/// - clientError: infidicates the error on the client's side.
/// - authorizationFailed: indicates that authorization failed.
/// - unauthorizedAction: action has not been authorized.
/// - resourceNotFound: resource has not been found.
/// - expectationMismatch: data mismatch.
/// - incorrectIdentificationStatus: the identification status was not allowed to proceed with the action.
/// - unprocessableEntity: data invalid or expired.
/// - internalServerError: indicates the internal server error.
/// - requestError: indicates build request error
/// - locationError: indicates issue with fetching device location data
/// - ibanVerfificationFailed: failed IBAN verification
/// - paymentFailed: failed payment initiation
/// - identificationDataInvalid: provided user data is not valid and should be creates one more time
/// - fraudData: provided data defines as fraud
/// - unsupportedResponse: SDK encountered a response that is not supported in this version
/// - identificationNotPossible: SDK could not identify the user. Try your fallback identification method
/// - unknownError: indicates that api client encountered an error not listed above.
public enum APIError: Error {
    case malformedResponseJson
    case clientError(error: ErrorDetail?)
    case authorizationFailed
    case unauthorizedAction
    case resourceNotFound
    case expectationMismatch
    case incorrectIdentificationStatus(error: ErrorDetail?)
    case unprocessableEntity
    case internalServerError
    case requestError
    case locationAccessError
    case locationError
    case ibanVerfificationFailed
    case paymentFailed
    case identificationDataInvalid(error: ErrorDetail?)
    case fraudData(error: ErrorDetail?)
    case unsupportedResponse
    case identificationNotPossible
    case unknownError
}

/// Server enum
struct ResponseError: Error {
    let apiError: APIError
    let response: HTTPURLResponse?
    
    init(_ error: APIError, _ response: HTTPURLResponse? = nil) {
        self.apiError = error
        self.response = response
    }
    
    var statusCode: String {
        guard let code = response?.statusCode else { return "" }
        return "[\(String(describing: code))]"
    }
    
    var failureReason: String {
        guard let statusCode = response?.statusCode else { return "" }
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
    
    var detailDescription: String {
        return "Code: \(statusCode)\nReason: \(failureReason)"
    }
}

/// Server error codes
/// - mobileNotVerified: person mobile number doesn't not verified
/// - unknown: error code is absent or not specified
enum ErrorCodes: String, Codable {

    case mobileNotVerified = "mobile_number_not_verified"
    case invalidIBAN = "invalid_iban"
    case invalidPerson = "match_for_person_data_not_found"
    case unknown
}

public extension APIError {

    func text() -> String {
        switch self {
        case .malformedResponseJson:
            return Localizable.APIErrorDesc.malformedResponseJson
        case .clientError(_):
            return Localizable.APIErrorDesc.clientError
        case.authorizationFailed:
            return Localizable.APIErrorDesc.authorizationFailed
        case .unauthorizedAction:
            return Localizable.APIErrorDesc.unauthorizedAction
        case .expectationMismatch:
            return Localizable.APIErrorDesc.expectationMismatch
        case .incorrectIdentificationStatus(_):
            return Localizable.APIErrorDesc.incorrectIdentificationStatus
        case .unprocessableEntity:
            return Localizable.APIErrorDesc.unprocessableEntity
        case .internalServerError:
            return Localizable.APIErrorDesc.internalServerError
        case .requestError:
            return Localizable.APIErrorDesc.requestError
        case .unknownError:
            return Localizable.APIErrorDesc.unknownError
        case .resourceNotFound:
            return Localizable.APIErrorDesc.resourceNotFound
        case .locationAccessError:
            return Localizable.APIErrorDesc.locationAccessError
        case .locationError:
            return Localizable.APIErrorDesc.locationError
        case .ibanVerfificationFailed:
            return Localizable.APIErrorDesc.ibanVerificationError
        case .paymentFailed:
            return Localizable.APIErrorDesc.paymentFailure
        case .identificationDataInvalid:
            return Localizable.APIErrorDesc.unprocessableEntity
        case .unsupportedResponse:
            return Localizable.APIErrorDesc.unsupportedResponse
        case .identificationNotPossible:
            return Localizable.APIErrorDesc.identificationNotPossible
        case .fraudData:
            return Localizable.APIErrorDesc.unprocessableEntity
        }
    }
}
