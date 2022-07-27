//
//  SessionURLParser.swift
//  IdentHubSDK
//

import Foundation
import IdentHubSDKCore

public enum IdentSessionURLError: Error {
    case invalidSessionURL // Session URL is empty or not valid, defines by creation URL object from url string. If URL object is nil raised error
    case invalidBaseURL // Base URL value obtains by getting host parameter in url object, if parameter is nil then raised error
    case invalidSessionToken // Session token value obtains from url path components. In current version of the session url it should be last path component and if value is empty or less than 30 symbols raised error
}

final class SessionURLParser {

    // MARK: - Public methods -

    /// Method validate and parsed session url string for obtaining session token and check if it valid
    /// - Parameter url: session url string
    /// - Throws: validation error case
    /// - Returns: identification session token string required for all requests to the server
    @objc static func obtainSessionToken(_ url: String) throws -> String {
        guard let sessionURL = URL(string: url) else { throw IdentSessionURLError.invalidSessionURL }

        guard sessionURL.host != nil else { throw IdentSessionURLError.invalidBaseURL }

        guard let token = sessionURL.pathComponents.last, token.count > 30 else { throw IdentSessionURLError.invalidSessionToken }
        
        APIToken.sessionToken = token

        if let scheme = sessionURL.scheme, let host = sessionURL.host {
            var apiHost = host

            if host.contains("-api") == false {
                apiHost = host.replacingOccurrences(of: "person-onboarding.", with: "person-onboarding-api.")
            }
            APIPaths.backendBasePath = scheme + "://" + apiHost
        }

        return token
    }
}
