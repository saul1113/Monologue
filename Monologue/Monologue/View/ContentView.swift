//
//  ContentView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct ContentView: View {
    @EnvironmentObject var authManager: AuthManager
    @State private var isLogout: Bool = false
    
    var body: some View {
        if isLogout {
            LoginView(isNextView: .constant(false))
        } else {
            VStack {
                Text("\(authManager.email)")
                Button("로그아웃") {
                    authManager.signOut()
                    isLogout = true
                }
            }
        }
    }
}

#Preview {
    ContentView()
        .environmentObject(AuthManager())
}
