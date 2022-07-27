//
//  Result.swift
//  IdentHubSDKCore
//

import Foundation

public extension Result {
    @discardableResult
    func onSuccess(_ onSuccess: @escaping (Success) -> Void) -> Self {
        switch self {
        case.success(let success): onSuccess(success)
        case .failure(_): break
        }

        return self
    }

    @discardableResult
    func onFailure(_ onFailure: @escaping (Failure) -> Void) -> Self {
        switch self {
        case .success(_): break
        case .failure(let failure): onFailure(failure)
        }

        return self
    }
}

public extension Result where Failure == Never {
    func eraseFailure() -> Success {
        guard case .success(let output) = self else {
            fatalError("Never shouldn't return failure")
        }
        return output
    }
}
