//
//  VoteRepository.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

protocol VoteRepository {
    func submitVote(_ request: VoteRequest) async throws
    func getCandidate(id: Int, userId: String) async throws -> Candidate
}

final class VoteRepositoryImplements: VoteRepository {
    private let networkService: NetworkService
    
    init(networkService: NetworkService) {
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
}
