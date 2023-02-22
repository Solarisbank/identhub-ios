//
//  StorageKey+Fourthline.swift
//  Fourthline
//

import IdentHubSDKCore

extension StorageKey {
    static var identificationStep: StorageKey<IdentificationStep> { .init(name: "IdentificationStepKey")}
    static var identificationUID: StorageKey<String> { .init(name: "IdentificationUIDKey") }
    static var documentsList: StorageKey<[SupportedDocument]> { .init(name: "documentsList") }
    static var fourthlineProvider: StorageKey<String> { .init(name: "FourthlineProviderKey") }
    static var token: StorageKey<String> { .init(name: "SessionTokenKey")}
}
