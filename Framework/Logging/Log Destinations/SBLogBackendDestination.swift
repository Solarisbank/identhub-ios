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
            print("Can't flush backend log queue without API client being set, postponing.")
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
        let payload = buildPayloadForEntries(queuedEntries)
        apiClient?.execute(payload: payload)
    }
    
    func buildPayloadForEntries(_ entries: [SBLogEntry]) -> String? {
        let payload = SBLogBackendPayload(content: entries)
        let payloadString: String?
        do {
            let data = try SBLogBackendDestination.jsonEncoder.encode(payload)
            payloadString = String(data: data, encoding: .utf8)
        } catch {
            print("Error while trying to encode logging payload!")
            payloadString = "{\"contents\":[{\"type\":\"error\",\"message\":\"Error while trying to encode logging payload!\"}]}"
        }
        return payloadString
    }
    
    static var jsonEncoder: JSONEncoder {
        let encoder = JSONEncoder()
        encoder.outputFormatting = .sortedKeys
        return encoder
    }
    
}

public protocol SBLogBackendConnectable {
    init(url: URL, sessionToken: String)
    func execute(payload: String?)
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

    // TODO: handle result of URLRequest?
    public func execute(payload: String?) {
        var request = URLRequest(url: url)
        request.httpMethod = "POST"
        if let payload = payload {
            request.httpBody = payload.data(using: .utf8)
        }
        let task = urlSession.dataTask(with: request) { data, response, error in
            guard let data = data, error == nil, let httpResponse = response as? HTTPURLResponse else {
                print("Error while sending log entries", error ?? "No valid response")
                return
            }
            guard 200 ..< 300 ~= httpResponse.statusCode else {
                print("Error while sending log entries: backend replied with status code \(httpResponse.statusCode), but expected 2xx")
                return
            }
            print("Log entries sucessfully submitted (response: \(String(data: data, encoding: .utf8) ?? ""))")
        }
        task.resume()
        print("Sending log entries to \(request.url!)...")
    }
    
}

extension SBLogLevel {
    /// Use log level text representation (e.g. "DEBUG", "INFO") as values for JSON encoding.
    public func encode(to encoder: Encoder) throws {
        var container = encoder.singleValueContainer()
        try container.encode(self.description)
    }
}

extension SBLogEntry {
    enum CodingKeys: String, CodingKey {
        case level = "type"
        case message
    }
}

struct SBLogBackendPayload: Encodable {
    var content: [SBLogEntry]
}