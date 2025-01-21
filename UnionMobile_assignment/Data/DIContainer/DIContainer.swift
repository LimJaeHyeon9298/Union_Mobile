//
//  DIContainer.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/20/25.
//

import SwiftUI

final class DIContainer {
    // MARK: - Network Layer
    private let session: URLSession
    private let networkService: NetworkServiceProtocol
    
    // MARK: - Repository Layer
    private let voteRepository: VoteRepository
    private let authRepository: AuthRepository
    
    // MARK: - UseCase Layer
    private let voteUseCase: VoteUseCase
    private let authUseCase: AuthUseCase
    
    // MARK: - Initialization
    init(session: URLSession = .shared) {
        // Network Layer
        self.session = session
        self.networkService = NetworkService(session: session)
        
        // Repository Layer
        self.voteRepository = VoteRepositoryImplements(networkService: networkService)
        self.authRepository = AuthRepositoryImplements(networkService: networkService)
        
        // UseCase Layer
        self.voteUseCase = VoteUseCase(repository: voteRepository)
        self.authUseCase = AuthUseCase(repository: authRepository)
    }
    
    // 테스트용 초기화
       init(testNetworkService: NetworkServiceForTest) {
           // Network Layer
           self.session = .shared
           self.networkService = testNetworkService
           
           // Repository Layer
           self.voteRepository = VoteRepositoryImplements(networkService: testNetworkService)
           self.authRepository = AuthRepositoryImplements(networkService: testNetworkService)
           
           // UseCase Layer
           self.voteUseCase = VoteUseCase(repository: voteRepository)
           self.authUseCase = AuthUseCase(repository: authRepository)
       }
    
    // MARK: - ViewModel
    func makeMainViewModel() -> MainViewModel {
        return MainViewModel(voteUseCase: voteUseCase)
    }
    
    func makeCandidateDetailViewModel(basicInfo: CandidateList.Item) -> CandidateDetailViewModel {
        return CandidateDetailViewModel(voteUseCase: voteUseCase,basicInfo: basicInfo)
    }
    
    func makeLoginViewModel() -> LoginViewModel {
        return LoginViewModel(authUseCase: authUseCase)
    }
}

