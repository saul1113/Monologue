//
//  CommentTextInputView.swift
//  Monologue
//
//  Created by 홍지수 on 10/18/24.
//

import SwiftUI
//댓글 입력창 뷰

struct CommentTextInputView: View {
    @Binding var newComment: String
    var isCommentFieldFocused: FocusState<Bool>.Binding
    var addComment: () -> Void
    
    var body: some View {
        HStack {
            ZStack(alignment: .trailing) {
                TextField("댓글을 입력하세요", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused(isCommentFieldFocused) // 포커스 상태 바인딩
                    .onSubmit {
                        addComment()
                        isCommentFieldFocused.wrappedValue = false
                    }
//                    .padding(.trailing, 30)
                
                if !newComment.isEmpty {
                    Button(action: {
                        if !newComment.isEmpty {
                            // 새로운 댓글 추가
                            addComment()
                            newComment = ""
                            isCommentFieldFocused.wrappedValue = false
                        }
                    }) {
                        Image(systemName: "arrowshape.up.circle.fill")
                            .resizable()
                            .foregroundColor(Color.accentColor)
                            .frame(width: 20, height: 20)
                    }
                    .padding(.trailing, 8)
//                    .transition(.move(edge: .trailing))  // 애니메이션 적용
                }
            }
        }
        .padding(.bottom, 16)
    }
}
