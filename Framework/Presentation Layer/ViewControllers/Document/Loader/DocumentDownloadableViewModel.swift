//
//  DocumentDownloadableViewModel.swift
//  IdentHubSDK
//

import Foundation

protocol DocumentDownloadableViewModel: ViewModel {

    /// Delegate which informs if the documents have been received..
    var documentDelegate: DocumentReceivable? { get set }

    /// The list of documents.
    var documents: [ContractDocument] { get set }

    /// Check if the documents are available.
    func checkDocumentsAvailability()

    /// Save the docuemnts.
    ///
    /// - Parameter docments: documents to be saved.
    func saveDocuments(_ documents: [ContractDocument])

    /// Download the document  with the given id and view it.
    ///
    /// - Parameter id: the id of the document.
    func previewDownloadedDocument(withId id: String)

    /// Download the document  with the given id and save it.
    ///
    /// - Parameter id: the id of the document.
    func exportDocument(withId id: String)

    /// Download all documents and save them.
    func downloadAndSaveAllDocuments()
}

extension DocumentDownloadableViewModel {

    /// - SeeAlso: DocumentDownloadable.checkDocumentsAvailability()
    func checkDocumentsAvailability() {
        verificationService.getIdentification { [weak self] result in
            switch result {
            case .success(let response):
                guard let documents = response.documents else { break }
                DispatchQueue.main.async {
                    self?.saveDocuments(documents)
                }
            default:
                break
            }
        }
    }

    /// - SeeAlso: DocumentDownloadable.saveDocuments()
    func saveDocuments(_ documents: [ContractDocument]) {
        for document in documents {
            self.documents.append(document)
        }
        documentDelegate?.didFetchDocuments()
    }

    /// - SeeAlso: DocumentDownloadable.previewDownloadedDocument()
    func previewDownloadedDocument(withId id: String) {
        downloadAndSaveDocument(withID: id) {[weak self] path in

            DispatchQueue.main.async { [weak self] in
                self?.flowCoordinator.perform(action: .documentPreview(url: path))
                self?.documentDelegate?.didFinishLoadingDocument()
            }
        }
    }

    /// - SeeAlso: DocumentDownloadable.downloadAndSaveDocument()
    func exportDocument(withId id: String) {

        downloadAndSaveDocument(withID: id) {[weak self] path in
            DispatchQueue.main.async {
                self?.flowCoordinator.perform(action: .documentExport(url: path))
                self?.documentDelegate?.didFinishLoadingDocument()
            }
        }
    }

    /// - SeeAlso: DocumentDownloadable.downloadAndSaveAllDocuments()
    func downloadAndSaveAllDocuments() {
        var savedDocuments: [URL] = []

        for document in documents {
            downloadAndSaveDocument(withID: document.id) {[weak self] path in
                guard let `self` = self else { return }

                savedDocuments.append(path)

                if savedDocuments.count == self.documents.count {
                    DispatchQueue.main.async {
                        self.flowCoordinator.perform(action: .allDocumentsExport(documents: savedDocuments))
                        self.documentDelegate?.didFinishLoadingAllDocuments()
                    }
                }
            }
        }
    }
}

// MARK: - Internal methods -
extension DocumentDownloadableViewModel {

    func downloadDocument(withID id: String, completion: @escaping (_ data: Data) -> Void) {

        verificationService.getDocument(documentId: id) { result in
            switch result {
            case .success(let response):
                guard let url = response,
                      let data = try? Data(contentsOf: url) else { return }

                completion(data)

            default:
                break
            }
        }
    }

    func downloadAndSaveDocument(withID id: String, completion: @escaping (_ path: URL) -> Void) {
        downloadDocument(withID: id) { data in

            guard let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).pdf") else { return }

            do {
                try data.write(to: path)

                completion(path)

            } catch {
                print("Error occurs during saving loaded file: \(error)")
            }
        }
    }
}

protocol DocumentReceivable: AnyObject {

    /// Called when the documents are fetched.
    func didFetchDocuments()

    /// Method notified when document loaded
    func didFinishLoadingDocument()

    /// Methods notified when all documents loaded
    func didFinishLoadingAllDocuments()
}

extension DocumentReceivable {
    func didFinishLoadingAllDocuments() {}
}
