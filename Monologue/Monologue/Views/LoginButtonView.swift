//
//  GoogleButtonView.swift
//  Monologue
//
//  Created by 김종혁 on 10/15/24.
//

import SwiftUI

struct GoogleButtonView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool
    @Binding var isNextView: Bool
    
    var body: some View {
        Button(action: {
            Task {
                let nicknameExists = await authManager.signInWithGoogle()
                
                if nicknameExists {
                    isNextView = true  // 닉네임이 있으면 ContentView로
                } else {
                    isPresented = true  // 닉네임이 없으면 Sheet 띄움
                }
            }
        }) {
            HStack {
                Image("GoogleLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                
                Text("Sign Up with Google")
                    .fontWeight(.medium)
                    .font(.system(size: 20))
                    .foregroundColor(.black)
                    .opacity(0.54)
                    .padding(.leading, 10)
            }
            .frame(width: 300)
            .padding()
            .background(Color.white)
            .cornerRadius(8)
            .shadow(color: .gray, radius: 2, x: 0, y: 1)
        }
    }
}

struct AppleButtonView: View {
    @EnvironmentObject var authManager: AuthManager
    @Binding var isPresented: Bool

    var body: some View {
        Button(action: {
            Task {
                
            }
        }) {
            HStack {
                Image("AppleLogo")
                    .resizable()
                    .scaledToFill()
                    .frame(width: 22, height: 22)
                
                Text("Sign Up with Apple")
                    .font(.system(size: 20))
                    .fontWeight(.medium)
                    .foregroundColor(.white)
                    .padding(.leading, 10)
            }
            .frame(width: 300)
            .padding()
            .background(Color.black)
            .cornerRadius(8)
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
