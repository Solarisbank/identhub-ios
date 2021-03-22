//
//  File.swift
//  IdentHubSDK
//

/// Base coordinator pattern protocol
protocol Coordinator {
    func start(completion: @escaping CompletionHandler)
}
