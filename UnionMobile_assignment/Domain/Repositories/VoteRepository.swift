//
//  VoteRepository.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

protocol VoteRepository {
    func submitVote(_ request: VoteRequest) async throws
    func getCandidate(id: Int, userId: String) async throws -> Candidate
    func getVotedCandidates(userId: String) async throws -> [Int]
    func getCandidateList(page: Int,size: Int,sort: [String],searchKeyword: String?) async throws -> CandidateList
}

final class VoteRepositoryImplements: VoteRepository {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func submitVote(_ request: VoteRequest) async throws {
        guard request.isValid else {
            throw NetworkError.invalidRequest
        }
        
        try await networkService.request(VoteEndPoint.submitVote(request: request))
    }
    
    func getCandidate(id: Int, userId: String) async throws -> Candidate {
        let dto: CandidateResponseDTO = try await networkService.get(VoteEndPoint.getCandidate(id: id, userId: userId))
        return dto.toDomain()
    }
    
    func getVotedCandidates(userId: String) async throws -> [Int] {
        let response: VotedCandidatesResponseDTO = try await networkService.get(VoteEndPoint.getVotedCandidates(userId: userId))
        return response.votedIds
    }
    
    func getCandidateList(page: Int,
                          size: Int,
                          sort: [String],
                          searchKeyword: String?) async throws -> CandidateList {
        let response: CandidateListResponseDTO = try await networkService.get(
            VoteEndPoint.getCandidateList(
                page: page,
                size: size,
                sort: sort,
                searchKeyword: searchKeyword
            )
        )
        return response.toDomain()
    }
}
