//
//  SignDocumentsSnapshotTests.swift
//  IdentHubSDKQESSnapshotTests
//

import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKCore
import IdentHubSDKTestBase
@testable import IdentHubSDKQESTests

final class SignDocumentsSnapshotTests: XCTestCase {
    private let transactionId = "8981-7341"
    private let mobileNumber = "+49 111 222 333"

    func testRequestCodeSent() {
        let sut = makeSut()
        let state = SignDocumentsState(
            mobileNumber: mobileNumber,
            state: .requestingCode,
            newCodeRemainingTime: 2
        )
        sut.updateView(state)
        assertSnapshot(for: sut)
    }

    func testRequestCodeReceived() {
        let sut = makeSut()
        let state = SignDocumentsState(
            mobileNumber: mobileNumber,
            state: .codeAvailable,
            newCodeRemainingTime: 2,
            transactionId: transactionId
        )
        sut.updateView(state)
        assertSnapshot(for: sut)
    }

    func testRequestCodeTimerExpired() {
        let sut = makeSut()
        let state = SignDocumentsState(
            mobileNumber: mobileNumber,
            state: .codeAvailable,
            newCodeRemainingTime: 0,
            transactionId: transactionId
        )
        sut.updateView(state)
        assertSnapshot(for: sut)
    }

    func testRequestCodeFailed() {
        let sut = makeSut()
        let state = SignDocumentsState(
            mobileNumber: mobileNumber,
            state: .codeUnavailable,
            newCodeRemainingTime: 2
        )
        sut.updateView(state)
        assertSnapshot(for: sut)
    }

    func testWrongCodeEntered() {
        let sut = makeSut()
        let state = SignDocumentsState(
            mobileNumber: mobileNumber,
            state: .codeInvalid,
            newCodeRemainingTime: 0,
            transactionId: transactionId
        )
        sut.updateView(state)
        assertSnapshot(for: sut)
    }
    
    func testProcessing() {
        let sut = makeSut()
        let state = SignDocumentsState(
            mobileNumber: mobileNumber,
            state: .processingIdentfication,
            newCodeRemainingTime: 0,
            transactionId: transactionId
        )
        sut.updateView(state)
        assertSnapshot(for: sut)
    }
    
    private func makeSut() -> SignDocumentsViewController {
        return trackedForMemoryLeaks(
            SignDocumentsViewController(colors: ColorsImpl.mock(), eventHandler: SignDocumentsEventHandlerMock())
        )
    }
}

private extension Array where Element == LoadableDocument {
    static func mock() -> Self {
        let identification = RequestFileMock.identificationNotConfirmed.decode(type: Identification.self)
        return identification.documents!.map { LoadableDocument(isLoading: false, document: $0) }
    }
}
