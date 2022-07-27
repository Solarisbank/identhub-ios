//
//  MobileNumberMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKCore

internal extension MobileNumber {
    static func mock(
        id: String? = nil,
        number: String = "+49123456789",
        verified: Bool = true
    ) -> MobileNumber {
        MobileNumber(
            id: nil,
            number: number,
            verified: verified
        )
    }
}
