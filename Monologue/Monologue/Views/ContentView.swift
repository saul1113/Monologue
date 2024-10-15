//
//  ContentView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject var userInfoStore: UserInfoStore
    @State private var isLogout: Bool = false
    
    var body: some View {
        if isLogout {
            LoginView()
        } else {
            VStack(spacing: 20) {
                Text("Email: \(authManager.email)")
                
                if let userInfo = userInfoStore.userInfo {
                    Text("Nickname: \(userInfo.nickname)")
                    Text("Introduction: \(userInfo.introduction)")
                    Text("Preferred Categories: \(userInfo.preferredCategories.joined(separator: ", "))")
                    Text("Followers: \(userInfo.followers.count)")
                    Text("Following: \(userInfo.following.count)")
                } else {
                    Text("Loading user information...") // 로드 중 메시지
                }
                
                Button("로그아웃") {
                    authManager.signOut()
                    isLogout = true
                }
            }
            .padding()
            .task {
                // 뷰가 로드되면 Firestore에서 사용자 정보를 로드
                await userInfoStore.loadUserInfo(email: authManager.email)
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
}
