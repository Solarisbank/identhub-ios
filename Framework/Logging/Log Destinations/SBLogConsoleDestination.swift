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
        print("\(entry.level): \(entry.message)")
    }

    public func flush() {
        // nothing to flush
    }
    
}
