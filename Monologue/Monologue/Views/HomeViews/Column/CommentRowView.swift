//
//  CommentRowView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI

struct CommentRowView: View {
    let comment: String  // comment 프로퍼티를 정확하게 선언
    
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .padding(5)
            VStack(alignment: .leading) {
                Text("닉네임")
                    .font(.caption2)
                    .fontWeight(.bold)
                Text(comment)
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
    }
}
