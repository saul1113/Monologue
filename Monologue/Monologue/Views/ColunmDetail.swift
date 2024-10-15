//
//  ColunmDetail.swift
//  Monologue
//
//  Created by 강희창 on 10/15/24.
//
import SwiftUI

struct ColunmDetail: View {
    @State private var isLiked: Bool = false
    @State private var likeCount: Int = 5
    @State private var showAllComments = false  // 시트를 열기 위한 상태
    @State private var newComment = ""  // 새 댓글을 저장할 상태
    
    var body: some View {
        ZStack {
            // 배경색 설정
            Color(.accent)
                .edgesIgnoringSafeArea(.all)
            
            VStack {
                // 게시글 영역
                VStack(alignment: .leading, spacing: 16) {
                    // 프로필 이미지, 닉네임, 시간 표시
                    HStack {
                        Image(systemName: "person.circle.fill")  // 프로필 이미지
                            .resizable()
                            .frame(width: 40, height: 40)
                            .clipShape(Circle())
                        VStack(alignment: .leading) {
                            Text("북극성")  // 닉네임
                                .font(.headline)
                            Text("24/10/14 · 6:22PM")  // 게시 시간
                                .font(.subheadline)
                                .foregroundColor(.gray)
                        }
                    }
                    .padding(.horizontal)
                    
                    // 게시글 제목과 내용
                    VStack(alignment: .leading, spacing: 8) {
                        Text("Lorem Ipsum is simply dummy text")
                            .font(.title3)
                            .bold()
                        Text("""
                        Lorem Ipsum is simply dummy text of the printing and typesetting industry. Lorem Ipsum has been the industry's standard dummy text ever since the 1500s, when an unknown printer took a galley of type and scrambled it to make a type specimen book.
                        """)
                        .font(.body)
                        .foregroundColor(.black)
                    }
                    .padding(.horizontal)
                    
                    // 댓글과 좋아요 버튼
                    HStack {
                        // 댓글 버튼
                        Button(action: {
                            showAllComments.toggle()  // 전체 댓글 보기 시트 열기
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: "bubble.right")
                                Text("\(column comments.count)")  // 댓글 개수 표시
                                    .font(.subheadline)
                            }
                        }
                        
                        // 좋아요 버튼
                        Button(action: {
                            isLiked.toggle()  // 하트 상태를 반전시킴
                            likeCount += isLiked ? 1 : -1
                        }) {
                            HStack(spacing: 4) {
                                Image(systemName: isLiked ? "heart.fill" : "heart")  // 좋아요 시 빨간 하트로 변경
                                    .foregroundColor(isLiked ? .red : .black)  // 색상 설정
                                Text("\(likeCount)")
                                    .font(.subheadline)
                            }
                        }
                        Spacer()
                        Text("에세이")  // 카테고리 텍스트
                            .font(.footnote)
                            .foregroundColor(.gray)
                            .padding(.trailing, 8)  // 여백 추가
                    }
                }
                .padding()
                .background(Color.white)  // 게시글의 배경을 흰색으로 설정
                .cornerRadius(10)  // 모서리를 둥글게 처리
                
                // 댓글 영역
                VStack(alignment: .leading, spacing: 16) {
                    HStack {
                        Text("댓글 \(comments.count)")
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
                    ForEach(comments.prefix(2)) { comment in
                        CommentView(comment: comment)
                    }
                    
                    // 댓글 더보기 버튼
                    if comments.count > 2 {
                        Button(action: {
                            showAllComments.toggle()  // 전체 댓글 보기 시트 열기
                        }) {
                            Text("댓글 더 보기")
                                .foregroundColor(.blue)
                        }
                        .sheet(isPresented: $showAllComments) {
                            // 전체 댓글을 보여주는 시트
                            CommentsSheetView(comments: $comments, newComment: $newComment)
                        }
                    }
                }
                .padding()
                .cornerRadius(10)  // 모서리를 둥글게 처리
                .padding(.horizontal)
                .background(Color.white)
                
                Spacer()
            }
            .padding(.top)
        }
    }
}

// 댓글 뷰 (메인 댓글과 더보기 댓글 모두에 적용)
struct CommentView: View {
    let comment: Comment
    @State private var showReportSheet = false  // 각 댓글마다 개별적인 상태로 ActionSheet 관리
    @State private var showReportReasonSheet = false  // 각 댓글마다 개별적인 상태로 신고 이유 선택 시트 관리
    
    var body: some View {
        HStack(alignment: .top) {
            Image(systemName: "person.circle.fill")
                .resizable()
                .frame(width: 40, height: 40)
                .clipShape(Circle())
            VStack(alignment: .leading) {
//                Text(comment.author)
//                    .font(.headline)
                Text("\(comment.date)")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Text("\(comment.content)")
                    .font(.body)
                    .foregroundColor(.gray)
            }
            Spacer()
            // ... 버튼 우측 상단에 배치
            Button(action: {
                showReportSheet.toggle()  // ActionSheet 표시
            }) {
                Image(systemName: "ellipsis")
                    .foregroundColor(.gray)
            }
        }
        .padding(.horizontal)
        // 각 댓글에 대한 ActionSheet 관리
        .actionSheet(isPresented: $showReportSheet) {
            ActionSheet(
                title: Text("댓글 관리"),
                buttons: [
                    .default(Text("공유하기")),
                    .destructive(Text("신고하기")) {
                        // 신고하기 누르면 신고 이유 시트 표시
                        showReportReasonSheet.toggle()
                    },
                    .cancel(Text("취소"))
                ]
            )
        }
        // 신고 이유 선택 시트 관리
        .sheet(isPresented: $showReportReasonSheet) {
            VStack {
                Text("신고 이유 선택")
                    .font(.headline)
                    .padding(.top)
                
                List {
                    Button("스팸") { /* 신고 처리 */ }
                    Button("비속어 및 욕설") { /* 신고 처리 */ }
                    Button("협오 및 음란 내용") { /* 신고 처리 */ }
                    Button("기타") { /* 신고 처리 */ }
                }
                
                Spacer()
                
                Button("취소") {
                    showReportReasonSheet = false
                }
                .padding(.bottom)
            }
            .presentationDetents([.fraction(0.4)])
        }
    }
}

// 전체 댓글 시트 뷰 (댓글 더보기 시트에서도 동일한 동작 적용)
struct CommentsSheetView: View {
    @Binding var comments: [Comment]  // 댓글 배열을 바인딩하여 전달
    @Binding var newComment: String
    
    var body: some View {
        VStack {
            Text("댓글")
                .font(.title2)
                .bold()
                .padding()
            
            ScrollView {
                VStack(alignment: .leading, spacing: 16) {
                    ForEach(comments) { comment in
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
                        let newCommentData = Comment(userNickname: "", content: newComment, date: Date())
                        comments.append(newCommentData)  // 새 댓글을 comments 배열에 추가
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
    ColunmDetail()
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
        .environmentObject(MemoStore())
        .environmentObject(ColumnStore())
        .environmentObject(CommentStore())
}
