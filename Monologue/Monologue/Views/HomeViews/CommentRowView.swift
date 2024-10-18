//
//  MemoRowView.swift
//  Monologue
//
//  Created by 홍지수 on 10/18/24.
//

import SwiftUI

struct CommentRowView: View {
    let comment: String  // comment 프로퍼티를 정확하게 선언
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 30, height: 30)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text("닉네임")
                    .font(.subheadline)
                    .fontWeight(.bold)
                Text(comment)
                    .font(.footnote)
                    .foregroundColor(.black)
            }
        }
    }
}
