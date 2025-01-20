//
//  UnionMobile_assignmentApp.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI
import SwiftData

@main
struct UnionMobile_assignmentApp: App {
    
    let container = DIContainer()
    @StateObject private var authState = AuthState()

    var body: some Scene {
        WindowGroup {
            Group {
                if authState.isLoggedIn {
                    MainView(container: container)
                        .environmentObject(authState)
                } else {
                    LoginView(container: container)
                        .environmentObject(authState)
                }
            }
  
        }
    }
}
