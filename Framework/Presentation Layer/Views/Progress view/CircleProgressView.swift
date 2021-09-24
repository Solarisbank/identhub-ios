//
//  CircleProgressView.swift
//  IdentHubSDK
//

import UIKit

class CircleProgressView: NibView {

    // MARK: - Outlets -
    @IBOutlet var contentView: UIView!
    @IBOutlet var animateProgress: RotatingCircularProgressBar!
    @IBOutlet var backgroundView: UIView!

    var defaultProgress: CGFloat? {
        didSet {
            animateProgress.progress = defaultProgress ?? 0
        }
    }

    // MARK: - Override methods -

    override func initUI() {
        super.initUI()

        addSubview(contentView)
        contentView.frame = bounds
    }

    override func configureUI() {
        backgroundView.layer.cornerRadius = backgroundView.frame.width / 2
        animateProgress.color = .sdkColor(.primaryAccent)
    }
}
