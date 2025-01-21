//
//  VotedCandidatesResponseDTO.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

struct VotedCandidatesResponseDTO:Decodable {
    let votedIds: [Int]
    
    init(from decoder: Decoder) throws {
        let container = try decoder.singleValueContainer()
        votedIds = try container.decode([Int].self)
    }
    
}
