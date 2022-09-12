//
//  ConfirmApplicationState.swift
//  IdentHubSDKQES
//

import IdentHubSDKCore

internal struct LoadableDocument: Equatable {
    var isLoading: Bool
    var document: ContractDocument
}

internal struct ConfirmApplicationState: Equatable {
    var hasQuitButton: Bool = true
    var documents: [LoadableDocument] = []
    var hasTermsAndConditionsLink = false
}
