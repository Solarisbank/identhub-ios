//
//  Body.swift
//  IdentHubSDKCore
//

import Foundation

/// Represents body sent in the url request.
///
/// - json: compliant with application/json encoding.
public enum Body {
    case json(body: [String: Any])
    case data(body: URL, boundary: String)

    // MARK: Properties

    /// Returns the body encoded into data.
    public var httpBody: Data? {
        switch self {
        case let .json(body):
            do {
                return try Body.createJson(body: body)
            } catch let error as NSError {
                print("Serilizationtion body dictionary to JSON throws error: \(error.localizedDescription)")
                return nil
            }
        case let .data(file, boundary):
            do {
                let fileData = try Data(contentsOf: file)

                let httpBody = NSMutableData()

                httpBody.append(Body.convertFileData(fieldName: "document", fileName: file.lastPathComponent, mimeType: "application/\(file.pathExtension)", fileData: fileData, using: boundary))

                httpBody.appendString("--\(boundary)--")

                return httpBody as Data
            } catch let error as NSError {
                print("Loading file data form content failed: \(error.localizedDescription)")
                return nil
            }
        }
    }

    // MARK: Private methods

    private static func createJson(body: [String: Any]) throws -> Data? {
        try JSONSerialization.data(withJSONObject: body, options: .prettyPrinted)
    }

    private static func convertFileData(fieldName: String, fileName: String, mimeType: String, fileData: Data, using boundary: String) -> Data {
        let data = NSMutableData()

        data.appendString("--\(boundary)\r\n")
        data.appendString("Content-Disposition: form-data; name=\"\(fieldName)\"; filename=\"\(fileName)\"\r\n")
        data.appendString("Content-Type: \(mimeType)\r\n\r\n")
        data.append(fileData)
        data.appendString("\r\n")

        return data as Data
      }
}

extension Body: Equatable {
    public static func == (lhs: Body, rhs: Body) -> Bool {
        switch (lhs, rhs) {
        case (.json(let lhsDictionary), .json(let rhsDictionary)):
            return (lhsDictionary as NSDictionary).isEqual(to: rhsDictionary)
        case (let .data(body: lhsUrl, boundary: lhsBoundary), let .data(body: rhsUrl, boundary: rhsBoundary)):
            return lhsUrl == rhsUrl && lhsBoundary == rhsBoundary
        default:
            return false
        }
    }
}
