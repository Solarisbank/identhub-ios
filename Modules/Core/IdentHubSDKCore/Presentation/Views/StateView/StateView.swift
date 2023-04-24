//
//  StateView.swift
//  IdentHubSDK
//

import UIKit

/// View which displays the icon and title for the current state.
@IBDesignable
public final class StateView: NibView {

    // MARK: - Inspectable -

    @IBInspectable public var hasDescriptionLabel: Bool = true

    // MARK: - Outlets -

    @IBOutlet private var containerView: UIView!
    @IBOutlet private var stateImageView: UIImageView!
    @IBOutlet private var stateLabel: UILabel!
    @IBOutlet private var stateDescriptionLabel: UILabel!

    // MARK: - Override methods -

    public override func initUI() {
        super.initUI()

        addSubview(containerView)
        containerView.frame = bounds
    }

    public override func configureUI() {
        stateDescriptionLabel.isHidden = !hasDescriptionLabel
        stateLabel.setLabelStyle(.title)
        stateDescriptionLabel.setLabelStyle(.subtitle)
    }

    public func setStateImage(_ image: UIImage?) {
        stateImageView.image = image
        stateImageView.tintColor = colors[.secondaryAccent]
    }

    public func setStateTitle(_ title: String) {
        stateLabel.text = title
    }

    public func setStateDescription(_ description: String) {
        stateDescriptionLabel.text = description
    }
}
