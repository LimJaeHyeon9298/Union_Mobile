//
//  NetworkError.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import Foundation

enum NetworkError:LocalizedError {
    case invalidRequest
    case invalidResponse
    case unauthorized(APIErrorResponse)
    case notFound(APIErrorResponse)
    case badRequest(APIErrorResponse)
    case conflict(APIErrorResponse)
    case serverError(statusCode:Int)
    case decodingError(Error)
    
    var errorDescription: String? {
        switch self {
        case .notFound(let response):
            return "Not Found: \(response.errorMessage) (Code: \(response.errorCode))"
        case .badRequest(let response):
            return "Bad Request: \(response.errorMessage) (Code: \(response.errorCode))"
        case .unauthorized(let response):
            return "Unauthorized: \(response.errorMessage) (Code: \(response.errorCode))"
        case .conflict(let response):
            return "Conflict: \(response.errorMessage) (Code: \(response.errorCode))"
        default : return nil
            
        }
    }
    
}

struct APIErrorResponse: Decodable {
    let errorCode: String
    let errorMessage: String
}
