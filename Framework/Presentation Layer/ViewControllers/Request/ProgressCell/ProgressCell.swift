//
//  ProgressCell.swift
//  IdentHubSDK
//

import UIKit

class ProgressCell: UITableViewCell {

    // MARK: - Outlets -
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var separator: UIView!
    @IBOutlet var progressActivity: UIActivityIndicatorView!
    @IBOutlet var completionStatus: UIImageView!

    // MARK: - Public methods -

    func configure(with content: ProgressCellObject) {

        titleLbl.text = content.title
        separator.isHidden = !content.visibleSeparator

        if content.loading {
            progressActivity.startAnimating()
            completionStatus.isHidden = true
        } else {
            progressActivity.stopAnimating()
            completionStatus.isHidden = false
        }
    }
}
