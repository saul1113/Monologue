//
//  ColunmDetail.swift
//  Monologue
//
//  Created by 강희창 on 10/15/24.
//

import SwiftUI

struct ColumnDetail: View {
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject var columnStore: ColumnStore
    @EnvironmentObject var commentStore: CommentStore
    @State private var showAllComments = false
    @State private var newComment = ""
    @State private var showShareSheet: Bool = false
    @State private var showDeleteSheet: Bool = false
    @State private var selectedComment: Comment?
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFieldFocused: Bool
    
    @Binding var column: Column
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color.background
                    .ignoresSafeArea()
                VStack {
                    ScrollView {
                        VStack(alignment: .leading) {
                            // 게시글 섹션
                            VStack(alignment: .leading, spacing: 16) {
                                ColumnHeaderView(
                                    column: $column,
                                    showShareSheet: $showShareSheet,
                                    isCommentFieldFocused: $isCommentFieldFocused,
                                    commentCount: column.comments?.count ?? 0 // 댓글 개수를 전달
                                )
                            }
                            .background(Color.white)
                            .cornerRadius(12)
                            
                            Divider()
                                .padding(.bottom, 8)
                            
                            Text("댓글 \(column.comments?.count ?? 0)")
                                .font(.footnote)
                                .bold()
                                .padding(.bottom, 8)
                            
                            VStack(alignment: .leading, spacing: 0) {
                                CommentListView(displayedComments: bindingForDisplayedComments(), selectedComment: $selectedComment, showDeleteSheet: $showDeleteSheet)
                            }
                            .padding(.bottom, 8)
                            .background(Color.white)
                            .cornerRadius(12)
                            //                            .padding(.horizontal, 16)
                        }
                        .padding(16)
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay {
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        }
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
                    Text("칼럼")
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
            print(userInfoStore.userInfo?.email ?? "")
            let tempComment = Comment(userNickname: userInfoStore.userInfo?.nickname ?? "",
                                      content: newComment,
                                      date: Date.now)
            Task {
                try await commentStore.addComment(columnId: column.id, comment: tempComment)
                column.comments?.append(tempComment)
                newComment = ""
            }
        }
    }
    func deleteComment() {
        guard let commentToDelete = selectedComment else { return }
        
        Task {
            try await commentStore.deleteComment(columnId: column.id, commentId: commentToDelete.id)
            column.comments?.removeAll { $0 == commentToDelete }
        }
        
        selectedComment = nil
    }
    
    private func bindingForDisplayedComments() -> Binding<[Comment]?> {
        Binding(
            get: {
                column.comments
            },
            set: { newValue in
                if let newComments = newValue {
                    column.comments = newComments
                }
            }
        )
    }
}
