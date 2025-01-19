//
//  CandidateResponseDTO.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import Foundation

struct CandidateResponseDTO: Decodable {
    let id: Int
    let candidateNumber: Int
    let name: String
    let country: String
    let education: String
    let major: String
    let hobby: String
    let talent: String
    let ambition: String
    let contents: String
    let profileInfoList: [ProfileInfoDTO]
    let regDt: String
    let voted: Bool
}

struct ProfileInfoDTO: Decodable {
    let fileArea: Int
    let displayOrder: Int
    let profileUrl: String
    let mimeType: String
}

struct Candidate {
    let id: Int
    let number: Int
    let name: String
    let country: String
    let hobby: String
    let talent: String
    let ambition: String
    let contents: String
    let profile: CandidateProfile
    let regDt: String
    let isVoted: Bool
    
    struct CandidateProfile {
        let education: String
        let major: String
        let images: [ProfileImage]
    }
    
    struct ProfileImage {
        let url: URL
        let order: Int
        let fileArea: Int
        let mimeType: String
    }
}

extension CandidateResponseDTO {
    func toDomain() -> Candidate {
        return Candidate(
            id: id,
            number: candidateNumber,
            name: name,
            country: country,
            hobby: hobby,
            talent: talent,
            ambition: ambition,
            contents: contents,
            profile: .init(
                education: education,
                major: major,
                images: profileInfoList.map { info in
                    Candidate.ProfileImage(
                        url: URL(string: info.profileUrl)!,
                        order: info.displayOrder,
                        fileArea: info.fileArea,
                        mimeType: info.mimeType
                    )
                }
            ),
            regDt: regDt,
            isVoted: voted
        )
    }
}
