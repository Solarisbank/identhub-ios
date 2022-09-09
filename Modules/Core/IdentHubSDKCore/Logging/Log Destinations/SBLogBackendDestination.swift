//
//  SBLoggerBackendDestination.swift
//  IdentHubSDK
//

import Foundation

/// Remote logging destination for `SBLog` logger to send log entries to Solarisbank's SDK backend.
///
/// Set a `backendRequestBundlingPeriod` > 0 to enable bundling of log entries:
/// within the specified period, incoming log entries will be collected locally and send out
/// in a single request at the end of the period.
///
/// Sending out log entries will silently fail if the backend can't be reached for any reason.
///
/// Example:
/// ```swift
/// // Create a backend destination
/// let backendDestination = SBLogBackendDestination()
/// backendDestination.level = .info
/// backendDestination.apiClient = SBLogBackendAPIClient(url: URL(string:"https://...")!, sessionToken: "...")
/// backendDestination.backendRequestBundlingPeriod = 1.0
///
/// // Add to standard logger
/// SBLog.standard.addDestination(backendDestination)
///
/// // Let's test
/// log.debug("Hello Debug")
/// log.info("Hello Info")
/// log.warn("Hello Warn")
/// ```
public class SBLogBackendDestination: SBLogDestination {
        
    /// Shared default backend destination
    public static let standard = SBLogBackendDestination()

    /// The time in seconds to collect log entries for before sending them to the backend.
    /// Set to 0 to immediately send each log entry in a separate request to the backend.
    /// Defaults to 0 (immediate sending).
    public var backendRequestBundlingPeriod = 0.0

    public var level: SBLogLevel = .error

    /// Set an API client to enable sending log entries to the backend.
    /// Log entries received before an API client has been set will be collected and
    /// sent out once the API client has been set.
    public var apiClient: SBLogBackendConnectable? {
        didSet {
            if apiClient != nil {
                self.flush()
            }
        }
    }
    
    var dispatchQueue: DispatchQueue?

    public init() {
        let uuid = UUID().uuidString
        let queueLabel = "sblogger-backend-queue-\(uuid)"
        dispatchQueue = DispatchQueue(label: queueLabel, target: nil)
    }

    public func send(_ entry: SBLogEntry) {
        guard shouldSendForLevel(entry.level) else {
            return
        }
        
        queuedEntries.append(entry)
        
        if shouldSendImmediately {
            self.flush()
        } else if !bundlingPeriodStarted {
            // flush after bundlingPeriod timeout
            flushWorkItem = DispatchWorkItem { self.flush() }
            dispatchQueue?.asyncAfter(deadline: .now() + backendRequestBundlingPeriod, execute: flushWorkItem!)
        }
    }
    
    public func flush() {
        // Flushing stops any already dispatched flush workitem
        flushWorkItem?.cancel()
        flushWorkItem = nil
        
        if canSendToBackend {
            sendToBackend()
            queuedEntries.removeAll()
        } else {
            print("[IdentHub] Can't flush backend log queue without API Client being set, postponing.")
        }
    }
    
    // MARK: - Internal definitions -

    var queuedEntries = [SBLogEntry]()
    private var flushWorkItem: DispatchWorkItem?
    
    /// Indicates wether log entries should be sent out individually,
    /// or wether multiple log entries should be collected and be sent together.
    var shouldSendImmediately: Bool {
        return backendRequestBundlingPeriod == 0
    }
    
    /// Indicates if it's possible to initiate sending to the backend.
    var canSendToBackend: Bool {
        return apiClient != nil
    }
    
    /// Indicates if there is running request bundling timeout.
    var bundlingPeriodStarted: Bool {
        return flushWorkItem != nil
    }
    
    func sendToBackend() {
        guard queuedEntries.isNotEmpty() else {
            return
        }
        let payload = SBLogBackendPayload(content: queuedEntries)
        apiClient?.sendToBackend(payload: payload)
    }
    
}

public protocol SBLogBackendConnectable {
    init(url: URL, sessionToken: String)
    func sendToBackend<T>(payload: T) where T: Encodable
}

public class SBLogBackendAPIClient: SBLogBackendConnectable {
    
    required public init(url: URL, sessionToken: String) {
        self.url = url
        
        let urlSessionConfiguration = URLSessionConfiguration.ephemeral
        urlSessionConfiguration.httpAdditionalHeaders = ["x-solaris-session-token": sessionToken]
        urlSession = URLSession(configuration: urlSessionConfiguration)
    }
    
    // MARK: - Internal definitions -

    var urlSession: URLSession
    private(set) var url: URL
    
    static var jsonEncoder: JSONEncoder = {
        let dateFormatter = DateFormatter()
        dateFormatter.locale = Locale(identifier: "en_US_POSIX")
        dateFormatter.dateFormat = "yyyy-MM-dd'T'HH:mm:ss'Z'"
        dateFormatter.timeZone = TimeZone(abbreviation: "UTC")
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        encoder.dateEncodingStrategy = .formatted(dateFormatter)
        return encoder
    }()

    public func encodePayload<T>(_ payload: T) -> Data where T: Encodable {
        var encodedPayload: Data
        do {
            encodedPayload = try Self.jsonEncoder.encode(payload)
        } catch {
            print("[IdentHub] Error while trying to encode logging payload.")
            encodedPayload = "{\"contents\":[{\"level\":\"WARN\",\"message\":\"Error while trying to encode logging payload!\"}]}".data(using: .utf8)!
        }
        return encodedPayload
    }

    /// Send the payload to the backend. Payload must be (JSON)-encodable and will be sent with content type `application/json`.
    public func sendToBackend<T>(payload: T) where T: Encodable {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        request.httpBody = encodePayload(payload)
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        
        // NOTE: No handling of the result of the request at this time.
        // If the request to the backend fails, the log items to be sent are discarded.
        // To be improved in future iterations.
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard data != nil && error == nil, let httpResponse = response as? HTTPURLResponse else {
                print("[IdentHub] Error while trying to send log entries:", error ?? "No valid response")
                return
            }
            guard 200 ..< 300 ~= httpResponse.statusCode else {
                print("[IdentHub] Failed to send log entries: backend replied with status code \(httpResponse.statusCode).")
                return
            }
        }
        task.resume()
    }
    
}

extension SBLogBackendAPIClient {
    /// Create an URL instance pointing to the SDK BFF based on the provided base path.
    public static func urlForAPIURL(_ apiURL: URL?) -> URL? {
        apiURL?.appendingPathComponent("sdk_logging")
    }
}

extension SBLogLevel {
    /// Use log level text representation (e.g. "DEBUG", "INFO") as values for JSON encoding.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension SBLogCategory {
    /// Use log category text representation (e.g. "NAV", "API") as values for JSON encoding.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

struct SBLogBackendPayload: Encodable {
    var content: [SBLogEntry]
}
