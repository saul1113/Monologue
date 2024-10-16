//
//  ProfileEditView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI
import PhotosUI

struct ProfileEditView: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    @Environment(\.dismiss) private var dismiss
    
    @State private var nickname: String = ""
    @State private var introduction: String = ""
    @State private var isShowingSheet: Bool = false
    @State private var selectedImageName: String = ""
    
    @State private var nicknameCheckWarning: Bool = false // 닉네임 확인
    @State private var nicknameDuplicateWarning: Bool = false // 닉네임 중복 경고
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                    // 프로필 사진 수정 버튼
                    Button {
                        isShowingSheet.toggle()
                    } label: {
                        ZStack {
                            ProfileImageView(profileImageName: !selectedImageName.isEmpty ? selectedImageName : userInfoStore.userInfo?.profileImageName ?? "", size: 84)
                            
                            Image(systemName: "pencil")
                                .bold()
                                .frame(width: 30, height: 30)
                                .background(Circle().fill(.white))
                                .padding(.top, 60)
                                .padding(.leading, 60)
                        }
                    }
                    .padding(.vertical, 20)
                    .sheet(isPresented: $isShowingSheet) {
                        ProfileImageEditView(selectedImageName: $selectedImageName)
                            .presentationDetents([.height(250)])
                    }
                
                HStack {
                    Text("닉네임")
                        .padding(.trailing, 30)
                        .bold()
                    
                    TextField("닉네임 변경", text: $nickname)
                    // 14글자로 제한
                        .onChange(of: nickname) { oldValue, newValue in
                            if newValue.count > 14 {
                                nickname = String(newValue.prefix(14))
                            }
                        }
                }
                
                Divider()
                    .padding(.bottom, (nicknameCheckWarning || nicknameDuplicateWarning) ? 0 : 18)
                
                // 닉네임 비어 있음 경고
                if nicknameCheckWarning && nickname.isEmpty {
                    Text("닉네임을 입력해주세요.")
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.bottom, 18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // 닉네임 중복 경고
                if nicknameDuplicateWarning {
                    Text("이미 존재하는 닉네임입니다.")
                        .foregroundStyle(.red)
                        .font(.caption)
                        .padding(.bottom, 18)
                        .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                HStack {
                    Text("자기소개")
                        .padding(.trailing, 15)
                        .bold()
                    
                    TextField("자기소개 추가", text: $introduction)
                    // 36글자로 제한
                        .onChange(of: introduction) { oldValue, newValue in
                            if newValue.count > 36 {
                                introduction = String(newValue.prefix(36))
                            }
                        }
                }
                
                Divider()
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .foregroundStyle(.accent)
        }
        .onAppear {
            // 기존 닉, 상메, 프사 불러옴
            nickname = userInfoStore.userInfo?.nickname ?? ""
            introduction = userInfoStore.userInfo?.introduction ?? ""
            selectedImageName = userInfoStore.userInfo?.profileImageName ?? ""
        }
        .navigationTitle("프로필 편집")
        .toolbarTitleDisplayMode(.inline)
        .navigationBarBackButtonHidden(true) // 기본 백 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .topBarLeading) {
                Button {
                    dismiss()
                } label: {
                    Image(systemName: "chevron.backward")
                }
            }
            
            ToolbarItem(placement: .topBarTrailing) {
                Button("완료") {
                    if nickname.isEmpty {
                        nicknameCheckWarning = true
                        nicknameDuplicateWarning = false
                    } else {
                        nicknameCheckWarning = false
                        
                        Task {
                            let nicknameExists = await authManager.NicknameDuplicate(nickname: nickname)
                            
                            if nicknameExists {
                                nicknameDuplicateWarning = true // 닉네임 중복 경고
                            } else {
                                nicknameDuplicateWarning = false
                                
                                if var userInfo = userInfoStore.userInfo {
                                    userInfo.nickname = nickname
                                    userInfo.introduction = introduction
                                    userInfo.profileImageName = selectedImageName
                                    
                                    await userInfoStore.updateUserInfo(userInfo, email: authManager.email)
                                    dismiss()
                                }
                            }
                        }
                    }
                }
            }
        }
    }
}

#Preview {
    NavigationStack {
        ProfileEditView()
    }
}
