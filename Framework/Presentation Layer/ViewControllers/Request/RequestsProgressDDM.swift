//
//  UploadProgressDDM.swift
//  IdentHubSDK
//

import UIKit

final class RequestsProgressDDM: NSObject {

    // MARK: - Private attributes -
    private var content: [ProgressCellObject] = []

    // MARK: - Public methods -
    func updateContent(_ content: [ProgressCellObject]) {
        self.content = content.filter { $0.visible }
    }
}

extension RequestsProgressDDM: UITableViewDataSource {

    func tableView(_ tableView: UITableView, numberOfRowsInSection section: Int) -> Int {
        content.count
    }

    func tableView(_ tableView: UITableView, cellForRowAt indexPath: IndexPath) -> UITableViewCell {
        let cell = tableView.dequeueReusableCell(withIdentifier: progressCellID, for: indexPath) as! ProgressCell

        cell.configure(with: content[indexPath.row])

        return cell
    }
}
