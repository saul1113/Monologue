//
//  PostView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct PostView: View {
    @State private var isSheetPresented: Bool = false
    @State private var isNavigatingToMemo: Bool = false // MemoWritingView 네비게이션 상태 관리
    @State private var isNavigatingToColumn: Bool = false // ColumnWirtingView 네비게이션 상태 관리
    
    var body: some View {
        NavigationStack {
            VStack {
                Color(.background)
                    .ignoresSafeArea()
            }
            .onAppear {
                isSheetPresented = true
            }
            .sheet(isPresented: $isSheetPresented) {
                ActionSheetView(isSheetPresented: $isSheetPresented, isNavigatingToMemo: $isNavigatingToMemo, isNavigatingToColumn: $isNavigatingToColumn)
                    .presentationDetents([.height(200)])
                    .presentationCornerRadius(21)
            }
            .navigationDestination(isPresented: $isNavigatingToMemo) {
                MemoWritingView() // 네비게이션이 활성화될 때 MemoWritingView로 이동
            }
            .navigationDestination(isPresented: $isNavigatingToColumn) {
                ColumnWritingView()
            }
        }
    }
}

struct ActionSheetView: View {
    @Binding var isSheetPresented: Bool
    @Binding var isNavigatingToMemo: Bool // 부모에서 네비게이션 상태를 관리
    @Binding var isNavigatingToColumn: Bool // 부모에서 네비게이션 상태를 관리
    
    var body: some View {
        VStack(spacing: 20) {
            Button("메모 하러 가기") {
                isSheetPresented = false // 시트 닫기
                isNavigatingToMemo = true // 메모 작성 화면으로 이동
            }
            
            Divider()
            
            Button("칼럼 쓰러 가기") {
                // 칼럼 쓰러 가기 액션
                isSheetPresented = false
                isNavigatingToColumn = true
            }
            
            Divider()
            
            Button("취소") {
                // 취소 액션
                isSheetPresented = false
            }
        }
        .frame(maxWidth: .infinity)
        .background(Color.white)
        .cornerRadius(21)
        .padding()
    }
}

struct ColumnWritingView: View {
    var body: some View {
        VStack {
            Text("123")
        }
    }
}

#Preview {
    PostView()
}
