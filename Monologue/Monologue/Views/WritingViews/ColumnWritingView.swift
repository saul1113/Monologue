//
//  ColumnWritingView.swift
//  Monologue
//
//  Created by Min on 10/15/24.
//

import SwiftUI

struct ColumnWritingView: View {
    @Environment(\.dismiss) var dismiss
    @Binding var title: String
    @Binding var text: String
    @State private var textLimit: Int = 2000
    @Binding var selectedColumnCategories: [String]
    
    let categoryOptions = ["오늘의 주제", "에세이", "소설", "SF", "철학", "역사", "리뷰", "정치"] // 더 많은 카테고리 추가
    let placeholder: String = "글을 입력해 주세요."
    
    @StateObject var columnStore = ColumnStore()
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    // 그리드 레이아웃 정의 (두 열의 고정 크기)
    let rows = [GridItem(.fixed(50))]
    
    var body: some View {
        
            VStack {
                TextField("제목을 입력해주세요", text: $title)
                    
                
                    .textFieldStyle(.roundedBorder)
                
                TextEditor(text: $text)
                    .font(.system(.title2, design: .default, weight: .regular))
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    .cornerRadius(8)
                    .frame(width: 370, height: 500)
                    .overlay(alignment: .topLeading) {
                        Text(placeholder)
                            .foregroundStyle(text.isEmpty ? .gray : .clear)
                            .padding(.top)
                            .padding(.leading, 22)
                    }
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.brown, lineWidth: 1)
                    )
                    .onReceive(text.publisher.collect()) { newValue in
                        if newValue.count > textLimit {
                            text = String(newValue.prefix(textLimit))
                        }
                    }
                
                HStack {
                    Spacer()
                    Text("\(text.count)/\(textLimit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                
                
                
                    HStack {
                        HStack {
                            Image(systemName: "tag")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.accent)
                            
                            Text("카테고리")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.accent)
                        }
                        ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 16) { // 두 줄짜리 그리드
                            ForEach(categoryOptions, id: \.self) { category in
                                CategoryColumnButton(
                                    title: category,
                                    isSelected: selectedColumnCategories.contains(category)
                                ) {
                                    if selectedColumnCategories.contains(category) {
                                        selectedColumnCategories.removeAll { $0 == category }
                                    } else {
                                        selectedColumnCategories.append(category)
                                    }
                                }
                            }
                        }
                    }
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
                        title: "testTitle",
                        content: text,
                        userNickname: columnStore.columns.first?.userNickname ?? "", 
                        font: "",
                        backgroundImageName: "",
                        categories: [selectedColumnCategory],
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
                .frame(width: 100, height: 30) // 버튼 크기를 고정
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
    ColumnWritingView(title: .constant(""), text: .constant(""), selectedColumnCategories: .constant([]))
}
