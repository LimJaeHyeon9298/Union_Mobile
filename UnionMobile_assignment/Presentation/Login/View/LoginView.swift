//
//  LoginView.swift
//  UnionMobile_assignment
//
//  Created by 임재현 on 1/18/25.
//

import SwiftUI
//TODO : 유효성 검사, 애니메이션
struct LoginView: View {
    @State private var userID = ""
    @State private var offset: CGFloat = 0
    
    var body: some View {
        NavigationStack {
            GeometryReader { geometry in
                VStack {
                    Text("World MISS UNIVERSITY")
                        .font(.kantumruyPro(size: 32, family: .semiBold))
                        .foregroundStyle(.white)
                        .padding(.top,40)
                        .padding(.horizontal,8)
                    
                    Text("CAMBODIA 2024")
                        .font(.kantumruyPro(size: 24, family: .medium))
                        .padding(.top, 0)
                        .foregroundStyle(.white)
                    
                    Image(systemName: "crown.circle")
                        .resizable()
                        .background(.red)
                        .frame(width: 230,height: 230)
                    
                    VStack(spacing: 20)  {
                        Text("Cast your vote for the brightest candidate!\n World Miss University voting starts soon !")
                            .font(.kantumruyPro(size: 14, family: .semiBold))
                            .foregroundStyle(.white)
                            .padding(.top, 8)
                        
                        VStack(spacing: 16) {
                            TextField("", text: $userID)
                                .padding(.leading, 20)
                                .foregroundStyle(.white)
                                .submitLabel(.search)
                                .clearButton(text: $userID)
                                .onSubmit {
                                    hideKeyboard()
                                }
                            
                                .frame(height: 60)
                                .background(Color(.lightGray))
                                .overlay(
                                    RoundedRectangle(cornerRadius: 10)
                                        .stroke(Color.white, lineWidth: 2)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .overlay(
                                    HStack {
                                        Text("Enter Your ID")
                                            .foregroundColor(.white.opacity(0.7))
                                            .padding(.leading, 20)
                                        Spacer()
                                    }
                                    .opacity(userID.isEmpty ? 1 : 0)
                                )
                                .clipShape(RoundedRectangle(cornerRadius: 10))
                                .padding(.horizontal, 20)
                                .tint(.white)
                            
                            Button {
                                print("\(userID)")
                                hideKeyboard()
                            } label: {
                                Text("Log in")
                                    .font(.system(size: 16, weight: .semibold))
                                    .foregroundColor(.white)
                                    .frame(maxWidth: .infinity)
                                    .frame(height: 50)
                            }
                            .background(Color.blue)
                            .clipShape(RoundedRectangle(cornerRadius: 30))
                            .padding(.horizontal, 20)
                        }
                        .frame(maxWidth: .infinity)
                        .frame(height: 200)
                        .background(.black)
                    }
                    
                    Spacer()
                }
                .onTapGesture {
                    hideKeyboard()
                }
                .offset(y: offset)
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(.black)
                .edgesIgnoringSafeArea(.bottom)
                .onAppear {
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
                .toolbar {
                    ToolbarItem(placement: .principal) {
                        Text("2024 WMU")
                            .foregroundStyle(.black)
                    }
                }
                .navigationBarTitleDisplayMode(.inline)
            }
            .toolbarBackground(.white, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbarColorScheme(.light, for: .navigationBar)
        }
    }
    
    private func hideKeyboard() {
        UIApplication.shared.sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}

#Preview {
    LoginView()
}


struct ClearButton: ViewModifier {
    @Binding var text: String
    
    func body(content: Content) -> some View {
        HStack {
            content
            
            if !text.isEmpty {
                Button(action: {
                    text = ""
                }) {
                    Image(systemName: "xmark.circle.fill")
                        .foregroundColor(.gray)
                }
                .padding(.trailing, 8)
            }
        }
    }
}

extension View {
    func clearButton(text: Binding<String>) -> some View {
        modifier(ClearButton(text: text))
    }
    
    func placeholder<Content: View>(
            when shouldShow: Bool,
            alignment: Alignment = .leading,
            @ViewBuilder placeholder: () -> Content) -> some View {
            
            ZStack(alignment: alignment) {
                placeholder().opacity(shouldShow ? 1 : 0)
                self
            }
        }
}
