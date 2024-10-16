//
//  MeMoDetailView.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI
import OrderedCollections

struct MemoDetailView: View {
    @State var memo: Memo
    @EnvironmentObject var memoStore: MemoStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    @State private var isLiked: Bool = false
    @State private var likesCount: Int = 0  // 좋아요 수를 관리할 상태 변수
    @State private var showAllComments = false  // 전체 댓글 보기 시트를 열기 위한 상태
    @State private var newComment = ""  // 새 댓글을 저장할 상태
    @State private var displayedComments: [String] = []  // 현재 보여지는 댓글 리스트
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                // 게시글 영역
                VStack(alignment: .leading, spacing: 16) {
                    // 프로필 이미지, 닉네임, 시간 표시
                    HStack {
                        Image(systemName: "person.circle.fill")
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text(memo.userNickname)  // 닉네임
                                .font(.headline)
                            Text(memo.date, style: .date)  // 게시 시간
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 메모
                    Image(memo.id)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .foregroundColor(.black)
                        .scaledToFit()
                    
                    // 댓글과 좋아요 버튼
                    HStack {
                        // 댓글 버튼
                        Button(action: {
                            showAllComments.toggle()  // 전체 댓글 보기 시트 열기
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.right")
                                Text("\(displayedComments.count)")  // 댓글 개수 표시
                                    .font(.subheadline)
                            }
                        }
                        
                        // 좋아요 버튼
                        Button(action: {
                            isLiked.toggle()  // 하트 상태를 반전시킴
                            if isLiked {
//                                userInfoStore.loadUserInfo { user, error in
//                                    userInfoStore.userInfoStore = user ?? nil
//                                }
//                                memo.likes.append(userInfo.userInfo.nickname)
//                                userInfoStore.loadUserInfo(email: authManager.email)
                            } else {
                                likesCount -= 1  // 좋아요 취소
//                                memo.likes.removeAll { $0 == "\(userInfoStore.loadUserInfo.nickname)" }
                            }
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")  // 좋아요 시 빨간 하트로 변경
                                    .foregroundColor(isLiked ? .red : .black)  // 색상 설정
                                Text("\(likesCount)")  // 좋아요 수 표시
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                        Text(memo.categories.first ?? "카테고리 없음")
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)
                    }
                }
                .padding()
                .background(Color.white)
                .cornerRadius(14)
                
                // MARK: - 댓글 영역
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
                    .padding(.horizontal)
                    
                    // 댓글 리스트 (2개까지만 표시)
                    ForEach(displayedComments.prefix(2), id: \.self) { comment in
                        MemoCommentView(comment: comment)
                    }
                    
                    // 댓글 더보기 버튼
                    if displayedComments.count > 2 {
                        Button(action: {
                            showAllComments.toggle()  // 전체 댓글 보기 시트 열기
                        }) {
                            Text("댓글 더 보기")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showAllComments) {
                            // 전체 댓글을 보여주는 시트
                            MemoCommentsSheetView(comments: $displayedComments, newComment: $newComment)
                        }
                    }
                }
                .padding()
                .cornerRadius(14)
                .padding(.horizontal)
                .background(Color.white)
                
                Spacer()
                
                // 댓글 입력창
                HStack {
                    TextField("댓글을 입력하세요", text: $newComment, onCommit: {
                        addComment()  // Enter를 눌렀을 때 댓글 추가
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    
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
                likesCount = memo.likes.count
                displayedComments = memo.comments  // 초기 댓글 리스트 설정
            }
        }
        .onAppear {
            Task {
                // 유저의 정보 로드
                await userInfoStore.loadUserInfo(email: authManager.email)
            }
        }
    }
    
    // 댓글을 추가하는 함수
    func addComment() {
        if !newComment.isEmpty {
            // 새로운 댓글을 배열에 추가
            displayedComments.append(newComment)
            
            // Firestore에 댓글 업데이트
            memoStore.updateComment(memoId: memo.id, userNickname: "사용자닉네임") { error in
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
}

// 댓글 뷰
struct MemoCommentView: View {
    let comment: String
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading) {
                Text(comment)
                    .font(.body)
                    .foregroundColor(.gray)
            }
            Spacer()
        }
        .padding(.horizontal)
    }
}

// 전체 댓글 시트 뷰 (댓글 더보기 시트에서도 동일한 동작 적용)
struct MemoCommentsSheetView: View {
    @Binding var comments: [String]  // 댓글 배열을 바인딩하여 전달
    @Binding var newComment: String
    
    var body: some View {
        VStack {
            Text("댓글")
                .font(.title2)
                .bold()
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(comments, id: \.self) { comment in
                        CommentView(comment: comment)
                    }
                }
                .padding()
            }
            
            // 댓글 입력창
            HStack {
                TextField("댓글을 입력하세요", text: $newComment)
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                Button(action: {
                    if !newComment.isEmpty {
                        comments.append(newComment)  // 새 댓글을 comments 배열에 추가
                        newComment = ""  // 입력 필드 초기화
                    }
                }) {
                    Text("등록")
                }
            }
            .padding()
        }
    }
}


//#Preview {
//    ColumnDetail(column: Column(content: "Example content", userNickname: "북극성", font: "", backgroundImageName: "", categories: ["에세이"], likes: [], comments: ["댓글 1", "댓글 2", "댓글 3"], date: Date()))
//        .environmentObject(ColumnStore())
//}
