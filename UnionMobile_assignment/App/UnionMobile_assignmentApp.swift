//
//  UnionMobile_assignmentApp.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI
import SwiftData

@main
struct UnionMobile_assignmentApp: App {

    private let networkService = NetworkService()
    private let voteRepository: VoteRepository
    private let voteUseCase: VoteUseCase
    private let mainViewModel: MainViewModel
        
    init() {
        voteRepository = VoteRepositoryImplements(networkService: networkService)
        voteUseCase = VoteUseCase(repository: voteRepository)
        mainViewModel = MainViewModel(voteUseCase: voteUseCase)
    }
    
    var sharedModelContainer: ModelContainer = {
        let schema = Schema([
            Item.self,
        ])
        let modelConfiguration = ModelConfiguration(schema: schema, isStoredInMemoryOnly: false)

        do {
            return try ModelContainer(for: schema, configurations: [modelConfiguration])
        } catch {
            fatalError("Could not create ModelContainer: \(error)")
        }
    }()

    var body: some Scene {
        WindowGroup {
            MainView(viewModel: mainViewModel)
           // PerformanceTestView(candidates: <#[CandidateList.Item]#>)
        }
        .modelContainer(sharedModelContainer)
    }
}
