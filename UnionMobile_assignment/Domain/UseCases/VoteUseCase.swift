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
    
    func getCandidate(id: Int, userId: String) async throws -> Candidate {
        return try await repository.getCandidate(id: id, userId: userId)
    }
}
