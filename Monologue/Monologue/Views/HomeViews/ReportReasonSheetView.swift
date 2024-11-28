//
//  ReportReasonSheetView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI

struct ReportReasonSheetView: View {
    @Binding var isPresented: Bool
    var onReport: ((String) -> Void)?
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16) // 상단 여백
            
            Text("신고하기")
                .font(.headline)
                .padding(.top, 12)
                .padding(.bottom, 8)
            
            VStack {
                Text("이 칼럼을 신고하는 이유를 선택해 주세요.")
                Text("회원님의 신고는 익명으로 처리됩니다.")
            }
                .font(.subheadline)
                .foregroundColor(.gray)
                .multilineTextAlignment(.center)
                .padding(.horizontal)
                .padding(.bottom, 16)
            
            Divider()
            
            ForEach(["스팸", "비속어 및 욕설", "혐오 및 음란 내용", "기타"], id: \.self) { reason in
                Button(action: {
                    onReport?(reason)
                    isPresented = false
                }) {
                    Text(reason)
                        .frame(maxWidth: .infinity)
                        .padding()
                        .background(Color.white)
                        .foregroundColor(.black)
                }
                Divider()
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
        .cornerRadius(16, corners: [.topLeft, .topRight])
        .padding(.horizontal)
        .padding(.top, 16) // 상단 패딩 추가
        .frame(maxWidth: .infinity)
        .presentationDetents([.medium, .large]) // 시트 높이 자동 조절
        .presentationDragIndicator(.visible)
    }
}
