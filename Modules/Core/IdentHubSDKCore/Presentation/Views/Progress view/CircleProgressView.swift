//
//  CircleProgressView.swift
//  IdentHubSDK
//

import UIKit

public class CircleProgressView: NibView {

    // MARK: - Outlets -
    @IBOutlet var contentView: UIView!
    @IBOutlet public var animateProgress: RotatingCircularProgressBar!
    
    public var defaultProgress: CGFloat? {
        didSet {
            animateProgress.progress = defaultProgress ?? 0
        }
    }

    // MARK: - Override methods -
    
    public override func initUI() {
        super.initUI()

        addSubview(contentView)
        contentView.frame = bounds
    }
}
