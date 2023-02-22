//
//  StorageKey+Core.swift
//  IdentHubSDKCore
//

import Foundation

public extension StorageKey {
    static var step: StorageKey<CoreStep> { .init(name: "Core.Step") }
//    static var sessionToken: StorageKey<String> { .init(name: "SessionTokenKey") }
    static var mobileNumber: StorageKey<String> { .init(name: "UserMobileNumberKey") }
    static var retriesCount: StorageKey<Int> { .init(name: "IdentRetriesCountKey") }
    static var fallbackIdentStep: StorageKey<IdentificationStep> { .init(name: "FallbackIdentificationSessionStepKey") }
    static var fourthlineProvider: StorageKey<String> { .init(name: "FourthlineProviderKey") }
}
