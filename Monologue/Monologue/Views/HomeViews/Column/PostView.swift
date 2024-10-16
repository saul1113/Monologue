//
//  PostView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct PostView: View {
    @Environment(\.dismiss) var dismiss

 
    @State var selectedSegment: String = "메모"
    
    @StateObject private var memoStore = MemoStore()
    @StateObject private var columnStore = ColumnStore()
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    
    @State private var text: String = ""
    @State private var selectedFont: String = "기본서체"
    @State private var selectedBackgroundImageName: String = "jery1"
    @State private var selectedMemoCategories: [String] = []
    @State private var selectedColumnCategories: [String] = []
    
    @State private var userMemos: [Memo] = [] // 사용자가 작성한 메모들
    @State private var userColumns: [Column] = [] // 사용자가 작성한 칼럼들

    var body: some View {
        NavigationView {
            VStack {
                HStack {
                    Spacer()

                    Text("Post")

                    Spacer()  // "Post" 뒤에 중간 여백을 위한 Spacer

                    Button(action: {
                        if selectedSegment == "메모" {
                            // 메모 저장 처리
                            let newMemo = Memo(content: text, userNickname: userInfoStore.userInfo?.nickname ?? "",
                                               font: selectedFont, backgroundImageName: selectedBackgroundImageName, categories: selectedMemoCategories, likes: [], comments: [], date: Date())
                            memoStore.addMemo(memo: newMemo) { error in
                                if let error = error {
                                    print("Error adding memo: \(error)")
                                } else {
                                    dismiss()
                                    restFields()
                                }
                            }
                        } else if selectedSegment == "칼럼" {
                            // 칼럼 저장 처리
                            let newColumn = Column(
                                content: text,
                                userNickname: userInfoStore.userInfo?.nickname ?? "",
                                font: "",
                                backgroundImageName: "",
                                categories: selectedColumnCategories, // 선택된 칼럼 카테고리 사용
                                likes: [],
                                comments: [],
                                date: Date()
                            )
                            columnStore.addColumn(column: newColumn) { error in
                                if let error = error {
                                    print("Error adding column: \(error)")
                                } else {
                                    dismiss()
                                    restFields()
                                }
                            }
                        }
                    }) {
                        Text("발행")
                            .foregroundColor(.accentColor)  // 강조 색상 설정
                    }
                }
                
                .padding(.bottom, 10)
                
                CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)

                if selectedSegment == "메모" {
                    MemoWritingView(text: $text, selectedFont: $selectedFont, selectedMemoCategories: $selectedMemoCategories, selectedBackgroundImageName: $selectedBackgroundImageName)
                } else if selectedSegment == "칼럼" {
                    ColumnWritingView(text: $text, selectedColumnCategories: $selectedColumnCategories)
                }
            }
            .onAppear {
                Task {
                    // 유저의 정보 로드
                    await userInfoStore.loadUserInfo(email: authManager.email)
                    
                    // 유저의 메모 로드
                    memoStore.loadMemosByUserNickname(userNickname: authManager.name) { memos, error in
                        if let memos = memos {
                            userMemos = memos
                        }
                    }
                    
                    // 유저의 칼럼 로드
                    columnStore.loadColumnsByUserNickname(userNickname: authManager.name) { columns, error in
                        if let columns = columns {
                            userColumns = columns
                        }
                    }
                }
            }
            .onChange(of: selectedSegment) { newSegment in
                text = ""
                selectedMemoCategories = []
                selectedColumnCategories = []
                
                if newSegment == "메모" {
                    selectedFont = "기본서체"
                    selectedBackgroundImageName = "jery1"
                }
                
            }
            
        }
        
    }
    
    private func restFields() {
        text = ""
        selectedMemoCategories = []
        selectedColumnCategories = []
        
        if selectedSegment == "메모" {
            selectedFont = "기본서체"
            selectedBackgroundImageName = "jery1"
        }
    }
}

#Preview {
    PostView()
        .environmentObject(UserInfoStore())  // 미리보기에서 필요한 환경 객체 제공
}
