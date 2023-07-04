//
//  APIError.swift
//  IdentHubSDKCore
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
/// - modulesNotFound: SDK could not found required modules. Check if your application has embedded the module's library.
/// - unknownError: indicates that api client encountered an error not listed above.
/// - kycZipNotFound: SDK could not found KYC.ZIP file for automation target.
public enum APIError: Error, Equatable {
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
    case modulesNotFound([String])
    case unknownError
    case kycZipNotFound
}

/// Server enum
public struct ResponseError: Error, Equatable, CustomStringConvertible {
    
    public let apiError: APIError
    public let response: HTTPURLResponse?
    
    public init(_ error: APIError, _ response: HTTPURLResponse? = nil) {
        self.apiError = error
        self.response = response
    }
    
    public var statusCode: String {
        guard let code = response?.statusCode else { return "" }
        return "\(String(describing: code))"
    }
    
    public var failureReason: String {
        guard let statusCode = response?.statusCode else { return "" }
        return HTTPURLResponse.localizedString(forStatusCode: statusCode)
    }
    
    public var detailDescription: String {
        return "Code: \(statusCode)\nReason: \(failureReason)"
    }
    
    public var description: String {
        return "ResponseError – \(apiError) (HTTP Code: \(statusCode) Reason: \(failureReason))"
    }

}

/// Server error codes
/// - mobileNotVerified: person mobile number doesn't not verified
/// - unknown: error code is absent or not specified
public enum ErrorCodes: String, Codable {

    case mobileNotVerified = "mobile_number_not_verified"
    case invalidIBAN = "invalid_iban"
    case invalidPerson = "match_for_person_data_not_found"
    case unknown
}
