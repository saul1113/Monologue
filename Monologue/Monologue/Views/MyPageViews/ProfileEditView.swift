//
//  ProfileEditView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct ProfileEditView: View {
    @Binding var userInfo: UserInfo

    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager: AuthManager
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    @Environment(\.dismiss) private var dismiss
    
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
                        ProfileImageView(
                            profileImageName: !userInfo.profileImageName.isEmpty ? userInfo.profileImageName : "",
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
                .padding(.vertical, 20)
                .sheet(isPresented: $isShowingSheet) {
                    ProfileImageEditView(selectedImageName: $userInfo.profileImageName)
                        .presentationDetents([.height(250)])
                }
                
                HStack {
                    Text("닉네임")
                        .padding(.trailing, 30)
                        .bold()
                    
                    TextField("닉네임 변경", text: $userInfo.nickname)
                    // 14글자로 제한
                        .onChange(of: userInfo.nickname) { oldValue, newValue in
                            if newValue.count > 14 {
                                userInfo.nickname = String(newValue.prefix(14))
                            } else {
                                userInfo.nickname = newValue
                            }
                        }
                }
                
                Divider()
                    .padding(.bottom, (nicknameCheckWarning || nicknameDuplicateWarning) ? 0 : 18)
                
                // 닉네임 비어 있음 경고
                if nicknameCheckWarning && userInfo.nickname.isEmpty {
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
                    
                    TextField("자기소개 추가", text: $userInfo.introduction)
                    // 36글자로 제한
                        .onChange(of: userInfo.introduction) { oldValue, newValue in
                            if newValue.count > 36 {
                                userInfo.introduction = String(newValue.prefix(36))
                            }
                        }
                }
                
                Divider()
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .foregroundStyle(.accent)
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
                    handleComplete()
                }
            }
        }
    }
    
    // 완료 버튼 핸들링
    private func handleComplete() {
        if userInfo.nickname.isEmpty {
            nicknameCheckWarning = true
            nicknameDuplicateWarning = false
        } else {
            nicknameCheckWarning = false
            
            Task {
                // 닉네임이 변경된 경우에만 중복 검사
                if userInfo.nickname != userInfoStore.userInfo?.nickname {
                    let nicknameExists = await authManager.NicknameDuplicate(nickname: userInfo.nickname)
                    if nicknameExists {
                        nicknameDuplicateWarning = true
                        return
                    }
                }
                nicknameDuplicateWarning = false
                try await memoStore.changeMemosNickname(email: userInfoStore.userInfo?.email ?? "", newNickname: userInfo.nickname)
                try await columnStore.changeColumnsNickname(email: userInfoStore.userInfo?.email ?? "", newNickname: userInfo.nickname)
                saveUserInfo()
            }
        }
    }
    
    // 유저 정보 저장
    private func saveUserInfo() {
        Task {
            await userInfoStore.updateUserInfo(userInfo)
            await userInfoStore.loadUserInfo(email: userInfo.email)
            
            dismiss()
        }
    }
}

//#Preview {
//    NavigationStack {
//        ProfileEditView()
//            .environmentObject(AuthManager())
//            .environmentObject(UserInfoStore())
//    }
//}
