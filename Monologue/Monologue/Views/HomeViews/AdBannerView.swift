//
//  AdBannerView.swift
//  Monologue
//
//  Created by 강희창 on 10/22/24.
//

import SwiftUI
import SafariServices

struct AdBannerView: View {
    
    let adURL: URL = URL(string: "https://likelion.net/")!
    let images: [String] = ["banner1", "banner2", "banner3"]
    
    @State private var selectedIndex = 0
    @State private var timer = Timer.publish(every: 3, on: .main, in: .common).autoconnect()
    
    @State private var isShowingSafariView = false
    
    var body: some View {
        VStack(spacing: 16) {
            // 자동 슬라이드 배너
            TabView(selection: $selectedIndex) {
                ForEach(0..<images.count, id: \.self) { index in
                    ZStack(alignment: .bottomTrailing) {
                        Button(action: {
                            isShowingSafariView = true
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
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(.gray, lineWidth: 0.5))
        .padding(.vertical, 1)
        .sheet(isPresented: $isShowingSafariView) {
            SafariView(url: adURL)
        }
    }
}

struct SafariView: UIViewControllerRepresentable {
    let url: URL
    
    func makeUIViewController(context: UIViewControllerRepresentableContext<SafariView>) -> SFSafariViewController {
        return SFSafariViewController(url: url)
    }
    
    func updateUIViewController(_ uiViewController: SFSafariViewController, context: UIViewControllerRepresentableContext<SafariView>) {
        // 업데이트는 필요하지 않으므로 빈 메서드
    }
}

struct AdBannerView_Previews: PreviewProvider {
    static var previews: some View {
        AdBannerView()
            .previewLayout(.sizeThatFits)
    }
}
