//
//  DocumentScannerOverlayView.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore
import FourthlineVision

final class DocumentScannerOverlayView: UIView {

    // MARK: - Outlet attributes -
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var manualControlView: UIView!
    @IBOutlet var statusComponentView: UIView!
    @IBOutlet var statusView: InfoStatusView!
    @IBOutlet var documentFrameView: UIImageView!
    @IBOutlet var maskAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet var maskWidthRatioConstraint: NSLayoutConstraint!
    @IBOutlet var maskCenterYConstraint: NSLayoutConstraint!

    var onDismiss: (() -> Void)?
    var onTakePicture: (() -> Void)?

    // MARK: - Action methods -

    @IBAction func didClickDismiss(_ sender: UIButton) {
        onDismiss?()
    }

    @IBAction func didClickTakePicture(_ sender: UIButton) {
        onTakePicture?()
    }

    // MARK: - Public attributes -

    var state: State = .warning("") {
        didSet {
            switch state {

            case let .success(message):
                displayManualScan(false)
                statusView.didUpdateStatus(Localizable.DocumentScanner.successScan, description: message, status: .success)
            case let .warning(message):
                displayManualScan(false)
                statusView.didUpdateStatus(Localizable.DocumentScanner.scanning, description: message, status: .loading)

            case let .failed(message):
                displayManualScan(false)
                statusView.didUpdateStatus(Localizable.DocumentScanner.scanFailed, description: message, status: .error)
            }
        }
    }

    var descriptionText: String {
        get { statusView.statusDescription.text ?? "" }
        set { statusView.setDescriptionText(newValue) }
    }

    // MARK: - Public methods -

    /// Method updated UI components
    /// - Parameter display: bool value of the displayed status view
    func displayManualScan(_ display: Bool) {
        statusComponentView.isHidden = display
        manualControlView.isHidden = !display
    }

    /// Method udpated document frame image with different states: default, warning, success
    /// - Parameters:
    ///   - mask: image object
    ///   - configuration: configuration object
    func set(mask: UIImage?, with configuration: DocumentScannerAssetConfiguration) {
        documentFrameView.image = mask
        changeMask(configuration: configuration)
    }
}

// MARK: - Internal methods -
private extension DocumentScannerOverlayView {

    func changeMask(configuration: DocumentScannerAssetConfiguration) {
        maskAspectRatioConstraint = remake(constraint: maskAspectRatioConstraint, multiplier: configuration.sizing.aspectRatio)
        maskWidthRatioConstraint = remake(constraint: maskWidthRatioConstraint, multiplier: configuration.layout.screenWidthRatio)
        maskCenterYConstraint = remake(constraint: maskCenterYConstraint, multiplier: configuration.layout.screenCenterYMultiplier)
        layoutIfNeeded()
    }
}

extension DocumentScannerOverlayView {
    enum State {
        case success(String)
        case warning(String)
        case failed(String)
    }
}
