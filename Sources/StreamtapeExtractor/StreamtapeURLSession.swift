//
//  StreamtapeURLSession.swift
//  StreamtapeExtractor
//
//  Created by Alexander Eichhorn on 17.01.22.
//

import Foundation
#if os(Linux)
import FoundationNetworking
#endif

/// used to wrap url connection methods and inject into `StreamtapeExtractor`
@available(iOS 13.0, watchOS 6.0, tvOS 13.0, macOS 10.15, *)
public struct StreamtapeURLSession {
    
    let handleRequest: ((Request) async throws -> Response)
    
    public struct Request {
        let url: URL
        var httpMethod = "get"
        var headers: [String: String] = [:]
    }
    
    public struct Response {
        let data: Data
        let url: URL?
    }
    
    
    public init(handleRequest: @escaping ((Request) async throws -> Response)) {
        self.handleRequest = handleRequest
    }
    
    public init(handleRequest: @escaping ((Request, (Result<Response, Error>) -> Void) -> Void)) {
        self.handleRequest = { req in
            try await withCheckedThrowingContinuation { continuation in
                handleRequest(req) { result in
                    continuation.resume(with: result)
                }
            }
        }
    }
    
    
    public static var `default`: StreamtapeURLSession {
        StreamtapeURLSession { request in
            var urlRequest = URLRequest(url: request.url)
            urlRequest.httpMethod = request.httpMethod
            urlRequest.allHTTPHeaderFields = request.headers
            
            let (data, response) = try await URLSession.shared.data(for: urlRequest)
            
            return Response(data: data, url: response.url)
        }
    }
    
}
