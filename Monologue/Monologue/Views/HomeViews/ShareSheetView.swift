//
//  ShareSheetView.swift
//  Monologue
//
//  Created by 강희창 on 10/17/24.
//

import SwiftUI

struct ShareSheetView: View {
    @Binding var isPresented: Bool
    @State private var showReportSheet = false
    let sharedString: String = "MONOLOG"
    
    var body: some View {
        VStack(spacing: 0) {
            Spacer().frame(height: 16) // 상단에 고정된 여백 추가
            
            ShareLink(item: sharedString) {
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
            
            Spacer().frame(height: 16) // 하단 여백 추가
        }
        .background(Color(UIColor.systemGray6))
        .cornerRadius(16, corners: [.topLeft, .topRight]) // 상단 모서리만 둥글게 설정
        .padding(.horizontal) // 좌우 여백만 추가
        .padding(.top, 16) // 상단 여백 추가
        .frame(maxWidth: .infinity)
        .presentationDetents([.medium, .large]) // 시트 높이를 자동으로 조절
        .presentationDragIndicator(.visible) // 드래그 인디케이터 표시
        .sheet(isPresented: $showReportSheet) {
            ReportReasonSheetView(isPresented: $showReportSheet) { reason in
                print("신고 사유: \(reason)")
                isPresented = false
            }
            .presentationDetents([.fraction(0.4), .large]) // 시트 높이를 자동으로 조절
            .presentationDragIndicator(.visible)
        }
    }
}

// UIView extension to customize which corners are rounded
extension View {
    func cornerRadius(_ radius: CGFloat, corners: UIRectCorner) -> some View {
        clipShape(RoundedCorner(radius: radius, corners: corners))
    }
}

// RoundedCorner struct for customizing corner radius
struct RoundedCorner: Shape {
    var radius: CGFloat = .infinity
    var corners: UIRectCorner = .allCorners
    
    func path(in rect: CGRect) -> Path {
        let path = UIBezierPath(roundedRect: rect,
                                byRoundingCorners: corners,
                                cornerRadii: CGSize(width: radius, height: radius))
        return Path(path.cgPath)
    }
}

#Preview {
    ShareSheetView(isPresented: .constant(true))
}
