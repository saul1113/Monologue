//
//  MemoWritingView.swift
//  Monologue
//
//  Created by Min on 10/15/24.
//

/*
 메모 ID -> String
 메모 내용 -> String
 글꼴 -> String
 배경 사진명 -> 메모 ID String
 카테고리 -> String 배열
 날짜 -> Date
 */

struct Memo {
    var memoID: String = UUID().uuidString // 메모 ID
    var memoContent: String // 메모 내용
    var memoFont: String // 글꼴
    var memoBackgroundImage: String? // 배경 사진명 (옵셔널)
    var memoCategory: [String]
    var memoDate: Date // 날짜
}


import SwiftUI



struct MemoWritingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var text: String = ""
    @State private var textLimit: Int = 500
    @State private var selectedFont: String = "기본서체"
    @State private var selectedMemoCategory: String = "오늘의 주제" // 선택된 카테고리
    @State private var selectedBackgroundColor: Color = .white // 기본 배경색

    let placeholder: String = "문장을 입력해 주세요."
    let fontOptions = ["기본서체", "고펍바탕", "노토세리프", "나눔바른펜", "나눔스퀘어"]
    let categoryOptions = ["오늘의 주제", "에세이", "소설", "SF"] // 카테고리 목록
    let backgroundColors: [Color] = [.white, .blue.opacity(0.3), .green.opacity(0.3), .yellow.opacity(0.3)] // 배경 색상 목록
    let backgroundColorNames = ["흰색", "파란색", "녹색", "노란색"] // 배경 색상 이름

    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                TextEditor(text: $text)
                    .font(.system(.title2, design: .default, weight: .regular))
                    .frame(height: 370)
                    .scrollContentBackground(.hidden)
                    .background(selectedBackgroundColor) // 선택된 배경색으로 설정
                    .overlay(alignment: .topLeading) {
                        Text(placeholder)
                            .foregroundColor(text.isEmpty ? .gray : .clear)
                            .padding(.top, -175)
                            .padding(.leading, -175)
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color(.systemGray4))
                    }
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
                
                ScrollView(.horizontal) {
                    HStack(spacing: 13) {
                        Image(systemName: "a.square")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.accent)
                        
                        Text("글꼴")
                            .font(.system(size: 15, weight: .light))
                            .foregroundStyle(Color.accent)
                        
                        ForEach(fontOptions, id: \.self) { font in
                            FontButton(title: font, isSelected: selectedFont == font) {
                                selectedFont = font
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        Image(systemName: "squareshape.split.2x2.dotted")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.accent)
                        
                        Text("배경")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.accent)
                        
                        ForEach(0..<backgroundColors.count, id: \.self) { index in
                            BackgroundButton(color: backgroundColors[index], colorName: backgroundColorNames[index]) {
                                selectedBackgroundColor = backgroundColors[index] // 선택된 배경색으로 변경
                            }
                        }
                    }
                    .padding()
                }
                
                Divider()
                
                ScrollView(.horizontal) {
                    HStack(spacing: 10) {
                        Image(systemName: "tag")
                            .resizable()
                            .frame(width: 20, height: 20)
                            .foregroundStyle(Color.accent)
                        
                        Text("카테고리")
                            .font(.system(size: 15))
                            .foregroundStyle(Color.accent)
                        
                        ForEach(categoryOptions, id: \.self) { category in
                            CategoryButton(title: category, isSelected: selectedMemoCategory == category) {
                                selectedMemoCategory = category
                            }
                        }
                    }
                    .padding()
                }
                
            }
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
                Text("메모")
                    .font(.headline)
            }
            
            ToolbarItem(placement: .navigationBarTrailing) {
                Button(action: {
                    // 발행 버튼 액션
                }) {
                    Text("발행")
                        .foregroundColor(.accentColor)
                }
            }
        }
    }
}

struct FontButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
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
    var color: Color
    var colorName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Text(colorName)
                .font(.system(size: 13, weight: .bold))
                .foregroundColor(.white)
                .frame(width: 70, height: 30)
                .background(color)
                .cornerRadius(10)
        }
    }
}

struct CategoryButton: View {
    var title: String
    var isSelected: Bool
    var action: () -> Void

    var body: some View {
        Button(action: action) {
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
    MemoWritingView()
}
