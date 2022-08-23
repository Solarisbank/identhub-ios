//
//  DocumentExporterMock.swift
//  IdentHubSDKQESTests
//

@testable import IdentHubSDKQES
import UIKit
import IdentHubSDKTestBase
import IdentHubSDKCore

class DocumentExporterMock: DocumentExporter {
    private let recorder: TestRecorder?

    var presentExporterCallsCount = 0
    var presentExporterArguments: [(showable: Showable, frame: CGRect, documentURL: URL)] = []

    var presentPreviewerCallsCount = 0
    var presentPreviewerArguments: [(showable: Showable, documentURL: URL)] = []

    init(recorder: TestRecorder? = nil) {
        self.recorder = recorder
    }
    
    func clear() {
        presentExporterArguments = []
        presentPreviewerArguments = []
    }

    func presentExporter(from showable: Showable, in frame: CGRect, documentURL: URL) {
        if let recorder = recorder {
            recorder.record(event: .ui, in: #function, caller: self)
        } else {
            presentExporterCallsCount += 1
            presentExporterArguments.append((showable: showable, frame: frame, documentURL: documentURL))
        }
    }
    
    func presentPreviewer(from showable: Showable, documentURL: URL) {
        if let recorder = recorder {
            recorder.record(event: .ui, in: #function, caller: self)
        } else {
            presentPreviewerCallsCount += 1
            presentPreviewerArguments.append((showable: showable, documentURL: documentURL))
        }
    }
}
