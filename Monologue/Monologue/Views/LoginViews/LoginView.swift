//
//  LoginView.swift
//  Monologue
//
//  Created by 김종혁 on 10/14/24.
//

import SwiftUI

struct LoginView: View {
    @State private var isPresented: Bool = false
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    @State private var isNextView: Bool = false
    
    var body: some View {
        NavigationStack {
            if isNextView {
                MainView()
            } else {
                ZStack {
                    Color(.background).ignoresSafeArea()
                    
                    VStack {
                        Text("MONOLOGUE")
                            .padding(40)
                            .font(.system(size: 42))
                            .foregroundStyle(.accent)
                            .bold()
                        
                        GoogleButtonView(isPresented: $isPresented, isNextView: $isNextView)
                            .environmentObject(authManager)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            .padding()
                        
                        AppleButtonView(isPresented: $isPresented, isNextView: $isNextView)
                            .environmentObject(authManager)
                    }
                }
            }
        }
        .sheet(isPresented: $isPresented) {
            AddUserInfoView(isPresented: $isPresented, isNextView: $isNextView)
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
