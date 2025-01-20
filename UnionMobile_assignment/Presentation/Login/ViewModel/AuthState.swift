//
//  AuthState.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/20/25.
//

import SwiftUI

class AuthState: ObservableObject {
    @Published var isLoggedIn = false
    @Published var userId: String = "" 
    
    func logout() {
        isLoggedIn = false
    }
}
