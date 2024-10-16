//
//  ShareSheetView.swift
//  Monologue
//
//  Created by 홍지수 on 10/17/24.
//


import SwiftUI

struct ShareSheetView: View {
    @Binding var isPresented: Bool
    @State private var showReportSheet = false
    
    var body: some View {
        VStack(spacing: 0) {
            Button(action: {
                print("공유하기 버튼 클릭")
                isPresented = false
            }) {
                Text("공유하기")
                    .frame(maxWidth: .infinity)
                    .padding()
                    .background(Color.white)
                    .foregroundColor(.black)
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
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(12)
        .padding()
        .frame(maxWidth: .infinity)
        .sheet(isPresented: $showReportSheet) {
            ReportReasonSheetView(isPresented: $showReportSheet) { reason in
                print("신고 사유: \(reason)")
            }
            .presentationDetents([.height(300)])
            .presentationDragIndicator(.hidden)
        }
    }
}
