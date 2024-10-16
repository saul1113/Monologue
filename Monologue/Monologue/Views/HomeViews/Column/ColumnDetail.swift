//
//  ColunmDetail.swift
//  Monologue
//
//  Created by 강희창 on 10/15/24.
//

import SwiftUI

struct ColumnDetail: View {
    @ObservedObject var columnStore = ColumnStore()  // ColumnStore 인스턴스
    @State private var isLiked: Bool = false
    @State private var likesCount: Int = 0  // 좋아요 수를 관리할 상태 변수
    @State private var showAllComments = false  // 전체 댓글 보기 시트를 열기 위한 상태
    @State private var newComment = ""  // 새 댓글을 저장할 상태
    @State private var displayedComments: [String] = []  // 현재 보여지는 댓글 리스트
    @State private var showShareSheet: Bool = false  // 공유하기 시트 표시 여부 상태
    @State private var showDeleteSheet: Bool = false  // 삭제하기 시트 표시 여부 상태
    @State private var selectedComment: String? 
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFieldFocused: Bool
    
    var column: Column  // Column 데이터를 외부에서 받아오도록 수정
    
    var body: some View {
        ZStack {
            // 배경색 설정
            Color(hex: "#FFF8ED")  // 사용자 선호 색상
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // 게시글 영역
                VStack(alignment: .leading, spacing: 16) {
                    // 프로필 이미지, 닉네임, 시간 표시
                    HStack {
                        Image(systemName: "person.circle")  // 프로필 이미지
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(column.userNickname)  // 닉네임
                                .font(.headline)
                            Text(column.date, style: .date)  // 게시 시간
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                        Spacer()
                        Button(action: {
                            showShareSheet = true
                        }) {
                            Image(systemName: "ellipsis")
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 게시글 제목과 내용
                    VStack(alignment: .leading, spacing: 8) {
                        Text(column.title)
                            .font(.title3)
                            .bold()
                        Text(column.content)
                            .font(.body)
                            .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // 댓글과 좋아요 버튼
                    HStack {
                        // 댓글 버튼
                        Button(action: {
                            isCommentFieldFocused = true
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.right")
                                Text("\(displayedComments.count)")  // 댓글 개수 표시
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.gray)
                        }
                        
                        // 좋아요 버튼
                        Button(action: {
                            isLiked.toggle()  // 하트 상태를 반전시킴
                            if isLiked {
                                likesCount += 1  // 좋아요 추가
                                columnStore.updateLikes(columnId: column.id, userNickname: "사용자닉네임") { _ in }
                            } else {
                                likesCount -= 1  // 좋아요 취소
                                columnStore.updateLikes(columnId: column.id, userNickname: "사용자닉네임") { _ in }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")  // 좋아요 시 빨간 하트로 변경
                                    .foregroundColor(isLiked ? .red : .gray)  // 색상 설정
                                Text("\(likesCount)")  // 좋아요 수 표시
                                    .font(.subheadline)
                            }
                            .foregroundStyle(.gray)
                        }
                        Spacer()
                        Text(column.categories.first ?? "카테고리 없음")  // 카테고리 텍스트
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)  // 여백 추가
                    }
                    .padding(.horizontal)
                }
                .padding()
                .background(Color.white)  // 게시글의 배경을 흰색으로 설정
                .cornerRadius(10)  // 모서리를 둥글게 처리
                
                // 댓글 영역
                ScrollView {
                    VStack(alignment: .leading, spacing: 16) {
                        HStack {
                            Text("댓글 \(displayedComments.count)")
                                .font(.headline)
                            Spacer()
                            Text("등록순")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                            Text("최신순")
                                .foregroundColor(.gray)
                                .font(.subheadline)
                        }
                        .padding()
                        
                        ForEach(displayedComments, id: \.self) { comment in
                            HStack {
                                Image(systemName: "person.circle")
                                    .resizable()
                                    .frame(width: 40, height: 40)
                                    .clipShape(Circle())
                                    .padding(5)
                                VStack(alignment: .leading) {
                                    Text("닉네임")
                                        .font(.caption2)
                                        .font(Font.headline.weight(.bold))
                                    Text(comment)
                                        .font(.caption)
                                        .foregroundColor(.black)
                                }
                                Spacer()
                                Button(action: {
                                    selectedComment = comment
                                    showDeleteSheet = true
                                }) {
                                    Image(systemName: "ellipsis")
                                        .foregroundColor(.gray)
                                }
                            }
                            .padding(.horizontal)
                        }
                    }
                }
                .cornerRadius(10)  // 모서리를 둥글게 처리
                .padding(.horizontal)
                .background(Color.white)
                
                Spacer()
                
                // 댓글 입력창
                HStack {
                    TextField("댓글을 입력하세요", text: $newComment)
                        .textFieldStyle(RoundedBorderTextFieldStyle())
                        .focused($isCommentFieldFocused) // 포커스 상태 바인딩
                        .onSubmit {
                            addComment()  // Enter를 눌렀을 때 댓글 추가
                        }
                    
                    Button(action: {
                        addComment()  // 등록 버튼을 눌렀을 때 댓글 추가
                    }) {
                        Text("등록")
                    }
                }
                .padding(.horizontal)
                .padding(.bottom)
            }
            .padding(.top)
            .onAppear {
                // 처음에 좋아요 수를 설정
                likesCount = column.likes.count
                displayedComments = column.comments  // 초기 댓글 리스트 설정
            }
        }
        .sheet(isPresented: $showShareSheet) {
            ShareSheetView(isPresented: $showShareSheet)
                .presentationDetents([.height(150)]) // 시트 높이를 버튼 수에 맞게 설정
                .presentationDragIndicator(.hidden) // 드래그 인디케이터를 숨겨서 깔끔하게
        }
        .sheet(isPresented: $showDeleteSheet) {
            DeleteSheetView(isPresented: $showDeleteSheet, onDelete: {
                deleteComment()
            })
            .presentationDetents([.height(150)]) // 시트 높이를 버튼 수에 맞게 설정
            .presentationDragIndicator(.hidden) // 드래그 인디케이터를 숨겨서 깔끔하게
        }
        .navigationBarBackButtonHidden(true) // 기본 백 버튼 숨기기
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) { // 위치를 .navigationBarLeading으로 설정
                Button(action: {
                    dismiss() // dismiss를 사용해 이전 화면으로 돌아가기
                }) {
                    Image(systemName: "chevron.backward") // "Back" 텍스트 없이 화살표 아이콘만 표시
                }
            }
        }
    }
    
    // 댓글을 추가하는 함수
    func addComment() {
        if !newComment.isEmpty {
            // 새로운 댓글을 배열에 추가
            displayedComments.append(newComment)
            
            // Firestore에 댓글 업데이트
            columnStore.updateComment(columnId: column.id, userNickname: "사용자닉네임") { error in
                if let error = error {
                    print("Error updating comment: \(error.localizedDescription)")
                } else {
                    print("Comment updated successfully.")
                }
            }
            
            // 입력 필드 초기화
            newComment = ""
        }
    }
    func deleteComment() {
            guard let commentToDelete = selectedComment else { return }
            // 클라이언트에서 삭제
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

// 댓글 뷰
struct CommentView: View {
    //    var column: Column
    let comment: String
    var body: some View {
        HStack {
            Image(systemName: "person.circle")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
                .padding(5)
            VStack(alignment: .leading) {
                Text("닉네임")
                    .font(.caption2)
                    .font(Font.headline.weight(.bold))
                Text(comment)
                    .font(.caption)
                    .foregroundColor(.black)
            }
        }
    }
}



// 확장 함수: HEX 색상 코드를 SwiftUI에서 사용 가능하게 하는 방법
extension Color {
    init(hex: String) {
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
    ColumnDetail(column: Column(title: "예시타이틀", content: "Example content", userNickname: "북극성", font: "", backgroundImageName: "", categories: ["에세이"], likes: [], comments: ["댓글 1", "댓글 2"], date: Date()))
        .environmentObject(ColumnStore())
}
