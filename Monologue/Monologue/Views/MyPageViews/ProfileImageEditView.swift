//
//  ProfileImageEditView.swift
//  Monologue
//
//  Created by Hyojeong on 10/16/24.
//

import SwiftUI

struct ProfileImageEditView: View {
    let imageNames = ["profileImage1", "profileImage2", "profileImage3", "profileImage4"]
    @Binding var selectedImageName: String
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        VStack(spacing: 40) {
            Text("프로필 사진 선택")
                .font(.system(size: 18, weight: .bold))
            
            HStack(spacing: 24) {
                ForEach(imageNames, id: \.self) { imageName in
                    Button {
                        selectedImageName = imageName
                        dismiss()
                    } label: {
                        Image(imageName)
                            .resizable()
                            .clipShape(Circle())
                            .frame(width: 77, height: 77)
                    }
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

#Preview {
    @Previewable @State var selectedImageName: String = "profileImage1" // 미리 보기에서 사용할 임시 값

    ProfileImageEditView(selectedImageName: $selectedImageName)
}
