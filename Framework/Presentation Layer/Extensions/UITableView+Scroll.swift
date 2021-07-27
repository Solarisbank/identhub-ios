//
//  UITableView+Scroll.swift
//  IdentHubSDK
//

import UIKit

extension UITableView {

    /// Method scrolled to the very last item in table view
    func scrollToBottom() {

        DispatchQueue.main.async {
            let row = self.numberOfRows(inSection: self.numberOfSections - 1) - 1
            let section = self.numberOfSections - 1
            let indexPath = IndexPath( row: row, section: section)
            self.scrollToRow(at: indexPath, at: .bottom, animated: true)
        }
    }
}
