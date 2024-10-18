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
    //    @EnvironmentObject var userInfoStore: UserInfoStore
    //    @EnvironmentObject private var authManager:AuthManager
    @State private var isLiked: Bool = false
    @State private var likesCount: Int = 0  // 좋아요 수를 관리할 상태 변수
    @State private var showAllComments = false  // 전체 댓글 보기 시트를 열기 위한 상태
    @State private var newComment = ""  // 새 댓글을 저장할 상태
    @State private var selectedComment: String?
    @State private var displayedComments: [String] = []  // 현재 보여지는 댓글 리스트
    @State private var showShareSheet: Bool = false  // 공유하기 시트 표시 여부 상태
    @State private var showDeleteSheet: Bool = false  // 삭제하기 시트 표시 여부 상태
    @State private var scrollViewProxy: ScrollViewProxy? // ScrollView 포커싱을 위한 Proxy
    @Environment(\.dismiss) private var dismiss
    @FocusState private var isCommentFieldFocused: Bool
    
    var body: some View {
        ZStack {
            Color.background
                .ignoresSafeArea()
            VStack {
                ScrollViewReader { proxy in
                    ScrollView {
                        //MARK: - 게시글 영역
                        VStack {
                            VStack() {
                                // 프로필 이미지, 닉네임, 시간 표시
                                HStack {
                                    Image(systemName: "person.circle.fill")
                                        .resizable()
                                        .frame(width: 30, height: 30)
                                        .clipShape(Circle())
//                                        .padding(.trailing, 8)
                                    Text(memo.userNickname)  // 닉네임
                                        .font(.subheadline)
                                        .bold()
                                    Spacer()
                                    Text(memo.date, style: .date)  // 게시 시간
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                }
                                .padding(.horizontal)
                                // 메모
                                
                                Image(memo.id)
                                    .resizable()
                                    .aspectRatio(contentMode: .fill)
                                    .foregroundColor(.black)
                                    .scaledToFit()
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
                                                .font(.footnote)
                                        }
                                        .foregroundStyle(.gray)
                                        .padding(.trailing, 5)
                                    }
                                    // 좋아요 버튼
                                    Button(action: {
                                        isLiked.toggle()  // 하트 상태를 반전시킴
                                        if isLiked {
                                            likesCount += 1  // 좋아요 추가
                                            memoStore.updateLikes(memoId: memo.id, userNickname: "사용자닉네임") { _ in }
                                            //                                userInfoStore.loadUserInfo { user, error in
                                            //                                    userInfoStore.userInfoStore = user ?? nil
                                            //                                }
                                            //                                memo.likes.append(userInfo.userInfo.nickname)
                                            //                                userInfoStore.loadUserInfo(email: authManager.email)
                                        } else {
                                            likesCount -= 1  // 좋아요 취소
                                            memoStore.updateLikes(memoId: memo.id, userNickname: "사용자닉네임") { _ in }
                                            //                                memo.likes.removeAll { $0 == "\(userInfoStore.loadUserInfo.nickname)" }
                                        }
                                    }) {
                                        HStack(spacing: 4) {
                                            Image(systemName: isLiked ? "heart.fill" : "heart")  // 좋아요 시 빨간 하트로 변경
                                                .foregroundColor(isLiked ? .red : .gray)  // 색상 설정
                                                .padding(.trailing, 5)
                                            Text("\(likesCount)")  // 좋아요 수 표시
                                                .font(.subheadline)
                                        }
                                        .foregroundStyle(.gray)
                                    }
                                    Spacer()
                                    Text(memo.categories.first ?? "카테고리 없음")
                                        .font(.footnote)
                                        .foregroundColor(.gray)
                                        .padding(8)
                                        .background(Color.gray.opacity(0.2))
                                        .cornerRadius(14)
                                }
                                .padding(.horizontal)
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(12)
                        .overlay( // 테두리 추가
                            RoundedRectangle(cornerRadius: 12)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        
                        // MARK: - 댓글 영역
                        VStack(alignment: .leading, spacing: 16) {
                            HStack {
                                Text("댓글 \(displayedComments.count)")
                                    .font(.subheadline)
                                Spacer()
                                Text("등록순")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                                Text("최신순")
                                    .foregroundColor(.gray)
                                    .font(.subheadline)
                            }
                            
                            ForEach(displayedComments, id: \.self) { comment in
                                VStack {
                                    HStack {
                                        Image(systemName: "person.circle.fill")
                                            .resizable()
                                            .frame(width: 30, height: 30)
                                        VStack(alignment: .leading) {
                                            Text(comment.userNickname)
                                                .font(.subheadline)
                                                .bold()
//                                            Text(comment.date, style: .date)  // 게시 시간
//                                                .font(.footnote)
//                                                .foregroundColor(.gray)
                                            Text(comment.content)
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
                                    Divider()
                                }
                            }
                        }
                        .padding()
                        .background(Color.white)
                        .cornerRadius(14)
                        .overlay( // 테두리 추가
                            RoundedRectangle(cornerRadius: 14)
                                .stroke(Color.gray.opacity(0.3), lineWidth: 1)
                        )
                        .padding(.horizontal)
                        
                        Spacer()
                    }
                    .padding(.top)
                    .onAppear {
                        // 처음에 좋아요 수를 설정
                        likesCount = memo.likes.count
                        displayedComments = memo.comments  // 초기 댓글 리스트 설정
                        
                        self.scrollViewProxy = proxy
                    }
                    
                }
                Spacer()
                
                
                // MARK: - 댓글 입력창
                HStack {
                    TextField("댓글을 입력하세요", text: $newComment, onCommit: {
                        addComment()  // Enter를 눌렀을 때 댓글 추가
                    })
                    .textFieldStyle(RoundedBorderTextFieldStyle())
                    .focused($isCommentFieldFocused) // 포커스 상태 바인딩
                    .onSubmit {
                        addComment()  // Enter를 눌렀을 때 댓글 추가
                    }
                    
                    // 업로드 버튼 (텍스트가 비어있지 않으면 나타남)
                    if !newComment.isEmpty {
                        Button(action: {
                            if !newComment.isEmpty {
                                // 새로운 댓글 추가
                                addComment()
                                newComment = ""
                            }
                        }) {
                            Image(systemName: "arrowshape.up.circle.fill")
                                .foregroundColor(Color.accentColor)
                                .frame(width: 30, height: 30)
                        }
//                        .transition(.move(edge: .trailing)) // 애니메이션 적용
                    }
                }
                .padding()
                .padding(.bottom)
                .background(Color.white)
            }
            .ignoresSafeArea(.keyboard, edges: .bottom) // 키보드가 입력창을 가리지 않도록
        }
        
        
        
        
        //MARK: - 시트
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
            ToolbarItem() {
                Text("칼럼")
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
    
    // 댓글을 추가하는 함수
    func addComment() {
        if !newComment.isEmpty {
            // 새로운 댓글을 배열에 추가
            displayedComments.insert(newComment, at: 0)
            
            // Firestore에 댓글 업데이트
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
        // 클라이언트에서 삭제
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

// 댓글 뷰
struct MemoCommentView: View {
    //    var column: Column
    let comment: String
    var body: some View {
        HStack {
            Image(systemName: "person.circle.fill")
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
