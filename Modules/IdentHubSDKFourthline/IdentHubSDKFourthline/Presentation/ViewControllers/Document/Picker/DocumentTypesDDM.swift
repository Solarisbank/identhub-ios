//
//  DocumentTypesDDM.swift
//  IdentHubSDKFourthline
//

import UIKit
import FourthlineCore
import IdentHubSDKCore

/// Output methods
/// Used for defining scanned document type
protocol DocumentTypesDDMDelegate: AnyObject {

    /// Method notified about selected document type for start scanning process
    /// - Parameter type: enum value of the document type
    func didSelectDocument(with type: DocumentType)
}

/// Class responsible for the conforming datasource and delegate protocols of documents type table
final class DocumentTypesDDM: NSObject {

    // MARK: - Properties -

    private var content: [ScanDocumentType]?
    private var colors: Colors?
    private weak var delegate: DocumentTypesDDMDelegate?

    convenience init(_ content: [ScanDocumentType], _ colors: Colors, output: DocumentTypesDDMDelegate) {

        self.init()

        self.content = content
        self.colors = colors
        self.delegate = output
    }
}

extension DocumentTypesDDM: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content?.count ?? 0
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: documentTypeCellID, for: indexPath) as! DocumentTypeCell

        cell.backgroundColor = .clear

        if let data = content?[indexPath.row] {
            cell.configureCell(with: data)
            cell.selectedStateView.backgroundColor = colors?[.primaryAccent]
        }

        return cell
    }
}

extension DocumentTypesDDM: UITableViewDelegate {

    func tableView(_ tableView: UITableView, didSelectRowAt indexPath: IndexPath) {
        guard let documentData = content?[indexPath.row] else { return }

        delegate?.didSelectDocument(with: documentData.type)
    }

    func tableView(_ tableView: UITableView, heightForRowAt indexPath: IndexPath) -> CGFloat {
        110
    }
}
