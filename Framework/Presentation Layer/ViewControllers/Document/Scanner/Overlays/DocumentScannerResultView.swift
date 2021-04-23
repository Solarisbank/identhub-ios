//
//  DocumentScannerResultView.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore
import FourthlineVision

final class DocumentScannerResultView: UIView {

    // MARK: - Private attributes -
    @IBOutlet var documentFrame: UIImageView!
    @IBOutlet var documentResult: UIImageView!
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var retakeBtnTitle: UILabel!
    @IBOutlet var confirmBtnTitle: UILabel!
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
    func set(_ stepResult: DocumentScannerStepResult, mask: UIImage, with configuration: DocumentScannerAssetConfiguration, for step: DocumentScannerStep) {
        self.stepResult = stepResult

        titleLbl.text = "Confirm \(step.name)"
        documentFrame.image = mask
        documentResult.image = stepResult.image.full
        changeMask(configuration: configuration)
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
