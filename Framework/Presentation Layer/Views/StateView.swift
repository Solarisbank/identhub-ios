//
//  StateView.swift
//  IdentHubSDK
//

import UIKit

/// View which displays the icon and title for the current state.
final internal class StateView: UIView {

    enum Constants {
        enum FontSize {
            static let big: CGFloat = 20
            static let normal: CGFloat = 14
        }

        enum ConstraintsOffset {
            static let massive: CGFloat = 64
            static let extended: CGFloat = 40
            static let normal: CGFloat = 24
            static let sidesExtended: CGFloat = 32
            static let size: CGFloat = 72
        }

        enum Size {
            static let cornerRadius: CGFloat = 8
        }
    }

    private let hasDescriptionLabel: Bool

    private lazy var roundedView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.sdkColor(.secondaryTint)
        view.layer.cornerRadius = Constants.ConstraintsOffset.size / 2
        return view
    }()

    private lazy var stateImageView: UIImageView = {
        let imageView = UIImageView()
        return imageView
    }()

    private lazy var stateLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.big)
        label.textColor = UIColor.sdkColor(.base100)
        return label
    }()

    private lazy var stateDescriptionLabel: UILabel = {
        let label = UILabel()
        label.textAlignment = .center
        label.numberOfLines = 0
        label.font = label.font.withSize(Constants.FontSize.normal)
        label.textColor = UIColor.sdkColor(.base75)
        return label
    }()

    // MARK: UI

    init(hasDescriptionLabel: Bool) {
        self.hasDescriptionLabel = hasDescriptionLabel
        super.init(frame: .zero)
        setUpUI()
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }

    private func setUpUI() {
        backgroundColor = .white

        addSubviews([
            roundedView,
            stateLabel
        ])

        roundedView.addConstraints { [
            $0.equal(.top, constant: Constants.ConstraintsOffset.extended),
            $0.equal(.centerX),
            $0.equalConstant(.height, Constants.ConstraintsOffset.size),
            $0.equalConstant(.width, Constants.ConstraintsOffset.size)
        ]
        }

        stateLabel.addConstraints { [
            $0.equalTo(roundedView, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
            $0.equal(.leading, constant: Constants.ConstraintsOffset.sidesExtended),
            $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sidesExtended)
        ]
        }

        if hasDescriptionLabel {
            addSubview(stateDescriptionLabel)
            stateDescriptionLabel.addConstraints { [
                $0.equalTo(stateLabel, .top, .bottom, constant: Constants.ConstraintsOffset.normal),
                $0.equal(.leading, constant: Constants.ConstraintsOffset.sidesExtended),
                $0.equal(.trailing, constant: -Constants.ConstraintsOffset.sidesExtended),
                $0.equal(.bottom, constant: -Constants.ConstraintsOffset.massive)
            ]
            }
        } else {
            stateLabel.addConstraints { [
                $0.equal(.bottom, constant: -Constants.ConstraintsOffset.massive)
            ]
            }
        }

        roundedView.addSubview(stateImageView)

        stateImageView.addConstraints { [
            $0.equal(.centerX),
            $0.equal(.centerY),
            $0.equalConstant(.height, Constants.ConstraintsOffset.size / 2),
            $0.equalConstant(.width, Constants.ConstraintsOffset.size / 2)
        ]
        }
    }

    /// Set image.
    func setStateImage(_ image: UIImage?) {
        stateImageView.image = image
    }

    /// Set state title.
    func setStateTitle(_ title: String) {
        stateLabel.text = title
    }

    /// Set state description.
    func setStateDescription(_ description: String) {
        stateDescriptionLabel.text = description
    }
}
