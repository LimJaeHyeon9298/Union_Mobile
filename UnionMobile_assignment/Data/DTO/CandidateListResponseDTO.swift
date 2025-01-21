//
//  CandidateListResponseDTO.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//


struct CandidateListResponseDTO: Decodable {
    let content: [CandidateListItemDTO]
    let pageable: PageableDTO
    let totalPages: Int
    let totalElements: Int
    let last: Bool
    let size: Int
    let number: Int
    let sort: SortDTO
    let numberOfElements: Int
    let first: Bool
    let empty: Bool
}

struct CandidateListItemDTO: Decodable {
    let id: Int
    let candidateNumber: Int
    let name: String
    let profileUrl: String
    let voteCnt: String
}

struct PageableDTO: Decodable {
    let sort: SortDTO
    let offset: Int
    let pageNumber: Int
    let pageSize: Int
    let paged: Bool
    let unpaged: Bool
}

struct SortDTO: Decodable {
    let empty: Bool
    let sorted: Bool
    let unsorted: Bool
}

struct CandidateListRequestDTO {
    let page: Int
    let size: Int
    let sort: [String]
    let searchKeyword: String?
}
