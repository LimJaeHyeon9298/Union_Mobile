//
//  NetworkService.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//
import Foundation

final class NetworkService {
    private let baseURL = "https://api-wmu-dev.angkorcoms.com"
    private let session: URLSession
    
    init(session: URLSession = .shared) {
        self.session = session
    }
    
    //MARK: - 투표 API
    func request(_ endPoint:VoteEndPoint) async throws {
        guard let request = try? endPoint.makeRequest(baseURL: baseURL) else {
            throw NetworkError.invalidRequest
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        print(httpResponse.statusCode,"statusCode----")
        switch httpResponse.statusCode {
        case 200...299:
            return
        case 400, 401, 404, 409:
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            switch httpResponse.statusCode {
            case 400: throw NetworkError.badRequest(errorResponse)
            case 401: throw NetworkError.unauthorized(errorResponse)
            case 404: throw NetworkError.notFound(errorResponse)
            case 409: throw NetworkError.conflict(errorResponse)
            default: throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
    
    //MARK: - 후보자 id로 후보자 상세정보 조회 API
    
    func get<T: Decodable>(_ endpoint: VoteEndPoint) async throws -> T {
        guard let request = try? endpoint.makeRequest(baseURL: baseURL) else {
            throw NetworkError.invalidRequest
        }
        
        let (data, response) = try await session.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse else {
            throw NetworkError.invalidResponse
        }
        
        switch httpResponse.statusCode {
        case 200...299:
            return try JSONDecoder().decode(T.self, from: data)
        case 400, 401, 404, 409:
            let errorResponse = try JSONDecoder().decode(APIErrorResponse.self, from: data)
            switch httpResponse.statusCode {
            case 400: throw NetworkError.badRequest(errorResponse)
            case 401: throw NetworkError.unauthorized(errorResponse)
            case 404: throw NetworkError.notFound(errorResponse)
            case 409: throw NetworkError.conflict(errorResponse)
            default: throw NetworkError.serverError(statusCode: httpResponse.statusCode)
            }
        default:
            throw NetworkError.serverError(statusCode: httpResponse.statusCode)
        }
    }
}
