//
//  AddUserInfoView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import SwiftUI
import OrderedCollections

struct AddUserInfoView: View {
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStroe: UserInfoStore
    
    @State private var nicknameCheckWarning: Bool = false // 닉네임 확인
    @State private var nicknameDuplicateWarning: Bool = false // 닉네임 중복 경고
    
    @State private var nicknameText: String = ""
    
    @State var dict: OrderedDictionary = [
        "전체": false,
        "오늘의 주제": false,
        "수필": false,
        "소설": false,
        "SF": false,
        "IT": false,
        "기타": false,
    ]
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
                VStack(alignment: .leading) {
                    TextField("사용하실 닉네임을 입력해주세요.", text: $nicknameText)
                        .padding(.horizontal, 10)
                        .frame(height: 45)
                        .background(
                            RoundedRectangle(cornerRadius: 10)
                                .stroke(.gray, lineWidth: 2).opacity(0.2)
                        )
                        .cornerRadius(10)
                        .padding(.bottom, 5)
                    
                    // 닉네임 비어 있음 경고
                    if nicknameCheckWarning && nicknameText.isEmpty {
                        Text("닉네임을 입력해주세요.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                    
                    // 닉네임 중복 경고
                    if nicknameDuplicateWarning {
                        Text("이미 존재하는 닉네임입니다.")
                            .foregroundColor(.red)
                            .font(.caption)
                    }
                }
                .padding(.bottom, 30)
                
                VStack(alignment: .leading, spacing: 5) {
                    Text("카테고리")
                        .foregroundStyle(.accent)
                    
                    categoryView(dict: $dict)
                }
                
                Spacer()
                
                Button {
                    // 닉네임 비어 있음 확인
                    if nicknameText.isEmpty {
                        nicknameCheckWarning = true
                        nicknameDuplicateWarning = false
                    } else {
                        nicknameCheckWarning = false
                        
                        // 닉네임 중복 확인
                        Task {
                            let nicknameExists = await authManager.NicknameDuplicate(nickname: nicknameText)
                            
                            if nicknameExists {
                                nicknameDuplicateWarning = true // 닉네임 중복 경고
                            } else {
                                nicknameDuplicateWarning = false
                                isPresented = false
                                isNextView = true
                                
                                // 선택된 카테고리 가져오기
                                let selectedCategories = dict
                                    .filter { $0.value } // 선택된 항목만 필터링
                                    .map { $0.key } // 선택된 항목의 키를 배열로 변환
                                
                                let newUserInfo = UserInfo(
                                    nickname: nicknameText,
                                    registrationDate: Date(),
                                    preferredCategories: selectedCategories,
                                    profileImageName: "",
                                    introduction: "",
                                    following: [],
                                    followers: [],
                                    blocked: [],
                                    likes: []
                                )
                                
                                await userInfoStroe.addUserInfo(newUserInfo, email: authManager.email)
                            }
                        }
                    }
                } label: {
                    Text("등록")
                        .frame(maxWidth: .infinity, minHeight: 35)
                }
                .buttonStyle(.borderedProminent)
                .tint(.accent)
                
                Spacer()
            }
        }
        .padding(.horizontal, 25)
    }
}

#Preview {
    AddUserInfoView(isPresented: .constant(false), isNextView: .constant(false))
}