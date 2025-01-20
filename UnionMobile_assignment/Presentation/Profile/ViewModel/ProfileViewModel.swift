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
    
    init(voteUseCase: VoteUseCase) {
        self.voteUseCase = voteUseCase
    }
    
    @MainActor
    func fetchCandidateDetail(id: Int) {
        guard !isLoading else { return }
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let userId = "some_user_id"
                let detail = try await voteUseCase.getCandidate(id: id, userId: userId)
                self.candidateDetail = detail
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}
