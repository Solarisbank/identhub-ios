//
//  PreviewDocumentAction.swift
//  IdentHubSDKQES
//
import Foundation
import IdentHubSDKCore
import QuickLook

final internal class PreviewDocumentAction: Action {
    private var documentExporter: DocumentExporter
    private var viewController: UIViewController

    init(documentExporter: DocumentExporter, viewController: UIViewController) {
        self.documentExporter = documentExporter
        self.viewController = viewController
    }

    func perform(input: URL, callback: @escaping (Bool) -> Void) -> Showable? {
        documentExporter.previewDocument(from: viewController, documentURL: input) {
            callback(true)
        }

        return nil
    }
}
