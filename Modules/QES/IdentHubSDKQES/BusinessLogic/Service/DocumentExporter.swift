//
//  DocumentExporter.swift
//  IdentHubSDK
//

import UIKit
import MobileCoreServices
import QuickLook
import IdentHubSDKCore

internal protocol DocumentExporter {

    /// Method presented UIDocumentInteractionController component on provided controller, from frame and with document URL.
    /// - Parameters:
    ///   - from: presented controller object
    ///   - frame: start presentation frame
    ///   - documentURL: exported document URL
    func presentExporter(
        from showable: Showable,
        in frame: CGRect,
        documentURL: URL
    )

    /// Method presents preview component with document data
    /// - Parameters:
    ///   - from: presented controller object
    ///   - documentURL: preview document URL
    func presentPreviewer(
        from showable: Showable,
        documentURL: URL
    )
}

final internal class DocumentExporterService: NSObject, DocumentExporter {

    private var documentExporter: UIDocumentInteractionController?
    private var previewItem: QLPreviewItem?

    private weak var presenter: UIViewController?

    // MARK: - Document exporter protocol methods -
    func presentExporter(from showable: Showable, in frame: CGRect, documentURL: URL) {
        buildDocumentInteractor(from: showable.toShowable(), documentURL: documentURL)

        documentExporter?.presentOptionsMenu(from: frame, in: presenter!.view, animated: true)
    }

    func presentPreviewer(from showable: Showable, documentURL: URL) {
        previewItem = documentURL as QLPreviewItem

        if QLPreviewController.canPreview(previewItem!) {
            let previewController = QLPreviewController()

            previewController.dataSource = self
            previewController.delegate = self

            showable.toShowable().present(previewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Internal methods methods -
extension DocumentExporterService {

    private func buildDocumentInteractor(from controller: UIViewController, documentURL: URL) {
        presenter = controller

        documentExporter = UIDocumentInteractionController(url: documentURL)

        documentExporter?.delegate = self
        documentExporter?.uti = kUTTypePDF as String
        documentExporter?.name = documentURL.lastPathComponent
    }
}

extension DocumentExporterService: UIDocumentInteractionControllerDelegate {

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        guard let presenter = presenter else {
            fatalError("No view controller available to present UIDocumentInteractionController")
        }

        return presenter
    }

    func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
        documentExporter = nil
    }
}

extension DocumentExporterService: QLPreviewControllerDataSource, QLPreviewControllerDelegate {

    func numberOfPreviewItems(in controller: QLPreviewController) -> Int {
        1
    }

    func previewController(_ controller: QLPreviewController, previewItemAt index: Int) -> QLPreviewItem {
        previewItem!
    }

    func previewControllerDidDismiss(_ controller: QLPreviewController) {

        if let fileURL = previewItem?.previewItemURL {
            do {
                try FileManager.default.removeItem(at: fileURL)
                previewItem = nil
            } catch let error {
                print("Occurs error during removing previewed file: \(error)")
            }
        }
    }
}
