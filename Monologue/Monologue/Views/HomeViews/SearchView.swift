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
    
    @State private var isTruncated: Bool? = nil
    @State private var isExpended: Bool = false
    @State private var scrollPosition: CGPoint = .zero
    @Binding var searchText: String
    @Binding var isSearching: Bool
    @State var recentWatchView: [String] = []
    @FocusState var focusField: field?
    
    // 더미데이터----------------------------------
    @State var recentSearchList: [String] = [
        "시인", "한강 작가", "채식주의자", "흰", "문인", "사랑의 기술", "철학", "율리시스 무어", "카프카", "바퀴벌레", "존재적 사랑"
    ]
    let recommandSearchList: [String] = [
        "시인", "한강 작가", "채식주의자", "흰", "문인", "사랑의 기술", "철학", "율리시스 무어", "카프카", "바퀴벌레", "존재적 사랑"
    ]
    
//    let productList: [String] = []
    var filteredSuggestions: [String] {
        let allContents = (memoStore.memos.map { $0.content } + columnStore.columns.map { $0.content }).joined(separator: " ")
        let allWords = Set(allContents.components(separatedBy: .whitespacesAndNewlines))
        
        let matchingWords = allWords.filter { word in
            word.lowercased().contains(searchText.lowercased()) && !searchText.isEmpty
        }
        // 자음 순으로 정렬하고 최대 10개의 결과만 반환
        return Array(matchingWords.sorted().prefix(10))
    }
    //------------------------------------------
    
    var body: some View {
        GeometryReader { proxy in
            NavigationStack {
                ZStack {
                    Color.background
                        .ignoresSafeArea()
                    ScrollView {
                        // MARK: - 검색 필드
                        Spacer()
                        HStack {
                            ZStack {
                                RoundedRectangle(cornerRadius: 15)
                                    .foregroundStyle(Color.white)
                                    .frame(width: isSearching ? proxy.size.width * 0.78 : proxy.size.width * 0.92)
                                    .frame(height: proxy.size.height * 0.05)
                                HStack {
                                    Image(systemName:"magnifyingglass")
                                        .foregroundStyle(.accent)
                                        .animation(.easeInOut(duration: 0.3), value: isSearching)
                                    TextField("글 검색", text: $searchText)
                                        .focused($focusField, equals: .search)
                                        .frame(width: isSearching ? proxy.size.width * 0.56 : proxy.size.width * 0.72)
                                        .autocorrectionDisabled()
                                        .transition(.move(edge: .trailing))
                                        .animation(.easeInOut(duration: 0.3), value: isSearching)
                                        .onChange(of: searchText) { value in
                                            if !value.isEmpty {
                                                isSearching = true
                                            }
                                        }
                                    
                                    if !searchText.isEmpty {
                                        clearTextButton()
                                            .foregroundStyle(.accent)
                                    }
                                }
                                .frame(width: isSearching ? proxy.size.width * 0.78 : proxy.size.width * 0.92)
                                .frame(height: proxy.size.height * 0.05)
                                
                                
                                if !isSearching {
                                    Rectangle()
                                        .foregroundStyle(.black.opacity(0.0001))
                                        .frame(width: isSearching ? proxy.size.width * 0.76 : proxy.size.width * 0.92)
                                        .frame(height: proxy.size.height * 0.05)
                                        .onTapGesture {
                                            isSearching = true
                                            self.focusField = .search
                                        }
                                }
                            }
                            .animation(.easeInOut, value: isSearching)
                            //                        .transition(.move(edge: .top))
                            
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
                        
                        
                        if isSearching {
                            Divider()
                        }
                        
                        if !isSearching {
                            if !recentWatchView.isEmpty {
                                ZStack {
                                    publicHeader("최근 본 정보")
                                    HStack {
                                        Spacer()
                                        Button {
                                            recentWatchView.removeAll()
                                        } label : {
                                            Text("지우기")
                                        }
                                    }
                                    .padding()
                                }
                            }
                            
                            //                        Section(header : publicHeader("검색 시도")) {
                            //                            ForEach(recommandSearchList, id:\.self) { search in
                            //                                recommandSearchButton(search)
                            //                            }
                            //                        }
                        }
                        
                        else { // 검색중일때
                            if searchText.isEmpty {
                                Divider()
                                
                                if !recentSearchList.isEmpty {
                                    HStack {
                                        Text("최근 검색")
                                            .font(.system(size: 24, weight: .bold))
                                        Spacer()
                                        Button {
                                            self.recentSearchList.removeAll()
                                        } label : {
                                            Text("지우기")
                                        }
                                    }
                                    .padding()
                                    
                                    Divider()
                                    
                                    // 최근 검색
                                    ForEach(recentSearchList, id:\.self) { search in
                                        Button {
                                            searchText = search
                                        } label : {
                                            VStack {
                                                HStack {
                                                    Image(systemName: "magnifyingglass")
                                                    Text(search)
                                                    Spacer()
                                                }
                                                .font(.system(size: 22))
                                                .foregroundStyle(.accent)
                                                .padding(.horizontal)
                                                .padding(.vertical, 5)
                                                
                                                Divider()
                                            }
                                        }
                                    }
                                }
                                
                            } else {
                                //
                                ForEach(searchResult(self.searchText), id:\.self) { search in
                                    Button {
                                        searchText = search
                                    } label : {
                                        VStack {
                                            HStack{
                                                Image(systemName: "magnifyingglass")
                                                HStack(spacing:0) {
                                                    Text(search.prefix(self.searchText.count))
                                                        .bold()
                                                        .foregroundStyle(.black)
                                                    Text(search.suffix(search.count - self.searchText.count))
                                                        .foregroundStyle(.accent)
                                                }
                                                Spacer()
                                            }
                                            .font(.system(size: 24))
                                            .padding(.horizontal)
                                            .padding(.vertical, 5)
                                            
                                            Divider()
                                        }
                                    }
                                    
                                }
                            }
                        }
                    }
                    //                .navigationTitle(isSearching ? "" : "검색")
                    .toolbarTitleDisplayMode(.automatic)
                }
            }
        }
    }
}
// 8 62 72
extension SearchView {
    
    private func searchResult(_ search: String) -> [String] {
        var len = search.count
        let result: [String] = filteredSuggestions.filter { product in
            return product.lowercased().prefix(len) == search.lowercased()
        }
        
        return result;
    }
    
    @ViewBuilder
    private func publicHeader(_ title: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 24, weight: .bold))
            Spacer()
        }
        .padding()
    }
    
    @ViewBuilder
    private func recommandSearchButton(_ text: String) -> some View {
        Button {
            self.searchText = text
        } label: {
            HStack {
                Image(systemName: "magnifyingglass")
                    .foregroundStyle(.accent)
                Text(text)
                    .foregroundStyle(.black)
                Spacer()
            }
            .padding(.horizontal)
            .padding(.vertical, 5)
            .font(.system(size: 20))
            
        }
    }
    
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
