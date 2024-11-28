//
//  ProfileImageView.swift
//  Monologue
//
//  Created by Hyojeong on 10/16/24.
//

import SwiftUI

// 다른 뷰에서 프로필 사진을 쉽게 쓰기 위해(사이즈만 변경)

struct ProfileImageView: View {
    let profileImageName: String
    let size: CGFloat

    var body: some View {
        if !profileImageName.isEmpty {
            Image(profileImageName)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: size, height: size)
        } else {
            ZStack {
                Circle()
                    .frame(width: size, height: size)
                    .foregroundStyle(.accent.opacity(0.6))
                
                Image(systemName: "person.fill")
                    .resizable()
                    .aspectRatio(contentMode: .fit)
                    .frame(width: size * 0.6, height: size * 0.6)
                    .foregroundColor(.white)
            }
        }
    }
}
