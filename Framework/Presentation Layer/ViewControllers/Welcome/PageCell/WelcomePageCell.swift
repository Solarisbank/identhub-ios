//
//  WelcomePageCell.swift
//  IdentHubSDK
//

import UIKit

/// Welcome screen page view
class WelcomePageCell: UICollectionViewCell {
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var descriptionLabel: UILabel!

    // MARK: - Public methods -

    /// Configure page data with title and description text
    /// - Parameter data: welcome page data with displayed content
    func configureScreen(_ data: WelcomePageContent) {
        titleLabel.text = data.title
        descriptionLabel.text = data.description
    }
}
