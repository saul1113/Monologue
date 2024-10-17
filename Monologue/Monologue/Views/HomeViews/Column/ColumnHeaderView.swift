//
//  ColumnHeaderView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI
//칼럼디테일 게시글 뷰
struct ColumnHeaderView: View {
    var column: Column
    @Binding var likesCount: Int
    @Binding var isLiked: Bool
    @Binding var showShareSheet: Bool
    var isCommentFieldFocused: FocusState<Bool>.Binding
    var commentCount: Int // 댓글 수를 전달받기 위한 변수 추가
    
    var body: some View {
        VStack(alignment: .leading, spacing: 16) {
            HStack(alignment: .top, spacing: 16) {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 40, height: 40)
                    .clipShape(Circle())
                VStack(alignment: .leading, spacing: 4) {
                    Text(column.userNickname)
                        .font(.headline)
                    Text(column.date, style: .date)
                        .font(.subheadline)
                        .foregroundColor(.gray)
                }
                Spacer()
                Button(action: {
                    showShareSheet = true
                }) {
                    Image(systemName: "ellipsis")
                        .foregroundColor(.gray)
                }
            }
            .padding(.horizontal)
            
            VStack(alignment: .leading, spacing: 8) {
                Text(column.title)
                    .font(.title3)
                    .bold()
                Text(column.content)
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            
            HStack {
                // 댓글 개수를 전달하여 실시간 업데이트가 되도록 수정
                LikeCommentButtons(isLiked: $isLiked, likesCount: $likesCount, commentCount: commentCount, isCommentFieldFocused: isCommentFieldFocused)
                Spacer()
                Text(column.categories.first ?? "카테고리 없음")
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            //            .padding(.horizontal, 16)
        }
    }
}
