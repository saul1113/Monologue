//
//  HomeColunm.swift
//  Monologue
//
//  Created by 강희창 on 10/15/24.
//
import SwiftUI

struct ColumnView: View {
    @EnvironmentObject private var columnStore: ColumnStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStore: UserInfoStore
    var filteredColumns: [Column]  // 필터링된 칼럼을 외부에서 전달받음
    
    var body: some View {
        ZStack(alignment: .leading) {
            Color.background.ignoresSafeArea()
            VStack {
                // 필터링된 칼럼 리스트
                List {
                    ForEach(filteredColumns) { post in
                        NavigationLink(destination: ColumnDetail(column: post)) {
                            PostRow(column: post)
                        }
                        .listRowBackground(Color.background)
                    }
                }
                .listStyle(PlainListStyle())
            }
        }
    }
}

// 게시물 리스트에서 각 항목을 표시하는 뷰
struct PostRow: View {
    let column: Column
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.circle.fill")
                    .resizable()
                    .frame(width: 15, height: 15)
                    .clipShape(Circle())
                
                Text("임시 닉네임")
                    .font(.caption2)
                    .foregroundStyle(.black)
                    .font(Font.headline.weight(.bold))
                
                Spacer()
                Text(column.date, style: .relative) // 게시 시간 표시
                        .font(.subheadline)
                        .foregroundColor(.black)
            }
            
            HStack {
                Text(column.content) // 칼럼 내용 표시
                    .font(.body)
                    .foregroundColor(.black)
                    .lineLimit(3) // 3 줄까지만 표시
            }
            
            HStack {
                HStack {
                    Image(systemName: "bubble.right")
                        .foregroundColor(.gray)
                    Text("\(column.comments.count)")  // 댓글 수 표시
                        .font(.subheadline)
                }

                HStack {
                    Image(systemName: "heart")
                        .foregroundColor(.gray)
                    Text("\(column.likes.count)")  // 좋아요 수 표시
                        .font(.subheadline)
                }
                
                Spacer()
                Text(column.categories.first ?? "카테고리 없음.")
                    .font(.subheadline)
                    .foregroundColor(.black)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(8)
            }
            .padding(.top, 8)
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .overlay(RoundedRectangle(cornerRadius: 10)
            .stroke(.gray, lineWidth: 0.5))
        .padding(.vertical, 1)
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        let sampleColumns = [
            Column(content: "Sample Column 1", userNickname: "User1", font: "", backgroundImageName: "", categories: ["에세이"], likes: [], comments: ["Comment 1", "Comment 2"], date: Date()),
            Column(content: "Sample Column 2", userNickname: "User2", font: "", backgroundImageName: "", categories: ["사랑"], likes: ["User1"], comments: [], date: Date())
        ]
        
        return ColumnView(filteredColumns: sampleColumns)
            .environmentObject(ColumnStore())
            .environmentObject(AuthManager())
            .environmentObject(UserInfoStore())
    }
}
