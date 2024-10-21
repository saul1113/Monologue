//
//  ColumnHeaderView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI
//칼럼디테일 게시글 뷰
struct ColumnHeaderView: View {
    @Binding var column: Column
    @Binding var showShareSheet: Bool
    var isCommentFieldFocused: FocusState<Bool>.Binding
    var commentCount: Int // 댓글 수를 전달받기 위한 변수 추가
    
    @State private var memo: Memo? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
                
                Text(column.userNickname)
                    .font(.subheadline)
                Spacer()
                
                Text(column.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)
            
            VStack(alignment: .leading) {
                Text(column.title)
                    .font(.title3)
                    .bold()
                Text(column.content)
                    .font(.body)
                    .foregroundColor(.black)
            }
            .padding(.bottom, 8)
            
            HStack {
                // 댓글 개수를 전달하여 실시간 업데이트가 되도록 수정
                LikeCommentButtons(memo: $memo,
                                   column: bindingForColumn(),
                                   isCommentFieldFocused: isCommentFieldFocused)
                Spacer()
                Text(column.categories.first ?? "")
                    .font(.footnote)
                    .foregroundColor(.gray)
                    .padding(8)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(14)
            }
            .padding(.bottom, 8)
            .background(Color.white)
            .cornerRadius(12)
            //            .padding(.horizontal, 16)
        }
    }
    
    private func bindingForColumn() -> Binding<Column?> {
        Binding(
            get: {
                return column
            },
            set: { newValue in
                if let newColumn = newValue {
                    column = newColumn
                }
            }
        )
    }
}
