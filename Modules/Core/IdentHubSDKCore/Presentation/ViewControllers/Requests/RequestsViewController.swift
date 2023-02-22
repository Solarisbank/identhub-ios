//
//  RequestsViewController.swift
//  IdentHubSDKCore
//

import UIKit

/// UIViewController which used for different Requests.
public final class RequestsViewController: UIViewController, Updateable {
    
    public typealias ViewState = RequestsState
    
    private enum Constants {
        static let defaultProgress = 0.15
    }
    
    // MARK: - Properties -
    public var eventHandler: AnyEventHandler<RequestsEvent>?
    var colors: Colors
    
    @IBOutlet var titleLbl: UILabel!
    @IBOutlet var descriptionLbl: UILabel!
    let progressView = CircleProgressView()
    
    /// Initialized with view model object
    /// - Parameter viewModel: view model object
    public init(colors: Colors, eventHandler: AnyEventHandler<RequestsEvent>) {
        self.colors = colors
        self.eventHandler = eventHandler
        super.init(nibName: String(describing: Self.self), bundle: Bundle(for: Self.self))
    }
    
    required init?(coder: NSCoder) {
        fatalError("init(coder:) has not been implemented")
    }
    
    public override func viewDidLoad() {
        super.viewDidLoad()
        
        setUpProgressView()
        self.eventHandler?.handleEvent(.identifyEvent)
        
    }
    
    // MARK: - Update -
    
    public func updateView(_ state: RequestsState) {
        if state.identifyEvent {
            self.identifyEvent(state.stateType)
        }
        
        self.titleLbl.text = state.title
        self.descriptionLbl.text = state.description
        
        if state.loading {
            self.showProgressView(isHidden: false)
        } else {
            self.showProgressView(isHidden: true)
        }
        
        if let retryStatus = state.onRetry {
            DispatchQueue.main.async {
                self.presentAlert(with: Localizable.Verification.title, message: Localizable.APIErrorDesc.unprocessableEntity, action: Localizable.Common.tryAgain, error: .unprocessableEntity) { [weak self] in
                    self?.eventHandler?.handleEvent(.reTry(status: retryStatus))
                }
            }
        }
        
        if let zipError = state.zipError {
            self.zipFailed(error: zipError)
            return
        }
        
        guard let error = state.onDisplayError else { return }
        
        DispatchQueue.main.async {
            if let err = error as? ResponseError {
                self.displayError(err)
            } else if let err = error as? APIError {
                self.locationFailed(with: err)
            }
        }
        
    }
    
    private func identifyEvent(_ state: RequestsType) {
        switch state {
        case .initateFlow:
            self.eventHandler?.handleEvent(.initateFlow)
        case .fetchData:
            self.eventHandler?.handleEvent(.fetchData)
        case .uploadData:
            self.eventHandler?.handleEvent(.uploadData)
        case .confirmation:
            self.eventHandler?.handleEvent(.verification)
        }
    }
    
    private func setUpProgressView() {
        view.addSubview(progressView)
        progressView.animateProgress.color = colors[.primaryAccent]
             
        progressView.translatesAutoresizingMaskIntoConstraints = false
        progressView.centerXAnchor.constraint(equalTo: view.centerXAnchor).isActive = true
        progressView.topAnchor.constraint(equalTo: descriptionLbl.bottomAnchor, constant:130).isActive = true

        progressView.defaultProgress = Constants.defaultProgress
    }
    
    private func showProgressView(isHidden: Bool) {
        progressView.isHidden = isHidden
    }
    
}

extension RequestsViewController {
    
    private func displayError(_ error: ResponseError) {
        
        switch error.apiError {
        case .locationError,
                .locationAccessError:
            self.locationFailed(with: error.apiError)
        case .identificationDataInvalid(_):
            identificationFailed(with: error)
        case .fraudData(let err):
            self.eventHandler?.handleEvent(.close(error: .fraudData(error: err)))
        default:
            self.requestFailed(with: error)
        }
    }
    
    private func locationFailed(with error: APIError) {
        presentAlert(with: Localizable.Location.Error.title, message: error.text(), action: Localizable.Common.settings, error: error) {
            UIApplication.openAppSettings()
        }
    }
    
    private func identificationFailed(with error: ResponseError) {
        var message = error.apiError.text()
        #if ENV_DEBUG
        message += "\n\(error.detailDescription)"
        #endif
        
        let alert = UIAlertController(title: Localizable.Verification.processTitle, message: message, preferredStyle: .alert)
        
        let retryAction = UIAlertAction(title: Localizable.Common.tryAgain, style: .default) { [weak self] _ in
            self?.eventHandler?.handleEvent(.zipFailedReTry(type: .invalidData))
        }
        
        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.eventHandler?.handleEvent(.quit)
        })
        
        alert.addAction(retryAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func requestFailed(with error: ResponseError) {
        var message = error.apiError.text()
        
        #if ENV_DEBUG
        message += "\n\(error.detailDescription)"
        #endif
        
        presentAlert(with: Localizable.APIErrorDesc.requestError, message: message, action: Localizable.Common.tryAgain, error: error.apiError) { [weak self] in
            self?.eventHandler?.handleEvent(.restart)
        }
    }
    
    private func presentAlert(with title: String, message: String, action: String, error: APIError, callback: @escaping () -> Void) {
        
        let alert = UIAlertController(title: title, message: message, preferredStyle: .alert)
        
        let reactionAction = UIAlertAction(title: action, style: .default, handler: {_ in
            callback()
        })
        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.eventHandler?.handleEvent(.close(error: error))
        })
        
        alert.addAction(reactionAction)
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
    private func zipFailed(error: ZipFailedError) {
        let alert = UIAlertController(title: Localizable.Zipper.Error.alertTitle, message: error.title, preferredStyle: .alert)
        
        if error.isRetry {
            let retryAction = UIAlertAction(title: Localizable.Common.tryAgain, style: .default) { [weak self] _ in
                self?.eventHandler?.handleEvent(.zipFailedReTry(type: error.type))
            }
            alert.addAction(retryAction)
        }
        
        let cancelAction = UIAlertAction(title: Localizable.Common.dismiss, style: .cancel, handler: { [weak self] _ in
            self?.eventHandler?.handleEvent(.quit)
        })
        
        alert.addAction(cancelAction)
        present(alert, animated: true)
    }
    
}
