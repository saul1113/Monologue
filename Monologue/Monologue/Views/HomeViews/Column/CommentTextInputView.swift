//
//  CommentTextInputView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI
//댓글 입력창 뷰

struct CommentTextInputView: View {
    @Binding var newComment: String
    var isCommentFieldFocused: FocusState<Bool>.Binding
    var addComment: () -> Void
    
    var body: some View {
        HStack {
            TextField("댓글을 입력하세요", text: $newComment)
                .textFieldStyle(RoundedBorderTextFieldStyle())
                .focused(isCommentFieldFocused) // 포커스 상태 바인딩
                .onSubmit {
                    addComment()
                }
            
            Button(action: {
                addComment()
            }) {
                Text("등록")
            }
        }
        .padding(.horizontal)
        .padding(.bottom)
    }
}
