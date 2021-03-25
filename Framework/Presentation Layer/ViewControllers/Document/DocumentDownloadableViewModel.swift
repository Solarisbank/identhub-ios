//
//  DocumentDownloadableViewModel.swift
//  IdentHubSDK
//

import Foundation

protocol DocumentDownloadableViewModel: ViewModel {

    /// Delegate which informs if the documents have been received..
    var documentDelegate: DocumentReceivable? { get set }

    /// The list of documents.
    var documents: [Document] { get set }

    /// Check if the documents are available.
    func checkDocumentsAvailability()

    /// Save the docuemnts.
    ///
    /// - Parameter docments: documents to be saved.
    func saveDocuments(_ documents: [Document])

    /// Download the document  with the given id and view it.
    ///
    /// - Parameter id: the id of the document.
    func previewDownloadedDocument(withId id: String)

    /// Download the document  with the given id and save it.
    ///
    /// - Parameter id: the id of the document.
    func downloadAndSaveDocument(withId id: String)

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
    func saveDocuments(_ documents: [Document]) {
        for document in documents {
            self.documents.append(document)
        }
        documentDelegate?.didFetchDocuments()
    }

    /// - SeeAlso: DocumentDownloadable.previewDownloadedDocument()
    func previewDownloadedDocument(withId id: String) {
        verificationService.getDocument(documentId: id) { result in
            switch result {
            case .success(let response):
                guard let url = response,
                      let data = try? Data(contentsOf: url) else { break }
                DispatchQueue.main.async { [weak self] in
                    self?.flowCoordinator.perform(action: .documentPreview(data: data))
                }
            default:
                break
            }
        }
    }

    /// - SeeAlso: DocumentDownloadable.downloadAndSaveDocument()
    func downloadAndSaveDocument(withId id: String) {
        verificationService.getDocument(documentId: id) { result in
            switch result {
            case .success(let response):
                guard let url = response,
                      let data = try? Data(contentsOf: url),
                      let path = FileManager.default.urls(for: .documentDirectory, in: .userDomainMask).first?.appendingPathComponent("\(id).pdf") else { break }
                do {
                    try data.write(to: path)
                } catch { }
            default:
                break
            }
        }
    }

    /// - SeeAlso: DocumentDownloadable.downloadAndSaveAllDocuments()
    func downloadAndSaveAllDocuments() {
        for document in documents {
            downloadAndSaveDocument(withId: document.id)
        }
    }
}

protocol DocumentReceivable: AnyObject {

    /// Called when the documents are fetched.
    func didFetchDocuments()
}
