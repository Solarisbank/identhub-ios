//
//  LogoAnimator.swift
//  IdentHubSDK
//

import UIKit

/// Class mainly used for animating welcome screen logo image
/// Also used for updating static image of the logo and logo frame
final internal class WelcomeLogoAnimator: NSObject {

    // MARK: - Properties -
    private var logoFrameImage: UIImageView
    private var logoImage: UIImageView

    // MARK: - Init methods -

    /// Init method with setting main UI components for animation
    /// - Parameters:
    ///   - logoImage: main logo image view component
    ///   - logoFrameImage: frame logo image view component
    init(_ logoImage: UIImageView, logoFrameImage: UIImageView) {

        self.logoImage = logoImage
        self.logoFrameImage = logoFrameImage

        super.init()
    }

    // MARK: - Public methods -

    /// Method updated logo and logo frame image and animate it
    /// - Parameter data: visible page data
    func updateImageData(_ data: WelcomePageContent) {

        logoImage.animationImages = imagesSet(data.pageLogoName, count: 5)
        logoImage.contentMode = .center
        logoImage.animationDuration = 0.4
        logoImage.animationRepeatCount = 1

        if let frameName = data.pageLogoFrameName {
            logoFrameImage.animationImages = imagesSet(frameName, count: 3)
            logoFrameImage.animationDuration = 0.4
            logoFrameImage.animationRepeatCount = 1
        } else {
            logoFrameImage.image = nil
        }

        UIView.animateKeyframes(withDuration: 1, delay: 0.4, options: .calculationModeLinear) { [weak self] in
            self?.logoImage.startAnimating()

            if data.pageLogoFrameName != nil {
                self?.logoFrameImage.startAnimating()
            }
        } completion: { [weak self] _ in
            self?.setStaticImage(data.pageLogoName, bgImageName: data.pageLogoFrameName ?? "")
        }
    }

    // MARK: - Internal methods -
    private func imagesSet(_ name: String, count: Int) -> [UIImage] {
        var imagesSet: [UIImage] = []

        for idx in 1...count {
            let imageName = "\(name)_\(idx)"

            imagesSet.append(loadImage(with: imageName))
        }
        return imagesSet
    }

    private func setStaticImage(_ logoImageName: String, bgImageName: String) {
        let logoImageName = "\(logoImageName)_5"
        let bgImageName = "\(bgImageName)_3"

        logoImage.image = loadImage(with: logoImageName)
        logoFrameImage.image = loadImage(with: bgImageName)
    }

    private func loadImage(with name: String) -> UIImage {
        if let image = UIImage(named: name, in: Bundle(for: WelcomeLogoAnimator.self), compatibleWith: nil) {

            return image
        }

        return UIImage()
    }
}
