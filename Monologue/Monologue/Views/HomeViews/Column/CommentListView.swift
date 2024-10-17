//
//  CommentListView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI

struct CommentListView: View {
    @Binding var displayedComments: [String]
    @Binding var selectedComment: String?
    @Binding var showDeleteSheet: Bool
    
    var body: some View {
        ForEach(displayedComments, id: \.self) { comment in
            HStack(alignment: .top, spacing: 16) {
                // 프로필 이미지
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                
                VStack(alignment: .leading, spacing: 4) {
                    Text("닉네임")
                        .font(.headline)
                    
                    Text(comment)
                        .font(.body)
                        .foregroundColor(.black)
                }
                Spacer()
                
                Button(action: {
                    selectedComment = comment
                    showDeleteSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.vertical, 8) // 댓글 간의 상하 여백
            .padding(.horizontal, 16)
        }
    }
}
