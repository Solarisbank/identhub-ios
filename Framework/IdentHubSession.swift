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
    func didFailureSession(_ failureReason: APIError)
}

/// Ident hub completion session block definition
public typealias CompletionHandler = (IdentificationSessionResult) -> Void

/// Responsible for creating and managing identification process provided by `Solarisbank` into your iOS app
final public class IdentHubSession {

    private let appDependencies: AppDependencies
    private let identRouter: IdentHubSDKRouter
    private weak var sessionDelegate: IdentHubSDKManagerDelegate?
    private var completionSessionBlock: CompletionHandler?
    private var bankIDSessionCoordinator: BankIDCoordinator?

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
    /// - Parameter type: identification process session type: bankid, fourhline
    /// - Parameter delegate: object conforms process status delegate methods
    public func start(_ delegate: IdentHubSDKManagerDelegate) {
        sessionDelegate = delegate

        startIdentification()
    }

    /// Method starts identification process (BankID) with updating status by closure callback
    /// - Parameter type: identification process session type: bankid, fourhline
    /// - Parameter completion: closure with result object in parameter, result has two cases: success with id or failure with error
    public func start(_ completion: CompletionHandler?) {
        completionSessionBlock = completion

        startIdentification()
    }
}

// MARK: - Internal methods methods -

private extension IdentHubSession {

    private func startIdentification() {
        let identCoordinator = IdentificationCoordinator(appDependencies: appDependencies, presenter: identRouter)

        identCoordinator.start { result in
            self.updateSessionResult(result)
        }
    }

    private func updateSessionResult(_ result: IdentificationSessionResult) {
        if let completion = self.completionSessionBlock {
            completion(result)
        }

        switch result {
        case .success(let identificaiton):
            self.sessionDelegate?.didFinishWithSuccess(identificaiton)
        case .failure(let error):
            self.sessionDelegate?.didFailureSession(error)
        }
    }
}
