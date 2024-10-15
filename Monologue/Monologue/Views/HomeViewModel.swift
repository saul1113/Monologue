//
//  HomeViewModel.swift
//  Monologue
//
//  Created by 홍지수 on 10/15/24.
//

import SwiftUI


@Observable
class HomeViewModel {
    let memos: [Memo]
    // 각 메모에 따라 생성된 image 이름 스트링 저장하는 Dictionary
    var imagesDic: [Memo.ID : String]
    
    init() {
        memos =
        [
            Memo(
                content: "사람아 외로워해도 좋다. 너는 꽃이다.",
                userNickname: "북극성",
                font: "Helvetica",
                backgroundImageName: "bg1",
                categories: ["에세이", "사랑"],
                likes: ["user1", "user2", "user3"],
                comments: ["정말 공감됩니다.", "좋은 글 감사합니다."],
                date: Date()
            ),
            Memo(
                content: "바람에 흔들려도 사라지지 않을 향기",
                userNickname: "작은별",
                font: "Arial",
                backgroundImageName: "bg2",
                categories: ["시", "자연"],
                likes: ["user4", "user5"],
                comments: ["이 시 정말 좋네요."],
                date: Date()
            ),
            Memo(
                content: "기억 속에 남는 것은 작은 일들이었다.",
                userNickname: "밤하늘",
                font: "Times New Roman",
                backgroundImageName: "bg3",
                categories: ["에세이", "추억"],
                likes: ["user1"],
                comments: [],
                date: Date()
            ),
            Memo(
                content: "나를 좋아해 주는 사람에게 정말 잘해야 한다.",
                userNickname: "푸른바다",
                font: "Courier",
                backgroundImageName: "bg4",
                categories: ["명언", "사랑"],
                likes: ["user2", "user6", "user7"],
                comments: ["진리네요.", "정말 공감해요!"],
                date: Date()
            ),
            Memo(
                content: "오늘도 나는 나만의 길을 걷는다.",
                userNickname: "고독한늑대",
                font: "Helvetica",
                backgroundImageName: "bg5",
                categories: ["독백", "자아"],
                likes: ["user8"],
                comments: ["멋진 글입니다."],
                date: Date()
            ),
            Memo(
                content: "햇살이 비추는 순간, 모든 것이 새롭게 보인다.",
                userNickname: "햇살맑음",
                font: "Verdana",
                backgroundImageName: "bg6",
                categories: ["자연", "영감"],
                likes: ["user3", "user9"],
                comments: ["너무 예쁜 표현이에요."],
                date: Date()
            ),
            Memo(
                content: "온실 속의 꽃은 언제 피어날까?",
                userNickname: "식물연구자",
                font: "Georgia",
                backgroundImageName: "bg7",
                categories: ["식물", "자기계발"],
                likes: ["user1", "user10"],
                comments: ["좋은 질문입니다."],
                date: Date()
            ),
            Memo(
                content: "기회는 준비된 자에게 온다.",
                userNickname: "열정가득",
                font: "Avenir",
                backgroundImageName: "bg8",
                categories: ["명언", "자기계발"],
                likes: ["user4", "user5", "user8"],
                comments: ["맞아요. 항상 준비하는 자세가 필요해요."],
                date: Date()
            ),
            Memo(
                content: "너의 꿈을 믿어라. 그 길은 너만이 걸을 수 있다.",
                userNickname: "꿈꾸는자",
                font: "Futura",
                backgroundImageName: "bg9",
                categories: ["자기계발", "동기부여"],
                likes: ["user6", "user9"],
                comments: ["용기를 얻었습니다!"],
                date: Date()
            ),
            Memo(
                content: "여행은 새로운 나를 만나는 과정이다.",
                userNickname: "여행자",
                font: "Gill Sans",
                backgroundImageName: "bg10",
                categories: ["여행", "자기계발"],
                likes: ["user7", "user10"],
                comments: ["여행의 진정한 의미네요."],
                date: Date()
            )
        ]
        
        imagesDic = [:]
        for index in memos.indices {
            imagesDic.updateValue("memo\(index)", forKey: memos[index].id)
        }
    }
}
