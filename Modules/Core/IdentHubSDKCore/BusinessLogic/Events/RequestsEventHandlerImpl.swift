//
//  RequestsEventHandlerImpl.swift
//  IdentHubSDKCore
//

import Foundation

// MARK: - Core Requests event logic -

typealias RequestsCallback = (RequestsOutput) -> Void

final internal class RequestsEventHandlerImpl<ViewController: UpdateableShowable>: EventHandler where ViewController.EventHandler == AnyEventHandler<RequestsEvent>, ViewController.ViewState == RequestsState {
    
    weak var updatableView: ViewController?
    
    // MARK: - Properties -
    
    private let verificationService: VerificationService
    private let alertsService: AlertsService
    private var input: RequestsInput
    private var storage: Storage
    internal var colors: Colors
    private var state: RequestsState
    private var callback: RequestsCallback
        
    let sessionInfoProvider: StorageSessionInfoProvider
        
    init(
        verificationService: VerificationService,
        alertsService: AlertsService,
        input: RequestsInput,
        colors: Colors,
        storage: Storage,
        session: StorageSessionInfoProvider,
        callback: @escaping RequestsCallback
    ) {
        self.verificationService = verificationService
        self.alertsService = alertsService
        self.input = input
        self.colors = colors
        self.storage = storage
        self.callback = callback
        self.state = RequestsState(title: "", description: "", type: input.requestsType)
        self.sessionInfoProvider = session
    }
    
    func handleEvent(_ event: RequestsEvent) {
            
        switch event {
        case .identifyEvent: self.identifyEvent()
        case .initateFlow:
            switch input.initStep {
            case .defineMethod:
                defineIdentificationMethod()
            case .obtainInfo:
                obtainIdentificationInfo()
            default: //Remain cases managed in respective module
                break
            }
        case .fetchData:
            self.callback(.fourthline(.fetchData))
        case .uploadData:
            self.callback(.fourthline(.upload))
        case .verification:
            self.callback(.fourthline(.confirmation))
        case .restart: self.restartProcess()
        case .close(let error):
            self.callback(.failure(error))
        case .quit:
            quit()
        default:
            break
        }
    }
    
    private func identifyEvent() {
        self.input.requestsType = input.requestsType
        updateState { state in
            state.identifyEvent = true
        }
    }
    
    private func updateState(_ update: @escaping (inout RequestsState) -> Void) {
        DispatchQueue.main.async {
            update(&self.state)
            self.updatableView?.updateView(self.state)
        }
    }
    
    private func defineIdentificationMethod() {
        self.input.requestsType = .initateFlow
        updateState { state in
            state.title = self.obtainScreenTitle()
            state.description = self.obtainScreenDescription()
            state.loading = true
            state.identifyEvent = false
        }
        
        verificationService.defineIdentificationMethod { [weak self] result in
            guard let self = self else { return }

            switch result {
            case .success(let response):
                self.sessionInfoProvider.identificationStep = response.firstStep
                self.sessionInfoProvider.fallbackIdentificationStep = response.fallbackStep
                self.sessionInfoProvider.retries = response.retries
                
                if let provider = response.fourthlineProvider, provider.isEmpty == false {
                    self.sessionInfoProvider.fourthlineProvider = provider
                }
                self.obtainIdentificationInfo()
            case .failure(let error):
                self.updateState { state in
                    state.onDisplayError = error
                    state.loading = false
                }
            }
        }
    }
    
    private func obtainIdentificationInfo() {
        verificationService.obtainIdentificationInfo { [weak self] result in
            guard let self = self else { return }
            
            self.updateState { state in
                state.loading = false
            }

            switch result {
            case .success(let response):                
                if let provider = response.fourthlineProvider {
                    self.sessionInfoProvider.fourthlineProvider = provider
                }
                self.callback(.finishInitialFetch(response))
            case .failure(let error):
                self.updateState { state in
                    state.onDisplayError = error
                    state.loading = false
                }
            }
        }
    }
    
    func quit() {
        callback(.quit)
    }
    
    /// Method defines and returns request screen title text
    /// - Returns: title text
    func obtainScreenTitle() -> String {
        switch self.input.requestsType {
        case .initateFlow:
            return Localizable.Initial.title
        default:
            return ""
        }
    }

    /// Method defines and returns request screen description text
    /// - Returns: description text
    func obtainScreenDescription() -> String {
        switch self.input.requestsType {
        case .initateFlow:
            return Localizable.Initial.info
        default:
            return ""
        }
    }
    
}

// MARK: - Restart Process -

private extension RequestsEventHandlerImpl {
    
    /// Consider only Core module API
    private func restartProcess() {
        switch self.input.requestsType {
        case .initateFlow:
            switch input.initStep {
            case .defineMethod:
                defineIdentificationMethod()
            case .obtainInfo:
                obtainIdentificationInfo()
            default:
                break
            }
        default:
            break
        }
    }
    
}
