//
//  CircleProgressView.swift
//  IdentHubSDK
//

import UIKit

class CircleProgressView: UIView {

    // MARK: - Outlets -
    @IBOutlet var contentView: UIView!
    @IBOutlet var animateProgress: RotatingCircularProgressBar!
    @IBOutlet var backgroundView: UIView!

    var defaultProgress: CGFloat? {
        didSet {
            animateProgress.progress = defaultProgress ?? 0
        }
    }

    // MARK: - Init methods -

    override init(frame: CGRect) {
        super.init(frame: frame)
        setup()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)

        setup()
    }

    // MARK: - Lifecycle methods -
    override func layoutSubviews() {
        super.layoutSubviews()

        backgroundView.layer.cornerRadius = backgroundView.frame.width / 2
    }

    // MARK: - Internal methods -

    private func setup() {
        Bundle(for: Self.self).loadNibNamed("CircleProgressView", owner: self, options: nil)

        addSubview(contentView)
        contentView.frame = bounds
    }

}
