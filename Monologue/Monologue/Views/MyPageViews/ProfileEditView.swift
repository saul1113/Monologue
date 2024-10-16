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
    
    @State private var selectedImage: UIImage?
    @State private var imagePickerItem: PhotosPickerItem?
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                if let selectedImage = selectedImage {
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: 77, height: 77)
                        .clipShape(Circle())
                        .padding(.bottom, 17)
                        .padding(.top, 20)
                } else {
                    Circle()
                        .frame(width: 77, height: 77)
                        .padding(.bottom, 17)
                        .padding(.top, 20)
                }
                
                PhotosPicker(selection: $imagePickerItem, matching: .images) {
                    Text("사진 수정")
                        .bold()
                }
                .padding(.bottom, 53)
                .onChange(of: imagePickerItem) { oldValue, newValue in
                    Task {
                        if let newValue {
                            if let imageData = try await newValue.loadTransferable(type: Data.self),
                               let image = UIImage(data: imageData) {
                                selectedImage = image
                            }
                        }
                    }
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
                    .padding(.bottom, 18)
                
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
            
            if let profileImageName = userInfoStore.userInfo?.profileImageName {
                selectedImage = UIImage(named: profileImageName)
            }
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
                    Task {
                        if var userInfo = userInfoStore.userInfo {
                            userInfo.nickname = nickname
                            userInfo.introduction = introduction

                            // 프사 이미지 업로드 로직...
                            
                            await userInfoStore.updateUserInfo(userInfo, email: authManager.email)
                            dismiss()
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
