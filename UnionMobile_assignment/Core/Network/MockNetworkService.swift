//
//  MockNetworkService.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/21/25.
//

import SwiftUI

class MockNetworkService: NetworkServiceForTest {
    var requestCount = 0
    var mockResponse: Any?
    var mockError: Error?
    var shouldFail = false
    var delayResponse = false
    
    override func request(_ endpoint: VoteEndPoint) async throws {
        requestCount += 1
        
        if delayResponse {
            try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
        }
        
        if shouldFail {
            if let networkError = mockError as? NetworkError {
                throw networkError
            } else {
                throw NetworkError.serverError(statusCode: 500)
            }
        }
    }
    
    override func get<T: Decodable>(_ endpoint: VoteEndPoint) async throws -> T {
        requestCount += 1
        
        if delayResponse {
            try await Task.sleep(nanoseconds: UInt64(2 * 1_000_000_000))
        }
        
        if shouldFail {
            if let networkError = mockError as? NetworkError {
                throw networkError
            } else {
                throw NetworkError.serverError(statusCode: 500)
            }
        }
        
        guard let response = mockResponse as? T else {
            throw NetworkError.serverError(statusCode: 500)
        }
        
        return response
    }
}

// MARK: - Helper methods for testing
extension MockNetworkService {
    func setMockResponse<T: Encodable>(_ response: T) {
        self.mockResponse = response
    }
    
    func simulateError(_ error: NetworkError) {
        self.shouldFail = true
        self.mockError = error
    }
    
    func simulateNetworkDelay() {
        self.delayResponse = true
    }
    
    func reset() {
        requestCount = 0
        mockResponse = nil
        mockError = nil
        shouldFail = false
        delayResponse = false
    }
}
