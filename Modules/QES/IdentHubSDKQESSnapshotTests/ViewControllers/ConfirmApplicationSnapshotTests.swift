//
//  ConfirmApplicationSnapshotTests.swift
//  IdentHubSDKQESTests
//
import XCTest
@testable import IdentHubSDKQES
import IdentHubSDKCore
import IdentHubSDKTestBase

final class ConfirmApplicationSnapshotTests: XCTestCase {
    private var state: ConfirmApplicationState!
    
    override func setUp() {
        state = ConfirmApplicationState(documents: .mock())
    }
    
    func testLoadedDocuments() {
        let sut = makeSut()
        sut.updateView(state)
        assertSnapshot(for: sut)
    }
    
    func testLoadedDocuments_TermsAndConditionsLink() {
        let input = ConfirmApplicationInput(identificationUID: "identification_uid", identificationStep: .bankQES)
        let sut = makeSut()
        state.hasTermsAndConditionsLink = (input.identificationStep == .bankQES)
        sut.updateView(state)
        assertSnapshot(for: sut)
    }
    
    private func makeSut() -> ConfirmApplicationViewController {
        return trackedForMemoryLeaks(
            ConfirmApplicationViewController(colors: ColorsImpl.mock(), eventHandler: EventHandlerMock<ConfirmApplicationEvent>().asAnyEventHandler())
        )
    }
}

private extension Array where Element == LoadableDocument {
    static func mock() -> Self {
        let identification = RequestFileMock.identificationNotConfirmed.decode(type: Identification.self)
        return identification.documents!.map { LoadableDocument(isLoading: false, document: $0) }
    }
}
