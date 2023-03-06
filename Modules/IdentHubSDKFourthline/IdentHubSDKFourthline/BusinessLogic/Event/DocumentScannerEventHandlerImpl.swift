//
//  DocumentScannerEventHandlerImpl.swift
//  IdentHubSDKFourthline
//

import Foundation
import IdentHubSDKCore
import FourthlineCore

internal enum DocumentScannerOutput: Equatable {
    case documentInfo
    case selfieScreen
    case quit
}

internal struct DocumentScannerInput {
    let documentScannerType: DocumentType
    let isSecondDocument: Bool
}

// MARK: - Document Scanner event logic -

typealias DocumentScannerCallback = (DocumentScannerOutput) -> Void

final internal class DocumentScannerEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<DocumentScannerViewEvent>, ViewController.ViewState == DocumentScannerViewState {
    
    weak var updatableView: ViewController?
    
    // MARK: - Properties -
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var state: DocumentScannerViewState
    private var input: DocumentScannerInput
    internal var colors: Colors
    private var callback: DocumentScannerCallback
        
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: DocumentScannerInput,
        colors: Colors,
        callback: @escaping DocumentScannerCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.colors = colors
        self.callback = callback
        self.state = DocumentScannerViewState(documentType: input.documentScannerType)
    }
    
    func handleEvent(_ event: DocumentScannerViewEvent) {
        updateState { state in
            state.isScreenLoad = false
        }
        
        switch event {
        case .loadScreen:
            if !input.isSecondDocument {
                KYCContainer.shared.removeDocumentData()
                KYCContainer.shared.removeSecondaryDocumentData()
            }
            updateState { state in
                state.documentType = self.input.documentScannerType
                state.isScreenLoad = true
            }
        case .cleanData:
            input.isSecondDocument ? KYCContainer.shared.removeSecondaryDocumentData() :          KYCContainer.shared.removeDocumentData()
        case .updateResult(let result): /// Update document scan result in KYC container
            if input.isSecondDocument {
                KYCContainer.shared.update(secondaryDocument: result, for: self.input.documentScannerType)
                callback(.selfieScreen)
            } else {
                KYCContainer.shared.update(with: result, for: self.input.documentScannerType)
                callback(.documentInfo)
            }
        case .saveResult(let stepResult): /// Save document result to the KYC container
            if input.isSecondDocument {
                KYCContainer.shared.update(secondaryDocument: stepResult)
            } else {
                KYCContainer.shared.update(with: stepResult)
            }
        case .quit:
            quit()
        }
    }
    
    private func updateState(_ update: @escaping (inout DocumentScannerViewState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    func quit() {
        callback(.quit)
    }
    
}
