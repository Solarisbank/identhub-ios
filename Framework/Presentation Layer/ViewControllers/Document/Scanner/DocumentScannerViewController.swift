//
//  DocumentScannerViewController.swift
//  IdentHubSDK
//

import UIKit
import FourthlineCore
import FourthlineVision
import AudioToolbox

final class DocumentScannerViewController: UIViewController {

    // MARK: - Private attributes
    private var viewModel: DocumentScannerViewModel
    private var currentStep: DocumentScannerStep!
    private var autodetectTimer: Timer?
    private var warningsTimer: Timer?
    private var cachedWarnings: Set<Int> = Set()

    private lazy var documentScanner: DocumentScanner = {
        let scanner = DocumentScanner()

        scanner.delegate = self
        scanner.dataSource = self
        scanner.setOverlayView(documentOverlay, animationType: .bothFade)

        return scanner
    }()

    private lazy var documentOverlay: DocumentScannerOverlayView = {
        let overlayView = DocumentScannerOverlayView.fromNib()

        overlayView.onTakePicture = { [unowned self] in
            self.documentScanner.takeSnapshot()
        }

        overlayView.onDismiss = { [unowned self] in
            self.dismissScanner()
        }

        return overlayView
    }()

    private lazy var resultView: DocumentScannerResultView = {
        let result = DocumentScannerResultView.fromNib()

        result.frame = view.bounds

        result.onDismiss = { [unowned self] in
            self.dismissScanner()
        }

        result.onRetake = { [unowned self] in
            self.dismissIntermediate()
            self.documentScanner.resetCurrentStep()
            self.changeMask(for: .warning)
        }

        result.onConfirm = { [unowned self] result in
            self.viewModel.saveResult(result)
            self.documentScanner.moveToNextStep()
            self.dismissIntermediate()
        }

        return result
    }()

    private lazy var config: DocumentScannerConfig = {
        DocumentScannerConfig(type: viewModel.documentType)
    }()

    // MARK: - Init methods -
    init(viewModel: DocumentScannerViewModel) {
        self.viewModel = viewModel

        super.init(nibName: nil, bundle: nil)
    }

    required init?(coder: NSCoder) {
        fatalError("init(coder:) had not been implemented")
    }

    // MARK: - Lifecycle methods -
    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()

        add(child: documentScanner)
    }
}

extension DocumentScannerViewController: DocumentScannerDataSource, DocumentScannerAssetPlacement {

    func documentDetectionArea(in scanner: DocumentScanner, for step: DocumentScannerStep) -> CGRect {

        let info = DocumentScannerInfo(step: currentStep, config: config, state: .warning)
        let configuration = assetConfiguration(for: info)
        let sizing = currentStep.isAngled ? configuration.tiltedSizing : configuration.sizing
        let scanningArea = detectionArea(inside: documentOverlay.documentFrameView.frame, from: sizing)

        return scanningArea
    }

    func documentConfig(for scanner: DocumentScanner) -> DocumentScannerConfig {
        config
    }
}

extension DocumentScannerViewController: DocumentScannerDelegate {
    func documentScanner(_ scanner: DocumentScanner, onSuccess result: DocumentScannerResult) {
        viewModel.updateResult(result)

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        dismissScanner()
    }

    func documentScanner(_ scanner: DocumentScanner, onFail error: DocumentScannerError) {
        stopProcessingWarnings()
        stopAutodetectTimer()

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        documentOverlay.state = .failed(error.text)
        viewModel.cleanData()
        displayScannerError()
    }

    func documentScanner(_ scanner: DocumentScanner, onStepUpdate step: DocumentScannerStep) {
        currentStep = step

        stopAutodetectTimer()
        documentOverlay.titleLbl.text = "Scan \(step.name)"

        if step.isAutoDetectAvailable {
            documentOverlay.state = .warning(step.name)
            startProcessingWarnings()
            scheduleAutodetectTimer()
        } else {
            documentOverlay.displayManualScan(true)
        }
        changeMask(for: .warning)
    }

    func documentScanner(_ scanner: DocumentScanner, onStepSuccess result: DocumentScannerStepResult) {
        stopProcessingWarnings()
        stopAutodetectTimer()

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        documentOverlay.state = .success("\(currentStep.name) scanned")
        changeMask(for: .success)

        // A delay was added to see the above state for 1 second before showing the result screen.
        DispatchQueue.main.asyncAfter(deadline: .now() + 1) { [weak self] in
            self?.displayIntermediate(step: result)
        }
    }

    func documentScanner(_ scanner: DocumentScanner, onStepFail error: DocumentScannerStepError) {
        fatalError("Should not reach document scanner onStepFail")
    }

    func documentScanner(_ scanner: DocumentScanner, onStepWarnings warnings: Set<Int>) {
        cachedWarnings = warnings
    }
}

// MARK: - Internal methods -
extension DocumentScannerViewController: DocumentScannerAssetsDataSource {

    private func startProcessingWarnings() {

        warningsTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true, block: { [weak self] _ in
            guard let self = self else { return }

            guard !self.cachedWarnings.isEmpty else {
                self.documentOverlay.state = .warning(self.currentStep.name)
                return
            }
            let warnings = self.cachedWarnings.compactMap { DocumentScannerStepWarning(rawValue: $0) }
            let sorted = warnings.sorted { $0.priority > $1.priority }
            guard let firstWarning = sorted.first else { return }

            self.documentOverlay.descriptionText = firstWarning.text
        })
    }

    private func stopProcessingWarnings() {
        warningsTimer?.invalidate()
        warningsTimer = nil
    }

    private func displayIntermediate(step stepResult: DocumentScannerStepResult) {
        let info = DocumentScannerInfo(step: currentStep, config: config, state: .default)
        let mask = asset(for: info)
        let config = assetConfiguration(for: info)
        let color = backgroundColorConfiguration(for: info)

        resultView.set(stepResult, mask: mask, with: config, for: currentStep)
        resultView.set(color)
        documentScanner.setOverlayView(resultView, animationType: .bothFade)
    }

    private func dismissIntermediate() {
        documentScanner.setOverlayView(documentOverlay, animationType: .bothFade)
    }

    private func scheduleAutodetectTimer() {
        stopAutodetectTimer()
        autodetectTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false, block: { [weak self] timer in
            self?.stopProcessingWarnings()
            self?.documentOverlay.displayManualScan(true)
            self?.stopAutodetectTimer()
        })
    }

    private func stopAutodetectTimer() {
        autodetectTimer?.invalidate()
        autodetectTimer = nil
    }

    private func dismissScanner() {
        documentScanner.delegate = nil
        stopAutodetectTimer()
        viewModel.closeScanner()

        dismiss(animated: true)
    }

    private func displayScannerError() {
        let alert = UIAlertController(title: Localizable.DocumentScanner.Error.alertTitle, message: Localizable.DocumentScanner.Error.alertMessage, preferredStyle: .alert)

        let tryAgainAction = UIAlertAction(title: "Try again", style: .default, handler: { [self] _ in
            documentScanner.resetScanner()
        })

        let cancelAction = UIAlertAction(title: "Dismiss", style: .cancel, handler: { [self] _ in
            dismissScanner()
        })
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func changeMask(for state: DocumentScannerState) {
        let info = DocumentScannerInfo(step: currentStep, config: config, state: state)
        let mask = asset(for: info)
        let config = assetConfiguration(for: info)
        let color = backgroundColorConfiguration(for: info)

        documentOverlay.set(mask: mask, with: config)
        documentOverlay.set(maskColor: color)
    }
}
