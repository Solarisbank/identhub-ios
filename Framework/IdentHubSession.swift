//
//  IdentHubSDKManager.swift
//  IdentHubSDK
//

import UIKit

/// Identification session results delegate
public protocol IdentHubSDKManagerDelegate: AnyObject {

    /// Session finished with successful result and returns identification string
    /// - Parameter identification: string value of the user identificaiton
    func didFinishWithSuccess(_ identification: String)

    /// Identificaiton session finished or interrupted with error
    /// - Parameter failureReason: session error object
    func didFailureSession(_ failureReason: Error)
}

/// Ident hub session result
/// success - successful result with identification string in parameter
/// failure - result returns with error in parameter
public enum IdentificationSessionResult {
    case success(identification: String)
    case failure(Error)
}

/// Ident hub completion session block definition
public typealias CompletionHandler = (IdentificationSessionResult) -> Void

/// Responsible for creating and managing identification process provided by `Solarisbank` into your iOS app
final public class IdentHubSession: IdentSessionTracker {

    private(set) var bankIDSessionActiveState: Bool = false
    private(set) var fourthlineSessionActiveState: Bool = false

    private let appDependencies: AppDependencies
    private let identRouter: IdentHubSDKRouter
    private weak var sessionDelegate: IdentHubSDKManagerDelegate?
    private var completionSessionBlock: CompletionHandler?

    /// Initiate ident hub session manager
    /// - Parameters:
    ///   - rootViewController: root controller for presenting all SDK screen VC
    ///   - sessionURL: string value of the session url with host URL and session token value in path component
    /// - Throws: validation session url cases
    public init(rootViewController: UIViewController, sessionURL: String) throws {
        let sessionToken = try SessionURLParser.obtainSessionToken(sessionURL)

        self.appDependencies = AppDependencies(sessionToken: sessionToken)
        self.identRouter = IdentHubSDKRouter(rootViewController: rootViewController)
    }

    /// Method starts BandID identification process with updating status by delegate
    /// - Parameter delegate: object conforms process status delegate methods
    public func start(_ delegate: IdentHubSDKManagerDelegate) {
        self.sessionDelegate = delegate

        startBankID()
    }

    /// Method starts identification process (BankID) with updating status by closure callback
    /// - Parameter completion: closure with result object in parameter, result has two cases: success with id or failure with error
    public func start(completion: @escaping CompletionHandler) {
        completionSessionBlock = completion

        startBankID()
    }

    // MARK: - Manager Session Tracker methods -

    internal func startBankID() {
        let bankIDCoordinator = BankIDCoordinator(appDependencies: appDependencies, presenter: identRouter)

        bankIDCoordinator.start(completion: { [weak self] result in
            guard let `self` = self else { return }

            if let completion = self.completionSessionBlock {
                completion(result)
            }

            switch result {
            case .success(let identificaiton):
                self.sessionDelegate?.didFinishWithSuccess(identificaiton)
            case .failure(let error):
                self.sessionDelegate?.didFailureSession(error)
            }
        })

        bankIDSessionActiveState = true
    }
}

protocol IdentSessionTracker: Coordinator {

    var bankIDSessionActiveState: Bool { get }
    var fourthlineSessionActiveState: Bool { get }

    func startBankID()
}
