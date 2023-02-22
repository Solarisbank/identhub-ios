//
//  Checkbox.swift
//  IdentHubSDKCore
//

import UIKit

class Checkbox: UIButton {

    // MARK: - Properties -

    override var isSelected: Bool {
        didSet {
            updateApperance()
        }
    }
    
    private var colors: Colors = ColorsImpl()

    // MARK: - Init methods -
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureUI()
    }
    
    public func setAppearance(_ colors: Colors) {
        self.colors = colors
        configureUI()
    }

    // MARK: - Private methods -
    private func updateUI() {
        layer.borderColor = colors[.primaryAccent].cgColor
    }
    private func configureUI() {

        layer.cornerRadius = 5
        layer.borderColor = colors[.primaryAccent].cgColor
        imageView?.contentMode = .scaleAspectFill
        setImage(Bundle.core.image(named: "checkmark"), for: .selected)

        updateApperance()
    }
    private func updateApperance() {

        layer.borderWidth = isSelected ? 0 : 1
        backgroundColor = isSelected ? colors[.primaryAccent] : .clear
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUI()
    }
}

