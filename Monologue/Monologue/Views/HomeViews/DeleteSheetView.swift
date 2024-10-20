//
//  DeleteSheetView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI

struct DeleteSheetView: View {
    @Binding var isPresented: Bool
    @State private var showReportSheet = false
    var onDelete: (() -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16) // 상단에 고정된 여백 추가
            
            Button(action: {
                onDelete?()
                isPresented = false
            }) {
                Text("삭제하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.red)
            }
            
            Divider()
            
            Button(action: {
                showReportSheet = true
            }) {
                Text("신고하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.red)
            }
            
            Divider()
            
            Button(action: {
                isPresented = false
            }) {
                Text("취소")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
            }
            
            Spacer().frame(height: 16) // 하단 여백 추가
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .padding(.horizontal)
        .padding(.top, 16) // 추가적으로 상단 여백 설정
        .frame(maxWidth: .infinity)
        .presentationDetents([.medium, .large]) // 시트 높이 자동 조절
        .presentationDragIndicator(.visible)
        .sheet(isPresented: $showReportSheet) {
            ReportReasonSheetView(isPresented: $showReportSheet) { reason in
                print("신고 사유: \(reason)")
                isPresented = false
            }
            .presentationDetents([.fraction(0.5), .large])
            .presentationDragIndicator(.visible)
        }
    }
}
