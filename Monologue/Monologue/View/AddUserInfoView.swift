//
//  AddUserInfoView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/15/24.
//

import SwiftUI
import OrderedCollections

struct AddUserInfoView: View {
    @State private var nicknameText: String = ""
    
    @State var dict: OrderedDictionary = [
        "전체": false,
        "오늘의 주제": false,
        "수필": false,
        "소설": false,
        "SF": false,
        "IT": false,
        "기타": false,
    ]
    
    var body: some View {
        Image(systemName: "ellipsis")
            .resizable()
            .foregroundStyle(.gray)
            .frame(width: 18, height: 4)
            .padding(10)
        
        VStack(alignment: .leading) {
            Spacer()
                .frame(height: 100)
            
            TextField("사용하실 닉네임을 입력해주세요.", text: $nicknameText)
                .padding(.horizontal, 10)
                .frame(height: 45)
                .background(
                    RoundedRectangle(cornerRadius: 10)
                        .stroke(.gray, lineWidth: 2).opacity(0.2)
                )
                .cornerRadius(10)
                .padding(.bottom, 30)
            
            VStack(alignment: .leading, spacing: 5) {
                Text("카테고리")
                    .foregroundStyle(.accent) // accentColor 변경해야함
                categoryView(dict: $dict)
            }
            
            Spacer()
            //
            
            Button {
                
            } label: {
                Text("등록")
                    .frame(maxWidth: .infinity, minHeight: 35)
            }
            .buttonStyle(.borderedProminent)
            .tint(.accent)
            
            Spacer()
        }
        .padding(.horizontal, 25)
    }
}

#Preview {
    AddUserInfoView()
}
