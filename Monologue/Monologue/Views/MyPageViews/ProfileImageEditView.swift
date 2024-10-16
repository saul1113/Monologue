//
//  ProfileImageEditView.swift
//  Monologue
//
//  Created by Hyojeong on 10/16/24.
//

import SwiftUI

struct ProfileImageEditView: View {
    @Environment(\.dismiss) private var dismiss
    @Binding var selectedImageName: String

    var body: some View {
        VStack(spacing: 40) {
            Text("프로필 사진을 선택해 주세요.")
                .font(.system(size: 16, weight: .bold))
            
            ProfileImageSelectionView(selectedImageName: $selectedImageName)
            
            Button {
                // 로직 추가
                dismiss()
            } label: {
                Text("등록")
                    .font(.system(size: 15))
                    .frame(width: 200, height: 40)
                    .background(RoundedRectangle(cornerRadius: 10)
                        .strokeBorder(.accent, lineWidth: 1)
                    )
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    @State var selectedImageName: String = "profileImage1" // 미리 보기에서 사용할 임시 값

    ProfileImageEditView(selectedImageName: $selectedImageName)
}
