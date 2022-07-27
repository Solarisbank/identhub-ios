//
//  DocumentExporter.swift
//  IdentHubSDK
//

import UIKit
import MobileCoreServices
import QuickLook

internal protocol DocumentExporter {

    /// Method presented UIDocumentInteractionController component on provided controller, from frame and with document URL.
    /// - Parameters:
    ///   - from: presented controller object
    ///   - frame: start presentation frame
    ///   - documentURL: exported document URL
    func presentExporter(
        from controller: UIViewController,
        in frame: CGRect,
        documentURL: URL,
        completion: (() -> Void)?
    )

    /// Method presented UIActivityViewController with exported items
    /// - Parameters:
    ///   - from: presented controller object
    ///   - documents: array with exported documents URLs
    func presentAllDocumentsExporter(from controller: UIViewController, documents: [URL])

    /// Method presents preview component with document data
    /// - Parameters:
    ///   - from: presented controller object
    ///   - documentURL: preview document URL
    func previewDocument(
        from controller: UIViewController,
        documentURL: URL,
        completion: (() -> Void)?
    )
}

final internal class DocumentExporterService: NSObject, DocumentExporter {

    private var documentExporter: UIDocumentInteractionController?
    private var presenter: UIViewController?
    private var previewItem: QLPreviewItem?
    private var callback: (() -> Void)?

    // MARK: - Document exporter protocol methods -
    func presentExporter(
        from controller: UIViewController,
        in frame: CGRect,
        documentURL: URL,
        completion: (() -> Void)?
    ) {
        callback = completion
        buildDocumentInteractor(from: controller, documentURL: documentURL)

        documentExporter?.presentOptionsMenu(from: frame, in: presenter!.view, animated: true)
    }

    func presentAllDocumentsExporter(from controller: UIViewController, documents: [URL]) {

        let activityController = UIActivityViewController(activityItems: documents, applicationActivities: nil)

        controller.present(activityController, animated: true, completion: nil)
    }

    func previewDocument(from controller: UIViewController, documentURL: URL, completion: (() -> Void)? = nil) {
        previewItem = documentURL as QLPreviewItem
        callback = completion

        if QLPreviewController.canPreview(previewItem!) {
            let previewController = QLPreviewController()

            previewController.dataSource = self
            previewController.delegate = self

            controller.present(previewController, animated: true, completion: nil)
        }
    }
}

// MARK: - Internal methods methods -
extension DocumentExporterService {

    func buildDocumentInteractor(from controller: UIViewController, documentURL: URL) {
        presenter = controller

        documentExporter = UIDocumentInteractionController(url: documentURL)

        documentExporter?.delegate = self
        documentExporter?.uti = kUTTypePDF as String
        documentExporter?.name = documentURL.lastPathComponent
    }
}

extension DocumentExporterService: UIDocumentInteractionControllerDelegate {

    func documentInteractionControllerViewControllerForPreview(_ controller: UIDocumentInteractionController) -> UIViewController {
        return self.presenter!
    }

    func documentInteractionControllerDidDismissOptionsMenu(_ controller: UIDocumentInteractionController) {
        documentExporter = nil
        presenter = nil
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
            callback?()
        }
    }
}
