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
    @Binding var columnText: String
    @State private var textLimit: Int = 2000
    @Binding var selectedColumnCategories: [String]
    
    let categoryOptions = ["오늘의 주제", "에세이", "사랑", "자연", "시", "자기계발", "추억", "소설", "SF", "IT", "기타"]
    let placeholder: String = "글을 입력해 주세요."
    
    @StateObject var columnStore = ColumnStore()
    @EnvironmentObject var userInfoStore: UserInfoStore
    
    let rows = [GridItem(.fixed(50))]
    
    @FocusState private var isTextEditorFocused: Bool
    @State private var keyboardHeight: CGFloat = 0 // 키보드 높이 상태 추가
    
    var body: some View {
        ScrollView {
            VStack {
                VStack  {
                    TextField("제목을 입력해주세요", text: $title)
                        .frame(maxWidth: .infinity, maxHeight: 30)
                        .focused($isTextEditorFocused)
                        .textFieldStyle(.roundedBorder)
                        .padding(.bottom, 10)
                    
                    TextEditor(text: $columnText)
                        .font(.system(.title3, design: .default, weight: .regular))
                        .frame(maxWidth: .infinity, minHeight: 500, maxHeight: 500)
                        .cornerRadius(8)
                        .focused($isTextEditorFocused)
                        .overlay {
                            Text(placeholder)
                                .font(.title2)
                                .foregroundColor(columnText.isEmpty ? .gray : .clear)
                            
                            RoundedRectangle(cornerRadius: 8)
                                .stroke(Color.brown, lineWidth: 1)
                        }
                        .onReceive(columnText.publisher.collect()) { newValue in
                            if newValue.count > textLimit {
                                columnText = String(newValue.prefix(textLimit))
                            }
                        }
                    
                    HStack {
                        Spacer()
                        Text("\(columnText.count)/\(textLimit)")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                }
                .padding(.horizontal, 16)
                .padding(.bottom, -5) // 여백 조정
                
                HStack {
                    Image(systemName: "exclamationmark.circle") // 경고 아이콘
                        .foregroundColor(Color(.systemGray2))
                    Text("카테고리는 최대 3개만 선택 가능합니다.")
                        .font(.system(size: 16, weight: .bold, design: .default)) // 크기와 굵기 조정
                        .foregroundStyle(Color(.systemGray2))
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.top, 5)
                .padding(.bottom, -2)
                HStack {
                    HStack(spacing: 10) {
                        Image(systemName: "tag")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.accent)
                        
                        Text("카테고리")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.accent)
                    }
                    ScrollView(.horizontal, showsIndicators: false) {
                        LazyHGrid(rows: rows, spacing: 10) {
                            ForEach(categoryOptions, id: \.self) { category in
                                CategoryColumnButton(title: category, isSelected: selectedColumnCategories.contains(category)) {
                                    // 선택된 카테고리가 포함되어 있으면 제거
                                    if selectedColumnCategories.contains(category) {
                                        selectedColumnCategories.removeAll { $0 == category }
                                    }
                                    // 선택된 카테고리 개수가 3개 미만일 때만 추가
                                    else if selectedColumnCategories.count < 3 {
                                        selectedColumnCategories.append(category)
                                    }
                                } onFocusChange: {
                                    isTextEditorFocused = false
                                }
                                .padding(.horizontal, 2)
                            }
                        }
                    }
                }
                .padding(.leading, 16)
            }
        }
        .contentShape(Rectangle())
        .onTapGesture {
            isTextEditorFocused = false
        }
        .toolbar {
            // 키보드 위에 '완료' 버튼 추가
            ToolbarItemGroup(placement: .keyboard) {
                HStack {
                    Spacer() // 왼쪽 공간을 확보하여 버튼을 오른쪽으로 이동
                    Button("완료") {
                        isTextEditorFocused = false // 키보드 숨기기
                    }
                }
            }
        }
    }
}

// 카테고리 버튼의 크기와 이름을 보여주는 뷰
struct CategoryColumnButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    var onFocusChange: () -> Void
    
    var body: some View {
        Button(action: {
            onFocusChange()
            action()
        }) {
            Text(title)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(isSelected ? .white : .brown)
                .frame(width: 70, height: 30)
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
    ColumnWritingView(title: .constant(""), columnText: .constant(""), selectedColumnCategories: .constant([]))
}
