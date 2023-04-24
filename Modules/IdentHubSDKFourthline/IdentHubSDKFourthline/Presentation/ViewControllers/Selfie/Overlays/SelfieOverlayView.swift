//
//  SelfieOverlayView.swift
//  IdentHubSDKFourthline
//

import UIKit
import FourthlineVision

final class SelfieOverlayView: UIView {

    // MARK: - Properties -

    @IBOutlet var selfieFrameView: UIView!
    @IBOutlet var titleLabel: UILabel!
    @IBOutlet var statusView: InfoStatusView!
    @IBOutlet var selfieFrame: UIImageView!
    @IBOutlet var titleShadowView: UIImageView!
    @IBOutlet var livenessDirectionView: UIImageView!

    var status: Status = .warning(withMessage: SelfieScannerWarning.faceNotInFrame.text) {

        didSet {
            switch status {
            case .success:
                statusView.status = .success
                selfieFrame.image = UIImage(named: "camera_success_frame", in: Bundle(for: Self.self), compatibleWith: nil)
                statusView.didUpdateStatus(Localizable.Selfie.detected, description: Localizable.Selfie.success, status: .success)
            case let .warning(text):
                selfieFrame.image = UIImage(named: "camera_warning_frame", in: Bundle(for: Self.self), compatibleWith: nil)
                statusView.didUpdateStatus(Localizable.Selfie.scanning, description: text, status: .loading)
            case let .failed(text):
                selfieFrame.image = UIImage(named: "camera_warning_frame", in: Bundle(for: Self.self), compatibleWith: nil)
                statusView.didUpdateStatus(Localizable.Selfie.Errors.failed, description: text, status: .error)
            case .livenessSuccess:
                selfieFrame.image = UIImage(named: "camera_warning_frame", in: Bundle(for: Self.self), compatibleWith: nil)
                statusView.didUpdateStatus(Localizable.Selfie.Liveness.confirm, description: Localizable.Selfie.success, status: .success)
            case .livenessCheck:
                titleLabel.text = Localizable.Selfie.Liveness.title
            case let .livenessFailed(text):
                statusView.didUpdateStatus(Localizable.Selfie.Liveness.failed, description: text, status: .error)
            }
        }
    }

    var onDismiss: (() -> Void)?

    var title: String = Localizable.Selfie.selfieTitle {

        didSet {
            titleLabel.text = title
            titleLabel.setLabelStyle(.title)
        }
    }

    var message: String {
        get { statusView.statusDescription.text ?? "" }
        set { statusView.setDescriptionText(newValue) }
    }

    var viewType: SelfieScannerStep = SelfieScannerStep.selfie {

        didSet {
            switch viewType {
            case .selfie:
                selfieFrameView.isHidden = false
                titleShadowView.isHidden = true
                livenessDirectionView.isHidden = true
            case .turnHeadLeft:
                selfieFrameView.isHidden = true
                titleShadowView.isHidden = false
                livenessDirectionView.isHidden = false
                livenessDirectionView.image = UIImage(named: "liveness_left_direction", in: Bundle(for: Self.self), compatibleWith: nil)
                statusView.didUpdateStatus(Localizable.Selfie.Liveness.checking, description: Localizable.Selfie.Liveness.turnHeadLeft, status: .loading)
            case .turnHeadRight:
                selfieFrameView.isHidden = true
                titleShadowView.isHidden = false
                livenessDirectionView.isHidden = false
                livenessDirectionView.image = UIImage(named: "liveness_right_direction", in: Bundle(for: Self.self), compatibleWith: nil)
                statusView.didUpdateStatus(Localizable.Selfie.Liveness.checking, description: Localizable.Selfie.Liveness.turnHeadRight, status: .loading)
            default:
                break
            }
        }
    }

    // MARK: - Actions methods -

    @IBAction func dismiss() {
        if let dismiss = onDismiss {
            dismiss()
        }
    }
}

extension SelfieOverlayView {

    enum Status {
        case success
        case warning(withMessage: String)
        case failed(withMessage: String)
        case livenessSuccess
        case livenessCheck
        case livenessFailed(withMessage: String)
    }
}
