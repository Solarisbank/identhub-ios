//
//  StateView.swift
//  IdentHubSDK
//

import UIKit

/// View which displays the icon and title for the current state.
@IBDesignable
final internal class StateView: NibView {

    // MARK: - Inspectable -

    @IBInspectable var hasDescriptionLabel: Bool = true

    // MARK: - Outlets -

    @IBOutlet var containerView: UIView!
    @IBOutlet var stateImageView: UIImageView!
    @IBOutlet var stateLabel: UILabel!
    @IBOutlet var stateDescriptionLabel: UILabel!

    // MARK: - Override methods -

    override func initUI() {
        super.initUI()

        addSubview(containerView)
        containerView.frame = bounds
        stateLabel.textColor = .sdkColor(.base100)
        stateDescriptionLabel.textColor = .sdkColor(.base75)
    }

    override func configureUI() {

        stateDescriptionLabel.isHidden = !hasDescriptionLabel
    }

    /// Set image.
    func setStateImage(_ image: UIImage?) {
        stateImageView.image = image
        stateImageView.tintColor = .sdkColor(.secondaryAccent)
    }

    /// Set state title.
    func setStateTitle(_ title: String) {
        stateLabel.text = title
    }

    /// Set state description.
    func setStateDescription(_ description: String) {
        stateDescriptionLabel.text = description
    }
}
