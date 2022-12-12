//
//  StorageKey+Core.swift
//  IdentHubSDKCore
//

import Foundation

extension StorageKey {
    public static var mobileNumber: StorageKey<String> { .init(name: "UserMobileNumberKey") }
    public static var retriesCount: StorageKey<Int> { .init(name: "IdentRetriesCountKey") }
    public static var fallbackIdentStep: StorageKey<IdentificationStep> { .init(name: "FallbackIdentificationSessionStepKey") }
}
