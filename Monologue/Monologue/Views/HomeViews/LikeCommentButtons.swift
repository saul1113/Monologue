//
//  LikeCommentButtons.swift
//  Monologue
//
//  Created by 홍지수 on 10/18/24.
//


import SwiftUI

struct LikeCommentButtons: View {
    @Binding var isLiked: Bool
    @Binding var likesCount: Int
    var commentCount: Int // 댓글 개수를 직접 전달받음
    var isCommentFieldFocused: FocusState<Bool>.Binding  // 추가된 부분
    
    var body: some View {
        HStack {
            // 댓글 버튼
            Button(action: {
                isCommentFieldFocused.wrappedValue = true  // 버튼을 누르면 포커스를 텍스트 필드로 이동
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    Text("\(commentCount)") // 댓글 개수 사용
                        .font(.subheadline)
                }
                .foregroundColor(.gray)
            }
            
            // 좋아요 버튼
            Button(action: {
                isLiked.toggle()
                if isLiked {
                    likesCount += 1
                } else {
                    likesCount -= 1
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                    Text("\(likesCount)")
                        .font(.subheadline)
                }
            }
        }
    }
}
