//
//  MainView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI

struct MainView: View {
    @State private var showingPerformanceTest = false
    
    @StateObject var viewModel: MainViewModel
    
       init(viewModel: MainViewModel) {
           _viewModel = StateObject(wrappedValue: viewModel)
       }
    
    var body: some View {
        NavigationStack {
            ScrollView {
                VStack {
                    Text("World MISS UNIVERSITY")
                        .font(.kantumruyPro(size: 32, family: .semiBold))
                        .foregroundStyle(.white)
                        .padding(.top,40)
                        .padding(.horizontal,8)
                    
                    Text("CAMBODIA 2024")
                        .font(.kantumruyPro(size: 24, family: .medium))
                        .padding(.top, 0)
                        .foregroundStyle(.white)
                    
                    Image(systemName: "crown.circle")
                        .resizable()
                        .background(.red)
                        .frame(width: 230,height: 230)
                    
                    Text("Cast your vote for the brightest candidate!\n World Miss University voting starts soon !")
                        .font(.kantumruyPro(size: 14, family: .semiBold))
                        .foregroundStyle(.white)
                        .padding(.top, 8)
                    
                    
                    CountdownTimerView(targetDate: Calendar.current.date(
                            from: DateComponents(
                            year: 2025,
                            month: 2,
                            day: 5
                        )
                    ) ?? Date())
                    .padding(.top, 8)
                    
                    VStack(alignment: .leading) {
                        HStack {
                            Text("WORLD MISS UNIVERSITY")
                                .font(.kantumruyPro(size: 14, family: .semiBold))
                                .foregroundStyle(.blue)
                            
                            Spacer()
                        }
                        .padding(.leading, 20)
                        
                        HStack {
                            Text("Moblie Voting \nInformation")
                                .font(.kantumruyPro(size: 24, family: .semiBold))
                                .foregroundStyle(.white)
                                
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top, 8)
                        
                        HStack {
                            Text("2024 World Miss University brings \ntogether future global leaders who embody both \nbeauty and intellect")
                                .font(.kantumruyPro(size: 14, family: .semiBold))
                                .foregroundStyle(.white)
                                
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top, 12)
                        
                        
                    }
                    .padding(.top, 16)
                    .background(.black)
                    
                    VStack(spacing: 0) {
                        // 첫 번째 행: Period
                        HStack {
                            Text("Period")
                                .font(.kantumruyPro(size: 13, family: .bold))
                                .padding(.leading, 8)
                            Spacer()
                            Text("10/17(Thu) 12PM ~ 10/31(Thu) 6PM")
                                .font(.kantumruyPro(size: 13, family: .bold))
                                .padding(.trailing, 8)
                        }
                        .frame(height: 43)
                        .background(.brown)
                        .padding(.horizontal, 20)
                        .padding(.top, 8)
                        
                        Divider()
                            .frame(height: 1)
                            .background(Color.gray)
                            .padding(.horizontal, 20)
                        
                        HStack(alignment: .top) {
                            Text("How to vote")
                                .font(.kantumruyPro(size: 13, family: .bold))
                                .foregroundStyle(.white)
                                .padding(.leading, 8)
                                .padding(.top, 8)
                            Spacer()
                            VStack(alignment: .leading, spacing: 8) {
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .foregroundStyle(.white)
                                    Text("Up to three people can \nparticipate in early voting per \nday.")
                                        .font(.kantumruyPro(size: 13, family: .semiBold))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.leading)
                                }
                                HStack(alignment: .top, spacing: 4) {
                                    Text("•")
                                        .foregroundStyle(.white)
                                    Text("Three new voting tickets are \nissued every day at midnight \n(00:00), and you can vote anew \nevery day during the early voting \nperiod.")
                                        .font(.kantumruyPro(size: 13, family: .semiBold))
                                        .foregroundStyle(.white)
                                        .multilineTextAlignment(.leading)
                                }
                                
                            }
                            .padding(.trailing, 8)
                            .padding(.top, 8)
                        }
                        .frame(minHeight: 80)
                        .background(.brown)
                        .padding(.horizontal, 20)
                    }
                    .padding(.top, 12)
                    .background(.black)
                    
                    VStack(alignment: .leading) {
                        Divider()
                            .frame(width: 20,height: 3)
                            .background(Color.blue)
                            .padding(.leading, 20)
                            
                        
                        HStack {
                            Text("2024 \nCandidate List")
                                .font(.kantumruyPro(size: 24, family: .semiBold))
                                .foregroundStyle(.white)
                            
                            Spacer()
                            
                        }
                        .padding(.leading, 20)
                        
                        HStack {
                            Text("※ You can vote for up to 3 candidates")
                                .font(.kantumruyPro(size: 14, family: .regular))
                                .foregroundStyle(.white)
                            Spacer()
                        }
                        .padding(.leading, 20)
                        .padding(.top,8)
                        
                    }
                    .padding(.top, 16)
                    .background(.red)
                    

//            #if DEBUG
//               // 테스트용 버튼들
//               HStack {
//                   Button("로딩 상태") {
//                       viewModel.setLoadingState()
//                   }
//                   Button("빈 상태") {
//                       viewModel.setEmptyState()
//                   }
//                   Button("에러 상태") {
//                       viewModel.setErrorState()
//                   }
//               }
//               .padding()
//               #endif
                    
//                    Button("성능 테스트 실행") {
//                                   showingPerformanceTest = true
//                               }
                    
                    Group {
                        if viewModel.isLoading {
                            ProgressView()
                                .frame(maxWidth: .infinity, minHeight: 200)
                        } else if let error = viewModel.error {
                            VStack {
                                Text("데이터를 불러오는데 실패했습니다")
                                    .foregroundColor(.red)
                                Button("다시 시도") {
                                    viewModel.fetchCandidates()
                                }
                            }
                            .frame(maxWidth: .infinity, minHeight: 200)
                        } else if viewModel.candidates.isEmpty {
                            Text("후보자가 없습니다")
                                .frame(maxWidth: .infinity, minHeight: 200)
                                .foregroundStyle(.white)
                        } else {
                            CandidateGridView(candidates: viewModel.candidates)
                                .background(.black)
                                .padding(.top, 16)
                        }
                    }
                    
                    Text("© 2024 World Miss University. All rights reserved.")
                        .font(.kantumruyPro(size: 12, family: .bold))
                        .foregroundStyle(.white)
                        .padding(.vertical, 24)
                     
                    
                    
                    

                }
//                .sheet(isPresented: $showingPerformanceTest) {
//                           PerformanceTestView(candidates: viewModel.candidates)
//                       }
                .frame(maxWidth: .infinity)
            }
            .onAppear {
                viewModel.fetchCandidates()
            }
            .refreshable {
                await viewModel.fetchCandidates()
            }
            
            
            .frame(maxWidth: .infinity)
            
            .background(.black)
            .toolbar {
                ToolbarItem(placement: .principal) {
                    Text("2024 WMU")
                        .foregroundStyle(.black)
                }
            }
            .navigationBarTitleDisplayMode(.inline)
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }
}

//#Preview {
//    MainView()
//}




