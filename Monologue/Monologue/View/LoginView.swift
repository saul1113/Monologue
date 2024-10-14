//
//  LoginView.swift
//  Monologue
//
//  Created by 김종혁 on 10/14/24.
//

import SwiftUI

struct LoginView: View {
    @State private var isPresented: Bool = false
    @State private var authState: AuthenticationState = .unauthenticated
    @EnvironmentObject var authManager: AuthManager
    var body: some View {
        NavigationStack {
            if isPresented {
                ContentView()
            }else {
                  VStack {
                    Button {
                        Task {
                            isPresented  = await authManager.signInWithGoogle()
                        }
                    } label: {
                        Text("Login Button")
                            .frame(maxWidth: .infinity)
                            .frame(height: 50)
                            .foregroundStyle(.white)
                            .background(.indigo.gradient, in: RoundedRectangle(cornerRadius: 10))
                    }
                }
                .padding(.horizontal, 20)
            }
        }
    }
}

#Preview {
    LoginView()
        .environmentObject(AuthManager())
}
