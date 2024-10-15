//
//  MemoView.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI
import OrderedCollections

struct MemoView: View {
    @Bindable var homeviewModel = HomeViewDummy()
    var filteredMemos: [Memo]
    
    var body: some View {
        ScrollView {
            MasonryLayout(columns: 2, spacing: 16) {
                ForEach(filteredMemos) { memo in
                    NavigationLink(destination: MemoDetailView(memo: memo)) {
                        if let imageName = homeviewModel.imagesDic[memo.id] {
                            VStack {
                                Image(imageName)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .frame(width: UIScreen.main.bounds.width / 2 - 24, height: nil)
                                    .clipped()
                                    .cornerRadius(12)
                                    .scaledToFit()
                            }
                        } else {
                            Text("이미지가 없습니다.")
                        }
                    }
                }
            }
            .padding(.horizontal, 16)
        }
    }
}
