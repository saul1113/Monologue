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
    @State private var text: String = ""
    @State private var textLimit: Int = 2000
    @State private var selectedColumnCategories: [String] = [] // 다중 선택을 위한 배열로 변경

    let categoryOptions = ["오늘의 주제", "에세이", "소설", "SF"] // 카테고리 목록
    let placeholder: String = "글을 입력해 주세요."
    
    @StateObject var columnStore = ColumnStore()
    @EnvironmentObject var userInfoStore: UserInfoStore

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                TextEditor(text: $text)
                    .font(.system(.title2, design: .default, weight: .regular))
                    .padding()
                    .cornerRadius(8)
                    .frame(height: 540)
                    .overlay(alignment: .topLeading) {
                        Text(placeholder)
                            .foregroundStyle(text.isEmpty ? .gray : .clear)
                            .padding(.top, -240)
                            .padding(.leading, -170)
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4))
                    }
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
                                isSelected: selectedColumnCategories.contains(category) // 배열에 해당 카테고리가 있는지 확인
                            ) {
                                if selectedColumnCategories.contains(category) {
                                    selectedColumnCategories.removeAll { $0 == category } // 이미 선택된 경우 배열에서 제거
                                } else {
                                    selectedColumnCategories.append(category) // 선택되지 않은 경우 배열에 추가
                                }
                            }
                        }
                    }
                    .padding(.bottom, 10)
                    .padding(.top, 10)
                }
                
                Divider()
                
            }
            .padding(.top, -100)
            .padding(.horizontal, 16)
        }
        .navigationBarBackButtonHidden(true)
        .toolbar {
            ToolbarItem(placement: .navigationBarLeading) {
                Button(action: {
                    dismiss()
                }) {
                    Image(systemName: "chevron.left")
                }
            }
            
            ToolbarItem(placement: .principal) {
                Text("칼럼")
                    .font(.headline)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // 발행 버튼 액션
                    let newColumn = Column(
                        content: text,
                        userNickname: userInfoStore.userInfo?.nickname ?? "",
                        font: "",
                        backgroundImageName: "",
                        categories: selectedColumnCategories, // 선택된 카테고리 배열을 저장
                        likes: [],
                        comments: [],
                        date: Date()
                    )
                    columnStore.addColumn(column: newColumn) { error in
                        if let error = error {
                            print("Error adding column: \(error)")
                        } else {
                            dismiss()
                        }
                    }
                }) {
                    Text("발행")
                        .foregroundColor(.accentColor)
                }
            }
        }
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
    ColumnWritingView()
}
