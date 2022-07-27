//
//  IdentificationMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKCore

internal extension Identification {
    static func mock(
        id: String = "mock_id",
        status: Status = .created,
        referenceToken: String? = nil,
        documents: [ContractDocument]? = nil
    ) -> Identification {
        Identification(
            id: id,
            reference: nil,
            url: nil,
            status: status,
            completedAt: nil,
            method: "method",
            proofOfAddressType: nil,
            proofOfAddressIssuedAt: nil,
            iban: nil,
            termsAndConditionsSignedAt: nil,
            authorizationExpireAt: nil,
            confirmationExpireAt: nil,
            estimatedWaitingTime: nil,
            address: nil,
            nextStep: nil,
            fallbackStep: nil,
            providerStatusCode: nil,
            failureReason: nil,
            referenceToken: referenceToken,
            documents: documents
        )
    }
}
