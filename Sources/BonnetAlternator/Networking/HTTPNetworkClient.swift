//
//  HTTPNetworkClient.swift
//  BonnetAlternator
//
//  Created by Ana Marquez on 23/09/2024.
//

import Foundation
import BFSecurity

internal class HTTPNetworkClient: NSObject, URLSessionDelegate {
    typealias NetworkResponse = (Data?, URLResponse?)
    internal var session: URLSession!
    
    static let shared = HTTPNetworkClient()
    
    private let defaultErrorMessage = "Sorry something went wrong. Please try again later."
    
    private override init() {
        super.init()
        
        // Configuration for requests
        let configuration = URLSessionConfiguration.ephemeral
        configuration.timeoutIntervalForRequest = 15.0
        configuration.urlCache = nil

        // Create and initialise url session
        let newSession = URLSession(configuration: configuration, delegate: self, delegateQueue: nil)
        self.session = newSession
    }
    
    func preloadUserProfile(with token: String, for environment: AlternatorEnvironment) async throws -> String {
        guard let profileURL = URL(string: environment.profileURL) else {
            debugPrint("[Alternator] Prolife URL incorrect")
            throw SecurityServiceError.other(message: "Sorry the service is currently unavailable. Please try again later.")
        }
        
        var request = URLRequest(url: profileURL)
        // Method
        request.httpMethod = "POST"
        // Headers
        request.setValue("application/json", forHTTPHeaderField: "Content-Type")
        // Body
        var body: Dictionary<String, String> = ["platform": "ios",
                                                "token": token]
        if let appBundle = Bundle.main.bundleIdentifier {
            body["app_id"] = appBundle
        }
        request.httpBody = body.jsonData
        // Handle request
        let response = try await self.callAPI(with: request)
        
        if let data = try self.checkHTTPStatus(for: response) {
            if let stringData = String(data: data, encoding: .utf8) {
                debugPrint("[Alternator] Coulnd't parse data from request: \(request.url?.absoluteString ?? "")")
                return stringData
            }
        }
        
        throw SecurityServiceError.other(message: self.defaultErrorMessage)
    }
    
    private func callAPI(with request: URLRequest) async throws -> NetworkResponse {
        return try await Task.retrying(maxRetryCount: 2) {
            let result = try await self.session.data(for: request)
            return result
        }.value
    }
    
    private func checkHTTPStatus(for networkResponse: NetworkResponse) throws -> Data? {
        guard let response = networkResponse.1 else {
            throw SecurityServiceError.other(message: self.defaultErrorMessage)
        }
        
        guard let urlResponse =  response as? HTTPURLResponse else {
            debugPrint("[Alternator] Trying to check status code, but HTTPURLResponse reponse was not provided")
            throw SecurityServiceError.other(message: self.defaultErrorMessage)
        }
        
        let data = networkResponse.0
        
        switch urlResponse.statusCode {
        case 200...299:
            return data
        case 400...500:
            var message = self.defaultErrorMessage
            if let data = data, let serverErrorMessage = String(bytes: data, encoding: .utf8) {
                message = serverErrorMessage
            }
            
            throw SecurityServiceError.other(message: message)
            
        default:
            debugPrint("[Alternator] Unhandeled HTTP response.statusCode: \(urlResponse.statusCode)")
            throw SecurityServiceError.other(message: self.defaultErrorMessage)
        }
    }
}

/// https://www.swiftbysundell.com/articles/retrying-an-async-swift-task/
extension Task where Failure == Error {
    
    @discardableResult
    static func retrying(
        priority: TaskPriority? = nil,
        maxRetryCount: Int = 3,
        retryDelay: TimeInterval = 1,
        operation: @Sendable @escaping () async throws -> Success
    ) async -> Task {
        Task(priority: priority) {
            for _ in 0..<maxRetryCount {
                do {
                    return try await operation()
                } catch {
                    let halfSecond = TimeInterval(500_000_000)
                    let delay = UInt64(halfSecond * retryDelay)
                    try await Task<Never, Never>.sleep(nanoseconds: delay)
                    
                    continue
                }
            }
            
            try Task<Never, Never>.checkCancellation()
            return try await operation()
        }
    }
}
