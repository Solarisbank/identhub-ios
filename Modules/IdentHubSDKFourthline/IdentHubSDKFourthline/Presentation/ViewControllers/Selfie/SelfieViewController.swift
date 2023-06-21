//
//  SelfieViewController.swift
//  IdentHubSDKFourthline
//

import UIKit
import FourthlineVision
import AudioToolbox
import AVFoundation
import IdentHubSDKCore

internal struct SelfieState: Equatable {
    enum State: Equatable {
        case none
        case scannerConfig
        case save
    }
    var state: State = .none
    var scannerConfig: SelfieScannerConfig? = nil
    var saveResult: Bool = false
}

internal enum SelfiEvent {
    case scannerConfig
    case setScannerResult(_ result: SelfieScannerResult)
    case saveResult
    case confirmStep
    case resetResult
    case closeProcess
}

final internal class SelfieViewController: UIViewController, Updateable {
    
    typealias ViewState = SelfieState
    
    // MARK: - Properties -
    
    var eventHandler: AnyEventHandler<SelfiEvent>?
    private var colors: Colors
    
    private var warningsTimer: Timer?
    private var cachedWarnings: Set<Int> = Set()
    private var state: SelfieState = SelfieState()

    private lazy var selfieOverlay: SelfieOverlayView = {
        let overlayView = SelfieOverlayView.fromNib()

        overlayView.onDismiss = { [unowned self] in
            self.dismissScanner()
        }

        return overlayView
    }()

    private lazy var selfieResultsOverlay: SelfieResultOverlayView = {
        let overlay = SelfieResultOverlayView.fromNib()
        overlay.configureUI(self.colors)

        overlay.onConfirm = { [unowned self] in
            self.eventHandler?.handleEvent(.saveResult)
            self.confirmSelfie()
        }
        overlay.onRetake = { [unowned self] in
            self.resetScannerFlow()
        }
        overlay.onDismiss = { [unowned self] in
            self.dismissScanner()
        }
        return overlay
    }()

    private lazy var selfieScanner: SelfieScanner = {
        let scanner = SelfieScanner()
        scanner.delegate = self
        scanner.dataSource = self
        scanner.setOverlayView(selfieOverlay)
        return scanner
    }()
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    init(colors: Colors, eventHandler: AnyEventHandler<SelfiEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: nil, bundle: nil)
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    // MARK: - Lifecycle methods -

    override func viewDidLoad() {
        super.viewDidLoad()

        configureUI()
    }
    
    override func viewWillDisappear(_ animated: Bool) {
        super.viewWillDisappear(animated)

        resetProperties()
    }
    
    // MARK: - Internal methods -
    
    func updateView(_ state: SelfieState) {
        self.state = state
    }
}

extension SelfieViewController {
    
    private func configureUI() {
        view.backgroundColor = .black
        #if AUTOMATION
        DispatchQueue.main.asyncAfter(deadline: .now() + 1.0) {
                self.eventHandler?.handleEvent(.confirmStep)
            }
        #endif
        add(child: selfieScanner)
        selfieOverlay.status = .warning(withMessage: Localizable.Selfie.Warnings.noFace)
        selfieOverlay.title  = Localizable.Selfie.selfieTitle
    }
    
    private func dismissScanner() {
        eventHandler?.handleEvent(.closeProcess)
    }

    private func confirmSelfie() {
        eventHandler?.handleEvent(.confirmStep)
    }

    private func startProcessingWarnings() {
        warningsTimer = Timer.scheduledTimer(withTimeInterval: 0.4, repeats: true, block: { [weak self] timer in
            guard let self = self else {
                timer.invalidate()
                return
            }

            guard !self.cachedWarnings.isEmpty else {
                return
            }
            let warnings = self.cachedWarnings.compactMap { SelfieScannerWarning(rawValue: $0) }
            let sorted = warnings.sorted { $0.priority > $1.priority }
            guard let firstWarning = sorted.first else { return }

            self.selfieOverlay.message = firstWarning.text
        })
    }

    private func stopProcessingWarnings() {
        warningsTimer?.invalidate()
        warningsTimer = nil
    }

    func showResultOverlay(with fullImage: UIImage) {
        selfieResultsOverlay.frame = view.bounds
        selfieResultsOverlay.resultContent.image = fullImage

        selfieScanner.setOverlayView(selfieResultsOverlay, animationType: .bothFade)
    }

    private func displayScannerError() {
        #if !AUTOMATION
        let alert = UIAlertController(title: Localizable.Selfie.Errors.alertTitle, message: Localizable.Selfie.Errors.alertMessage, preferredStyle: .alert)

        let tryAgainAction = UIAlertAction(title: Localizable.Common.tryAgain, style: .default, handler: { [self] _ in
            resetScannerFlow()
        })

        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [self] _ in
            dismissScanner()
        })
        alert.addAction(tryAgainAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
        #endif
    }

    private func resetScannerFlow() {
        selfieOverlay.status = .warning(withMessage: Localizable.Selfie.Warnings.noFace)
        selfieOverlay.title = Localizable.Selfie.selfieTitle
        selfieOverlay.viewType = .selfie

        selfieScanner.setOverlayView(selfieOverlay, animationType: .bothFade)
        selfieScanner.resetScanner()

        eventHandler?.handleEvent(.resetResult)
    }

    private func resetProperties() {
        selfieScanner.delegate = nil
        selfieScanner.dataSource = nil
    }
}

extension SelfieViewController: SelfieScannerDelegate {

    func selfieScanner(_ scanner: SelfieScanner, onSuccess result: SelfieScannerResult) {

        stopProcessingWarnings()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        eventHandler?.handleEvent(.setScannerResult(result))
        selfieOverlay.status = scanner.step == .selfie ? .success : .livenessSuccess

        // A delay was added to see the above state for 1 second before showing the result screen.
        DispatchQueue.main.asyncAfter(deadline: 1.seconds.fromNow) { [weak self] in
            guard let self = self else { return }

            // We flip the image to match the the live feed preview.
            let flippedFullImage = result.image.full.withHorizontallyFlippedOrientation()
            self.showResultOverlay(with: flippedFullImage)
        }
    }

    func selfieScanner(_ scanner: SelfieScanner, onStepUpdate step: SelfieScannerStep) {

        step == .selfie ? startProcessingWarnings() : stopProcessingWarnings()

        if step == .turnHeadLeft ||
            step == .turnHeadRight {

            AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

            if case .livenessCheck = selfieOverlay.status {
                selfieOverlay.status = .livenessSuccess
            } else {
                selfieOverlay.status = .success
            }

            // A delay was added to see the above state for 1 second before showing the result screen.
            DispatchQueue.main.asyncAfter(deadline: 2.seconds.fromNow) { [weak self] in

                self?.selfieOverlay.title = Localizable.Selfie.Liveness.title
                self?.selfieOverlay.status = .livenessCheck
                self?.selfieOverlay.message = step.text
                self?.selfieOverlay.viewType = step
            }
        }
    }

    func selfieScanner(_ scanner: SelfieScanner, onWarnings warnings: Set<Int>) {
        cachedWarnings = warnings
    }

    func selfieScanner(_ scanner: SelfieScanner, onFail error: SelfieScannerError) {
        stopProcessingWarnings()
        AudioServicesPlaySystemSound(kSystemSoundID_Vibrate)

        selfieOverlay.status = scanner.step == .selfie ? .failed(withMessage: error.text) : .livenessFailed(withMessage: error.text)
        displayScannerError()
    }
}

extension SelfieViewController: SelfieScannerDataSource {

    func faceDetectionArea(in scanner: SelfieScanner) -> CGRect {
        selfieOverlay.selfieFrame.frame
    }

    func selfieConfig(for scanner: SelfieScanner) -> SelfieScannerConfig {
        self.state.scannerConfig ?? SelfieScannerConfig()
    }
}
