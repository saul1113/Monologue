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
    
    @State private var isNextView: Bool = false
    
    var body: some View {
        NavigationStack {
            if isNextView {
                ContentView()
            } else {
                ZStack {
                    Color(red: 255 / 255, green: 248 / 255, blue: 237 / 255).ignoresSafeArea()
                    
                    VStack {
                        Text("MONOLOGUE")
                            .padding(40)
                            .font(.system(size: 42))
                            .foregroundStyle(Color(red: 120 / 255, green: 88 / 255, blue: 79 / 255))
                            .bold()
                        
                        GoogleButtonView(isPresented: $isPresented)
                            .environmentObject(authManager)
                            .shadow(color: .gray, radius: 2, x: 0, y: 2)
                            .padding()
                        
                        AppleButtonView(isPresented: $isPresented)
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
}


// SignUpDetailView.swift

//import SwiftUI
//
//struct SignUpDetailView: View {
//    @Binding var isPresented: Bool
//    @Binding var isNextView: Bool
//    
//    var body: some View {
//        NavigationStack {
//            Button {
//                isPresented = false
//                isNextView = true
//            } label: {
//                Text("다음")
//            }
//        }
//    }
//}
//
//#Preview {
//    SignUpDetailView(isPresented: .constant(false), isNextView: .constant(false))
//}
