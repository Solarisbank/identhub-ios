//
//  StateView.swift
//  IdentHubSDK
//

import UIKit

/// View which displays the icon and title for the current state.
@IBDesignable
public final class StateView: NibView {

    // MARK: - Inspectable -

    @IBOutlet weak var processingBgView: UIView!
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
        stateLabel.setLabelStyle(.custom(font: UIFont.getFont(size: FontSize.big), color: colors[.header]))
        stateDescriptionLabel.setLabelStyle(.subtitle)
        processingBgView.backgroundColor = colors[.primaryAccent].withAlphaComponent(0.08)
    }

    public func setStateImage(_ image: UIImage?) {
        stateImageView.image = image
        stateImageView.tintColor = colors[.primaryAccent]
    }

    public func setStateTitle(_ title: String) {
        stateLabel.text = title
    }

    public func setStateDescription(_ description: String) {
        stateDescriptionLabel.text = description
    }
}
