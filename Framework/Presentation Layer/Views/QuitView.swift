//
//  QuitView.swift
//  IdentHubSDK
//

import UIKit

@objc protocol Quitable {
    func didClickQuit(_ sender: Any)
}

/// A view with a quit button displayed on the right side.
final class QuitView: UIView {
    private enum Constants {
        enum ConstraintsOffset {
            static let small: CGFloat = 10
        }

        enum Size {
            static let width: CGFloat = 50
            static let height: CGFloat = 50
        }

        enum Image {
            static let close = UIImage(named: "close_btn", in: .current, compatibleWith: nil)
        }
    }

    private let quitBtn = UIButton()

    required init?(coder: NSCoder) {
        super.init(coder: coder)
        configureUI()
    }

    override init(frame: CGRect) {
        super.init(frame: frame)
        configureUI()
    }
    
    /// Sets target on quit button.
    func setTarget(_ target: Quitable) {
        quitBtn.allTargets
            .compactMap { $0 as? Quitable }
            .forEach { quitBtn.removeTarget($0, action: #selector($0.didClickQuit(_:)), for: .touchUpInside) }
        quitBtn.addTarget(target, action: #selector(target.didClickQuit(_:)), for: .touchUpInside)
    }
    
    private func configureUI() {
        quitBtn.setImage(Constants.Image.close, for: .normal)

        addSubview(quitBtn)
        quitBtn.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.small),
            $0.equal(.bottom, constant: .zero),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.small),
            $0.equalConstant(.width, Constants.Size.width),
            $0.equalConstant(.height, Constants.Size.height)
        ]}
    }
}
