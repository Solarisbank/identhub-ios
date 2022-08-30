//
//  IdentHubSDKManager.swift
//  IdentHubSDK
//

import UIKit
import IdentHubSDKCore

/// Identification session results delegate
public protocol IdentHubSDKManagerDelegate: AnyObject {

    /// Session finished with successful result and returns identification string
    /// - Parameter identification: string value of the user identificaiton
    func didFinishWithSuccess(_ identification: String)

    /// Identification session finished or interrupted with error
    /// - Parameter failureReason: session error object
    func didFailureSession(_ failureReason: APIError)

    /// Session finished with fourthline signing on confirm step and returns identification string
    /// - Parameter identification: string value of the user identificaiton
    func didFinishOnConfirm(_ identification: String)
}

/// Default implementation of IdentHubSDKManagerDelegate protocol for optionality
public extension IdentHubSDKManagerDelegate {

    func didFinishOnConfirm(_ identification: String) {}

}

/// Ident hub completion session block definition
public typealias CompletionHandler = (IdentificationSessionResult) -> Void

/// Responsible for creating and managing identification process provided by `Solarisbank` into your iOS app
final public class IdentHubSession {
    private static var isSessionStarted = false

    private let sessionToken: String

    private lazy var appDependencies: AppDependencies = {
        AppDependencies(sessionToken: sessionToken, presenter: identRouter)
    }()

    private lazy var identRouter: IdentHubSDKRouter = {
        guard let rootViewController = self.rootViewController else {
            fatalError("Please provide root view controller first.")
        }
        
        return IdentHubSDKRouter(rootViewController: rootViewController, identHubSession: self)
    }()
    
    private var identCoordinator: IdentificationCoordinator?
    private var completionSessionBlock: CompletionHandler?
    private weak var rootViewController: UIViewController?
    private weak var sessionDelegate: IdentHubSDKManagerDelegate?

    /// Initiate ident hub session manager
    /// - Parameters:
    ///   - rootViewController: root controller for presenting all SDK screen VC
    ///   - sessionURL: string value of the session url with host URL and session token value in path component
    /// - Throws: validation session url cases
    public init(rootViewController: UIViewController, sessionURL: String) throws {
        self.sessionToken = try SessionURLParser.obtainSessionToken(sessionURL)
        self.rootViewController = rootViewController
        
        // Logging setup via Swift compile-time flags:
        
        #if DEBUG
        self.enableLogging(level: .warn)
        #endif
        
        #if IDENTHUB_LOGGING_REMOTE
        self.enableRemoteLogging()
        #endif
        
    }
    
    deinit {
        KYCContainer.removeSharedContainer()
    }
    
    /// Method starts BandID identification process with updating status by delegate
    /// - Parameter type: identification process session type: bankid, fourhline
    /// - Parameter delegate: object conforms process status delegate methods
    public func start(_ delegate: IdentHubSDKManagerDelegate) {
        SBLog.info("Starting IdentHubSession (using delegate)")
        sessionDelegate = delegate
        startIdentification()
    }

    /// Method starts identification process (BankID) with updating status by closure callback
    /// - Parameter type: identification process session type: bankid, fourhline
    /// - Parameter completion: closure with result object in parameter, result has two cases: success with id or failure with error
    public func start(_ completion: CompletionHandler?) {
        SBLog.info("Starting IdentHubSession (using completion handler)")
        completionSessionBlock = completion
        startIdentification()
    }
    
    /// Static method builds and return current version and build number of the SDK
    /// - Returns: version string
    public static func version() -> String {
        if let info = Bundle.current.infoDictionary,
           let version = info["CFBundleShortVersionString"] as? String,
           let buildNumber = info[kCFBundleVersionKey as String] {
            return "v\(version)(\(buildNumber))"
        }
        return ""
    }
}

// MARK: - Logging Functionalities

extension IdentHubSession {
    
    /// Enable logging messages to the console.
    ///
    /// - Parameters:
    ///   - level: Minimum log level to display. Defaults to `.debug`.
    public func enableLogging(level: SBLogLevel = .debug) {
        Self.enableLogging(level: level)
    }
    
    /// Enable logging messages to be sent to Solarisbank servers for the active IdentHubSession.
    ///
    /// - Parameters:
    ///   - level: Minimum log level to display. Defaults to `.warn`.
    public func enableRemoteLogging(level: SBLogLevel = .warn) {
        let sessionToken = self.appDependencies.sessionInfoProvider.sessionToken
        // Only enable backend logging if we have a valid URL to send entries to
        if let logURL = SBLogBackendAPIClient.urlForAPIBasePath(APIPaths.backendBasePath) {
            let logAPIClient = SBLogBackendAPIClient(url: logURL, sessionToken: sessionToken)
            SBLogBackendDestination.standard.apiClient = logAPIClient
            SBLogBackendDestination.standard.level = level
            SBLogBackendDestination.standard.backendRequestBundlingPeriod = 3.0
            SBLog.standard.addDestination(SBLogBackendDestination.standard)
            SBLog.info("Enabled backend logging")
        } else {
            SBLog.warn("Could not initialize backend logging")
        }
    }

    /// Enable logging messages to the console.
    ///
    /// - Parameters:
    ///   - level: Minimum log level to display. Defaults to `.debug`.
    public static func enableLogging(level: SBLogLevel = .debug) {
        SBLogConsoleDestination.standard.level = level
        SBLog.standard.addDestination(SBLogConsoleDestination.standard)
        SBLog.info("Enabled console logging")
    }
    
    // NOTE: No static version of enableRemoteLogging(…) as remote logging requires
    // an IdentificationSession URL to determine the log endpoint URL.
    // Set up your own SBLogBackendDestination in case you want to use remote logging
    // independently of an IdentHubSession.

}

// MARK: - Internal methods methods

private extension IdentHubSession {

    private func startIdentification() {
        guard !IdentHubSession.isSessionStarted else {
            SBLog.error("Another session is already starter. Please finish previously started session to start this one.")

            // TODO: Use proper error to indicate state
            updateSessionResult(.failure(.identificationNotPossible))

            return
        }

        IdentHubSession.isSessionStarted = true

        identCoordinator = IdentificationCoordinator(appDependencies: appDependencies, presenter: identRouter)
        
        appDependencies.sessionInfoProvider.addEnableRemoteLoggingCallback { [weak self] in
            guard let self = self else {
                SBLog.error("Cannot handle remote logging : `self` is not present")
                
                return
            }
            
            self.enableRemoteLogging()
        }
        
        SBLog.debug("Starting IdentificationCoordinator")
        identCoordinator?.start { [weak self] result in
            IdentHubSession.isSessionStarted = false

            guard let self = self else {
                SBLog.error("Cannot handle identification coordinator start completion: `self` is not present")
                
                return
            }
            
            SBLog.debug("IdentificationCoordinator result: \(result)")
            self.updateSessionResult(result)
        }
    }

    private func updateSessionResult(_ result: IdentificationSessionResult) {
        if let completion = self.completionSessionBlock {
            SBLog.info("Invoking IdentHubSession completion handler: \(result)")
            completion(result)
        }

        switch result {
        case .success(let identification):
            SBLog.info("Invoking IdentHubSession delegate's didFinishWithSuccess method: \(identification)")
            self.sessionDelegate?.didFinishWithSuccess(identification)
        case .failure(let error):
            SBLog.warn("Invoking IdentHubSession delegate's didFailureSession method: \(error.logDescription)")
            self.sessionDelegate?.didFailureSession(error)
        case .onConfirm(let identification):
            SBLog.info("Invoking IdentHubSession delegate's didFinishOnConfirm method: \(identification)")
            self.sessionDelegate?.didFinishOnConfirm(identification)
        }
    }
}
