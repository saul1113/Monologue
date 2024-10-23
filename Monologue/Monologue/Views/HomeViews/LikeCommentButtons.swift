//
//  LikeCommentButtons.swift
//  Monologue
//
//  Created by 홍지수 on 10/18/24.
//


import SwiftUI

struct LikeCommentButtons: View {
    @EnvironmentObject private var userInfoStore: UserInfoStore
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    @Binding var memo: Memo?
    @Binding var column: Column?
    @State var isLiked: Bool = false
    var isCommentFieldFocused: FocusState<Bool>.Binding  // 추가된 부분
    
    var body: some View {
        HStack {
            // 댓글 버튼
            Button(action: {
                isCommentFieldFocused.wrappedValue = true  // 버튼을 누르면 포커스를 텍스트 필드로 이동
            }) {
                HStack(spacing: 4) {
                    Image(systemName: "bubble.right")
                    
                    if memo == nil {
                        Text("\(column?.comments?.count ?? 0)") // 댓글 개수 사용
                            .font(.subheadline)
                    } else {
                        Text("\(memo?.comments?.count ?? 0)") // 댓글 개수 사용
                            .font(.subheadline)
                    }
                }
                .foregroundColor(.gray)
            }
            
            // 좋아요 버튼
            Button(action: {
                isLiked.toggle()
                if isLiked {
                    if memo == nil {
                        column?.likes.append(userInfoStore.userInfo?.uid ?? "")
                        
                        if let column = column {
                            Task {
                                try await columnStore.addColumn(column: column)
                            }
                        }
                        
                        userInfoStore.userInfo?.likesColumns.append(column?.id ?? "")
                        
                        if let userInfo = userInfoStore.userInfo {
                            Task {
                                await userInfoStore.addUserInfo(userInfo)
                            }
                        }
                    } else {
                        memo?.likes.append(userInfoStore.userInfo?.uid ?? "")
                        
                        if let memo = memo {
                            Task {
                                try await memoStore.addMemo(memo: memo)
                            }
                        }
                        
                        userInfoStore.userInfo?.likesMemos.append(memo?.id ?? "")
                        
                        if let userInfo = userInfoStore.userInfo {
                            Task {
                                await userInfoStore.addUserInfo(userInfo)
                            }
                        }
                    }
                    
                } else {
                    if memo == nil {
                        column?.likes.removeAll(where: { $0 == userInfoStore.userInfo?.uid ?? "" })
                        if let column = column {
                            Task {
                                try await columnStore.addColumn(column: column)
                            }
                        }
                        
                        userInfoStore.userInfo?.likesColumns.removeAll(where: { $0 == column?.id ?? "" })
                        
                        if let userInfo = userInfoStore.userInfo {
                            Task {
                                await userInfoStore.addUserInfo(userInfo)
                            }
                        }
                    } else {
                        memo?.likes.removeAll(where: { $0 == userInfoStore.userInfo?.uid ?? "" })
                        
                        if let memo = memo {
                            Task {
                                try await memoStore.addMemo(memo: memo)
                            }
                        }
                        
                        userInfoStore.userInfo?.likesMemos.removeAll(where: { $0 == memo?.id ?? "" })
                        
                        if let userInfo = userInfoStore.userInfo {
                            Task {
                                await userInfoStore.addUserInfo(userInfo)
                            }
                        }
                    }
                }
            }) {
                HStack(spacing: 4) {
                    Image(systemName: isLiked ? "heart.fill" : "heart")
                        .foregroundColor(isLiked ? .red : .gray)
                    if memo == nil {
                        Text("\(column?.likes.count ?? 0)")
                            .font(.subheadline)
                    } else {
                        Text("\(memo?.likes.count ?? 0)")
                            .font(.subheadline)
                    }
                }
            }
        }
        .onAppear {
            if memo == nil {
                if let contains = userInfoStore.userInfo?.likesColumns.contains(column?.id ?? "") {
                    isLiked = contains ? true : false
                }
                
            } else {
                if let contains = userInfoStore.userInfo?.likesMemos.contains(memo?.id ?? "") {
                    isLiked = contains ? true : false
                }
            }
        }
    }
}
