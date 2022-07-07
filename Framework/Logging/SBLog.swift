//
//  SBLog.swift
//  IdentHubSDK
//

import Foundation

/// Priority of a log entry.
///
/// How to decide which log level to use:
/// * `.debug`: Any information used during development.
/// * `.info`: Information about events and actions relevant to the SDK and flow state. Example: a backend request has been started.
/// * `.warn`: Something didn't go the happy path but will be handled at this level. Example: the backend responded with an unsuccessful HTTP status code.
/// * `.error`: Something unexpected happened that will have impact to the flow. Example: a response of the backend can't be decoded.
/// * `.fatal`: Something unexpected happened that can't be recovered from.
///
/// > Note: Log levels are ordered: `.debug` &lt; `.info`  &lt; `.warn` &lt; `.error` &lt; `.fault`
public enum SBLogLevel: Int, Comparable, Codable, CustomStringConvertible {
    
    /// Log level `DEBUG`
    ///
    /// Use this to mark any log information that's used during development.
    case debug = 10
    
    /// Log level `INFO`
    ///
    /// Use this log level to mark information about events and actions relevant to the SDK and flow state.
    ///
    /// Example: a backend request has been started.
    case info = 20
    
    /// Log level `WARN`
    ///
    /// Use this level to log information about something not going the happy path but which will be handled at this level.
    ///
    /// Example: the backend responded with an unsuccessful HTTP status code.
    case warn = 30
    
    /// Log level `ERROR`
    ///
    /// Use this log level to indicate that something unexpected happened which will have impact to the flow.
    ///
    /// Example: a response of the backend can't be decoded.
    case error = 40
    
    /// Log level `FAULT`
    ///
    /// Use this log level to indicate that something unexpected happened that can't be recovered from.
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

/// Specifies the scope of a log message.
public enum SBLogCategory: Encodable, Equatable, CustomStringConvertible {
    
    /// A UI navigation event.
    case nav
    
    /// A log message related to interaction with the backend.
    case api
    
    /// A custom log message category.
    case other(String)
    
    public var description: String {
        switch self {
        case .nav: return "NAV"
        case .api: return "API"
        case .other(let other): return other
        }
    }
}

/// Log message type.
public typealias SBLogMessage = String

/// Representation of a log entry.
public struct SBLogEntry: Encodable, Equatable {
    init(_ message: SBLogMessage, level: SBLogLevel, category: SBLogCategory? = nil) {
        self.message = message
        self.level = level
        self.category = category
    }
    let level: SBLogLevel
    let message: SBLogMessage
    let category: SBLogCategory?
}

// MARK: -

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
/// log.debug("A debugging message")
/// log.info("An API request", category: .api)
/// log.warn("Attention!")
/// ```
public class SBLog: SBLogClient {
    
    // MARK: - Static methods
    
    /// Shared `SBLog` instance.
    public static let standard = SBLog()
    
    /// Convencience method to log a message with `DEBUG` level to the standard logger.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public static func debug(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return standard.debug(message, category: category)
    }
    
    /// Convencience method to log a message with `INFO` level to the standard logger.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public static func info(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return standard.info(message, category: category)
    }

    /// Convencience method to log a message with `WARN` level to the standard logger.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public static func warn(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return standard.warn(message, category: category)
    }

    /// Convencience method to log a message with `ERROR` level to the standard logger.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public static func error(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return standard.error(message, category: category)
    }

    /// Convencience method to log a message with `FAULT` level to the standard logger.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public static func fault(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return standard.fault(message, category: category)
    }

    /// Convencience method to log a message to the standard logger.
    /// - Parameters:
    ///   - message: The log message.
    ///   - level: The log level for this log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public static func log(_ message: SBLogMessage, level: SBLogLevel, category: SBLogCategory? = nil) -> SBLogEntry {
        return standard.log(message, level: level, category: category)
    }

    /// Convencience method for flushing the standard logger, causing all registered destinations to process and clean up their pending log entries.
    public static func flush() {
        standard.flush()
    }
    
    // MARK: - Instance methods
    
    public init() {
        // public initializer
    }
    
    /// Log a message with provided log level and an optional category.
    /// - Parameters:
    ///   - message: The log message.
    ///   - level: The log level for this log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public func log(_ message: SBLogMessage, level: SBLogLevel, category: SBLogCategory? = nil) -> SBLogEntry {
        let entry = SBLogEntry(message, level: level, category: category)
        sendToDestinations(entry)
        return entry
    }

    /// Flush the logger, causing all registered destinations to process and clean up their pending log entries.
    public func flush() {
        for item in destinationItems {
            item.destination.flush()
        }
    }
    
    /// Add a destination for incoming log entries, e.g. to be displayed on the console.
    /// Destination instance will not be added again if already present as a destination.
    ///
    /// - Parameters:
    ///   - destination: The log destination to add to the logger.
    public func addDestination(_ destination: SBLogDestination) {
        for item in destinationItems where (item.destination as AnyObject) === (destination as AnyObject) {
            return
        }
        destinationItems.append(SBLogDestinationItem(destination))
    }
    
    ///  Returns a SBCategorizingLog proxy for this instance that will log with the provided category.
    ///
    ///  - Parameters:
    ///    - category: The category to use for logging through this log proxy.
    public func withCategory(_ category: SBLogCategory) -> SBCategorizingLog {
        return SBCategorizingLog(category, log: self)
    }
    
    // MARK: - Internal definitions
    
    /// Wrapper object holding a SBLogDestination instance together with an associated DispatchQueue.
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

    /// Performs the actual sending of the entry to the destinations.
    func sendToDestinations(_ entry: SBLogEntry) {
        for item in destinationItems {
            item.dispatchQueue.async {
                item.destination.send(entry)
            }
        }
    }
            
}

// MARK: -

/// Serves as an abstract base class for Log implementations.
/// SBLogClient provides and implements log level convenience methods for all Log implementations.
/// Deriving classes need to implement the actual logging methods `log(…)` and `flush()`.
public protocol SBLogClient {
    @discardableResult
    func log(_ message: SBLogMessage, level: SBLogLevel, category: SBLogCategory?) -> SBLogEntry
    func flush()
}

extension SBLogClient {
    /// Log a message with `DEBUG` level and optional category.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public func debug(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return self.log(message, level: .debug, category: category)
    }
    
    /// Log a message with `INFO` level and optional category.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public func info(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return self.log(message, level: .info, category: category)
    }
    
    /// Log a message with `WARN` level and optional category.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public func warn(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return self.log(message, level: .warn, category: category)
    }
    
    /// Log a message with `ERROR` level and optional category.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public func error(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return self.log(message, level: .error, category: category)
    }
    
    /// Log a message with `FAULT` level and optional category.
    /// - Parameters:
    ///   - message: The log message.
    ///   - category: An optional category for the log event.
    /// - Returns: The created log entry.
    @discardableResult
    public func fault(_ message: SBLogMessage, category: SBLogCategory? = nil) -> SBLogEntry {
        return self.log(message, level: .fault, category: category)
    }
}

// MARK: -

/// A proxy for `SBLogClient`s that will always log with a initially set category.
///
/// Example:
/// ```swift
/// // Logger setup
/// let log = SBLog()
///
/// // Create a proxy logger that always uses the .api category:
/// let apiLog = log.categorizingLog(.api)
///
/// // Let's test:
/// apiLog.debug("A debugging message that will have category .api set")
/// ```
public class SBCategorizingLog: SBLogClient {
    
    let target: SBLogClient
    public private(set) var category: SBLogCategory
    
    /// Initialize with the category to use and the logger to be proxied.
    public init(_ category: SBLogCategory, log: SBLog) {
        self.target = log
        self.category = category
    }
    
    public func log(_ message: SBLogMessage, level: SBLogLevel, category: SBLogCategory? = nil) -> SBLogEntry {
        // We always override an explicitly provided category with our own:
        return target.log(message, level: level, category: self.category)
    }
    
    public func flush() {
        target.flush()
    }

}
