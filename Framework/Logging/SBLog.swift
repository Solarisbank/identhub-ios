//
//  SBLog.swift
//  IdentHubSDK
//

import Foundation

/// Priority of a log entry.
///
/// Log levels are ordered: `DEBUG` &lt; `INFO`  &lt; `WARN` &lt; `ERROR` &lt; `FAULT`
public enum SBLogLevel: Int, Comparable, Codable, CustomStringConvertible {
    
    case debug = 10
    case info = 20
    case warn = 30
    case error = 40
    case fault = 50
    
    public static func < (lhs: SBLogLevel, rhs: SBLogLevel) -> Bool {
        return lhs.rawValue < rhs.rawValue
    }
    
    public var description: String {
        switch self {
        case .debug: return "DEBUG"
        case .info: return "INFO"
        case .warn: return "WARN"
        case .error: return "ERROR"
        case .fault: return "FAULT"
        }
    }
}

/// Log message type.
public typealias SBLogMessage = String

/// Internal representation of a log entry.
public struct SBLogEntry: Encodable, Equatable {
    let level: SBLogLevel
    let message: SBLogMessage
}

/// Provides logging methods, to be used for debugging and triaging.
///
/// Usage: create an `SBLog` instance or use the `standard` shared instace and static convenience methods.
/// Attach one or more `SBLogDestination`s to output log entries.
///
/// Example:
/// ```swift
/// // Logger setup
/// let log = SBLog()
///
/// // Add a console destination
/// let consoleDestination = SBLogConsoleDestination()
/// consoleDestination.level = .info
/// log.addDestination(consoleDestination)
///
/// // Let's test
/// log.debug("Hello Debug")
/// log.info("Hello Info")
/// log.warn("Hello Warn")
/// ```
public class SBLog {
    
    // MARK: - Static methods -
    
    /// Shared `SBLog` instance.
    public static let standard = SBLog()
    
    /// Convencience method to log a message with `DEBUG` level to the standard logger.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public static func debug(_ message: SBLogMessage) -> SBLogEntry {
        return standard.debug(message)
    }
    
    /// Convencience method to log a message with `INFO` level to the standard logger.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public static func info(_ message: SBLogMessage) -> SBLogEntry {
        return standard.info(message)
    }

    /// Convencience method to log a message with `WARN` level to the standard logger.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public static func warn(_ message: SBLogMessage) -> SBLogEntry {
        return standard.warn(message)
    }

    /// Convencience method to log a message with `ERROR` level to the standard logger.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public static func error(_ message: SBLogMessage) -> SBLogEntry {
        return standard.error(message)
    }

    /// Convencience method to log a message with `FAULT` level to the standard logger.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public static func fault(_ message: SBLogMessage) -> SBLogEntry {
        return standard.fault(message)
    }

    /// Convencience method to log a message to the standard logger.
    /// - Parameters:
    ///  - level: The log level for this log message.
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public static func log(level: SBLogLevel, message: SBLogMessage) -> SBLogEntry {
        return standard.log(level: level, message: message)
    }

    /// Convencience method for flushing the standard logger, causing all registered destinations to process and clean up their pending log entries.
    public static func flush() {
        standard.flush()
    }
    
    // MARK: - Instance methods -
    
    public init() {
        // public initializer
    }
    
    /// Add a destination for incoming log entries, e.g. to be displayed on the console.
    ///
    /// - Parameters:
    ///  - destination: The log destination to add to the logger.
    /// - Returns: The created log entry.
    public func addDestination(_ destination: SBLogDestination) {
        destinationItems.append(SBLogDestinationItem(destination))
    }
    
    /// Log a message with `DEBUG` level.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public func debug(_ message: SBLogMessage) -> SBLogEntry {
        return log(level: .debug, message: message)
    }
    
    /// Log a message with `INFO` level.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public func info(_ message: SBLogMessage) -> SBLogEntry {
        return log(level: .info, message: message)
    }

    /// Log a message with `WARN` level.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public func warn(_ message: SBLogMessage) -> SBLogEntry {
        return log(level: .warn, message: message)
    }

    /// Log a message with `ERROR` level.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public func error(_ message: SBLogMessage) -> SBLogEntry {
        return log(level: .error, message: message)
    }
    
    /// Log a message with `FAULT` level.
    /// - Parameters:
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public func fault(_ message: SBLogMessage) -> SBLogEntry {
        return log(level: .fault, message: message)
    }

    /// Log a message with provided log level.
    /// - Parameters:
    ///  - level: The log level for this log message.
    ///  - message: The log message.
    /// - Returns: The created log entry.
    @discardableResult
    public func log(level: SBLogLevel, message: SBLogMessage) -> SBLogEntry {
        let entry = SBLogEntry(level: level, message: message)
        sendToDestinations(entry)
        return entry
    }

    /// Flush the logger, causing all registered destinations to process and clean up their pending log entries.
    public func flush() {
        for item in destinationItems {
            item.destination.flush()
        }
    }
    
    // MARK: - Internal definitions -
    
    struct SBLogDestinationItem {
        var destination: SBLogDestination
        var dispatchQueue: DispatchQueue
        
        init(_ destination: SBLogDestination) {
            self.destination = destination
            let uuid = UUID().uuidString
            let queueLabel = "sblogger-queue-\(uuid)"
            dispatchQueue = DispatchQueue(label: queueLabel, target: nil)
        }
    }

    var destinationItems = [SBLogDestinationItem]()

    func sendToDestinations(_ entry: SBLogEntry) {
        for item in destinationItems {
            item.dispatchQueue.async {
                item.destination.send(entry)
            }
        }
    }
            
}
