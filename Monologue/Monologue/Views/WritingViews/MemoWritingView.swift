//
//  MemoWritingView.swift
//  Monologue
//
//  Created by Min on 10/15/24.
//

import SwiftUI

struct MemoWritingView: View {
    @Binding var text: String
    @Binding var selectedFont: String
    @Binding var selectedMemoCategories: [String]
    @Binding var selectedBackgroundImageName: String
    @Binding var lineCount: Int

    @StateObject private var memoStore = MemoStore()
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager: AuthManager

    let rows = [GridItem(.fixed(50))]
    
    let placeholder: String = "문장을 입력해 주세요."
    let fontOptions = ["기본서체", "고펍바탕", "노토세리프", "나눔바른펜", "나눔스퀘어"]
    let categoryOptions = ["오늘의 주제", "에세이", "사랑", "자연", "시", "자기계발", "추억", "소설", "SF", "IT", "기타"]
    let backgroundImageNames = ["jery1", "jery2", "jery3", "jery4"]

    let lineHeight: CGFloat = 24
    
    // FocusState 변수를 선언하여 TextEditor의 포커스 상태를 추적
    @FocusState private var isTextEditorFocused: Bool
    
    var body: some View {
        ScrollView {
            ZStack {
                VStack {
                    VStack {
                        ZStack {
                            Image(selectedBackgroundImageName)
                                .resizable()
                                .scaledToFit()
                                .frame(maxWidth: .infinity, maxHeight: 500)
                                .cornerRadius(8)
                                .clipped()
                            
                            GeometryReader { geometry in
                                TextEditor(text: $text)
                                    .font(.system(.title2, design: .default, weight: .regular))
                                    .scrollContentBackground(.hidden)
                                    .background(Color.white.opacity(0.8))
                                    .frame(maxWidth: .infinity, maxHeight: 500)
                                    .cornerRadius(8)
                                    .focused($isTextEditorFocused) // TextEditor에 포커스 상태 연결
                                    .overlay {
                                        Text(placeholder)
                                            .font(.title2)
                                            .foregroundColor(text.isEmpty ? .gray : .clear)
                                    }
                                    .onChange(of: text) { _ in
                                        let editWidth = geometry.size.width
                                        calculateLineCount(in: editWidth)
                                    }
                            }
                        }
                    }
                    .padding(.horizontal, 16)
                    
                    HStack {
                        Spacer()
                        Text("\(text.count)/500")
                            .font(.subheadline)
                            .foregroundStyle(.secondary)
                    }
                    .padding(.bottom, -5)
                    .padding(.horizontal, 16)
                    
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "a.square")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.accent)
                            
                            Text("글꼴")
                                .font(.system(size: 15, weight: .light))
                                .foregroundStyle(Color.accent)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: rows, spacing: 10) {
                                    ForEach(fontOptions, id: \.self) { font in
                                        FontButton(title: font, isSelected: selectedFont == font) {
                                            selectedFont = font
                                        } onFocusChange: {
                                            isTextEditorFocused = false // 포커스를 해제하여 키보드를 내리기
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                    
                    Divider()
                    
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "squareshape.split.2x2.dotted")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.accent)
                            Text("배경")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.accent)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: rows, spacing: 10) {
                                    ForEach(backgroundImageNames, id: \.self) { imageName in
                                        BackgroundButton(imageName: imageName) {
                                            selectedBackgroundImageName = imageName
                                        } onFocusChange: {
                                            isTextEditorFocused = false
                                        }
                                    }
                                    .padding(.horizontal, 2)
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                    
                    Divider()
                    
                    HStack {
                        HStack(spacing: 10) {
                            Image(systemName: "tag")
                                .resizable()
                                .frame(width: 20, height: 20)
                                .foregroundStyle(Color.accent)
                            Text("카테고리")
                                .font(.system(size: 15))
                                .foregroundStyle(Color.accent)
                            ScrollView(.horizontal, showsIndicators: false) {
                                LazyHGrid(rows: rows, spacing: 10) {
                                    ForEach(categoryOptions, id: \.self) { category in
                                        CategoryMemoButton(title: category, isSelected: selectedMemoCategories.contains(category)) {
                                            if selectedMemoCategories.contains(category) {
                                                selectedMemoCategories.removeAll { $0 == category }
                                            } else {
                                                selectedMemoCategories.append(category)
                                            }
                                        } onFocusChange: {
                                            isTextEditorFocused = false
                                        }
                                        .padding(.horizontal, 2)
                                    }
                                }
                            }
                        }
                    }
                    .padding(.leading, 16)
                }
            }
            .contentShape(Rectangle()) // 전체 뷰가 터치 가능하도록 설정
            .onTapGesture {
                isTextEditorFocused = false // 다른 곳을 클릭하면 포커스 해제
            }
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
    }
    
    private func calculateLineCount(in width: CGFloat) {
        let size = CGSize(width: width, height: .infinity)
        let attributes: [NSAttributedString.Key: Any] = [
            .font: UIFont(name: selectedFont, size: 17) ?? UIFont.systemFont(ofSize: 17)
        ]
        let textHeight = (text as NSString).boundingRect(with: size, options: [.usesLineFragmentOrigin], attributes: attributes, context: nil).height
        lineCount = Int(ceil(textHeight / lineHeight))
    }
}

struct FontButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void
    var onFocusChange: () -> Void // 포커스 상태 변경을 위한 클로저 추가
    
    var body: some View {
        Button(action: {
            onFocusChange() // 포커스 상태 변경 호출
            action() // 기존의 action 실행
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

struct BackgroundButton: View {
    var imageName: String
    var action: () -> Void
    var onFocusChange: () -> Void // 포커스 상태 변경을 위한 클로저 추가
    
    var body: some View {
        Button(action: {
            onFocusChange()
            action()
        }) {
            Image(imageName)
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 30)
                .cornerRadius(10)
        }
    }
}

struct CategoryMemoButton: View {
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
    MemoWritingView(text: .constant(""), selectedFont: .constant("기본서체"), selectedMemoCategories: .constant([]), selectedBackgroundImageName: .constant("jery1"), lineCount: .constant(5))
}
