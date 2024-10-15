//
//  MemoWritingView.swift
//  Monologue
//
//  Created by Min on 10/15/24.
//

/*
 Memo
 메모 ID -> String
 메모 내용 -> String
 유저 닉네임 -> String
 글꼴 -> String
 배경 사진명 -> 메모 ID String
 카테고리 -> String 배열
 좋아요 개수 -> 유저 닉네임 String 배열
 Comment -> 코멘트 ID String 배열
 날짜 -> Date
 */


import SwiftUI

struct MemoWritingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var text: String = ""
    @State private var textLimit: Int = 500
    @State private var selectedFont: String = "기본서체"
    @State private var selectedMemoCategory: String = "오늘의 주제"
    @State private var selectedBackgroundImageName: String = "jery1" // 기본 이미지 이름
    
    @StateObject private var memoStore = MemoStore()
    @EnvironmentObject var userInfoStore: UserInfoStore

    let placeholder: String = "문장을 입력해 주세요."
    let fontOptions = ["기본서체", "고펍바탕", "노토세리프", "나눔바른펜", "나눔스퀘어"]
    let categoryOptions = ["오늘의 주제", "에세이", "소설", "SF"]
    let backgroundImageNames = ["jery1", "jery2", "jery3", "jery4"] // 에셋에 저장된 이미지 이름

    var body: some View {
        ZStack {
            Color(.systemBackground)
                .ignoresSafeArea()
            
            VStack {
                ZStack {
                    
                    Image(selectedBackgroundImageName) // 선택된 배경 이미지
                        .resizable()
                        .scaledToFit()
                        .cornerRadius(8) // 모서리 둥글게
                        .frame(height: 400) // 프레임 높이 지정
                        .clipped() // 이미지가 프레임을 넘어가지 않도록 클리핑
                    
                    TextEditor(text: $text)
                        .font(.system(.title2, design: .default, weight: .regular))
                        .padding() // 내부 패딩 추가
                        .scrollContentBackground(.hidden)
                        .background(Color.white.opacity(0.8))
                        .frame(height: 400)
                        .cornerRadius(8) // 모서리 둥글게
                        .overlay(alignment: .topLeading) {
                            Text(placeholder)
                                .foregroundColor(text.isEmpty ? .gray : .clear)
                                .padding(.top, -170) // 상단 패딩 조정
                                .padding(.leading, -170) // 좌측 패딩 조정
                        }
                        .onReceive(text.publisher.collect()) { newValue in
                            if newValue.count > textLimit {
                                text = String(newValue.prefix(textLimit))
                            }
                        }
                }

                HStack {
                    Spacer()
                    Text("\(text.count)/\(textLimit)")
                        .font(.subheadline)
                        .foregroundStyle(.secondary)
                }
                .padding(.bottom, 10)
                
                
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
                        ForEach(backgroundImageNames, id: \.self) { imageName in
                            BackgroundButton(imageName: imageName) {
                                selectedBackgroundImageName = imageName // 선택된 배경 이미지로 변경
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
                            CategoryMemoButton(title: category, isSelected: selectedMemoCategory == category) {
                                selectedMemoCategory = category
                            }
                        }
                    }
                    .padding()
                }
                
            }
            .padding(.top, -120)
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
                    let newMemo = Memo(content: text, userNickname: memoStore.memos.first?.userNickname ?? "", font: selectedFont, backgroundImageName: selectedBackgroundImageName, categories: [selectedMemoCategory], likes: [], comments: [], date: Date())
                    memoStore.addMemo(memo: newMemo) { error in
                        if let error = error {
                            // Handle error (e.g., show an alert)
                            print("Error adding memo: \(error)")
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
    var imageName: String
    var action: () -> Void

    var body: some View {
        Button(action: action) {
            Image(imageName) // 이미지 버튼으로 변경
                .resizable()
                .scaledToFit()
                .frame(width: 70, height: 30) // 버튼 크기 조정
                .cornerRadius(10)
        }
    }
}

struct CategoryMemoButton: View {
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