//
//  MainView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct MainView: View {
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
}
