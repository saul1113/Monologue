//
//  AdBannerView.swift
//  Monologue
//
//  Created by 강희창 on 10/22/24.
//

import SwiftUI

struct AdBannerView: View {
    
    let adURL: URL = URL(string: "https://likelion.net/")!
    let images: [String] = ["banner1", "banner2", "banner3"]
    
    @State private var selectedIndex = 0
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    var body: some View {
        VStack(spacing: 16) {
            // 자동 슬라이드 배너
            TabView(selection: $selectedIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    ZStack(alignment: .bottomTrailing) {
                        Button(action: {
                            UIApplication.shared.open(adURL)
                        }) {
                            Image(images[index])
                                .resizable()
                                .aspectRatio(contentMode: .fit)  // 이미지가 fit하게 맞게 설정
                                .frame(height: 150)
                                .cornerRadius(12)
                        }
                        Text("AD")
                            .font(.caption2)
                            .foregroundColor(.gray)
                            .padding(8)
                            .background(Color.white.opacity(0.7))
                            .cornerRadius(4)
                            .padding(10)
                    }
                    .tag(index)
                }
            }
            .tabViewStyle(PageTabViewStyle(indexDisplayMode: .automatic))  // 페이지 표시 추가
            .frame(height: 150)
            .cornerRadius(12)
            .onReceive(timer) { _ in
                withAnimation {
                    selectedIndex = (selectedIndex + 1) % images.count
                }
            }
        }
        .padding(.horizontal, 16)
    }
}

struct AdBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AdBannerView()
            .previewLayout(.sizeThatFits)
    }
}
