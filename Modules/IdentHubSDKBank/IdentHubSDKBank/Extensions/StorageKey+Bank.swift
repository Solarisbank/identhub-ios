//
//  StorageKey+Bank.swift
//  IdentHubSDKBank
//

import IdentHubSDKCore

extension StorageKey {
    static var step: StorageKey<BankStep> { .init(name: "Bank.Step") }
    static var identificationPath: StorageKey<String> { .init(name: "IdentificationSessionPathKey") }
    static var identificationUID: StorageKey<String> { .init(name: "IdentificationUIDKey") }
}
