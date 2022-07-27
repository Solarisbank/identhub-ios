//
//  ConfirmApplicationEventHandlerMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES

final class ConfirmApplicationEventHandlerMock: ConfirmApplicationEventHandler {
    func loadDocuments() {}
    
    func signDocuments() {}
    
    func previewDocument(withId id: String) {}
    
    func downloadDocument(withId id: String) {}
    
    func quit() {}
}
