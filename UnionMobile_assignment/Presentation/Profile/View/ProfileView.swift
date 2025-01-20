//
//  ProfileView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI
import Combine

struct ProfileView: View {
    var body: some View {
        Text(/*@START_MENU_TOKEN@*/"Hello, World!"/*@END_MENU_TOKEN@*/)
    }
}

#Preview {
    ProfileView()
}

struct CandidateDetailView: View {
    let candidateId: CandidateList.Item  // 후보자 ID
 //   @StateObject private var viewModel: CandidateDetailViewModel
    let sampleImages = ["book", "person", "star", "heart"]
    @Environment(\.dismiss) private var dismiss
    
    init(candidateId: CandidateList.Item) {
            self.candidateId = candidateId
        }
    
    var body: some View {
        ScrollView {
            VStack(spacing: 16) {
                // 프로필 이미지
                ImagePagerView(images: sampleImages)
                
                VStack(alignment: .leading, spacing: 16) {

                    VStack(alignment: .leading, spacing: 4) {
                        Text("임재현\(candidateId)")
                            .font(.kantumruyPro(size: 24, family: .semiBold))
                            .foregroundStyle(.white)
                        
                        Text("Entry No.5")
                            .font(.kantumruyPro(size: 16, family: .regular))
                            .foregroundStyle(.blue)
                    }
                    
                    VStack(alignment: .leading, spacing: 12) {
                        ProfileSectionRow(title: "Name",value: "임재현")
                            .padding(.top,8)
                        ProfileSectionRow(title: "Age", value: "23")
                        ProfileSectionRow(title: "Height",value: "170cm" )
                        ProfileSectionRow( title: "University",value: "Seoul National University")
                        ProfileSectionRow(title: "Major",value: "Computer Science")
 
                    }
                    .background(.red)
                    .padding(.top, 8)
                    
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
                    } label: {
                        Text("Vote")
                            .font(.kantumruyPro(size: 16, family: .semiBold))
                            .foregroundStyle(.white)
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .background(
                                RoundedRectangle(cornerRadius: 25)
                                    .fill(Color.blue)
                            )
                    }
                    .padding(.top, 24)
                }
                .padding(.horizontal, 20)
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
        .toolbarBackground(.white, for: .navigationBar)
        .toolbarBackground(.visible, for: .navigationBar)
        .toolbarColorScheme(.light, for: .navigationBar)


        .background(.black)
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
    let images: [String]
    @State private var currentPage = 0
    @State private var timer: Timer.TimerPublisher
    @State private var timerCancellable: AnyCancellable?
    @Environment(\.scenePhase) private var scenePhase
    
    init(images: [String]) {
        self.images = images
        self._timer = State(initialValue: Timer.publish(every: 3, on: .main, in: .common))
    }
    
    var body: some View {
        TabView(selection: $currentPage) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(systemName: images[index])
                    .resizable()
                    .scaledToFill()
                    .frame(maxWidth: .infinity)
                    .frame(height: 300)
                    .clipped()
                    .background(.red)
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
        .onChange(of: currentPage) { _, _ in
            resetTimer()
        }
        // 앱의 상태 변화 감지
        .onChange(of: scenePhase) { _, newPhase in
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
                currentPage = (currentPage + 1) % images.count
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
