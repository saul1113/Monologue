//
//  MeMoDetailView.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI

struct MemoDetailView: View {
    @ObservedObject var memoStore = MemoStore()
    @State private var isLiked: Bool = false
    @State private var likesCount: Int = 0
    @State private var showAllComments = false
    @State private var newComment = ""
    @State private var displayedComments: [String] = []
    @State private var showShareSheet: Bool = false
    @State private var showDeleteSheet: Bool = false
    @State private var selectedComment: String?
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFieldFocused: Bool
    
    var memo: Memo = Memo(content: "안녕하세요", userNickname: "김종혁", font: "나눔고딕", backgroundImageName: "image1", categories: ["전체"], likes: ["23", "12"], comments: ["ㄴㅇ", "ㄴㅇ"], date: Date(), lineCount: 2)
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.background
                    .ignoresSafeArea()
                VStack() {
                    ScrollView {
                        VStack(alignment: .leading) {
                            // 게시글 섹션
                            VStack(alignment: .leading, spacing: 16) {
                                MemoHeaderView(
                                    memo: memo,
                                    likesCount: $likesCount,
                                    isLiked: $isLiked,
                                    showShareSheet: $showShareSheet,
                                    isCommentFieldFocused: $isCommentFieldFocused,
                                    commentCount: displayedComments.count // 댓글 개수를 전달
                                )
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            Divider()
                            
                            Text("댓글 \(displayedComments.count)")
                                .font(.footnote)
                                .bold()
                                .padding(16)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                CommentListView(displayedComments: $displayedComments, selectedComment: $selectedComment, showDeleteSheet: $showDeleteSheet)
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay( // 테두리 추가
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                    }
                    
                    // 하단에 고정된 댓글 입력 필드
                    CommentTextInputView(newComment: $newComment, isCommentFieldFocused: $isCommentFieldFocused, addComment: addComment)
                        .padding(.horizontal)
                }
            }
            .onAppear {
                likesCount = memo.likes.count
                displayedComments = memo.comments
            }
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(isPresented: $showShareSheet)
                    .presentationDetents([.height(150)])
                    .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showDeleteSheet) {
                DeleteSheetView(isPresented: $showDeleteSheet, onDelete: deleteComment)
                    .presentationDetents([.height(150)])
                    .presentationDragIndicator(.hidden)
            }
            .navigationBarBackButtonHidden(true)
            .toolbar {
                ToolbarItem(placement: .navigationBarLeading) {
                    Button(action: { dismiss() }) {
                        Image(systemName: "chevron.backward")
                    }
                }
                ToolbarItem(placement: .principal) {
                    Text("칼럼") // 중앙의 텍스트
                        .font(.headline)
                        .foregroundColor(Color.accentColor) // 색상을 갈색으로 설정
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
            }
        }
    }
    
    func addComment() {
        if !newComment.isEmpty {
            displayedComments.append(newComment)
            memoStore.updateComment(memoId: memo.id, userNickname: "사용자닉네임") { error in
                if let error = error {
                    print("Error updating comment: \(error.localizedDescription)")
                } else {
                    print("Comment updated successfully.")
                }
            }
            newComment = ""
        }
    }
    
    func deleteComment() {
        guard let commentToDelete = selectedComment else { return }
        displayedComments.removeAll { $0 == commentToDelete }
        memoStore.updateComment(memoId: memo.id, userNickname: commentToDelete) { error in
            if let error = error {
                print("Error deleting comment: \(error.localizedDescription)")
            } else {
                print("Comment deleted successfully.")
            }
        }
        selectedComment = nil
    }
}

#Preview {
    MemoDetailView()
}
