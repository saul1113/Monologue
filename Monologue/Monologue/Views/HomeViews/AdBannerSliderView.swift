//
//  AdBannerSliderView.swift
//  Monologue
//
//  Created by 강희창 on 10/22/24.
//

import SwiftUI

// 여러 개의 광고 이미지를 슬라이더로 보여주는 뷰
struct AdBannerSliderView: View {
    let images: [String]
    @State private var selectedIndex = 0
    
    var body: some View {
        TabView(selection: $selectedIndex) {
            ForEach(0..<images.count, id: \.self) { index in
                Image(images[index])
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: UIScreen.main.bounds.width / 2 - 24, height: 150)
                    .clipped()
                    .cornerRadius(12)
                    .tag(index)
            }
        }
        .frame(height: 150)
        .tabViewStyle(PageTabViewStyle(indexDisplayMode: .always))
        .cornerRadius(12)
    }
}

