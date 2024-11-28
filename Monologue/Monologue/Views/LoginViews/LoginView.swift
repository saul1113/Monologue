//
//  LoginView.swift
//  Monologue
//
//  Created by 김종혁 on 10/14/24.
//

import SwiftUI

struct LoginView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background).ignoresSafeArea()
                
                VStack {
                    Text("MONOLOGUE")
                        .padding(40)
                        .font(.system(size: 42))
                        .foregroundStyle(.accent)
                        .bold()
                    
                    GoogleButtonView()
                        .environmentObject(authManager)
                        .shadow(color: .gray, radius: 2, x: 0, y: 2)
                        .padding()
                    
                    AppleButtonView()
                        .environmentObject(authManager)
                }
            }
        }
        .sheet(isPresented: $authManager.isPresented) {
            AddUserInfoView(isPresented: $authManager.isPresented)
                .presentationDetents([.medium])
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
