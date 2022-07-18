//
//  SBLoggerConsoleDestination.swift
//  IdentHubSDK
//

import Foundation

/// Destination for `SBLog` instances to print log entries to the console.
public class SBLogConsoleDestination: SBLogDestination {
    /// Shared default console destination.
    public static let standard = SBLogConsoleDestination()

    public var level: SBLogLevel = .debug
    
    public init() {
        // public initializer
    }
        
    public func send(_ entry: SBLogEntry) {
        guard shouldSendForLevel(entry.level) else {
            return
        }
        var output = "\(entry.level): \(entry.message)"
        
        if let category = entry.category {
            output = "[\(category)] \(output)"
        }
        
        let logOutput = "[\(Constants.logPrefix)] \(output)"
        
        print(logOutput)
    }

    public func flush() {
        // nothing to flush
    }
    
}

private extension SBLogConsoleDestination {
    enum Constants {
        static let logPrefix = "IdentHub"
    }
}
