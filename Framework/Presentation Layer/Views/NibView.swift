//
//  NibView.swift
//  IdentHubSDK
//

import UIKit

class NibView: UIView {

    // MARK: - Init methods -

    override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }

    // MARK: - Lifecycle methods -

    override func layoutSubviews() {
        super.layoutSubviews()
        setupUI()
    }

    // MARK: - Internal methods -

    internal func initUI() {
        Bundle(for: Self.self).loadNibNamed(String(describing: Self.self), owner: self, options: nil)

        print("Override this method to initiate UI components")
    }

    internal func setupUI() {
        print("Override this method to setup UI components")
    }
}
