//
//  ColumnWritingView.swift
//  Monologue
//
//  Created by Min on 10/15/24.
//

import SwiftUI

/*
 Column
 칼럼 ID -> String
 칼럼 내용 -> String
 유저 닉네임 -> String
 카테고리 -> String 배열
 좋아요 개수 -> 유저 닉네임 String 배열
 Comment -> 코멘트 ID String 배열
 날짜 -> Date
 */
// 닉네임을 불러오는데 시간이 걸린다...
struct ColumnWritingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var text: String // Make text a Binding
    @State private var textLimit: Int = 2000
    @Binding var selectedColumnCategories: [String] // Change to Binding
    
    let categoryOptions = ["오늘의 주제", "에세이", "소설", "SF"] // 카테고리 목록
    let placeholder: String = "글을 입력해 주세요."
    
    @StateObject var columnStore = ColumnStore()
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    var body: some View {
        ZStack {
            
            VStack {
                TextEditor(text: $text)
                    .font(.system(.title2, design: .default, weight: .regular))
                    .padding(.horizontal, 16) // 좌우 패딩만 16으로 설정
                    .padding(.vertical, 8) // 상하 패딩은 자유롭게 설정 가능
                    .cornerRadius(8)
                    .frame(width: 370 ,height: 545)
                    .overlay(alignment: .topLeading) {
                        Text(placeholder)
                            .foregroundStyle(text.isEmpty ? .gray : .clear)
                            .padding(.top)
                            .padding(.leading, 22)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.brown, lineWidth: 1) // 테두리 색상과 두께 조정
                    )
                    .onReceive(text.publisher.collect()) { newValue in
                        if newValue.count > textLimit {
                            text = String(newValue.prefix(textLimit))
                        }
                    }
                    .onAppear {
                        print("\(userInfoStore.userInfo?.nickname ?? "닉네임 없음")")
                    }
                    
                
                HStack {
                    Spacer()
                    Text("\(text.count)/\(textLimit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                ScrollView(.horizontal) {
                    HStack(spacing: 13) {
                        Image(systemName: "tag")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.accent)
                        
                        Text("카테고리")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.accent)
                        ForEach(categoryOptions, id: \.self) { category in
                            CategoryColumnButton(
                                title: category,
                                isSelected: selectedColumnCategories.contains(category) // Check if the category is selected
                            ) {
                                if selectedColumnCategories.contains(category) {
                                    selectedColumnCategories.removeAll { $0 == category } // Remove if already selected
                                } else {
                                    selectedColumnCategories.append(category) // Add if not selected
                                }
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 10)
                }
                
                Divider()
            }
            
        }
        .padding(.horizontal, 16)
        
    }
}




struct CategoryColumnButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    
    var body: some View {
        Button(action: action) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isSelected ? .white : .brown)
                .frame(width: 80, height: 30)
                .background(isSelected ? Color.accentColor : Color.clear)
                .cornerRadius(10)
                .overlay(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(Color.brown, lineWidth: 1)
                )
        }
    }
}

#Preview {
    // Provide necessary environment object for preview
    ColumnWritingView(text: .constant(""), selectedColumnCategories: .constant([]))
}
