//
//  ColumnWritingView.swift
//  Monologue
//
//  Created by Min on 10/15/24.
//

/*
 Column
 칼럼 ID -> String
 칼럼 내용 -> String
 유저 닉네임 -> String
 카테고리 -> String 배열
 좋아요 개수 ->  유저 닉네임 String 배열
 Comment -> 코멘트 ID String 배열
 날짜 -> Date
 */
import SwiftUI

struct ColumnWritingView: View {
    @Environment(\.dismiss) var dismiss
    @State private var text: String = ""
    @State private var textLimit: Int = 2000
    @State private var selectedColumnCategory: String = "오늘의 주제"

    let categoryOptions = ["오늘의 주제", "에세이", "소설", "SF"] // 카테고리 목록
    let placeholder: String = "글을 입력해 주세요."
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            
            VStack {
                TextEditor(text: $text)
                    .font(.system(.title2, design: .default, weight: .regular))
                    .frame(height: 540)
                    .overlay(alignment: .topLeading) {
                        Text(placeholder)
                            .foregroundStyle(text.isEmpty ? .gray : .clear)
                            .padding(.top, -260)
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
                
                // Add spacing here
                Spacer(minLength: 10)
                
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
                            CategoryColumnButton(title: category, isSelected: selectedColumnCategory == category) {
                                selectedColumnCategory = category
                            }
                        }
                    }
                    .padding()
                }
                .frame(height: 50) // Set a fixed height for the ScrollView
                Divider()
                
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
                Text("칼럼")
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

struct CategoryColumnButton: View {
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
    ColumnWritingView()
}
