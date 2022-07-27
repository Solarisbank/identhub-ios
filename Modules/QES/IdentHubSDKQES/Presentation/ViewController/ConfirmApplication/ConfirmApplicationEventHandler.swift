//
//  ConfirmApplicationEventHandler.swift
//  IdentHubSDKQES
//

internal protocol ConfirmApplicationEventHandler: AnyObject {
    func loadDocuments()
    func signDocuments()
    func previewDocument(withId id: String)
    func downloadDocument(withId id: String)
    func quit()
}
