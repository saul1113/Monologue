//
//  ProfileImageSelectionView.swift
//  Monologue
//
//  Created by Hyojeong on 10/16/24.
//

import SwiftUI

// 회원가입 뷰, ProfileImageEditView 에서 사용
struct ProfileImageSelectionView: View {
    @Binding var selectedImageName: String
    let imageNames = ["profileImage1", "profileImage2", "profileImage3", "profileImage4"]
    
    var body: some View {
        HStack(spacing: 24) {
            ForEach(imageNames, id: \.self) { imageName in
                Button {
                    selectedImageName = imageName
                } label: {
                    Image(imageName)
                        .resizable()
                        .clipShape(Circle())
                        .frame(width: 77, height: 77)
                }
            }
        }
    }
}
