//
//  ProfileEditView.swift
//  Monologue
//
//  Created by Hyojeong on 10/15/24.
//

import SwiftUI

struct ProfileEditView: View {
    @Environment(\.dismiss) private var dismiss
    @State private var nickname: String = "" // 파베로 변경 예정
    @State private var introduction: String = "" // 파베로 변경 예정
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                Circle() // profileImageName
                    .frame(width: 77, height: 77)
                    .padding(.bottom, 17)
                    .padding(.top, 20)
                
                Button {
                    
                } label: {
                    Text("사진 수정")
                        .bold()
                }
                .padding(.bottom, 53)
                
                HStack {
                    Text("닉네임")
                        .padding(.trailing, 30)
                        .bold()
                    
                    TextField("닉네임 변경", text: $nickname)
                }
                
                Divider()
                    .padding(.bottom, 18)
                
                HStack {
                    Text("자기소개")
                        .padding(.trailing, 15)
                        .bold()
                    
                    TextField("자기소개 추가", text: $introduction)
                }
                
                Divider()
                
                Spacer()
            }
            .padding(.horizontal, 16)
            .foregroundStyle(.accent)
        }
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
                    // 프로필 변경 저장 로직
                    dismiss()
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
