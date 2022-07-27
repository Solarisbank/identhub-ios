//
//  APIClient.swift
//  IdentHubSDKCore
//

import Foundation

public protocol APIClient: AnyObject {

    func execute<DataType: Decodable>(
        request: Request,
        answerType: DataType.Type,
        completion: @escaping (Result<DataType, ResponseError>) -> Void
    )

    func download(
        request: Request,
        completion: @escaping (Result<URL?, ResponseError>) -> Void
    )
}
