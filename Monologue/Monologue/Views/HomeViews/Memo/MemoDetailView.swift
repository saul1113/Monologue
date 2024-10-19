//
//  MeMoDetailView.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI

struct MemoDetailView: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var memoStore: MemoStore
    @EnvironmentObject var commentStore: CommentStore
    @State private var isLiked: Bool = false
    @State private var likesCount: Int = 0
    @State private var showAllComments = false
    @State private var newComment = ""
    @State private var displayedComments: [Comment] = []
    @State private var showShareSheet: Bool = false
    @State private var showDeleteSheet: Bool = false
    @State private var selectedComment: Comment?
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFieldFocused: Bool
    
    @Binding var memo: Memo
    @Binding var image: UIImage
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.background
                    .ignoresSafeArea()
                VStack() {
                    ScrollView {
                        VStack(alignment: .leading) {
                            Image(uiImage: image)
                                .resizable()
                                .aspectRatio(contentMode: .fit)
                            VStack(alignment: .leading, spacing: 16) {
                                MemoHeaderView(
                                    memo: memo,
                                    likesCount: $likesCount,
                                    isLiked: $isLiked,
                                    showShareSheet: $showShareSheet,
                                    isCommentFieldFocused: $isCommentFieldFocused,
                                    commentCount: memo.comments?.count ?? 0 // 댓글 개수를 전달
                                )
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            Divider()
                            
                            Text("댓글 \(memo.comments?.count ?? 0)")
                                .font(.footnote)
                                .bold()
                                .padding(16)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                CommentListView(displayedComments: $memo.comments, selectedComment: $selectedComment, showDeleteSheet: $showDeleteSheet)
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
                //displayedComments = memo.comments
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
    
//    func addComment() {
//        if !newComment.isEmpty {
//            displayedComments.append(newComment)
//            memoStore.updateComment(memoId: memo.id, email: memo.email) { error in
//                if let error = error {
//                    print("Error updating comment: \(error.localizedDescription)")
//                } else {
//                    print("Comment updated successfully.")
//                }
//            }
//            newComment = ""
//        }
//    }
    
    func addComment() {
        if !newComment.isEmpty {
            let tempComment = Comment(userNickname: userInfoStore.userInfo?.nickname ?? "",
                                      content: newComment,
                                      date: Date.now)
            Task {
                try await commentStore.addComment(memoId: memo.id, comment: tempComment)
                self.memo.comments?.append(tempComment)
                newComment = ""
            }
        }
    }
    
    func deleteComment() {
        guard let commentToDelete = selectedComment else { return }
               
        Task {
            try await commentStore.deleteComment(memoId: memo.id, commentId: commentToDelete.id)
            memo.comments?.removeAll { $0 == commentToDelete }
        }
            
        selectedComment = nil
    }
}

//#Preview {
//    MemoDetailView()
//        .environmentObject(UserInfoStore())
//        .environmentObject(MemoStore())
//        .environmentObject(CommentStore())
//}

//Memo(content: "안녕하세요", email: "김종혁", userNickname: "나눔고딕", font: "나눔고딕", backgroundImageName: "아무튼 이미지", categories: ["전체"], likes: ["ㄴㅇ", "ㄴㅇ"], date: Date(), lineCount: 2, comments: [])
