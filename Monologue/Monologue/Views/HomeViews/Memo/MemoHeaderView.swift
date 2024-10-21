//
//  MemoHeaderView.swift
//  Monologue
//
//  Created by 홍지수 on 10/18/24.
//

import SwiftUI
//칼럼디테일 게시글 뷰
struct MemoHeaderView: View {
    @Binding var memo: Memo
    @Binding var image: UIImage
    @Binding var showShareSheet: Bool
    var isCommentFieldFocused: FocusState<Bool>.Binding
    var commentCount: Int // 댓글 수를 전달받기 위한 변수 추가
    
    @State private var column: Column? = nil
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack() {
                Image(systemName: "person.circle")
                    .resizable()
                    .frame(width: 30, height: 30)
                    .clipShape(Circle())
                    .padding(.trailing, 8)
                Text(memo.userNickname)
                    .font(.subheadline)
                Spacer()
                Text(memo.date, style: .date)
                    .font(.footnote)
                    .foregroundColor(.gray)
            }
            .padding(.bottom, 8)
            
            Image(uiImage: image)
                .resizable()
                .aspectRatio(contentMode: .fit)
                .padding(.bottom, 8)
            
            HStack {
                // 댓글 개수를 전달하여 실시간 업데이트가 되도록 수정
                LikeCommentButtons(memo: bindingForColumn(),
                                   column: $column,
                                   isCommentFieldFocused: isCommentFieldFocused)
                Spacer()
                ForEach(memo.categories.prefix(3), id: \.self) { category in
                    if !category.isEmpty {
                        Text(category)
                            .font(.footnote)
                            .foregroundColor(.black)
                            .padding(8)
                            .background(Color.gray.opacity(0.2))
                            .cornerRadius(14)
                    }
                }
            }
            .padding(.bottom, 8)
            .background(Color.white)
            .cornerRadius(12)
            //            .padding(.horizontal, 16)
        }
    }
    
    private func bindingForColumn() -> Binding<Memo?> {
        Binding(
            get: {
                return memo
            },
            set: { newValue in
                if let newColumn = newValue {
                    memo = newColumn
                }
            }
        )
    }
}
