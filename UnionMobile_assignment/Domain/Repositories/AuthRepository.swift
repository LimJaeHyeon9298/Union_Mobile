//
//  AuthRepository.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/20/25.
//

import SwiftUI

protocol AuthRepository {
    func login(userId: String) async throws -> Bool
    func logout() async throws
}

class AuthRepositoryImplements: AuthRepository {
    private let networkService: NetworkServiceProtocol
    
    init(networkService: NetworkServiceProtocol) {
        self.networkService = networkService
    }
    
    func login(userId: String) async throws -> Bool {
        return true
    }
    
    func logout() async throws {
      
    }
}
