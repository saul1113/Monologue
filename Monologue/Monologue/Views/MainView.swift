//
//  MainView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct MainView: View {
    // PostView에 바인딩 하는 변수, 선택시 탭뷰로 이동하는 변수
    @State private var selectedTab: Int = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            Group {
                HomeView()
                    .tabItem {
                        VStack {
                            Image(systemName: "book.pages")
                            Text("Home")
                        }
                    }
                    .tag(0)
                
                PostView(selectedTab: $selectedTab)
                    .tabItem {
                        VStack {
                            Image(systemName: "plus.circle")
                            Text("Post")
                        }
                    }
                    .tag(1)
                
                MyPageView()
                    .tabItem {
                        VStack {
                            Image(systemName: "person")
                            Text("My Page")
                        }
                    }
                    .tag(2)
            }
            .toolbarBackground(Color.background, for: .tabBar)
            
        }
        .accentColor(.accent).ignoresSafeArea()
    }
}

#Preview {
    MainView()
}
