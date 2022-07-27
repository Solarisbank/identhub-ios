//
//  NibView.swift
//  IdentHubSDK
//

import UIKit

open class NibView: UIView {
    public private(set) var colors: Colors = ColorsImpl()

    // MARK: - Init methods -

    public override init(frame: CGRect) {
        super.init(frame: frame)
        initUI()
    }

    public required init?(coder aDecoder: NSCoder) {
        super.init(coder: aDecoder)
        initUI()
    }

    // MARK: - Lifecycle methods -

    public override func layoutSubviews() {
        super.layoutSubviews()
        configureUI()
    }

    // MARK: - Update methods -
    public func configure(with colors: Colors) {
        self.colors = colors
        configureUI()
    }

    // MARK: - Internal methods -

    open func initUI() {
        Bundle(for: Self.self).loadNibNamed(String(describing: Self.self), owner: self, options: nil)

        print("Override this method to initiate UI components in \(Self.self)")
    }

    open func configureUI() {
        print("Override this method to setup UI components in \(Self.self)")
    }
}
