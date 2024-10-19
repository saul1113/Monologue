//
//  MemoHeaderView.swift
//  Monologue
//
//  Created by 홍지수 on 10/18/24.
//

import SwiftUI
//칼럼디테일 게시글 뷰
struct MemoHeaderView: View {
    @Binding var memo: Memo
    @Binding var image: UIImage
    @Binding var likesCount: Int
    @Binding var isLiked: Bool
    @Binding var showShareSheet: Bool
    var isCommentFieldFocused: FocusState<Bool>.Binding
    var commentCount: Int // 댓글 수를 전달받기 위한 변수 추가
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
                Text(memo.userNickname)
                    .font(.subheadline)
                Spacer()
                Text(memo.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
            
            VStack(alignment: .leading, spacing: 8) {
//                Text(memo.content)
//                    .font(.body)
//                    .foregroundColor(.black)
            }
            .padding(.horizontal)
            
            HStack {
                // 댓글 개수를 전달하여 실시간 업데이트가 되도록 수정
                LikeCommentButtons(isLiked: $isLiked, likesCount: $likesCount, commentCount: commentCount, isCommentFieldFocused: isCommentFieldFocused)
                Spacer()
                Text(memo.categories.first ?? "전체")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
            }
            .padding(16)
            .background(Color.white)
            .cornerRadius(12)
            //            .padding(.horizontal, 16)
        }
    }
}
