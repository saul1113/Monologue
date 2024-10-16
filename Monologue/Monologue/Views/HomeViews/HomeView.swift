//
//  HomeView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI
import OrderedCollections

struct HomeView: View {
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    @State private var isScrollingDown = false
//        @State private var selectedPickerIndex: Int = 0
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State var selectedSegment: String = "메모"
    @State private var selectedCategories: [String] = ["전체"]
    @State var dict: OrderedDictionary = [
        "전체": false,
        "오늘의 주제": false,
        "에세이": false,
        "사랑" : false,
        "자연" : false,
        "시" : false,
        "자기계발" : false,
        "추억" : false,
        "소설": false,
        "SF": false,
        "IT": false,
        "기타": false,
    ]
    var filteredMemos: [Memo] {
        if selectedCategories == ["전체"] {
            memoStore.loadMemos { memos, error in
                memoStore.memos = memos ?? []
            }
            return memoStore.memos
        } else {
            //            print(self.filteredMemos[0].id)
            return memoStore.memos.filter { memo in
                memo.categories.contains { selectedCategories.contains($0) }
            }
        }
    }
    
    var filteredColumns: [Column] {
        if selectedCategories == ["전체"] {
            columnStore.loadColumn { columns, error in
                columnStore.columns = columns ?? []
            }
            return columnStore.columns
        } else {
            return columnStore.columns.filter { column in
                column.categories.contains { selectedCategories.contains($0) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TopBarView()
                    .transition(.move(edge: .top))
                    
//                    // 필터 버튼
                    categoryView(dict: $dict)
                        .padding(.bottom)
                        .onChange(of: dict) { oldValue, newValue in
                            // dict 값이 변경될 때마다 selectedCategories를 업데이트
                            selectedCategories = newValue.filter { $0.value }.map { $0.key }
                        }
                    
                    // grid
//                                        if selectedPickerIndex == 0 {
//                                            // 메모 뷰
//                                            MemoView(filteredMemos: filteredMemos)
//                                        } else {
//                                            // HomeColumn(filteredColumns: filteredColumns)
//                                        }
                    if selectedSegment == "메모" {
                        MemoView(filteredMemos: filteredMemos)
                    } else if selectedSegment == "칼럼" {
                        ColumnView(filteredColumns: filteredColumns)
                    }
                }
            }
            .onAppear {
                UIScrollView.appearance().bounces = true
            }
            .navigationBarHidden(true)
        }
    }
}
    
    
    
    #Preview {
    HomeView()
        .environmentObject(AuthManager())
        .environmentObject(UserInfoStore())
        .environmentObject(MemoStore())
        .environmentObject(ColumnStore())
        .environmentObject(CommentStore())
}
