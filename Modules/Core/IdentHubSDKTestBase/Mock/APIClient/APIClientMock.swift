//
//  APIClientMock.swift
//  IdentHubSDKTestBase
//
import Foundation
import IdentHubSDKCore

/// Mock class of APIClient service.
/// Class conforms APIClient protocol
public class APIClientMock: APIClient {
    private typealias Expectation = (id: Request.Id, result: Result<RequestFileMock, ResponseError>)
    public var executeCommandCalled = false
    public var downloadCommandCalled = false
    public var inputRequest: Request?
    public var downloadResult: Result<URL?, ResponseError>?

    private var recorder: TestRecorder?
    private var expectations = [Expectation]()
    private var failUnexpectedRequests: Bool

    public init(failUnexpectedRequests: Bool = false, recorder: TestRecorder? = nil) {
        self.failUnexpectedRequests = failUnexpectedRequests
        self.recorder = recorder
    }
    
    public func expectSuccess(_ file: RequestFileMock, for request: Request) {
        expectations.append((id: request.id, result: .success(file)))
    }

    public func expectError(_ apiError: APIError, for request: Request) {
        expectError(.init(apiError), for: request)
    }

    public func expectError(_ error: ResponseError, for request: Request) {
        expectations.append((id: request.id, result: .failure(error)))
    }

    public func execute<DataType>(request: Request, answerType: DataType.Type, completion: @escaping (Result<DataType, ResponseError>) -> Void) where DataType: Decodable {

        let result = execute(request: request) { file in
            file.decode(type: DataType.self)
        } defaultHandler: {
            executeCommandCalled = true
            inputRequest = request
        }
        
        if let result = result {
            completion(result)
        }
    }

    public func download(request: Request, completion: @escaping (Result<URL?, ResponseError>) -> Void) {
        let result = execute(request: request) { file -> URL? in
            file.url
        } defaultHandler: {
            downloadCommandCalled = true
            inputRequest = request
            downloadResult.map(completion)
        }

        if let result = result {
            completion(result)
        }
    }
    
    private func execute<T>(request: Request, process: (RequestFileMock) -> T, defaultHandler: () -> Void) -> Result<T, ResponseError>? {
        if expectations.first?.id == request.id {
            let expectation = expectations.removeFirst()
            switch expectation.result {
            case .success(let file):
                self.recorder?.record(event: .api, value: "\(request.id): OK")
                return .success(process(file))
            case .failure(let error):
                self.recorder?.record(event: .api, value: "\(request.id): \(error)")
                return .failure(error)
            }
        } else {
            if failUnexpectedRequests {
                if expectations.isEmpty {
                    print("Error! Request \(request.id) is not mocked")
                } else {
                    print("Error! Unexpected request (expected \(expectations.first!.id), received \(request.id))")
                }
                return .failure(.init(.internalServerError))
            } else {
                defaultHandler()
                return nil
            }
        }
    }
}

/// Request mock object
/// Used for internal request tests
public final class RequestMock: Request {
    public var path: String { "/test_request/" }

    public var method: HTTPMethod = .get
}

public struct ModelMock: Decodable {}

public extension Request {
    typealias Id = String
    var id: Id {
        apiPath.appending(path)
    }
}
