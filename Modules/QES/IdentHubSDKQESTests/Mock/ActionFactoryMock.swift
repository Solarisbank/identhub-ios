//
//  ActionFactoryMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
import IdentHubSDKTestBase
import IdentHubSDKCore

class ActionFactoryMock: ActionFactory {
    private var testRecorder: TestRecorder?

    var confirmApplicationAction: ActionMock<ConfirmApplicationActionInput, ConfirmApplicationActionOutput>!

    var signDocumentsAction: ActionMock<SignDocumentsActionInput, Result<SignDocumentsActionOutput, APIError>>!
    
    var previewDocumentAction: ActionMock<URL, Bool>!
    
    var downloadDocumentAction: ActionMock<URL, Bool>!
    
    var quitAction: ActionMock<Void, Bool>!

    init(testRecorder: TestRecorder? = nil) {
        self.testRecorder = testRecorder
        self.confirmApplicationAction = .init(name: "ConfirmApplicationAction", testRecorder: testRecorder)
        self.signDocumentsAction = .init(name: "SignDocumentsAction", testRecorder: testRecorder)
        self.previewDocumentAction = .init(name: "PreviewDocumentsAction", testRecorder: testRecorder)
        self.downloadDocumentAction = .init(name: "DownloadDocumentsAction", testRecorder: testRecorder)
        self.quitAction = .init(name: "Quit", testRecorder: testRecorder)
    }

    func makeConfirmApplicationAction() -> AnyAction<ConfirmApplicationActionInput, ConfirmApplicationActionOutput> {
        confirmApplicationAction!.asAnyAction()
    }

    func makeSignDocumentsAction() -> AnyAction<SignDocumentsActionInput, Result<SignDocumentsActionOutput, APIError>> {
        signDocumentsAction!.asAnyAction()
    }
    
    func makePreviewDocumentAction() -> AnyAction<URL, Bool> {
        previewDocumentAction!.asAnyAction()
    }
    
    func makeDownloadDocumentAction() -> AnyAction<URL, Bool> {
        downloadDocumentAction!.asAnyAction()
    }
    
    func makeQuitAction() -> AnyAction<Void, Bool> {
        quitAction!.asAnyAction()
    }
}
