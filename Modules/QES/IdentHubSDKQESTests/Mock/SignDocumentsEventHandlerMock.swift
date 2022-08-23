//
//  SignDocumentsEventHandlerMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES

final class SignDocumentsEventHandlerMock: SignDocumentsEventHandler {
    func requestNewCode() {}
    
    func submitCodeAndSign(_ code: String) {}
    
    func quit() {}
}
