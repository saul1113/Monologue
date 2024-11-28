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
                    .padding(.vertical, 10)
                    .padding(.leading, 10)  // 좌우 패딩 추가
                    .padding(.trailing, 30)
                    .background(.white)
                    .cornerRadius(25)
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                    )
//                    .padding(.horizontal)  // 좌우 여유 공간 추가
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
//                            .background {
//                                Circle()
//                                    .frame(width: 20, height: 20)
//                                    .foregroundStyle(.white)
//                            }
                    }
                    .padding(.trailing, 8)
                    //                    .transition(.move(edge: .trailing))  // 애니메이션 적용
                }
            }
        }
        .padding(.bottom, 16)
    }
}
extension UIApplication {
    func endEditing() {
        // 현재 포커스된 뷰의 포커스를 해제하여 키보드를 내림
        sendAction(#selector(UIResponder.resignFirstResponder), to: nil, from: nil, for: nil)
    }
}
