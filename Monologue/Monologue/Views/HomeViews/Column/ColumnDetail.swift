//
//  ColunmDetail.swift
//  Monologue
//
//  Created by 강희창 on 10/15/24.
//

import SwiftUI

struct ColumnDetail: View {
    @ObservedObject var columnStore = ColumnStore()
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
    
    var column: Column
    
    var body: some View {
        GeometryReader { geometry in
            ZStack {
                Color("#FFF8ED")
                    .edgesIgnoringSafeArea(.all)
                
                VStack(spacing: 0) {
                    ScrollView {
                        VStack(alignment: .leading, spacing: 0) {
                            // 게시글 섹션
                            VStack(alignment: .leading, spacing: 16) {
                                ColumnHeaderView(
                                    column: column,
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
                            
                            VStack(alignment: .leading, spacing: 0) {
                                CommentListView(displayedComments: $displayedComments, selectedComment: $selectedComment, showDeleteSheet: $showDeleteSheet)
                                Divider()
                            }
                            .padding(16)
                            .background(Color.white)
                            .cornerRadius(12)
                            //                            .padding(.horizontal, 16)
                        }
                        .padding(.vertical)
                    }
                    
                    // 하단에 고정된 댓글 입력 필드
                    CommentTextInputView(newComment: $newComment, isCommentFieldFocused: $isCommentFieldFocused, addComment: addComment)
                        .padding(.horizontal)
                        .background(Color.white) // 하단 배경색을 흰색으로 설정
                }
            }
            .onAppear {
                likesCount = column.likes.count
                //displayedComments = column.comments
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
            }
        }
    }
    
    func addComment() {
        if !newComment.isEmpty {
            displayedComments.append(newComment)
            columnStore.updateComment(columnId: column.id, userNickname: "사용자닉네임") { error in
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
        columnStore.updateComment(columnId: column.id, userNickname: commentToDelete) { error in
            if let error = error {
                print("Error deleting comment: \(error.localizedDescription)")
            } else {
                print("Comment deleted successfully.")
            }
        }
        selectedComment = nil
    }
}

extension Color {
    init(_ hex: String) {
        let scanner = Scanner(string: hex)
        _ = scanner.scanString("#")
        
        var rgb: UInt64 = 0
        scanner.scanHexInt64(&rgb)
        
        let r = Double((rgb >> 16) & 0xFF) / 255.0
        let g = Double((rgb >> 8) & 0xFF) / 255.0
        let b = Double(rgb & 0xFF) / 255.0
        
        self.init(red: r, green: g, blue: b)
    }
}

#Preview {
    ColumnDetail(column: Column(title: "예시타이틀", content: "Example content", email: "Test Email", userNickname: "북극성", font: "", backgroundImageName: "", categories: ["에세이"], likes: [], date: Date(), comments: []))
        .environmentObject(ColumnStore())
}
