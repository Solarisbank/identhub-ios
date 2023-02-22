//
//  RequestsEvent.swift
//  IdentHubSDKCore
//

import UIKit

public enum RequestsType {
    case initateFlow
    case fetchData
    case uploadData
    case confirmation
}

public enum RequestsOutput: Equatable {
    public static func == (lhs: RequestsOutput, rhs: RequestsOutput) -> Bool {
        return false
    }
    
    case finishInitialFetch(_ info: IdentificationInfo? = nil)
    case fourthline(_ step: FourthlineStep)
    case failure(APIError)
    case quit
}

public struct RequestsInput {
    public var requestsType: RequestsType
    public var initStep: InitStep
    
    public init(requestsType: RequestsType, initStep: InitStep) {
        self.requestsType = requestsType
        self.initStep = initStep
    }
}

public struct ZipFailedError {
    
    public enum ErrorType {
        case none
        case invalidDocument
        case invalidSelfie
        case invalidData
    }
    
    public var type: ErrorType = .none
    public var title: String = ""
    public var description: String = ""
    public var isRetry: Bool = false
    
    public init(title: String, description: String, type: ErrorType, isRetry: Bool) {
        self.title = title
        self.description = description
        self.type = type
        self.isRetry = isRetry
    }
}

public struct RequestsState: Equatable {
    public static func == (lhs: RequestsState, rhs: RequestsState) -> Bool {
        return true
    }
    
    public var stateType: RequestsType = .initateFlow
    public var title: String? = ""
    public var description: String? = ""
    public var loading: Bool = false
    public var identifyEvent: Bool = false
    public var onDisplayError: Error? = .none
    public var onRetry: FourthlineIdentificationStatus?
    public var zipError: ZipFailedError?

    public init(title: String, description: String, type: RequestsType) {
        self.title = title
        self.description = description
        self.stateType = type
    }
}

public enum RequestsEvent {
    case identifyEvent
    case initateFlow
    case fetchData
    case uploadData
    case verification
    case reTry(status: FourthlineIdentificationStatus)
    case zipFailedReTry(type: ZipFailedError.ErrorType)
    case close(error: APIError)
    case restart
    case quit
}
