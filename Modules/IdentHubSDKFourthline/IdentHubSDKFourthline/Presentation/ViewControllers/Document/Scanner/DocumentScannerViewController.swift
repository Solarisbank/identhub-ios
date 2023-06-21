//
//  DocumentScannerViewController.swift
//  IdentHubSDKFourthline
//

import UIKit
import IdentHubSDKCore
import FourthlineCore
import FourthlineVision
import AudioToolbox

internal struct DocumentScannerViewState: Equatable {
    var documentType: DocumentType = .undefined
    var isScreenLoad: Bool = false
}

internal enum DocumentScannerViewEvent {
    case loadScreen
    case updateResult(_ result: DocumentScannerResult)
    case saveResult(_ stepResult: DocumentScannerStepResult)
    case cleanData
    case automationTest
    case quit
}
    
final internal class DocumentScannerViewController: UIViewController, Updateable {
        
    typealias ViewState = DocumentScannerViewState
    
    // MARK: - Properties -

    var eventHandler: AnyEventHandler<DocumentScannerViewEvent>?
    private var colors: Colors
    private var state = DocumentScannerViewState()
    
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

        overlayView.configureUI(colors: self.colors)

        overlayView.onTakePicture = { [unowned self] in
            self.documentScanner.takeSnapshot()
        }

        overlayView.onDismiss = { [unowned self] in
            dismiss(animated: true)
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
            eventHandler?.handleEvent(.saveResult(result))
            self.documentScanner.moveToNextStep()
            self.dismissIntermediate()
        }
        return result
    }()

    private lazy var config: DocumentScannerConfig = {
        DocumentScannerConfig(type: state.documentType)
    }()
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<DocumentScannerViewEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods -
    
    override var prefersStatusBarHidden: Bool {
        true
    }

    override func viewDidLoad() {
        super.viewDidLoad()
        eventHandler?.handleEvent(.loadScreen)
    }
    
    func updateView(_ state: DocumentScannerViewState) {
        self.state.documentType = state.documentType
        if state.isScreenLoad {
            add(child: documentScanner)
        }
    }

}

extension DocumentScannerViewController: DocumentScannerDataSource, DocumentScannerAssetPlacement {

    func documentDetectionArea(in scanner: DocumentScanner, for step: DocumentScannerStep) -> CGRect {
        guard let step = currentStep else { return .zero }
        
        let info = DocumentScannerInfo(step: step, config: config, state: .warning)
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
        eventHandler?.handleEvent(.updateResult(result))
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        dismissScanner()
    }

    func documentScanner(_ scanner: DocumentScanner, onFail error: DocumentScannerError) {
        occursScannerFail()
        documentOverlay.state = .failed(error.text)
    }

    func documentScanner(_ scanner: DocumentScanner, onStepUpdate step: DocumentScannerStep) {
        currentStep = step

        stopAutodetectTimer()
        documentOverlay.titleLbl.text = step.localizedTitle

        if step.isAutoDetectAvailable {
            documentOverlay.state = .warning(step.localizedName)
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

        documentOverlay.state = .success(currentStep.localizedName.capitalized)
        changeMask(for: .success)

        // A delay was added to see the above state for 1 second before showing the result screen.
        DispatchQueue.main.asyncAfter(deadline: 1.seconds.fromNow) { [weak self] in
            self?.displayIntermediate(step: result)
        }
    }

    func documentScanner(_ scanner: DocumentScanner, onStepFail error: DocumentScannerStepError) {
        occursScannerFail()
        var errorDesc = ""

        switch error {
        case .takeSnapshotNotAllowed:
            errorDesc = Localizable.DocumentScanner.Error.takeSnapshotNotAllowed
        case .moveToNextStepNotAllowed:
            errorDesc = Localizable.DocumentScanner.Error.moveToNextStepNotAllowed
        case .resetCurrentStepNotAllowed:
            errorDesc = Localizable.DocumentScanner.Error.resetCurrentStepNotAllowed
        default:
            errorDesc = Localizable.DocumentScanner.Warning.unknown
        }

        documentOverlay.state = .failed(errorDesc)
    }

    func documentScanner(_ scanner: DocumentScanner, onStepWarnings warnings: Set<Int>) {
        cachedWarnings = warnings
    }
}
// MARK: - Internal methods -

extension DocumentScannerViewController: DocumentScannerAssetsDataSource {

    private func startProcessingWarnings() {
        warningsTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                
                return
            }

            guard !self.cachedWarnings.isEmpty else {
                self.documentOverlay.state = .warning(self.currentStep.localizedName)
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
        let mask = asset(for: info, border: false)
        let config = assetConfiguration(for: info)

        resultView.set(stepResult, mask: mask, with: config, for: currentStep, self.colors)
        documentScanner.setOverlayView(resultView, animationType: .bothFade)
    }

    private func dismissIntermediate() {
        documentScanner.setOverlayView(documentOverlay, animationType: .bothFade)
    }

    private func scheduleAutodetectTimer() {
        stopAutodetectTimer()
        autodetectTimer = Timer.scheduledTimer(withTimeInterval: 20, repeats: false, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                
                return
            }
            
            self.stopProcessingWarnings()
            self.documentOverlay.displayManualScan(true)
            self.stopAutodetectTimer()
        })
    }

    private func stopAutodetectTimer() {
        autodetectTimer?.invalidate()
        autodetectTimer = nil
    }

    private func dismissScanner() {
        documentScanner.delegate = nil
        stopAutodetectTimer()
        dismiss(animated: true)
    }

    private func occursScannerFail() {
        stopProcessingWarnings()
        stopAutodetectTimer()

        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        eventHandler?.handleEvent(.cleanData)
        #if AUTOMATION
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.dismissScanner()
                self.eventHandler?.handleEvent(.automationTest)
            }
        #else
            displayScannerError()
        #endif
    }

    private func displayScannerError() {
        let alert = UIAlertController(title: Localizable.DocumentScanner.Error.alertTitle, message: Localizable.DocumentScanner.Error.alertMessage, preferredStyle: .alert)

        let tryAgainAction = UIAlertAction(title: Localizable.Common.tryAgain, style: .default, handler: { [self] _ in
            documentScanner.resetScanner()
        })

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [self] _ in
            dismissScanner()
        })
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }

    func changeMask(for state: DocumentScannerState) {
        let info = DocumentScannerInfo(step: currentStep, config: config, state: state)
        let mask = asset(for: info, border: false)
        let status = asset(for: info, border: true)
        let config = assetConfiguration(for: info)

        documentOverlay.set(mask: mask, status: status, with: config)
    }
}
