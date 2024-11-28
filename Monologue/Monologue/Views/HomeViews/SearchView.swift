//
//  Searc.swift
//  Monologue
//
//  Created by 홍지수 on 10/16/24.
//

import SwiftUI

enum field {
    case search
}

struct SearchView: View {
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @State var recentWatchView: [String] = []
    @State var selectedSegment: String = "메모"
    @FocusState var focusField: field?
    @FocusState private var isSearchFieldFocused: Bool
    
    // 검색 결과 게시물들
    @State private var searchMemos: [Memo] = []
    @State private var searchColumns: [Column] = []
    @State private var selectedCategories: [String]? = ["전체"]
    
    // 더미데이터----------------------------------
    @State var recentSearchList: [String] = [
        "시인", "한강 작가", "채식주의자", "흰", "문인", "사랑의 기술", "철학", "율리시스 무어", "카프카", "바퀴벌레", "존재적 사랑"
    ]
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                    VStack {
                        // MARK: - 검색 필드
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(Color.white)
                                    .frame(width: isSearching ? proxy.size.width * 0.78 : proxy.size.width * 0.92)
                                    .frame(height: proxy.size.height * 0.05)
                                HStack {
                                    Image(systemName:"magnifyingglass")
                                        .foregroundStyle(.accent)
                                        .padding(.leading, 16)
//                                        .animation(.easeInOut(duration: 0.3), value: isSearching)
                                    TextField("글 검색", text: $searchText)
                                        .focused($focusField, equals: .search)
//                                        .frame(width: isSearching ? proxy.size.width * 0.56 : proxy.size.width * 0.72)
                                        .autocorrectionDisabled()
                                        .transition(.move(edge: .trailing))
//                                        .animation(.easeInOut(duration: 0.3), value: isSearching)
                                        .onChange(of: searchText) { value in
                                            if !value.isEmpty {
                                                isSearching = true
                                            }
                                        }
                                    if !searchText.isEmpty {
                                        clearTextButton()
                                            .foregroundStyle(.accent)
                                            .padding(.trailing, 16)
                                    }
                                }
                                .frame(width: isSearching ? proxy.size.width * 0.78 : proxy.size.width * 0.92)
                                .frame(height: proxy.size.height * 0.05)
                            }
                            .animation(.easeInOut, value: isSearching)
                            // 취소 버튼
                            if isSearching {
                                Button {
                                    withAnimation(.easeInOut(duration: 0.3)) {
                                        isSearching = false
                                        searchText = "" // 검색어 초기화
                                    }
                                } label : {
                                    Text("취소")
                                        .padding(10)
                                }
                                .transition(.move(edge: .trailing))
                            }
                        }
                        .frame(width: proxy.size.width)
                    }
                }
                .toolbarTitleDisplayMode(.automatic)
                .toolbar {
                    ToolbarItemGroup(placement: .keyboard) {
                        Spacer() // 왼쪽 공간을 확보하여 버튼을 오른쪽으로 이동
                        Button("완료") {
                            isSearchFieldFocused = false // 키보드 숨기기
                        }
                    }
                }
            }
        }
    }
//}

extension SearchView {

    @ViewBuilder
    private func clearTextButton() -> some View {
        Button {
            self.searchText = ""
        } label : {
            Image(systemName: "x.circle.fill")
        }
    }
}

//
//#Preview {
//    SearchView()
//}
