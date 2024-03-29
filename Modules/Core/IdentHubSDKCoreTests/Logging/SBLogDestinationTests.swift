//
//  SBLogDestinationTest.swift
//  IdentHubSDKTests
//

import XCTest
@testable import IdentHubSDKCore

final class SBLogDestinationTests: XCTestCase {
    
    override func tearDownWithError() throws {
        MockURLProtocol.loadingHandler = nil
    }

    // MARK: - Destination Tests

    func testLogDestinationShouldSend() throws {
        let destination = SBLogBaseDestination()
        destination.level = .debug
        XCTAssertTrue(destination.shouldSendForLevel(.debug))
        XCTAssertTrue(destination.shouldSendForLevel(.info))
        XCTAssertTrue(destination.shouldSendForLevel(.warn))
        XCTAssertTrue(destination.shouldSendForLevel(.error))
        XCTAssertTrue(destination.shouldSendForLevel(.fault))

        destination.level = .info
        XCTAssertFalse(destination.shouldSendForLevel(.debug))
        XCTAssertTrue(destination.shouldSendForLevel(.info))
        XCTAssertTrue(destination.shouldSendForLevel(.warn))
        XCTAssertTrue(destination.shouldSendForLevel(.error))
        XCTAssertTrue(destination.shouldSendForLevel(.fault))

        destination.level = .warn
        XCTAssertFalse(destination.shouldSendForLevel(.debug))
        XCTAssertFalse(destination.shouldSendForLevel(.info))
        XCTAssertTrue(destination.shouldSendForLevel(.warn))
        XCTAssertTrue(destination.shouldSendForLevel(.error))
        XCTAssertTrue(destination.shouldSendForLevel(.fault))

        destination.level = .error
        XCTAssertFalse(destination.shouldSendForLevel(.debug))
        XCTAssertFalse(destination.shouldSendForLevel(.info))
        XCTAssertFalse(destination.shouldSendForLevel(.warn))
        XCTAssertTrue(destination.shouldSendForLevel(.error))
        XCTAssertTrue(destination.shouldSendForLevel(.fault))

        destination.level = .fault
        XCTAssertFalse(destination.shouldSendForLevel(.debug))
        XCTAssertFalse(destination.shouldSendForLevel(.info))
        XCTAssertFalse(destination.shouldSendForLevel(.warn))
        XCTAssertFalse(destination.shouldSendForLevel(.error))
        XCTAssertTrue(destination.shouldSendForLevel(.fault))
    }

    // MARK: - ConsoleDestination Tests

    func testConsoleLogDestination() throws {
        // TBD
    }
    
    // MARK: - BackendDestination Tests

    func testBackendDestinationLogEntrySerialization() throws {
        let destination = SBLogBackendAPIClient(url: SOME_URL, sessionToken: SOME_SESSION_TOKEN)

        let dateString = "2022-07-08T16:22:13Z"
        let date = ISO8601DateFormatter().date(from: dateString)!

        // single entry w/o category
        let logEntry = SBLogEntry("Log message", level: .error, timestamp: date)
        var expectedPayload = "{\"content\":[{\"level\":\"\(logEntry.level)\",\"message\":\"\(logEntry.message)\",\"timestamp\":\"\(dateString)\"}]}"
        var payload = destination.encodePayload(SBLogBackendPayload(content: [logEntry]))
        XCTAssertEqual(payload, expectedPayload.data(using: .utf8))

        // single entry with category
        let logEntryWithCategory = SBLogEntry("Log message", level: .info, category: .nav, timestamp: date)
        expectedPayload = "{\"content\":[{\"category\":\"\(logEntryWithCategory.category!)\",\"level\":\"\(logEntryWithCategory.level)\",\"message\":\"\(logEntryWithCategory.message)\",\"timestamp\":\"\(dateString)\"}]}"
        payload = destination.encodePayload(SBLogBackendPayload(content: [logEntryWithCategory]))
        XCTAssertEqual(payload, expectedPayload.data(using: .utf8))

        // empty entry
        expectedPayload = "{\"content\":[]}"
        payload = destination.encodePayload(SBLogBackendPayload(content: []))
        XCTAssertEqual(payload, expectedPayload.data(using: .utf8))

        // multiple entries
        let logEntry2 = SBLogEntry("Log message 2", level: .fault, timestamp: date)
        expectedPayload = "{\"content\":[{\"level\":\"\(logEntry.level)\",\"message\":\"\(logEntry.message)\",\"timestamp\":\"\(dateString)\"},{\"level\":\"\(logEntry2.level)\",\"message\":\"\(logEntry2.message)\",\"timestamp\":\"\(dateString)\"}]}"
        payload = destination.encodePayload(SBLogBackendPayload(content: [logEntry, logEntry2]))
        XCTAssertEqual(payload, expectedPayload.data(using: .utf8))
    }
    
    func testBackendDestinationClientReceivesPayload() throws {
        let dateString = "2022-07-08T16:22:13Z"
        let date = ISO8601DateFormatter().date(from: dateString)!

        let destination = SBLogBackendDestination()
        let mockAPIClient = SBLogBackendMockAPIClient(url: SOME_URL, sessionToken: SOME_SESSION_TOKEN)
        destination.apiClient = mockAPIClient

        let logEntry = SBLogEntry("Log message", level: .error, timestamp: date)
        destination.send(logEntry)
        
        let expectedPayload = "{\"content\":[{\"level\":\"\(logEntry.level)\",\"message\":\"\(logEntry.message)\",\"timestamp\":\"\(dateString)\"}]}"
        XCTAssertEqual(mockAPIClient.receivedPayload, expectedPayload)
    }

    func testBackendDestinationStoresEntriesUntilAPIClientAvailable() throws {
        let destination = SBLogBackendDestination()
        let mockAPIClient = SBLogBackendMockAPIClient(url: SOME_URL, sessionToken: SOME_SESSION_TOKEN)

        let logEntry = SBLogEntry("Log message", level: .error)
        destination.send(logEntry)
        
        XCTAssertEqual(destination.queuedEntries.count, 1)
        
        destination.apiClient = mockAPIClient
        
        XCTAssertEqual(destination.queuedEntries.count, 0)
        XCTAssertNotNil(mockAPIClient.receivedPayload)
    }

    func testBackendDestinationImmediateSendingLogic() throws {
        let destination = SBLogBackendDestination()

        destination.backendRequestBundlingPeriod = 0
        XCTAssertTrue(destination.shouldSendImmediately)

        destination.backendRequestBundlingPeriod = 3.0
        XCTAssertFalse(destination.shouldSendImmediately)
    }

    func testBackendDestinationCanSendLogic() throws {
        let destination = SBLogBackendDestination()

        destination.apiClient = nil
        XCTAssertFalse(destination.canSendToBackend)

        destination.apiClient = SBLogBackendAPIClient(url: SOME_URL, sessionToken: SOME_SESSION_TOKEN)
        XCTAssertTrue(destination.canSendToBackend)
    }
    
    // MARK: - BackendAPICLient Tests
    
    func testAPIClientURLGeneration() throws {
        let validURL = SBLogBackendAPIClient.urlForAPIURL(URL(string: "https://person-onboarding-api.solaris-sandbox.de/person_onboarding"))
        XCTAssertEqual(validURL?.absoluteString, "https://person-onboarding-api.solaris-sandbox.de/person_onboarding/sdk_logging")

        let validLocalURL = SBLogBackendAPIClient.urlForAPIURL(URL(string: "http://local.dev:3000"))
        XCTAssertEqual(validLocalURL?.absoluteString, "http://local.dev:3000/sdk_logging")

        let invalidURL = SBLogBackendAPIClient.urlForAPIURL(nil)
        XCTAssertNil(invalidURL)
    }
    
    func testAPIClientURLSessionSetup() throws {
        let apiClient = SBLogBackendAPIClient(url: SOME_URL, sessionToken: SOME_SESSION_TOKEN)
        let urlSession = apiClient.urlSession
        
        XCTAssertNotNil(urlSession)
        XCTAssertEqual(apiClient.urlSession.configuration.httpAdditionalHeaders?["x-solaris-session-token"] as! String, SOME_SESSION_TOKEN)
    }
    
    func testAPIClientSending() throws {
        let apiClient = SBLogBackendAPIClient(url: SOME_URL, sessionToken: SOME_SESSION_TOKEN)
        let configuration = apiClient.urlSession.configuration
        configuration.protocolClasses = [MockURLProtocol.self]
        apiClient.urlSession = URLSession(configuration: configuration)
        
        let payloadString = "{\"item\":\"payload string\"}"
        let expectation = expectation(description: "HTTP request intercepted")
        MockURLProtocol.loadingHandler = { request in
            XCTAssertEqual(request.url, SOME_URL)
            XCTAssertEqual(request.bodyStreamAsData(), payloadString.data(using: .utf8))
            XCTAssertEqual(request.httpMethod, "POST")
            XCTAssertEqual(request.value(forHTTPHeaderField: "x-solaris-session-token"), SOME_SESSION_TOKEN)
            XCTAssertEqual(request.value(forHTTPHeaderField: "Content-Type"), "application/json")
            expectation.fulfill()
            let response = HTTPURLResponse(url: request.url!, statusCode: 200, httpVersion: nil, headerFields: nil)!
            return (response, "true".data(using: .utf8), nil)
        }

        let payload: [String: String] = ["item": "payload string"]
        apiClient.sendToBackend(payload: payload)
        wait(for: [expectation], timeout: 2)
    }

}

// MARK: - Helpers and Mocks

// Minimal implementation of SBLogDestination protocol to test included methods.
class SBLogBaseDestination: SBLogDestination {
    var level: SBLogLevel = .debug
    var shouldSendAsynchronously: Bool = false
    init() { }
    func send(_ entry: SBLogEntry) { }
    func flush() { }
}

class SBLogBackendMockAPIClient: SBLogBackendConnectable {
    @objc dynamic var receivedPayload: String?
    required init(url: URL, sessionToken: String) { }
    
    func sendToBackend<T>(payload: T) where T: Encodable {
        let encoder = SBLogBackendAPIClient.jsonEncoder
        self.receivedPayload = String(data: (try? encoder.encode(payload))!, encoding: .utf8)
    }
}

extension URLRequest {

    // To be able to inspect URLRequest body values during testing
    func bodyStreamAsData() -> Data? {
        guard let bodyStream = self.httpBodyStream else { return nil }
        bodyStream.open()
        let bufferSize: Int = 16 // Can use bigger buffer if needed
        let buffer = UnsafeMutablePointer<UInt8>.allocate(capacity: bufferSize)
        var data = Data()
        while bodyStream.hasBytesAvailable {
            let readData = bodyStream.read(buffer, maxLength: bufferSize)
            data.append(buffer, count: readData)
        }
        buffer.deallocate()
        bodyStream.close()
        return data
    }
}

final class MockURLProtocol: URLProtocol {

    // Set this static handler to intercept loading and provide a response
    static var loadingHandler: ((URLRequest) -> (HTTPURLResponse, Data?, Error?))?
    
    override class func canInit(with request: URLRequest) -> Bool {
        return true
    }
    
    override class func canonicalRequest(for request: URLRequest) -> URLRequest {
        return request
    }

    override func startLoading() {
        guard let handler = MockURLProtocol.loadingHandler else {
            XCTFail("Loading handler is not set.")
            return
        }
        let (response, data, error) = handler(request)
        if let data = data {
            client?.urlProtocol(self, didReceive: response, cacheStoragePolicy: .notAllowed)
            client?.urlProtocol(self, didLoad: data)
            client?.urlProtocolDidFinishLoading(self)
        } else {
            client?.urlProtocol(self, didFailWithError: error!)
        }
    }
    
    override func stopLoading() {}
}

// swiftlint:disable identifier_name
fileprivate let SOME_URL = URL(string: "https://some.domain.com")!
fileprivate let SOME_SESSION_TOKEN = "a_session_token"
// swiftlint:enable identifier_name
