//
//  MainView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct MainView: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    var body: some View {
        TabView {
            Group {
                HomeView()
                    .tabItem {
                        VStack {
                            Image(systemName: "book.pages")
                            Text("Home")
                        }
                    }
                
                PostView()
                    .tabItem {
                        VStack {
                            Image(systemName: "plus.circle")
                            Text("Post")
                        }
                    }
                
                MyPageView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person")
                            Text("My Page")
                        }
                    }
            }
            .toolbarBackground(Color.background, for: .tabBar)
            
        }
        .accentColor(.accent).ignoresSafeArea()
    }
}

#Preview {
    MainView()
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
        .environmentObject(MemoStore())
        .environmentObject(ColumnStore())
        .environmentObject(CommentStore())
}
