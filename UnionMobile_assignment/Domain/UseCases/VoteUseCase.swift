//
//  VoteUseCase.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//


final class VoteUseCase {
    private let repository: VoteRepository
    
    init(repository: VoteRepository) {
        self.repository = repository
    }
    
    func vote(request: VoteRequest) async throws {
        return try await repository.submitVote(request)
    }
    
    func getCandidate(id: Int, userId: String) async throws -> Candidate {
        return try await repository.getCandidate(id: id, userId: userId)
    }
    
    func getVotedCandidates(userId: String) async throws -> [Int] {
        return try await repository.getVotedCandidates(userId: userId)
    }
    
    func getCandidateList(page: Int = 0,
                          size: Int = 10,
                          sort: [String] = [],
                          searchKeyword: String? = nil) async throws -> CandidateList {
            return try await repository.getCandidateList(
                page: page,
                size: size,
                sort: sort,
                searchKeyword: searchKeyword
            )
        }
}
