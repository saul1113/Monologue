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
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedPickerIndex: Int = 0
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
            return homeviewModel.memos
        } else {
            return homeviewModel.memos.filter { memo in
                memo.categories.contains { selectedCategories.contains($0) }
            }
        }
    }
    
    var body: some View {
        NavigationView {
            ZStack {
                Color.background.ignoresSafeArea()
                
                VStack(spacing: 0) {
                    // 상단 바
                    HStack {
                        if isSearching {
                            TextField("검색", text: $searchText)
                                .textFieldStyle(RoundedBorderTextFieldStyle())
                                .transition(.move(edge: .trailing))
                        }
                        Spacer()
                        
                        Button(action: {
                            withAnimation {
                                isSearching.toggle()
                            }
                        }) {
                            Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                        }
                        .padding(.trailing, 8)
                        
                        Button(action: {
                            // 알림 페이지로 이동
                        }) {
                            Image(systemName: "bell")
                                .font(.title2)
                                .foregroundStyle(Color.accentColor)
                        }
                    }
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    //MARK: - Picker & category
                    // 피커
                    Picker(selection: $selectedPickerIndex, label: Text("")) {
                        Text("메모").tag(0)
                        Text("칼럼").tag(1)
                    }
                    .pickerStyle(SegmentedPickerStyle())
                    .padding(.horizontal, 16)
                    .padding(.vertical, 8)
                    
                    // 필터 버튼
                    categoryView(dict: $dict)
                        .padding(.bottom)
                        .onChange(of: dict) { oldValue, newValue in
                                // dict 값이 변경될 때마다 selectedCategories를 업데이트
                                selectedCategories = newValue.filter { $0.value }.map { $0.key }
                            }
                    
                    //MARK: - Grid
                    if selectedPickerIndex == 0 {
                        // 메모 뷰
                        MemoView(homeviewModel: homeviewModel, filteredMemos: filteredMemos)
                    } else {
                        HomeColumn(filteredColumns: filteredColumns)
                    }
                }
                .navigationBarHidden(true)
            }
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
