//
//  AddUserInfoView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import SwiftUI

struct AddUserInfoView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStroe: UserInfoStore
    
    @State private var nicknameText: String = ""
    
    @Binding var isPresented: Bool
    @Binding var isNextView: Bool
    
    var body: some View {
        NavigationStack {
            Image(systemName: "ellipsis")
                .resizable()
                .foregroundStyle(.gray)
                .frame(width: 18, height: 4)
                .padding(10)
            
            VStack(alignment: .leading) {
                Spacer()
                    .frame(height: 100)
                
                TextField("사용하실 닉네임을 입력해주세요.", text: $nicknameText)
                    .padding(.horizontal, 10)
                    .frame(height: 45)
                    .background(
                        RoundedRectangle(cornerRadius: 10)
                            .stroke(.gray, lineWidth: 2).opacity(0.2)
                    )
                    .cornerRadius(10)
                    .padding(.bottom, 30)
                
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("카테고리")
                        .foregroundStyle(.black) // accentColor 변경해야함
                    Text("?")
                    Text("?")
                }
                
                Spacer()
                // categoryView(dict: dict)
                
                Button {
                    isPresented = false
                    isNextView = true
                    
                    Task {
                        let newUserInfo = UserInfo(nickname: nicknameText, registrationDate: Date(), preferredCategories: [""], profileImageName: "", introduction: "", following: [""], followers: [""], blocked: [""], likes: [""])
                        
                        await userInfoStroe.addUserInfo(newUserInfo, email: authManager.email)
                        
                    }
                } label: {
                    Text("등록")
                        .frame(maxWidth: .infinity, minHeight: 35)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accentColor)
                
                Spacer()
            }
            .padding(.horizontal, 25)
        }
    }
}

#Preview {
    AddUserInfoView(isPresented: .constant(false), isNextView: .constant(false))
}
