//
//  ConfirmApplicationEvent.swift
//  IdentHubSDKQES
//
import IdentHubSDKCore

internal enum ConfirmApplicationEvent {
    case loadDocuments
    case signDocuments
    case previewDocument(withId: String)
    case downloadDocument(withId: String)
    case quit
}
