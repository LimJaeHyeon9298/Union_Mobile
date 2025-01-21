//
//  ProfileViewModel.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI

struct ProfileViewModel: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ProfileViewModel()
}

final class CandidateDetailViewModel: ObservableObject {
    private let voteUseCase: VoteUseCase
    @Published private(set) var candidateDetail: Candidate?
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var basicInfo: CandidateList.Item
    @EnvironmentObject var authState: AuthState
    
    init(voteUseCase: VoteUseCase, basicInfo: CandidateList.Item) {
        self.voteUseCase = voteUseCase
        self.basicInfo = basicInfo
    }
    
    @MainActor
        func submitVote(request: VoteRequest) async throws {
            try await voteUseCase.vote(request: request)
        }
    
    @MainActor
    func fetchCandidateDetail(userId: String) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let userId = userId
                let detail = try await voteUseCase.getCandidate(id: basicInfo.id, userId: userId)
                self.candidateDetail = detail
                print("CandidateDetails ---- \(candidateDetail)")
                print("\(userId) fetchCandidateDetail()- CandidateDetailViewModel")
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
