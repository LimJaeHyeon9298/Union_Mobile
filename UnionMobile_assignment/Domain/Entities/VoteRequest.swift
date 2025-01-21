//
//  VoteRequest.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import Foundation

struct VoteRequest {
    let userId: String
    let candidateId: Int
    
    var isValid: Bool {
        guard userId.count <= 16 && !userId.isEmpty else {return false}
        
        guard userId.trimmingCharacters(in: .whitespaces).isEmpty == false else { return false }
            
        let allowedCharacters = CharacterSet.alphanumerics
        guard userId.unicodeScalars.allSatisfy({ allowedCharacters.contains($0) }) else { return false }
        
        return candidateId >= 1
    }
}
    
