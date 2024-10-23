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
    
    @State var isColumnModifyingView: Bool = false
    @State var itemSheet: Bool = false // 글자에때라 쉬트 크기
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.background
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            VStack(alignment: .leading, spacing: 16) {
                                MemoHeaderView(
                                    memo: $memo,
                                    image: $image,
                                    showShareSheet: $showShareSheet,
                                    isCommentFieldFocused: $isCommentFieldFocused,
                                    commentCount: memo.comments?.count ?? 0 // 댓글 개수를 전달
                                )
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            Divider()
                                .padding(.bottom, 8)
                            
                            Text("댓글 \(memo.comments?.count ?? 0)")
                                .font(.footnote)
                                .bold()
                                .padding(.bottom, 8)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                CommentListView(displayedComments: bindingForDisplayedComments(), selectedComment: $selectedComment, showDeleteSheet: $showDeleteSheet)
                            }
                            .padding(.bottom, 8)
                            .background(Color.white)
                            .cornerRadius(12)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay( // 테두리 추가
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal, 16)
                    }
                    
                    // 하단에 고정된 댓글 입력 필드
                    CommentTextInputView(newComment: $newComment, isCommentFieldFocused: $isCommentFieldFocused, addComment: addComment)
                        .padding(.horizontal)
                }
            }
            .onTapGesture {
                UIApplication.shared.endEditing() // 화면을 탭하면 키보드 내려가도록 함
            }         
            .sheet(isPresented: $showShareSheet) {
                ShareSheetView(shareType: .memo(memo), isPresented: $showShareSheet, isColumnModifyingView: $isColumnModifyingView, itemSheet: $itemSheet, onDelete: {
                    dismiss()
                })
                    .presentationDetents([.height(150)])
                    .presentationDragIndicator(.hidden)
            }
            .sheet(isPresented: $showDeleteSheet) {
                DeleteSheetView(isPresented: $showDeleteSheet, onDelete: deleteComment, selectedComment: $selectedComment, itemSheet: $itemSheet)
                    .presentationDetents([itemSheet ? .height(150) : .height(100)])
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
                    Text("메모")
                        .font(.headline)
                        .foregroundColor(Color.accentColor)
                }
                ToolbarItem(placement: .navigationBarTrailing) {
                    Button(action: {
                        showShareSheet = true
                    }) {
                        Image(systemName: "ellipsis")
                            .foregroundColor(.gray)
                    }
                }
                
                // 키보드 위에 '완료' 버튼 추가
                ToolbarItemGroup(placement: .keyboard) {
                    Spacer() // 왼쪽 공간을 확보하여 버튼을 오른쪽으로 이동
                    Button("완료") {
                        isCommentFieldFocused = false // 키보드 숨기기
                    }
                }
            }
            .navigationBarTitleDisplayMode(.inline)
        }
    }

    
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
    
    private func bindingForDisplayedComments() -> Binding<[Comment]?> {
        Binding(
            get: {
                memo.comments
            },
            set: { newValue in
                if let newComments = newValue {
                    memo.comments = newComments
                }
            }
        )
    }
}

//#Preview {
//    MemoDetailView()
//        .environmentObject(UserInfoStore())
//        .environmentObject(MemoStore())
//        .environmentObject(CommentStore())
//}

//Memo(content: "안녕하세요", email: "김종혁", userNickname: "나눔고딕", font: "나눔고딕", backgroundImageName: "아무튼 이미지", categories: ["전체"], likes: ["ㄴㅇ", "ㄴㅇ"], date: Date(), lineCount: 2, comments: [])
