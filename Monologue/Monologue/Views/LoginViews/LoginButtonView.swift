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
    @Binding var isNextView: Bool
    
    var body: some View {
        Button(action: {
            Task {
                let googleLoginCancel = await authManager.signInWithGoogle()
                let nicknameExists = await authManager.checkNicknameExists(email: authManager.email)
                
                if googleLoginCancel && nicknameExists {
                    isNextView = true  // 닉네임이 있으면 ContentView로
                } else if !googleLoginCancel { // 구글로그인 취소할 때 sheet 안뜸
                    isPresented = false
                } else if googleLoginCancel && !nicknameExists {
                    isPresented = true // 닉네임이 없으면 Sheet 띄움
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
    @Binding var isNextView: Bool
    
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
                            isNextView = true  // 닉네임이 있으면 ContentView로
                        } else if !appleAuth.isSignedIn { // 구글로그인 취소할 때 sheet 안뜸
                            isPresented = false
                        } else if appleAuth.isSignedIn && !nicknameExists {
                            isPresented = true // 닉네임이 없으면 Sheet 띄움
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
