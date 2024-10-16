//
//  ReportReasonSheetView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//
import SwiftUI

struct ReportReasonSheetView: View {
    @Binding var isPresented: Bool
    var onReport: ((String) -> Void)?  // 신고 사유를 전달하는 클로저
    
    var body: some View {
        VStack(spacing: 0) {
            Text("신고하기")
                .font(.headline)
                .padding(.top, 16)
            
            Text("이 칼럼을 신고하는 이유를 선택해 주세요. 회원님의 신고는 익명으로 처리됩니다.")
                .font(.subheadline)
                .foregroundColor(.gray)
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
    }
}
