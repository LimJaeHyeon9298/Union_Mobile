//
//  LoginView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI

struct LoginView: View {
    @StateObject var viewModel: LoginViewModel
    @EnvironmentObject var authState: AuthState
    
    init(container: DIContainer) {
            _viewModel = StateObject(wrappedValue: container.makeLoginViewModel())
        }
    
    var body: some View {
        if #available(iOS 16.0, *) {
            NavigationStack {
                GeometryReader { geometry in
                    LoginContentView(viewModel: viewModel, geometry: geometry)
                }
                .toolbarBackground(.white, for: .navigationBar)
                .toolbarBackground(.visible, for: .navigationBar)
                .toolbarColorScheme(.light, for: .navigationBar)
            }
            
        } else {
            NavigationView {
                GeometryReader { geometry in
                    LoginContentView(viewModel: viewModel, geometry: geometry)
                }
                .navigationBarTitleDisplayMode(.inline)
                .background(.white)
                .onAppear {
                    let appearance = UINavigationBarAppearance()
                    appearance.configureWithOpaqueBackground()
                    appearance.backgroundColor = .white
                    UINavigationBar.appearance().standardAppearance = appearance
                    UINavigationBar.appearance().compactAppearance = appearance
                    UINavigationBar.appearance().scrollEdgeAppearance = appearance
                }
            }
        }

    }
}

struct LoginContentView: View {
    @ObservedObject var viewModel: LoginViewModel
    let geometry: GeometryProxy
    @State private var offset: CGFloat = 0
    
    var body: some View {
        VStack {
            HeaderView()
            LoginFormView(viewModel: viewModel)
            Spacer()
        }
        .onTapGesture {
            hideKeyboard()
        }
        .offset(y: offset)
        .frame(maxWidth: .infinity, maxHeight: .infinity)
        .background(.black)
        .edgesIgnoringSafeArea(.bottom)
        .setupKeyboardHandling(geometry: geometry, offset: $offset)
        .toolbar {
            ToolbarItem(placement: .principal) {
                Text("2024 WMU")
                    .foregroundStyle(.black)
            }
        }
        .navigationBarTitleDisplayMode(.inline)
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

struct HeaderView: View {
    var body: some View {
        VStack {
            Text("World MISS UNIVERSITY")
                .font(.kantumruyPro(size: 32, family: .semiBold))
                .foregroundStyle(.white)
                .padding(.top, 40)
                .padding(.horizontal, 8)
            
            Text("CAMBODIA 2024")
                .font(.kantumruyPro(size: 24, family: .medium))
                .padding(.top, 0)
                .foregroundStyle(.white)
            
            Image("Crown")
                .resizable()
                .background(.black)
                .frame(width: 230, height: 230)
        }
    }
}

struct LoginFormView: View {
    @ObservedObject var viewModel: LoginViewModel
   
    
    var body: some View {
        VStack(spacing: 20) {
            Text("Cast your vote for the brightest candidate!\n World Miss University voting starts soon !")
                .font(.kantumruyPro(size: 14, family: .semiBold))
                .foregroundStyle(.white)
                .padding(.top, 8)
            
            VStack(spacing: 16) {
                LoginTextField(viewModel: viewModel)
                LoginButton(viewModel: viewModel)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 200)
            .background(.black)
        }
    }
}

struct LoginTextField: View {
    @ObservedObject var viewModel: LoginViewModel
    
    var body: some View {
        VStack(alignment: .leading, spacing: 4) {
            // 에러 메시지 표시
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
                    .font(.system(size: 12))
                    .foregroundColor(.red)
                    .padding(.leading, 20)
            }
            
            TextField("", text: $viewModel.userId)
                .padding(.leading, 20)
                .foregroundStyle(.white)
                .submitLabel(.search)
                .clearButton(text: $viewModel.userId)
                .frame(height: 60)
                .background(Color("232122"))
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(viewModel.errorMessage != nil ? Color.red : Color.white, lineWidth: 2)  // 에러 시 빨간 테두리
                )
                .clipShape(RoundedRectangle(cornerRadius: 10))
                .overlay(
                    HStack {
                        Text("Enter Your ID")
                            .foregroundColor(.white.opacity(0.7))
                            .padding(.leading, 20)
                        Spacer()
                    }
                    .opacity(viewModel.userId.isEmpty ? 1 : 0)
                    .allowsHitTesting(false)
                )
                .padding(.horizontal, 20)
                .tint(.white)
                .onChange(of: viewModel.userId) { _ in
                    viewModel.validateInput()  // 입력값이 변경될 때마다 유효성 검사
                }
        }
    }
}

struct LoginButton: View {
    @ObservedObject var viewModel: LoginViewModel
    @EnvironmentObject var authState: AuthState
    
    var body: some View {
        Button {
            print("\(viewModel.userId)")
            Task {
                do {
                    let success = try await viewModel.login()
                    if success {
                        authState.isLoggedIn = true
                        authState.userId = viewModel.userId
                        print("\(authState.userId) 저장완료")
                    }
                } catch {
                    print("Login failed: \(error)")
                }
            }
        } label: {
            Text("Log in")
                .font(.system(size: 16, weight: .semibold))
                .foregroundColor(.white)
                .frame(maxWidth: .infinity)
                .frame(height: 50)
                .background(viewModel.isValidInput ? Color.blue : Color.gray)
               
        }
        .disabled(!viewModel.isValidInput)
        .background(Color.blue)
        .clipShape(RoundedRectangle(cornerRadius: 30))
        .padding(.horizontal, 20)
    }
}

// 키보드 핸들링을 위한 ViewModifier
struct KeyboardHandlingModifier: ViewModifier {
    let geometry: GeometryProxy
    @Binding var offset: CGFloat
    
    func body(content: Content) -> some View {
        content.onAppear {
            setupKeyboardNotifications()
        }
    }
    
    private func setupKeyboardNotifications() {
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
            let keyboardFrame = notification.userInfo?[UIResponder.keyboardFrameEndUserInfoKey] as? CGRect ?? .zero
            let textFieldPosition = geometry.size.height * 0.7
            let overlap = textFieldPosition + keyboardFrame.height - geometry.size.height
            
            if overlap > 0 {
                withAnimation(.easeOut(duration: 0.3)) {
                    offset = -overlap - 20
                }
            }
        }
        
        NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillHideNotification, object: nil, queue: .main) { _ in
            withAnimation(.easeOut(duration: 0.3)) {
                offset = 0
            }
        }
    }
}

