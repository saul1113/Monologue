//
//  CustomAlert.swift
//  Monologue
//
//  Created by Hyojeong on 10/22/24.
//

import SwiftUI

extension View {
    func customAlert(
        isPresented: Binding<Bool>,
        transition: AnyTransition,
        title: String,
        message: String,
        primaryButtonTitle: String,
        primaryAction: @escaping () -> Void
    ) -> some View {
        return modifier(
            CustomAlertViewModifier(
                isPresented: isPresented,
                transition: transition,
                title: title,
                message: message,
                primaryButtonTitle: primaryButtonTitle,
                primaryAction: primaryAction
            )
        )
    }
}

private struct CustomAlertViewModifier: ViewModifier {

    @Binding var isPresented: Bool
    let transition: AnyTransition
    let title: String
    let message: String
    let primaryButtonTitle: String
    let primaryAction: () -> Void

    func body(content: Content) -> some View {
        ZStack {
            content
                .blur(radius: isPresented ? 2 : 0)

            ZStack {
                if isPresented {
                    Color.black.opacity(0.5)
                        .ignoresSafeArea()
                        .transition(.opacity)

                    CustomAlert(
                        isPresented: self.$isPresented,
                        title: self.title,
                        message: self.message,
                        primaryButtonTitle: self.primaryButtonTitle,
                        primaryAction: self.primaryAction
                    )
                    .transition(self.transition)
                }
            }
            // 암시적 애니메이션
            .animation(.snappy, value: isPresented)
        }
    }
}

private struct CustomAlert: View {

    /// Alert 를 트리거 하기 위한 바인딩 필요
    @Binding var isPresented: Bool
    
    /// Alert 의 제목
    let title: String

    /// Alert 의 설명
    let message: String
    
    /// 주요 버튼에 들어갈 텍스트
    let primaryButtonTitle: String
    
    /// 주요 버튼이 눌렸을 때의 액션 (클로저가 필요함!)
    let primaryAction: () -> Void

    var body: some View {
        VStack(alignment: .center, spacing: 25) {
            Text(title)
                .bold()

            Text(message)
                .font(.system(size: 16))
                .multilineTextAlignment(.center)
                .lineSpacing(6)
            
            HStack {
                Button {
                    isPresented = false // Alert dismiss
                } label: {
                    Text("취소")
                        .font(.headline)
                        .foregroundStyle(.accent)
                        .bold()
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                }
                .tint(.white)
                .overlay {
                    RoundedRectangle(cornerRadius: 8)
                        .stroke(.accent, lineWidth: 1)
                }
                
                Button {
                    isPresented = false // Alert dismiss
                    primaryAction() // 클로저 실행
                } label: {
                    Text(primaryButtonTitle)
                        .font(.headline)
                        .bold()
                        .padding(.vertical, 3)
                        .frame(maxWidth: .infinity)
                }
                .tint(.accent)
            }
            .buttonStyle(.borderedProminent)
        }
        .padding(.horizontal, 24)
        .padding(.vertical, 20)
        .frame(width: 270)
        .background(
            RoundedRectangle(cornerRadius: 12)
                .fill(.white)
//                .strokeBorder(.accent, lineWidth: 1)
        )
    }
}

#Preview {
    CustomAlert(
        isPresented: .constant(true),
        title: "차단하기",
        message: "차단된 사람은 회원님을 팔로우할 수 없으며, 회원님의 게시물을 볼 수 없게 됩니다.",
        primaryButtonTitle: "차단",
        primaryAction: { }
    )
}
