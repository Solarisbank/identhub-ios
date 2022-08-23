//
//  ShowableFactoryMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
import IdentHubSDKTestBase
import IdentHubSDKCore

class ShowableFactoryMock: ShowableFactory {
    private var testRecorder: TestRecorder?

    var confirmApplicationCallback: ConfirmApplicationCallback?
    var signDocumentsCallback: SignDocumentsCallback?

    init(testRecorder: TestRecorder? = nil) {
        self.testRecorder = testRecorder
    }

    func makeConfirmApplicationShowable(input: ConfirmApplicationInput, callback: @escaping ConfirmApplicationCallback) -> Showable? {
        let showable = UpdateableMock<ConfirmApplicationState, ConfirmApplicationEventHandler>(recorder: testRecorder)
        testRecorder?.record(event: .service, caller: self, arguments: input)
        confirmApplicationCallback = { result in
            self.testRecorder?.record(event: .service, value: "ShowableFactoryMock.makeConfirmApplicationShowable.callback(\(result))")
            callback(result)
        }
        return showable
    }
    
    func makeSignDocumentsShowable(input: SignDocumentsInput, callback: @escaping SignDocumentsCallback) -> Showable? {
        let showable = UpdateableMock<SignDocumentsState, SignDocumentsEventHandler>(recorder: testRecorder)
        testRecorder?.record(event: .service, caller: self, arguments: input)
        signDocumentsCallback = { result in
            self.testRecorder?.record(event: .service, value: "ShowableFactoryMock.makeSignDocumentsShowable.callback(\(result))")
            callback(result)
        }

        return showable
    }
}
