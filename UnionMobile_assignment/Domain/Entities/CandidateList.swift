//
//  CandidateList.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/19/25.
//

import Foundation

struct CandidateList {
    struct Item {
        let id: Int
        let number: Int
        let name: String
        let profileUrl: URL
        let voteCount: Int
    }
    
    let items: [Item]
    let currentPage: Int
    let totalPages: Int
    let totalElements: Int
    let isLastPage: Bool
    let isFirstPage: Bool
}

// DTO to Domain 매핑
extension CandidateListResponseDTO {
    func toDomain() -> CandidateList {
        return CandidateList(
            items: content.map { dto in
                CandidateList.Item(
                    id: dto.id,
                    number: dto.candidateNumber,
                    name: dto.name,
                    profileUrl: URL(string: dto.profileUrl)!,
                    voteCount: Int(dto.voteCnt) ?? 0
                )
            },
            currentPage: number,
            totalPages: totalPages,
            totalElements: totalElements,
            isLastPage: last,
            isFirstPage: first
        )
    }
}
