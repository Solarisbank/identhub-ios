//
//  TestRecorder.swift
//  IdentHubSDKTestBase
//

import XCTest
import SnapshotTesting

public class TestRecorder {
    public enum Event: String {
        case event = "EVENT"
        case updateView = "UPDATE_VIEW"
        case api = "API"
        case service = "SERVICE"
        case ui = "UI"
    }

    private var recording = ""
    private var isRecordingMode: Bool

    public init(isRecordingMode: Bool = false) {
        self.isRecordingMode = isRecordingMode
    }

    public func record(event: Event, value: Any) {
        let text = "\(event.rawValue): \(String(describing: value))\n"
        recording.append(text)
    }

    public func record(event: Event, in function: StaticString = #function, caller: Any? = nil) {
        let prefix = caller == nil ? "" : String(describing: type(of: caller!)) + "."
        let value = prefix + valueForFunction(function, with: [])
        record(event: event, value: value)
    }

    public func record(event: Event, in function: StaticString = #function, caller: Any? = nil, arguments: Any...) {
        let prefix = caller == nil ? "" : String(describing: type(of: caller!)) + "."
        let value = prefix + valueForFunction(function, with: arguments)
        record(event: event, value: value)
    }
    
    
    public func assert(file: StaticString = #file, testName: String = #function, isRecordingMode: Bool = false) {
        let isRecordingMode = isRecordingMode || self.isRecordingMode
        SnapshotTesting.assertSnapshot(
            matching: recording,
            as: .lines,
            record: isRecordingMode,
            file: file,
            testName: testName
        )
    }
    
    private func prepareSnapshotFolder(file: String) -> URL {
        let fileURL = URL(fileURLWithPath: file)
        let name = (fileURL.lastPathComponent as NSString).deletingPathExtension
        let baseURL = fileURL
            .deletingLastPathComponent()
            .appendingPathComponent("__Snapshots__")
            .appendingPathComponent(name)

        XCTAssertNoThrow(try FileManager.default.createDirectory(at: baseURL, withIntermediateDirectories: true))
        return baseURL
    }
    
    private func valueForFunction(_ functionName: StaticString, with arguments: [Any]) -> String {
        let argumentsStrings = arguments.map { String(describing: $0) }
        var functionParts = functionName.description.split(separator: ":")

        guard functionParts.count >= argumentsStrings.count else {
            XCTFail("Too many arguments")
            
            return ""
        }
        
        guard functionParts.count > 1 else {
            if arguments.isNotEmpty() {
                return functionName.description + ", arguments: " + argumentsStrings.joined(separator: ", ")
            } else {
                return functionName.description
            }
        }

        var returnValues: [String] = []

        argumentsStrings.forEach { argument in
            returnValues.append(String(functionParts.removeFirst()) + ": \"" + argument + "\"")
        }
        
        while functionParts.count > 1 {
            returnValues.append(String(functionParts.removeFirst()) + ":")
        }

        return returnValues.joined(separator: ", ") + functionParts.joined(separator: "")
    }
}

private extension String {
    func printable() -> String {
        String(prefix(while: { $0 != "(" }))
    }
}
