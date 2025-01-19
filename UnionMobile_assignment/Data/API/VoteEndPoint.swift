//
//  VoteEndPoint.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//
import Foundation

enum VoteEndPoint {
    case submitVote(request: VoteRequest)
    case getCandidate(id:Int,userId: String)
    case getVotedCandidates(userId: String)
    case getCandidateList(page: Int, size: Int, sort: [String], searchKeyword: String?)
    
    
    func makeRequest(baseURL: String) throws -> URLRequest {
        switch self {
        case .submitVote(let request):
            let url = URL(string: baseURL + "/vote")!
            var urlRequest = URLRequest(url: url)
            urlRequest.httpMethod = "POST"
            urlRequest.setValue("application/json", forHTTPHeaderField: "Content-Type")
            
            let dto = VoteRequestDTO(userId: request.userId, id: request.candidateId)
            urlRequest.httpBody = try JSONEncoder().encode(dto)
            
            return urlRequest
        case .getCandidate(id: let id, userId: let userId):
            var components = URLComponents(string: baseURL + "/vote/candidate/\(id)")!
            components.queryItems = [
                URLQueryItem(name: "userId", value: userId)
            ]
            
            guard let url = components.url else {
                throw NetworkError.invalidRequest
            }
            
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        case .getVotedCandidates(let userId):
            var components = URLComponents(string: baseURL + "/vote/voted/candidate/list")!
            components.queryItems = [
                URLQueryItem(name: "userId", value: userId)
            ]
                   
            guard let url = components.url else {
                throw NetworkError.invalidRequest
            }
                   
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        case .getCandidateList(let page, let size, let sort, let searchKeyword):
            var components = URLComponents(string: baseURL + "/vote/candidate/list")!
                   
            var queryItems = [
                URLQueryItem(name: "page", value: String(page)),
                URLQueryItem(name: "size", value: String(size))
            ]
                   
            // 정렬 조건 추가
            sort.forEach { sortItem in
                queryItems.append(URLQueryItem(name: "sort", value: sortItem))
            }
                   
            // 검색어가 있는 경우 추가
            if let keyword = searchKeyword {
                queryItems.append(URLQueryItem(name: "searchKeyword", value: keyword))
            }
                   
            components.queryItems = queryItems
                   
            guard let url = components.url else {
                throw NetworkError.invalidRequest
            }
                   
            var request = URLRequest(url: url)
            request.httpMethod = "GET"
            return request
        }
    }
}

