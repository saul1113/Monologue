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
    @EnvironmentObject private var memoImageStore: MemoImageStore
    @State private var memos: [Memo] = []
    @State private var isScrollingDown = false
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State var selectedSegment: String = "메모"
    @State private var selectedCategories: [String]? = ["전체"]
    @State var dict: OrderedDictionary = [
        "전체": true,
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
    
    var filteredColumns: [Column] {
//        guard !columnStore.columns.isEmpty else { return [] }
        if selectedCategories == ["전체"] {
            columnStore.loadColumn { columns, error in
                columnStore.columns = columns ?? []
            }
            return columnStore.columns
        } else {
            return columnStore.columns.filter { column in
                column.categories.contains { selectedCategories!.contains($0) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    TopBarView(searchText: $searchText, isSearching: $isSearching, selectedSegment: $selectedSegment)
                    .transition(.move(edge: .top))
                    
                    // 필터 버튼
                    categoryView(dict: $dict)
                        .padding(.bottom)
                        .onChange(of: dict) { oldValue, newValue in
                            selectedCategories = newValue.filter { $0.value }.map { $0.key }
                            
                            let otherSelected = newValue.filter { $0.key != "전체" && $0.value }.count
                            if otherSelected == newValue.count - 1 {
                                // 모든 항목이 선택되면 "전체"를 활성화하고 나머지 항목을 비활성화
                                for (key, _) in newValue {
                                    dict[key] = (key == "전체")
                                }
                            } else if selectedCategories!.isEmpty {
                                // 아무 항목도 선택되지 않았을 때 "전체" 선택
                                dict["전체"] = true
                            } else if selectedCategories!.contains("전체") && selectedCategories!.count > 1 {
                                // "전체"와 다른 항목이 같이 선택되었을 때 "전체"를 비활성화
                                dict["전체"] = false
                            }
                        }
                    if selectedSegment == "메모" {
                        MemoView(filters: $selectedCategories)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                    } else if selectedSegment == "칼럼" {
                        ColumnView(filteredColumns: filteredColumns)
                            .frame(maxWidth: .infinity, maxHeight: .infinity)
                            .padding(.horizontal, -16)
                    }
                }
                VStack {
                    if isSearching {
                        SearchView(searchText: $searchText, isSearching: $isSearching)
                    }
                }
            }
            .navigationBarHidden(true)
        }
        .onAppear {
            UIScrollView.appearance().bounces = true
        }
    }
}

//#Preview {
//    HomeView()
//        .environmentObject(AuthManager())
//        .environmentObject(UserInfoStore())
//        .environmentObject(MemoStore())
//        .environmentObject(ColumnStore())
//        .environmentObject(CommentStore())
//}
