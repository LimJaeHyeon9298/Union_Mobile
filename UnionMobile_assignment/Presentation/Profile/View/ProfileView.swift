//
//  ProfileView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI
import Combine


struct CandidateDetailView: View {
    let candidateId: CandidateList.Item  // 후보자 ID
    @StateObject private var viewModel: CandidateDetailViewModel
    let container: DIContainer
    @Environment(\.dismiss) private var dismiss
    @State private var showAlreadyVotedAlert = false
    @State private var showMaxVotesAlert = false
    @State private var showVoteSuccessAlert = false
    @EnvironmentObject var authState: AuthState
    
    init(candidateId: CandidateList.Item,container:DIContainer) {
        self.candidateId = candidateId
        self.container = container
        _viewModel = StateObject(wrappedValue: container.makeCandidateDetailViewModel(basicInfo: candidateId))
        }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 프로필 이미지
                if let detail = viewModel.candidateDetail {
                    ImagePagerView(imageUrls: detail.profile.images.sorted(by: { $0.order < $1.order }).map(\.url))
                } else {
                    ProgressView()
                        .frame(height: 300)
                }
                
                VStack(alignment: .leading, spacing: 16) {
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text("\(candidateId.name)")
                            .font(.kantumruyPro(size: 24, family: .semiBold))
                            .foregroundStyle(.white)
                        
                        
                        if let detail = viewModel.candidateDetail {
                            Text("Entry No.\(detail.number)")
                                .font(.kantumruyPro(size: 16, family: .regular))
                                .foregroundStyle(.blue)
                        } else {
                            ProgressView()
                                .frame(height: 20)
                        }
                    }
                    
                    if let detail = viewModel.candidateDetail {
                        VStack(alignment: .leading, spacing: 12) {
                            ProfileSectionRow(title: "Education", value: detail.profile.education)
                                .padding(.top, 8)
                            ProfileSectionRow(title: "Major", value: "\(detail.profile.major)")
                            ProfileSectionRow(title: "Hobbies", value: detail.hobby)
                            ProfileSectionRow(title: "Talent", value: detail.talent)
                            ProfileSectionRow(title: "Ambition", value: detail.ambition)
                        }
                        .background(Color("252525"))
                        .padding(.top, 8)
                    } else {
                        VStack {
                            ProgressView()
                                .frame(height: 200)
                        }
                        .frame(maxWidth: .infinity)
                        .background(.red)
                    }
                    
                    HStack {
                        Spacer()
                        Text("© 2024 World Miss University. All rights reserved.")
                            .font(.kantumruyPro(size: 12, family: .bold))
                            .foregroundStyle(.white)
                            .padding(.vertical, 24)
                            .padding(.horizontal, 20)
                        Spacer()
                    }
                    
                    // 투표 버튼
                    Button {
                        print("Vote tapped")
                        if viewModel.candidateDetail?.isVoted == true {
                            showAlreadyVotedAlert = true
                        } else {
                            print("Vote tapped")
                            Task {
                                let request = VoteRequest(userId: authState.userId, candidateId: candidateId.id)
                                print("\(authState.userId) VoteRequest-Vote tapped")
                                do {
                                    try await viewModel.submitVote(request: request)
                                    // 투표 후 상세 정보 다시 불러오기
                                    viewModel.fetchCandidateDetail(userId: authState.userId)
                                    showVoteSuccessAlert = true
                                } catch let error  {
                                    if case NetworkError.badRequest(let apiError) = error,
                                       apiError.errorCode == "2005" {
                                     
                                       showMaxVotesAlert = true
                                    }
                                    print("투표 실패: \(error)")
                                }
                            }
                        }
                    } label: {
                        Text(viewModel.candidateDetail?.isVoted == true ? "Voted" : "Vote")
                            .font(.kantumruyPro(size: 16, family: .semiBold))
                            .foregroundStyle(viewModel.candidateDetail?.isVoted == true ? .blue : .white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(viewModel.candidateDetail?.isVoted == true ? Color.white : Color.blue)
                            )
                    }
                    .padding(.top, 24)
                }
                .padding(.horizontal, 20)
            }
            .alert("이미 투표한 후보자입니다!", isPresented: $showAlreadyVotedAlert) {
                       Button("확인", role: .cancel) { }
                   } message: {
                       Text("다른 후보자에게 투표해주세요.")
                   }
            .alert("투표 제한", isPresented: $showMaxVotesAlert) {
                        Button("확인", role: .cancel) { }
                    } message: {
                        Text("투표는 3명까지 제한됩니다! 다음 기회에 투표해주세요.")
                    }
            
            .alert("투표 완료", isPresented: $showVoteSuccessAlert) {  // 추가
                        Button("확인", role: .cancel) { }
                    } message: {
                        Text("\(candidateId.name)님께 투표가 완료되었습니다.")
                    }
            .onAppear {
                viewModel.fetchCandidateDetail(userId: authState.userId)
            }
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                        .foregroundStyle(.black)
                }
            }
            ToolbarItem(placement: .principal) {
                Text("2024 WMU")
                    .foregroundStyle(.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
//        .toolbarBackground(.white, for: .navigationBar)
//        .toolbarBackground(.visible, for: .navigationBar)
//        .toolbarColorScheme(.light, for: .navigationBar)
        .modifier(NavigationBarModifier())
        
        
        .background(.black)
    }
}

struct NavigationBarModifier: ViewModifier {
    func body(content: Content) -> some View {
        if #available(iOS 16.0, *) {
            content
                .toolbarBackground(.white, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
        } else {
            content
                .onAppear {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = .white
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().compactAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
        }
    }
}



// 정보 행 컴포넌트
struct InfoRow: View {
    let title: String
    let value: String
    
    var body: some View {
        HStack {
            Text(title)
                .font(.kantumruyPro(size: 14, family: .regular))
                .foregroundStyle(.gray)
                .frame(width: 100, alignment: .leading)
            
            Text(value)
                .font(.kantumruyPro(size: 14, family: .medium))
                .foregroundStyle(.white)
        }
    }
}

struct ProfileSectionRow: View {
    let title: String
    let value: String
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            Text(title)
                .font(.kantumruyPro(size: 13, family: .bold))
                .foregroundStyle(.gray)
            
            Text(value)
                .font(.kantumruyPro(size: 16, family: .semiBold))
                .foregroundStyle(.white)
            
            Divider()
                .frame(height: 1)
                .background(Color.gray.opacity(0.3))
                .padding(.top, 8)
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 8)
        .frame(height: 60)
    }
}

struct ImagePagerView: View {
    let imageUrls: [URL]
    @State private var currentPage = 0
    @State private var timer: Timer.TimerPublisher
    @State private var timerCancellable: AnyCancellable?
    @Environment(\.scenePhase) private var scenePhase
    
    init(imageUrls: [URL]) {
        
        self.imageUrls = imageUrls
        self._timer = State(initialValue: Timer.publish(every: 3, on: .main, in: .common))
    }
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<imageUrls.count, id: \.self) { index in
                CachedAsyncImage(url: imageUrls[index],
                                 targetSize: CGSize(width: UIScreen.main.bounds.width, height: 300)
                               ) { image in
                                   image
                                       .resizable()
                                       .scaledToFill()
                               } placeholder: {
                                   ProgressView()
                               }
                               .frame(maxWidth: .infinity)
                               .frame(height: 300)
                               .clipped()
                               .tag(index)
            }
        }
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))
        .frame(height: 300)
        // 뷰가 나타날 때 타이머 시작
        .onAppear {
            startTimer()
        }
        // 뷰가 사라질 때 타이머 정리
        .onDisappear {
            stopTimer()
        }
        // 페이지 변경 시 타이머 리셋
        .onChange(of: currentPage) {  _ in
            resetTimer()
        }
        // 앱의 상태 변화 감지
        .onChange(of: scenePhase) {  newPhase in
            switch newPhase {
            case .active:
                startTimer()    // 앱이 활성화될 때 타이머 시작
            case .background, .inactive:
                stopTimer()     // 앱이 백그라운드나 비활성 상태일 때 타이머 정지
            @unknown default:
                break
            }
        }
    }
    
    private func startTimer() {
        print("타이머 시작")
        stopTimer()  // 기존 타이머가 있다면 정리
        timer = Timer.publish(every: 3, on: .main, in: .common)
        timerCancellable = timer.autoconnect().sink { _ in
            withAnimation {
                currentPage = (currentPage + 1) % imageUrls.count
            }
        }
    }
    
    private func stopTimer() {
        print("타이머 종료")
        timerCancellable?.cancel()
        timerCancellable = nil
    }
    
    private func resetTimer() {
        startTimer()
    }
}
