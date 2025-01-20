//
//  CandidateCardView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/19/25.
//

import SwiftUI

struct CandidateCardView: View {
    let width: CGFloat
    let candidateId: CandidateList.Item
    @State private var loadingStartTime: Date?
    @State private var loadingTime: TimeInterval?
    @State private var loadCount = 0

    var body: some View {
        NavigationLink(destination: CandidateDetailView(candidateId: candidateId)) {
            VStack(spacing: 8) {
                
                let imageSize = CGSize(width: width - 24, height: width - 24)
//                    CachedAsyncImage(url: candidateId.profileUrl,targetSize: imageSize) { image in
//                        image
//                            .resizable()
//                            .scaledToFit()
//                            .frame(width: imageSize.width, height: imageSize.height)
//                        } placeholder: {
//                            ProgressView()
//                                .frame(width: imageSize.width, height: imageSize.height)
//                        }
//                        .clipShape(RoundedRectangle(cornerRadius: 8))
//
                
                CachedAsyncImage(url: candidateId.profileUrl, targetSize: imageSize) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .onAppear {
                            if let startTime = loadingStartTime {
                                loadingTime = Date().timeIntervalSince(startTime)
                                print("캐시 이미지 로딩 시간: \(loadingTime ?? 0)초")
                            }
                        }
                } placeholder: {
                    ProgressView()
                        .frame(width: imageSize.width, height: imageSize.height)
                        .onAppear {
                            
                            loadingStartTime = Date()
                        }
                }
                .clipShape(RoundedRectangle(cornerRadius: 8))
                
                .onAppear {
                    loadCount += 1
                    loadingStartTime = Date()
                }
                .onDisappear {
                    print("이미지 로드 횟수: \(loadCount)")
                }
                
                
                Text("\(candidateId.name)")
                    .font(.kantumruyPro(size: 16, family: .semiBold))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                
                Text("\(candidateId.voteCount)")
                    .font(.kantumruyPro(size: 14, family: .regular))
                    .foregroundStyle(.gray)
                
                Button {
                    print("hi")
                } label: {
                    Text("Voted")
                        .font(.kantumruyPro(size: 14, family: .semiBold))
                        .foregroundStyle(.gray)
                        .frame(width: width - 24, height: 36)
                        .background(
                            RoundedRectangle(cornerRadius: 18)
                                .fill(Color.blue)
                        )
                }
            }
            .padding(12)
            .frame(width: width)
            .background(Color.black)
        }
    }
}

struct CandidateGridView: View {
    var hi = [1,2,3,4,5,6,7,8,9,10]
    let candidates: [CandidateList.Item]
    
    let columns = [
        GridItem(.flexible(), spacing: 16),
        GridItem(.flexible(), spacing: 16)
    ]
    
    var body: some View {
  
        GeometryReader { geometry in
            let spacing: CGFloat = 16
            let numberOfColumns: CGFloat = 2
            let itemWidth = (geometry.size.width - spacing - 32) / numberOfColumns
            
            LazyVGrid(
                columns: columns,
                spacing: spacing
            ) {
                ForEach(candidates, id: \.id) { candidate in
                    CandidateCardView(width: itemWidth,candidateId: candidate)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: CGFloat(hi.count) * 320 / 2)
    }
}

struct ImageLoadingTestView: View {
    let isUsingCache: Bool
    @State private var loadingTimes: [TimeInterval] = []
    @State private var memoryUsage: [Double] = []
    let width: CGFloat
    let candidate: CandidateList.Item
    
    var body: some View {
        VStack {
            if isUsingCache {
                // 캐시 사용 버전
                CachedAsyncImage(
                    url: candidate.profileUrl,
                    targetSize: CGSize(width: width - 24, height: width - 24)
                ) { image in
                    image
                        .resizable()
                        .scaledToFit()
                        .frame(width: width - 24, height: width - 24)
                        .onAppear {
                            measurePerformance()
                        }
                } placeholder: {
                    ProgressView()
                }
            } else {
                // 기본 버전
                AsyncImage(url: candidate.profileUrl) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                    case .success(let image):
                        image
                            .resizable()
                            .scaledToFit()
                            .onAppear {
                                measurePerformance()
                            }
                    case .failure:
                        Image(systemName: "photo")
                    @unknown default:
                        Image(systemName: "photo")
                    }
                }
                .frame(width: width - 24, height: width - 24)
            }
            
            // 성능 지표 표시
            VStack(alignment: .leading) {
                Text("평균 로딩 시간: \(averageLoadingTime)ms")
                Text("평균 메모리 사용: \(averageMemoryUsage)MB")
            }
        }
    }
    
    private var averageLoadingTime: Double {
        loadingTimes.isEmpty ? 0 : loadingTimes.reduce(0, +) / Double(loadingTimes.count)
    }
    
    private var averageMemoryUsage: Double {
        memoryUsage.isEmpty ? 0 : memoryUsage.reduce(0, +) / Double(memoryUsage.count)
    }
    
    private func measurePerformance() {
        let startTime = Date()
        
        // 메모리 사용량 측정
        var info = mach_task_basic_info()
        var count = mach_msg_type_number_t(MemoryLayout<mach_task_basic_info>.size)/4
        let kerr: kern_return_t = withUnsafeMutablePointer(to: &info) {
            $0.withMemoryRebound(to: integer_t.self, capacity: 1) {
                task_info(mach_task_self_,
                         task_flavor_t(MACH_TASK_BASIC_INFO),
                         $0,
                         &count)
            }
        }
        
        if kerr == KERN_SUCCESS {
            let memoryUsageInMB = Double(info.resident_size) / 1024.0 / 1024.0
            memoryUsage.append(memoryUsageInMB)
        }
        
        // 로딩 시간 측정
        let timeInterval = Date().timeIntervalSince(startTime) * 1000 // milliseconds
        loadingTimes.append(timeInterval)
    }
}

struct PerformanceTestView: View {
    let candidates: [CandidateList.Item]
    
    var body: some View {
        VStack {
            Text("성능 비교 테스트")
                .font(.title)
            
            ScrollView {
                LazyVStack {
                    // 캐시 사용 버전
                    Section(header: Text("캐시 사용")) {
                        ForEach(candidates, id: \.id) { candidate in
                            ImageLoadingTestView(
                                isUsingCache: true,
                                width: UIScreen.main.bounds.width,
                                candidate: candidate
                            )
                        }
                    }
                    
                    // 기본 버전
                    Section(header: Text("기본 버전")) {
                        ForEach(candidates, id: \.id) { candidate in
                            ImageLoadingTestView(
                                isUsingCache: false,
                                width: UIScreen.main.bounds.width,
                                candidate: candidate
                            )
                        }
                    }
                }
            }
        }
    }
}
