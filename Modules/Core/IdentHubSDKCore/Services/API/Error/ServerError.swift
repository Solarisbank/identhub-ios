//
//  ServerError.swift
//  IdentHubSDKCore
//

import Foundation

public struct ServerError: Equatable {

    /// Error object id
    public let id: String?

    /// Error status code
    public let status: Int?

    /// Error object server code
    public let code: ErrorCodes?

    /// Error title, can be used for user alert
    public let title: String?

    /// Error details
    public let detail: String?

    enum CodingKeys: String, CodingKey {
        case id = "id"
        case status = "status"
        case code = "code"
        case title = "title"
        case detail = "detail"
    }
}

extension ServerError: Decodable {

    public init(from decoder: Decoder) throws {
        let container = try decoder.container(keyedBy: CodingKeys.self)

        id = try container.decodeIfPresent(String.self, forKey: .id)
        status = try container.decodeIfPresent(Int.self, forKey: .status)
        code = try container.decodeIfPresent(ErrorCodes.self, forKey: .code)
        title = try container.decodeIfPresent(String.self, forKey: .title)
        detail = try container.decodeIfPresent(String.self, forKey: .detail)
    }
}
