//
//  HomeColunm.swift
//  Monologue
//
//  Created by 강희창 on 10/15/24.
//


import SwiftUI
import OrderedCollections

struct HomeColunm: View {
    // 세그먼트 선택을 위한 상태
    @State private var selectedSegment = "전체" // 기본값을 전체로 설정
    @State private var selectedTab = "메모" // 메모와 칼럼 중 기본값을 메모로 설정
    @State private var isSearching = false // 검색 버튼
    @State private var searchText = "" // 검색 텍스트필드

    // 카테고리 딕셔너리
    @State var categories: OrderedDictionary = [
        "전체": false,
        "오늘의 주제": false,
        "에세이": false,
        "사랑": false,
        "자연": false,
        "시": false,
        "자기계발": false,
        "추억": false,
        "소설": false,
        "SF": false,
        "IT": false,
        "기타": false,
    ]
    
    // 샘플 데이터 (리스트에 표시될 데이터)
    let posts: [Post] = [
        Post(title: "Lorem Ipsum is simply dummy text", category: "에세이", timeAgo: "4분 전"),
        Post(title: "Lorem Ipsum is simply dummy text", category: "소설", timeAgo: "7분 전"),
        Post(title: "Lorem Ipsum is simply dummy text", category: "IT", timeAgo: "9분 전"),
        Post(title: "Lorem Ipsum is simply dummy text", category: "에세이", timeAgo: "10분 전")
    ]
    
    // 현재 선택된 카테고리에 맞춰 필터링된 게시물을 반환
    var filteredPosts: [Post] {
        let result = selectedSegment == "전체" ? posts : posts.filter { $0.category == selectedSegment }
        print("Filtered posts: \(result.map { $0.title })")
        return result
    }
    
    var body: some View {
        ZStack {
            // 배경색 지정
            Color(UIColor(red: 255/255, green: 248/255, blue: 237/255, alpha: 1))
                .edgesIgnoringSafeArea(.all) // 배경색을 전체 화면에 적용

            VStack {
                // 검색 필드와 검색 버튼
                HStack {
                    if isSearching {
                        TextField("검색어를 입력하세요", text: $searchText)
                            .textFieldStyle(RoundedBorderTextFieldStyle())
                            .padding()
                    }
                    Spacer()
                    
                    Button(action: {
                        withAnimation {
                            isSearching.toggle()
                        }
                    }) {
                        Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                            .foregroundStyle(Color.black)
                    }
                    
                    // 종 모양 버튼
                    Button(action: {}) {
                        Image(systemName: "bell")
                            .foregroundStyle(Color.black)
                    }
                }
                .padding(.horizontal)
                
                // 메모/칼럼 세그먼트 탭 추가
                Picker("메모/칼럼", selection: $selectedTab) {
                    Text("메모").tag("메모")
                    Text("칼럼").tag("칼럼")
                }
                .pickerStyle(SegmentedPickerStyle())
                .padding()
                
                // 선택된 탭에 따라 다르게 표시할 내용
                if selectedTab == "메모" {
                    Text("메모 리스트")
                    // 메모에 대한 리스트 등을 여기에 추가할 수 있습니다.
                } else {
                    VStack {
                        // 카테고리 필터를 위한 ViewBuilder 함수 호출
                        categoryView(dict: $categories) // selectedSegment는 전달하지 않음

                        Divider() // 구분선
                        
                        // `onChange` 모디파이어로 카테고리 변경 시 필터링
                        .onChange(of: categories) { newCategories in
                            // 선택된 카테고리에 맞춰 selectedSegment를 업데이트
                            for (category, isSelected) in newCategories {
                                if isSelected {
                                    selectedSegment = category
                                    break
                                }
                            }
                        }

                        // 선택된 카테고리에 맞춘 리스트
                        List {
                            ForEach(filteredPosts) { post in
                                PostRow(post: post)
                                    .listRowBackground(Color(UIColor(red: 255/255, green: 248/255, blue: 237/255, alpha: 1))) // 각 리스트의 배경색 설정
                            }
                            // 광고 배너 위치 예시 (간단한 텍스트 배너)
                            Text("배너 광고")
                                .frame(maxWidth: .infinity, minHeight: 100)
                                .background(Color.gray.opacity(0.3))
                                .cornerRadius(10)
                                .padding()
                                .listRowBackground(Color(UIColor(red: 255/255, green: 248/255, blue: 237/255, alpha: 1))) // 광고 배경색 설정
                        }
                        .listStyle(PlainListStyle()) // 리스트 스타일 설정
                    }
                }
            }
        }
    }
}

// 게시물 정보 구조체
struct Post: Identifiable {
    let id = UUID()
    let title: String
    let category: String
    let timeAgo: String
}

// 게시물 리스트에서 각 항목을 표시하는 뷰
struct PostRow: View {
    let post: Post
    
    var body: some View {
        VStack(alignment: .leading) {
            Text(post.title)
                .font(.headline)
            HStack {
                Text(post.timeAgo)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(post.category)
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
        }
        .padding()
        .background(Color.white)
        .cornerRadius(8)
        .shadow(radius: 2)
        .padding(.vertical, 4)
    }
}
struct HomeView_Previews: PreviewProvider {
    static var previews: some View {
        HomeColunm()
    }
}
