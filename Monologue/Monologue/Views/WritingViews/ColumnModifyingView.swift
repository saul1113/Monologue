//
//  ColumnModifyingView.swift
//  Monologue
//
//  Created by 김종혁 on 10/22/24.
//

import SwiftUI

struct ColumnModifyingView: View {
    @Environment(\.dismiss) var dismiss
    @EnvironmentObject private var columnStore: ColumnStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    @EnvironmentObject private var memoImageStore: MemoImageStore
    
    @Binding var selectedTab: Int
    @Binding var showShareSheet: Bool
    
    @State private var columnText: String = ""
    
    @State private var title: String = ""
    @State private var selectedColumnCategories: [String] = ["오늘의 주제"]
    @State private var lineCount: Int = 0
    @State private var textLimit: Int = 2000
    
    let column: Column
    
    let categoryOptions = ["오늘의 주제", "에세이", "사랑", "자연", "시", "자기계발", "추억", "소설", "SF", "IT", "기타"]
    let placeholder: String = "글을 입력해 주세요."
    
    let rows = [GridItem(.fixed(50))]
    
    @FocusState private var isTextEditorFocused: Bool
    @State private var keyboardHeight: CGFloat = 0 // 키보드 높이 상태 추가
    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        HStack {
                            Text("Post")
                                .font(.headline)
                            
                            Spacer()
                            Button("수정 완료") {
                                Task {
                                    let updatedColumn = Column(
                                        id: column.id,
                                        title: title,
                                        content: columnText,
                                        email: column.email,
                                        userNickname: column.userNickname,
                                        categories: selectedColumnCategories,
                                        likes: column.likes,
                                        date: column.date,
                                        comments: column.comments ?? []
                                    )
                                    await columnStore.updateColumn(column: updatedColumn)
                                    dismiss()
                                    showShareSheet = false
                                }
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        
                        ScrollView {
                            VStack {
                                VStack  {
                                    TextField("제목을 입력해주세요", text: $title)
                                        .frame(maxWidth: .infinity, maxHeight: 30)
                                        .focused($isTextEditorFocused)
                                        .textFieldStyle(.roundedBorder)
                                    
                                    TextEditor(text: $columnText)
                                        .font(.system(.title3, design: .default, weight: .regular))
                                        .frame(maxWidth: .infinity, minHeight: 500, maxHeight: .infinity)
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
                                                CategoryColumnButton(
                                                    title: category,
                                                    isSelected: selectedColumnCategories.contains(category)
                                                ) {
                                                    if selectedColumnCategories.contains(category) {
                                                        selectedColumnCategories.removeAll { $0 == category }
                                                    } else {
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
                                Divider()
                            }
                        }
                        .contentShape(Rectangle())
                        .onTapGesture {
                            isTextEditorFocused = false
                        }
                        .toolbar {
                            // 키보드 위에 '완료' 버튼 추가
                            ToolbarItemGroup(placement: .keyboard) {
                                Spacer() // 왼쪽 공간을 확보하여 버튼을 오른쪽으로 이동
                                Button("완료") {
                                    isTextEditorFocused = false // 키보드 숨기기
                                }
                            }
                        }
                        .onAppear {
                            NotificationCenter.default.addObserver(forName: UIResponder.keyboardWillShowNotification, object: nil, queue: .main) { notification in
                                if let userInfo = notification.userInfo,
                                   let keyboardFrame = userInfo[UIResponder.keyboardFrameEndUserInfoKey] as? NSValue {
                                    let keyboardHeight = keyboardFrame.cgRectValue.height
                                    withAnimation {
                                        self.keyboardHeight = keyboardHeight // 실제 키보드 높이를 사용
                                    }
                                }
                            }
                        }
                        .onDisappear {
                            NotificationCenter.default.removeObserver(self, name: UIResponder.keyboardWillShowNotification, object: nil)
                        }
                        
                    }
                }
            }
        }
        .onAppear {
            for family in UIFont.familyNames {
                print("Font Family: \(family)")
                for font in UIFont.fontNames(forFamilyName: family) {
                    print("  Font Name: \(font)")
                }
            }
        }
        .onAppear {
            title = column.title
            columnText = column.content
            selectedColumnCategories = column.categories
        }
    }
    
    private func restFields() {
        title = ""
        columnText = ""
        selectedColumnCategories = ["오늘의 주제"]
    }
}

//#Preview {
//    ColumnModifyingView(selectedTab: .constant(0))
//        .environmentObject(AuthManager())
//        .environmentObject(UserInfoStore())
//        .environmentObject(MemoStore())
//        .environmentObject(ColumnStore())
//        .environmentObject(CommentStore())
//        .environmentObject(MemoImageStore())
//}
