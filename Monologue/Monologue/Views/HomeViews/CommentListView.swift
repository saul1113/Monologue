//
//  MemoListView.swift
//  Monologue
//
//  Created by 홍지수 on 10/18/24.
//

import SwiftUI

struct CommentListView: View {
    @Binding var displayedComments: [Comment]?
    @Binding var selectedComment: Comment?
    @Binding var showDeleteSheet: Bool
    @State var date: Date = .init()
    
    var body: some View {
        if displayedComments != nil {
            ForEach(displayedComments ?? [], id: \.self) { comment in
                HStack(alignment: .top, spacing: 16) {
                    // 프로필 이미지
                    Image(systemName: "person.circle")
                        .resizable()
                        .frame(width: 30, height: 30)
                        .clipShape(Circle())
                    
                    VStack(alignment: .leading, spacing: 4) {
                        Text(comment.userNickname)
                            .font(.subheadline)
                        
                        Text(displayTimeSince(postDate: comment.date))
                            .font(.footnote)
                            .foregroundColor(.gray)
                        Text(comment.content)
                            .font(.footnote)
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
                .padding(.vertical, 16) // 댓글 간의 상하 여백
                Divider()
            }
        }
    }
    
    // 날짜 표시 함수
    func displayTimeSince(postDate: Date) -> String {
            let calendar = Calendar.current
            let currentDate = Date()
            
            if let daysDifference = calendar.dateComponents([.day], from: postDate, to: currentDate).day {
                if daysDifference >= 7 {
                    let formatter = DateFormatter()
                    formatter.dateStyle = .medium
                    formatter.locale = Locale(identifier: "ko_KR") // 한국어 날짜 형식
                    return formatter.string(from: postDate)
                } else {
                    let relativeFormatter = RelativeDateTimeFormatter()
                    relativeFormatter.locale = Locale(identifier: "ko_KR") // 한국어로 설정
                    return relativeFormatter.localizedString(for: postDate, relativeTo: currentDate)
                }
            }
            return ""
        }
}