//
//  HomeColunm.swift
//  Monologue
//
//  Created by 강희창 on 10/15/24.
//

import SwiftUI
import OrderedCollections

struct HomeColumn: View {
    @EnvironmentObject private var columnStore: ColumnStore
    @EnvironmentObject var authManager: AuthManager
    @EnvironmentObject private var userInfoStroe: UserInfoStore

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
    
    @State private var isAddUserInfoPresented: Bool = false // 사용자 정보 추가 뷰 표시 상태
    @State private var isNextView: Bool = false // 다음 뷰로 이동할 상태

    // 전체 게시글 리스트 (필터링 이전의 원본 데이터)
    private var allColumns: [Column] = [
        Column(content: "첫 번째 칼럼 내용", userNickname: "김작가", font: "defaultFont", backgroundImageName: "defaultBackground", categories: ["에세이"], likes: ["user1", "user2", "user3"], comments: ["좋은 글이네요", "팔로잉하고 갑니다.","맞팔해요","퍼갑니다"], date: Date()),
        Column(content: "두 번째 칼럼 내용", userNickname: "홍작가", font: "defaultFont", backgroundImageName: "defaultBackground", categories: ["사랑"], likes: ["user1", "user2"], comments: ["댓글 1"], date: Date().addingTimeInterval(-3600)),
        Column(content: "세 번째 칼럼 내용", userNickname: "이작가", font: "defaultFont", backgroundImageName: "defaultBackground", categories: ["자연"], likes: ["user1"], comments: [], date: Date().addingTimeInterval(-7200)),
        Column(content: "네 번째 칼럼 내용", userNickname: "신작가", font: "defaultFont", backgroundImageName: "defaultBackground", categories: ["소설"], likes: ["user1", "user2", "user3", "user4"], comments: ["댓글 1", "댓글 2", "댓글 3", "댓글 4"], date: Date().addingTimeInterval(-10800)),
        Column(content: "다섯 번째 칼럼 내용", userNickname: "강작가", font: "defaultFont", backgroundImageName: "defaultBackground", categories: ["IT"], likes: ["user1", "user2", "user3"], comments: ["좋은글이네요.", "구독하고 가요", "맞팔해요"], date: Date().addingTimeInterval(-14400))
    ]
    
    // 필터링된 게시글 리스트 (카테고리에 따라 업데이트)
    @State private var filteredColumns: [Column] = []
    
    var body: some View {
        NavigationView {
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
                            // 카테고리 필터
                            ScrollView(.horizontal, showsIndicators: false) {
                                HStack {
                                    ForEach(categories.keys, id: \.self) { key in
                                        Button(action: {
                                            categories[key]?.toggle()
                                            filterColumns() // 카테고리 변경 시 필터링 함수 호출
                                        }) {
                                            Text(key)
                                                .padding()
                                                .background(categories[key] == true ? Color.blue : Color.gray.opacity(0.2))
                                                .cornerRadius(10)
                                                .foregroundColor(categories[key] == true ? .white : .black)
                                        }
                                    }
                                }
                                .padding(.horizontal)
                            }

                            Divider() // 구분선

                            // 필터링된 칼럼 리스트
                            List {
                                ForEach(filteredColumns) { post in
                                    // NavigationLink로 ColumnDetail로 전환
                                    NavigationLink(destination: ColumnDetail(column: post)) {
                                        PostRow(column: post)
                                    }
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
                    
                    // 사용자 정보 추가 버튼
                    Button(action: {
                        isAddUserInfoPresented = true
                    }) {
                        Text("사용자 정보 추가")
                            .frame(maxWidth: .infinity, minHeight: 35)
                    }
                    .buttonStyle(.borderedProminent)
                    .tint(.accent)
                    .sheet(isPresented: $isAddUserInfoPresented) {
                        AddUserInfoView(isPresented: $isAddUserInfoPresented, isNextView: $isNextView)
                            .environmentObject(authManager)
                            .environmentObject(userInfoStroe)
                    }
                }
            }
            .onAppear {
                filterColumns() // 뷰가 처음 로드될 때 필터링을 적용
            }
        }
    }

    // 카테고리에 따라 게시글 필터링
    func filterColumns() {
        let selectedCategories = categories.filter { $0.value }.map { $0.key }
        
        // 선택된 카테고리가 없으면 전체 게시글 표시
        if selectedCategories.isEmpty || selectedCategories.contains("전체") {
            filteredColumns = allColumns
        } else {
            // 선택된 카테고리에 해당하는 게시글만 필터링
            filteredColumns = allColumns.filter { column in
                // Array 타입을 Set 타입으로 변환하여 isDisjoint 사용
                !Set(column.categories).isDisjoint(with: Set(selectedCategories))
            }
        }
    }
}

// 게시물 리스트에서 각 항목을 표시하는 뷰
struct PostRow: View {
    let column: Column
    
    var body: some View {
        VStack(alignment: .leading) {
            HStack {
                Text(column.date, style: .relative) // 게시 시간 표시
                    .font(.subheadline)
                    .foregroundColor(.gray)
                Spacer()
                Text(column.categories.first ?? "카테고리 없음")
                    .font(.subheadline)
                    .foregroundColor(.gray)
                    .padding(4)
                    .background(Color.gray.opacity(0.2))
                    .cornerRadius(5)
            }
            
            Text(column.content) // 칼럼 내용 표시
                .font(.body)
                .foregroundColor(.black)
                .lineLimit(2) // 두 줄까지만 표시

            HStack {
                // 하트 아이콘과 좋아요 수
                // 댓글 아이콘과 댓글 수
                HStack {
                    Image(systemName: "bubble.right.fill")
                        .foregroundColor(.gray)
                    Text("\(column.comments.count)")  // 댓글 수 표시
                        .font(.subheadline)
                }
                
                HStack {
                    Image(systemName: "heart.fill")
                        .foregroundColor(.red)
                    Text("\(column.likes.count)")  // 좋아요 수 표시
                        .font(.subheadline)
                }
            }
            .padding(.top, 8)
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
        HomeColumn()
            .environmentObject(ColumnStore())
            .environmentObject(AuthManager())
            .environmentObject(UserInfoStore())
    }
}
