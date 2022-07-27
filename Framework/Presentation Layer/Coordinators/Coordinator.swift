//
//  Coordinator.swift
//  IdentHubSDK
//

/// Base coordinator pattern protocol
protocol Coordinator {
    func start(_ completion: @escaping CompletionHandler)
}
