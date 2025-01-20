//
//  MainViewModel.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI

final class MainViewModel: ObservableObject {
    private let voteUseCase: VoteUseCase
    @Published private(set) var candidates: [CandidateList.Item] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    
    init(voteUseCase: VoteUseCase) {
        self.voteUseCase = voteUseCase
    }
    
    @MainActor
    func fetchCandidates() {
        guard !isLoading else {return}
        
        isLoading = true
        error = nil
        
        Task {
            do {
                let result = try await voteUseCase.getCandidateList(
                    page: 0,
                    size: 10,
                    sort: ["name,ASC"]
                )
                self.candidates = result.items
                print("candidate \(candidates)")
            } catch {
                self.error = error
            }
            isLoading = false
        }
    }
}

#if DEBUG
extension MainViewModel {
    func setLoadingState() {
        isLoading = true
        candidates = []
        error = nil
    }
    
    func setEmptyState() {
        isLoading = false
        candidates = []
        error = nil
    }
    
    func setErrorState() {
        isLoading = false
        candidates = []
        error = NetworkError.serverError(statusCode: 500)
    }
}
#endif
