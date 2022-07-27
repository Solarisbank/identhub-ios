//
//  RequestFileMock.swift
//  IdentHubSDKTestBase
//

/// Mock files for API requests
public enum RequestFileMock: String {
    case identificationNotConfirmed
    case identificationConfirmed
    case mobileNumber
    case signDocumentsAuthorize
    case signDocumentsConfirm
    case bankDocument
    
    var fileExtension: String {
        switch self {
        case .bankDocument: return "pdf"
        default: return "json"
        }
    }
}

public extension RequestFileMock {
    var url: URL {
        URL(fileURLWithPath: #file)
            .deletingLastPathComponent()
            .appendingPathComponent("APIResponse")
            .appendingPathComponent("\(rawValue).\(fileExtension)")
    }

    /// - Returns: data 
    func loadData() -> Data {
        return try! Data(contentsOf: url)
    }
    
    func decode<DataType: Decodable>(type: DataType.Type) -> DataType {
        let jsonDecoder = JSONDecoder()
        return try! jsonDecoder.decode(type, from: loadData())
    }
}
