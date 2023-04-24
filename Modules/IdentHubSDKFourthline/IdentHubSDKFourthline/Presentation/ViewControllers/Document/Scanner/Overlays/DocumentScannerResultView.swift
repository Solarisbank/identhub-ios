//
//  DocumentScannerResultView.swift
//  IdentHubSDKFourthline
//

import UIKit
import FourthlineCore
import FourthlineVision
import IdentHubSDKCore

final class DocumentScannerResultView: UIView {

    // MARK: - Private attributes -
    @IBOutlet var topMaskView: UIView!
    @IBOutlet var leftMaskView: UIView!
    @IBOutlet var bottomMaskView: UIView!
    @IBOutlet var rightMaskView: UIView!
    @IBOutlet var documentFrame: UIImageView!
    @IBOutlet var documentResult: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var retakeBtnTitle: UILabel!
    @IBOutlet var confirmBtnTitle: UILabel!
    @IBOutlet var confirmBtn: UIButton!
    @IBOutlet var maskAspectRatioConstraint: NSLayoutConstraint!
    @IBOutlet var maskWidthRatioConstraint: NSLayoutConstraint!
    @IBOutlet var maskCenterYConstraint: NSLayoutConstraint!

    private var stepResult: DocumentScannerStepResult!

    var onDismiss: (() -> Void)?
    var onRetake: (() -> Void)?
    var onConfirm: ((_ stepResult: DocumentScannerStepResult) -> Void)?

    // MARK: - Public methods -

    /// Method updated view with new data
    /// - Parameters:
    ///   - stepResult: scan step result object
    ///   - mask: scan frame image
    ///   - step: scan step object
    func set(_ stepResult: DocumentScannerStepResult, mask: UIImage, with configuration: DocumentScannerAssetConfiguration, for step: DocumentScannerStep,_ colors: Colors) {
        self.stepResult = stepResult

        titleLbl.text = Localizable.DocumentScanner.confirmResult
        titleLbl.setLabelStyle(.title)
        documentFrame.image = mask
        documentResult.image = stepResult.image.full
        changeMask(configuration: configuration)
        retakeBtnTitle.text = Localizable.DocumentScanner.retake
        confirmBtnTitle.text = Localizable.Selfie.confirm
        retakeBtnTitle.setLabelStyle(.buttonTitle)
        confirmBtnTitle.setLabelStyle(.buttonTitle)
        configureUI(colors: colors)
    }

    /// Method configure custom colors in UI components
    func configureUI(colors: Colors) {
        confirmBtnTitle.textColor = .white
        confirmBtn.tintColor = colors[.primaryAccent]
    }

    // MARK: - Action methods -
    @IBAction func didClickDismiss(_ sender: UIButton) {
        onDismiss?()
    }

    @IBAction func didClickRetake(_ sender: UIButton) {
        onRetake?()
    }

    @IBAction func didClickConfirm(_ sender: UIButton) {
        onConfirm?(stepResult)
    }
}

// MARK: - Internal methods -
private extension DocumentScannerResultView {

    func changeMask(configuration: DocumentScannerAssetConfiguration) {
        maskAspectRatioConstraint = remake(constraint: maskAspectRatioConstraint, multiplier: configuration.sizing.aspectRatio)
        maskWidthRatioConstraint = remake(constraint: maskWidthRatioConstraint, multiplier: configuration.layout.screenWidthRatio)
        maskCenterYConstraint = remake(constraint: maskCenterYConstraint, multiplier: configuration.layout.screenCenterYMultiplier)

        layoutIfNeeded()
    }
}
