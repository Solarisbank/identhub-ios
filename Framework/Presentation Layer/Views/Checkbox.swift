//
//  Checkbox.swift
//  IdentHubSDK
//

import UIKit

class Checkbox: UIButton {

    // MARK: - Properties -

    override var isSelected: Bool {
        didSet {
            updateApperance()
        }
    }

    // MARK: - Init methods -
    override init(frame: CGRect) {
        super.init(frame: frame)

        configureUI()
    }

    required init?(coder: NSCoder) {
        super.init(coder: coder)

        configureUI()
    }

    // MARK: - Private methods -
    private func updateUI() {
        layer.borderColor = UIColor.sdkColor(.primaryAccent).cgColor
    }
    private func configureUI() {

        layer.cornerRadius = 5
        layer.borderColor = UIColor.sdkColor(.primaryAccent).cgColor
        imageView?.contentMode = .scaleAspectFill
        setImage(.sdkImage(.checkmark, type: Checkbox.self), for: .selected)

        updateApperance()
    }
    private func updateApperance() {

        layer.borderWidth = isSelected ? 0 : 1
        backgroundColor = isSelected ? .sdkColor(.primaryAccent) : .clear
    }
    
    override func traitCollectionDidChange(_ previousTraitCollection: UITraitCollection?) {
        super.traitCollectionDidChange(previousTraitCollection)
        updateUI()
    }
}
