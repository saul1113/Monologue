//
//  ProfileImageEditView.swift
//  Monologue
//
//  Created by Hyojeong on 10/16/24.
//

import SwiftUI

struct ProfileImageEditView: View {
    @Binding var selectedImageName: String

    var body: some View {
        VStack(spacing: 40) {
            Text("프로필 사진 선택")
                .font(.system(size: 18, weight: .bold))
            
            ProfileImageSelectionView(selectedImageName: $selectedImageName)
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    @Previewable @State var selectedImageName: String = "profileImage1" // 미리 보기에서 사용할 임시 값

    ProfileImageEditView(selectedImageName: $selectedImageName)
}
