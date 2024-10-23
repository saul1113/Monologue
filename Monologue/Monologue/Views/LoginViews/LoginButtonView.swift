//
//  GoogleButtonView.swift
//  Monologue
//
//  Created by 김종혁 on 10/15/24.
//

import SwiftUI
import CryptoKit
import AuthenticationServices
import FirebaseAuth

struct GoogleButtonView: View {
    @EnvironmentObject var authManager: AuthManager
    @State var loadingGoogleLogin: Bool = false // 로그인 중 표시할려고 사용
    
    var body: some View {
        Button(action: {
            loadingGoogleLogin = true
            Task {
                let loginSuccess = await authManager.signInWithGoogle()
                if loginSuccess {
                    let nicknameExists = await authManager.checkNicknameExists(email: authManager.email)
                    if nicknameExists {
                        authManager.isPresented = false
                        authManager.nicknameExists = true // 닉네임이 있다는 것을 알림
                        authManager.authenticationState = .authenticated  // 닉네임이 존재하면 로그인 성공
                    } else {
                        authManager.isPresented = true  // 닉네임이 없으면 사용자 정보 추가 화면 표시
                    }
                }
                loadingGoogleLogin = false
            }
        }) {
            HStack {
                if loadingGoogleLogin {
                    ProgressView() // 로딩 인디케이터
                        .progressViewStyle(CircularProgressViewStyle())
                } else {
                    Image("GoogleLogo")
                        .resizable()
                        .scaledToFill()
                        .frame(width: 19, height: 19)
                }
                
                Text(loadingGoogleLogin ? "Logging in..." : "Sign in with Google")
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
        // 로그인 중일 때 버튼 비활성화
        .disabled(loadingGoogleLogin)
    }
}

struct AppleButtonView: View {
    @StateObject private var appleAuth = AppleAuth()
    @EnvironmentObject var authManager: AuthManager
    @State var loadingAppleLogin: Bool = false
    
    var body: some View {
        HStack {
            Image("AppleLogo")
                .resizable()
                .scaledToFit()
                .frame(width: 19, height: 19)
            Text(loadingAppleLogin ? "Logging in..." : "Sign in with Apple") // 상태에 따라 텍스트 변경
                .fontWeight(.medium)
                .font(.system(size: 21))
                .foregroundColor(.white)
                .padding(.trailing, 9)
        }
        .frame(width: 300)
        .padding()
        .background(Color.black)
        .cornerRadius(8)
        .overlay {
            SignInWithAppleButton(
                .signIn,
                onRequest: { request in
                    loadingAppleLogin = true
                    appleAuth.prepareRequest(request)
                },
                onCompletion: { result in
                    appleAuth.handleAuthorization(result) {
                        Task {
                            if appleAuth.isSignedIn {
                                authManager.email = appleAuth.userEmail ?? ""
                                
                                let nicknameExists = await authManager.checkNicknameExists(email: authManager.email)
                                
                                if nicknameExists {
                                    authManager.authenticationState = .authenticated  // 닉네임이 존재하면 로그인 성공
                                    authManager.nicknameExists = true // 닉네임이 있다는 것을 알림
                                    authManager.isPresented = false
                                } else {
                                    authManager.isPresented = true  // 닉네임이 없으면 사용자 정보 추가 화면 표시
                                }
                            }
                            loadingAppleLogin = false
                        }
                    }
                }
            )
            .blendMode(.overlay) // 중첩해서... 커스텀함요...ㅜ
        }
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
