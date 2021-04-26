//
//  DocumentInfoDDM.swift
//  IdentHubSDK
//

import UIKit

protocol DocumentInfoDDMDelegate: AnyObject {

    /// Method notified when user updated document info
    /// - Parameter content: content cell object
    func didUpdatedContent(_ content: DocumentItemInfo)
}

final class DocumentInfoDDM: NSObject {

    // MARK: - Private attributes -
    private var content: [DocumentItemInfo]
    private weak var output: DocumentInfoDDMDelegate?

    // MARK: - Init methods -
    init(_ content: [DocumentItemInfo], output: DocumentInfoDDMDelegate) {

        self.content = content
        self.output = output

        super.init()
    }
}

extension DocumentInfoDDM: UITableViewDataSource {
    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: documentInfoCellID, for: indexPath) as! DocumentItemInfoCell

        let cellContent = content[indexPath.row]

        cell.configure(with: cellContent)

        cell.didEdited = { [unowned self] content in
            guard let content = content else { return }

            self.output?.didUpdatedContent(content)
        }

        return cell
    }
}