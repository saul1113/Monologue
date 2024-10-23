//
//  AddUserInfoView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import SwiftUI
import OrderedCollections

struct AddUserInfoView: View {
    @State var dict: OrderedDictionary = [
        "전체": true,
        "오늘의 주제": false,
        "수필": false,
        "소설": false,
        "SF": false,
        "IT": false,
        "기타": false,
    ]
    
    @EnvironmentObject var authManager: AuthManager
    
    @State private var nicknameCheckWarning: Bool = false // 닉네임 확인
    @State private var nicknameDuplicateWarning: Bool = false // 닉네임 중복 경고
    @State private var nicknameText: String = ""
    
    @Binding var isPresented: Bool
    
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @State private var isShowingSheet: Bool = false
    @State private var selectedImageName: String = ""
    
    var body: some View {
        NavigationStack {
            Image(systemName: "ellipsis")
                .resizable()
                .foregroundStyle(.gray)
                .frame(width: 18, height: 4)
                .padding(10)
            
            VStack(alignment: .leading) {
                Spacer()
                      
                VStack(alignment: .leading) {
                    Button {
                        isShowingSheet.toggle()
                    } label: {
                        ZStack {
                            ProfileImageView(
                                profileImageName: !selectedImageName.isEmpty ? selectedImageName : (userInfoStore.userInfo?.profileImageName ?? ""),
                                size: 84
                            )
                            Image(systemName: "pencil")
                                .bold()
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(.white))
                                .padding(.top, 60)
                                .padding(.leading, 60)
                        }
                    }
                    .sheet(isPresented: $isShowingSheet) {
                        ProfileImageEditView(selectedImageName: $selectedImageName)
                            .presentationDetents([.height(250)])
                    }
                    
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
                
                VStack(alignment: .leading) {
                    Text("관심 카테고리")
                        .foregroundStyle(.accent)
                    
                    categoryView(dict: $dict)
                        .padding(.leading, -15)
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
                                
                                // 선택된 카테고리 가져오기
                                let selectedCategories = dict
                                    .filter { $0.value } // 선택된 항목만 필터링
                                    .map { $0.key } // 선택된 항목의 키를 배열로 변환
                                
                                let newUserInfo = UserInfo(
                                    uid: authManager.userID,
                                    email: authManager.email,
                                    nickname: nicknameText,
                                    registrationDate: Date(),
                                    preferredCategories: selectedCategories,
                                    profileImageName: selectedImageName,
                                    introduction: "",
                                    followers: [],
                                    followings: [],
                                    blocked: [],
                                    likesMemos: [],
                                    likesColumns: []
                                )
                                
                                await userInfoStore.addUserInfo(newUserInfo)
                                authManager.nicknameExists = true // 닉네임이 있다는 것을 알림
                                authManager.authenticationState = .authenticated // 메인뷰로 이동
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
    AddUserInfoView(isPresented: .constant(false))
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
        .environmentObject(MemoStore())
        .environmentObject(ColumnStore())
        .environmentObject(CommentStore())
}
