//
//  ProfileImageView.swift
//  Monologue
//
//  Created by Hyojeong on 10/16/24.
//

import SwiftUI

// 다른 뷰에서 프로필 사진을 쉽게 쓰기 위해
struct ProfileImageView: View {
    let profileImageName: String

    var body: some View {
        if let uiImage = UIImage(named: profileImageName) {
            Image(uiImage: uiImage)
                .resizable()
                .aspectRatio(contentMode: .fill)
                .clipShape(Circle())
                .frame(width: 77, height: 77)
        } else {
            Circle()
                .frame(width: 77, height: 77)
        }
    }
}
