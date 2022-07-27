//
//  APIError+Text.swift
//  IdentHubSDKCore
//

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
