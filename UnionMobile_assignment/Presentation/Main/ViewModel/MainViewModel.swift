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
    @Published private(set) var votedCandidates: [Int] = []
    @Published private(set) var isLoading = false
    @Published private(set) var error: Error?
    @Published private(set) var showMaxVotesAlert = false
    var currentTask: Task<Void, Never>?
    // 테스트를 위해 30초로 설정
     private let cacheValidityDuration: TimeInterval = 30
     private var lastFetchTime: Date?
    

    init(voteUseCase: VoteUseCase) {
        self.voteUseCase = voteUseCase
    }

    @MainActor
    func fetchCandidates(forceRefresh: Bool = false, userId:String) async {
        // 진행 중인 작업이 있다면 취소
        currentTask?.cancel()
        
        // 새로운 작업 시작
        currentTask = Task { @MainActor in
            if !forceRefresh,
               let lastFetch = lastFetchTime,
               !candidates.isEmpty {
                let timeSinceLastFetch = Date().timeIntervalSince(lastFetch)
                if timeSinceLastFetch < cacheValidityDuration {
                    print("캐시가 아직 유효함 - API 호출 스킵")
                    return
                }
                print("캐시 만료됨 - 새로운 데이터 fetch 시작")
            }
            
            guard !isLoading else { return }
            
            isLoading = true
            error = nil
            
            do {
                print("API 호출 시작")
                let result = try await voteUseCase.getCandidateList(
                    page: 0,
                    size: 10,
                    sort: ["name,ASC"]
                )
                
                if !Task.isCancelled {
                    self.candidates = result.items
                    self.lastFetchTime = Date()
                    try await self.checkUserVoted(userId: userId)
                    print("API 호출 완료 - 받은 데이터 수: \(result.items.count)")
//                    print("API 호출 완료 - 받은 데이터 목록: \(result.items)")
                    
                }
            } catch {
                if !Task.isCancelled {
                    self.error = error
                    print("API 호출 실패: \(error.localizedDescription)")
                }
            }
            
            isLoading = false
        }
        
        await currentTask?.value
    }
    
    func submitVote(request: VoteRequest) async throws {
        do {
            try await voteUseCase.vote(request: request)
            try await checkUserVoted(userId: request.userId)
        } catch let error as NetworkError {
            if case .badRequest(let apiError) = error, apiError.errorCode == "2005" {
                await MainActor.run {
                    self.showMaxVotesAlert = true
                }
            }
            throw error
        }
    }
    @MainActor
    func checkUserVoted(userId: String) async throws {
        let results = try await voteUseCase.getVotedCandidates(userId: userId)
        self.votedCandidates = results
        print("이미 투표한 id \(results)")
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
