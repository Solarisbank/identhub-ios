//
//  DownloadDocumentAction.swift
//  IdentHubSDKQES
//

import Foundation
import UIKit
import IdentHubSDKCore

final internal class DownloadDocumentAction: Action {
    private var documentExporter: DocumentExporter
    private var viewController: UIViewController

    init(documentExporter: DocumentExporter, viewController: UIViewController) {
        self.documentExporter = documentExporter
        self.viewController = viewController
    }

    func perform(input: URL, callback: @escaping (Bool) -> Void) -> Showable? {
        documentExporter.presentExporter(from: viewController, in: .zero, documentURL: input) {
            callback(true)
        }

        return nil
    }
}
