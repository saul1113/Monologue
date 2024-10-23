//
//  TopBarView.swift
//  Monologue
//
//  Created by 홍지수 on 10/16/24.
//
import SwiftUI
import OrderedCollections

struct TopBarView: View {
    @Binding var searchText: String
    @Binding var isSearching: Bool
//    @State private var selectedPickerIndex: Int = 0
    @Binding var selectedSegment: String
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
    
    var body: some View {
        VStack(spacing: 0) {
            // 상단 바 (로고, 검색 버튼, 알림 버튼)
            HStack {
                // 로고 (좌측에 위치)
                if !isSearching {
                    Text("MONOLOG")
                        .font(.title2)
                        .bold()
                        .foregroundStyle(Color.accentColor)
                        .transition(.move(edge: .leading))
                }
                Spacer()

                Button(action: {
                    withAnimation(.easeInOut(duration: 0.3)) {
                        isSearching.toggle()
                    }
                }) {
                    Image(systemName: isSearching ? "xmark" : "magnifyingglass")
                        .font(.title2)
                        .fontWeight(.light)
                        .foregroundStyle(Color.accentColor)
                }
                .padding(.trailing, 17)
//                .frame(maxWidth: .infinity, maxHeight: .infinity, alignment: .topTrailing)
                
                // 알림 버튼 (우측에 위치)
                if !isSearching {
                    Button(action: {
                        // 알림 페이지로 이동하는 액션
                    }) {
                        Image(systemName: "bell")
                            .font(.title2)
                            .fontWeight(.light)
                            .foregroundStyle(Color.accentColor)
                    }
                }
            }
            .padding(.horizontal, 16)
            .animation(.easeInOut(duration: 0.2), value: isSearching) // 스프링 애니메이션 적용
            .frame(height: 34)
            .padding(.bottom, 17)

            CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)

            
            // 피커 (메모와 칼럼 사이에서 전환)
//            Picker(selection: $selectedPickerIndex, label: Text("")) {
//                Text("메모").tag(0)
//                Text("칼럼").tag(1)
//            }
//            .pickerStyle(SegmentedPickerStyle())
//            .padding(.horizontal, 16)
//            .padding(.vertical, 8)
            
        }
        .background(Color.background)
    }
}


