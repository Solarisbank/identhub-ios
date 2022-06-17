//
//  SBLogDestination.swift
//  IdentHubSDK
//

import Foundation

public protocol SBLogDestination {
    var level: SBLogLevel { get set }
    func send(_ entry: SBLogEntry)
    func flush()
}

extension SBLogDestination {
    func shouldSendForLevel(_ level: SBLogLevel) -> Bool {
        return level >= self.level
    }
}
