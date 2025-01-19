//
//  CandidateCardView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/19/25.
//

import SwiftUI

struct CandidateCardView: View {
    let width: CGFloat
    let candidateId: Int
    
    var body: some View {
        NavigationLink(destination: CandidateDetailView(candidateId: candidateId)) {
            VStack(spacing: 8) {
                Image(systemName: "book")
                    .resizable()
                    .scaledToFit()
                    .background(.blue)
                    .frame(width: width - 24, height: width - 24)
                    .clipShape(RoundedRectangle(cornerRadius: 8))
                
                Text("임재현")
                    .font(.kantumruyPro(size: 16, family: .semiBold))
                    .foregroundStyle(.white)
                    .padding(.top, 8)
                
                Text("1200 votes")
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
                ForEach(hi, id: \.self) { index in
                    CandidateCardView(width: itemWidth,candidateId: index)
                }
            }
            .padding(.horizontal, 16)
        }
        .frame(height: CGFloat(hi.count) * 320 / 2)
    }
}

