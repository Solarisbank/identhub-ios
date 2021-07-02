//
//  SolarisViewController.swift
//  IdentHubSDK
//

import UIKit

/// UIViewController which contains container with white background for the main content and a bottom view for Solarisbank logo.
internal class SolarisViewController: UIViewController {

    enum Constants {
        static let normalOffset: CGFloat = 28
    }

    internal lazy var containerView: UIView = {
        let view = UIView()
        view.backgroundColor = .sdkColor(.black0)
        return view
    }()

    private lazy var bottomSolarisView: UIView = {
        let view = UIView()
        view.backgroundColor = UIColor.sdkColor(.black05)
        return view
    }()

    private lazy var solarisImageView: UIImageView = {
        let imageView = UIImageView()
        let image = UIImage.sdkImage(.poweredBySolarisbank, type: SolarisViewController.self)
        imageView.image = image
        return imageView
    }()

    override func viewDidLoad() {
        super.viewDidLoad()
        setUpUI()
    }

    private func setUpUI() {
        view.addSubviews([
            containerView,
            bottomSolarisView
        ])

        containerView.addConstraints { [
            $0.equalTo(view, .top, .safeAreaTop),
            $0.equal(.leading),
            $0.equal(.trailing)
        ]
        }

        bottomSolarisView.addConstraints { [
            $0.equalTo(containerView, .top, .bottom),
            $0.equal(.leading),
            $0.equal(.trailing),
            $0.equal(.bottom)
        ]
        }

        bottomSolarisView.addSubviews([solarisImageView])

        solarisImageView.addConstraints { [
            $0.equal(.top, constant: Constants.normalOffset),
            $0.equal(.centerX)
        ]
        }
    }
}
