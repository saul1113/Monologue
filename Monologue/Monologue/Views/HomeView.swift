//
//  HomeView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI
import OrderedCollections

struct HomeView: View {
    @State private var searchText: String = ""
    @State private var isSearching: Bool = false
    @State private var selectedPickerIndex: Int = 0
    @State private var selectedCategory: String = "전체"
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
    
    let columns = [
        GridItem(.flexible(), spacing: 10),
        GridItem(.flexible(), spacing: 10)
    ]
    
    @State var homeviewModel = HomeViewModel()
    
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
                            Image(systemName: "magnifyingglass")
                                .font(.title)
                        }
                        .padding(.trailing, 8)
                        
                        Button(action: {
                            // 알림 페이지로 이동
                        }) {
                            Image(systemName: "bell")
                                .font(.title)
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
                    
                    //MARK: - Grid
                    if selectedPickerIndex == 0 {
                        // 메모 뷰
                        MemoView(homeviewModel: homeviewModel)
                    } else {
                        // 칼럼 뷰
                    }
                }
                .navigationBarHidden(true)
            }
        }
        
    }
    var filteredMemos: [Memo] {
        homeviewModel.memos.filter { memo in
            (selectedCategory == "전체" || memo.categories.contains(selectedCategory))
//            && (searchText.isEmpty || memo.content.contains(searchText))
        }
    }
}


#Preview {
    HomeView()
}
