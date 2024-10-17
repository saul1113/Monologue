//
//  GoogleButtonView.swift
//  Monologue
//
//  Created by 김종혁 on 10/15/24.
//

//

import SwiftUI
import CryptoKit
import AuthenticationServices
import FirebaseAuth

struct GoogleButtonView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool
    
    var body: some View {
        Button(action: {
            Task {
                let loginSuccess = await authManager.signInWithGoogle()
                if loginSuccess {
                    let nicknameExists = await authManager.checkNicknameExists(email: authManager.email)
                    if nicknameExists {
                        isPresented = false
                        authManager.authenticationState = .authenticated  // 닉네임이 존재하면 로그인 성공
                    } else {
                        isPresented = true  // 닉네임이 없으면 사용자 정보 추가 화면 표시
                    }
                }
            }
        }) {
            HStack {
                Image("GoogleLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 19, height: 19)
                
                Text("Sign Up with Google")
                    .fontWeight(.medium)
                    .font(.system(size: 21))
                    .foregroundColor(.black)
                    .opacity(0.54)
            }
            .frame(width: 300)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
        }
    }
}

struct AppleButtonView: View {
    @StateObject private var appleAuth = AppleAuth()
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool
    
    var body: some View {
        SignInWithAppleButton(
            .signIn,
            onRequest: { request in
                appleAuth.prepareRequest(request)
            },
            onCompletion: { result in
                appleAuth.handleAuthorization(result) {
                    Task {
                        let nicknameExists = await authManager.checkNicknameExists(email: authManager.email)
                        if appleAuth.isSignedIn && nicknameExists {
                            authManager.authenticationState = .authenticated  // 닉네임이 있으면 로그인 성공
                        } else if !appleAuth.isSignedIn {
                            isPresented = false  // 로그인 실패 시 Sheet 닫기
                        } else if appleAuth.isSignedIn && !nicknameExists {
                            isPresented = true  // 닉네임이 없으면 사용자 정보 추가 화면 표시
                        }
                    }
                }
            }
        )
        .signInWithAppleButtonStyle(.black)
        .frame(height: 60)
        .frame(width: 330)
        .font(.system(size: 12))
        .cornerRadius(8)
        .padding()
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
        .environmentObject(MemoStore())
        .environmentObject(ColumnStore())
        .environmentObject(CommentStore())
}
