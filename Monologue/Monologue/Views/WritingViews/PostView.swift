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
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    @EnvironmentObject private var memoImageStore: MemoImageStore
    
    @State private var text: String = ""
    @State private var selectedFont: String = "기본서체"
    @State private var selectedBackgroundImageName: String = "jery1"
    
    @State private var title: String = ""
    @State private var selectedMemoCategories: [String] = []
    @State private var selectedColumnCategories: [String] = []
    @State private var lineCount: Int = 0
    
    @State private var userMemos: [Memo] = [] // 사용자가 작성한 메모들
    @State private var userColumns: [Column] = [] // 사용자가 작성한 칼럼들
    
    var body: some View {
        ZStack {
            Color(.background)
                .ignoresSafeArea()
            VStack {
                HStack {
                    
                    
                        Text("Post")
                        .font(.headline)
                        
                    Spacer()
                            Button(action: {
                                if selectedSegment == "메모" {
                                    // 메모 저장 처리
                                    let newMemo = Memo(content: text,
                                                       userNickname: userInfoStore.userInfo?.nickname ?? "",
                                                       font: selectedFont,
                                                       backgroundImageName: selectedBackgroundImageName,
                                                       categories: selectedMemoCategories,
                                                       likes: [],
                                                       comments: [],
                                                       date: Date(),
                                                       lineCount: lineCount)
                                    memoStore.addMemo(memo: newMemo) { error in
                                        if let error = error {
                                            print("Error adding memo: \(error)")
                                        } else {
                                            dismiss()
                                            restFields()
                                        }
                                    }
                                    
                                    memoImageStore.UploadImage(image: .EB_16_DFE_8_47_DF_4_F_86_B_4_F_9_476_A_05_CBB_390, imageName: newMemo.id)
                                    
                                } else if selectedSegment == "칼럼" {
                                    let newColumn = Column(
                                        title: title,
                                        content: text,
                                        userNickname: userInfoStore.userInfo?.nickname ?? "",
                                        font: "",
                                        backgroundImageName: "",
                                        categories: selectedColumnCategories,
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
                                    .foregroundColor(.accent)
                            }
                        
                    
                }
                .padding(.vertical, 10)
                .padding(.horizontal, 16)
                
                CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)
                
                if selectedSegment == "메모" {
                    MemoWritingView(text: $text, selectedFont: $selectedFont, selectedMemoCategories: $selectedMemoCategories, selectedBackgroundImageName: $selectedBackgroundImageName,
                                    lineCount: $lineCount)
                    
                } else if selectedSegment == "칼럼" {
                    ColumnWritingView(title: $title, text: $text, selectedColumnCategories: $selectedColumnCategories)
                    
                }
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

//#Preview {
//    PostView()
//        .environmentObject(AuthManager())
//        .environmentObject(UserInfoStore())
//        .environmentObject(MemoStore())
//        .environmentObject(ColumnStore())
//        .environmentObject(CommentStore())
//        .environmentObject(MemoImageStore())
//}