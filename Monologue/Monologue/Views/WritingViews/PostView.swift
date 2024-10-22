//
//  PostView.swift
//  Monologue
//
//  Created by Hyunwoo Shin on 10/14/24.
//

import SwiftUI

struct PostView: View {
    @Environment(\.dismiss) var dismiss
    @State var selectedSegment: String = "메모"
    @EnvironmentObject private var memoStore: MemoStore
    @EnvironmentObject private var columnStore: ColumnStore
    @EnvironmentObject var userInfoStore: UserInfoStore
    @EnvironmentObject private var authManager:AuthManager
    @EnvironmentObject private var memoImageStore: MemoImageStore
    
    @Binding var selectedTab: Int
    
    
    @State private var memoText: String = ""
    @State private var columnText: String = ""
    @State private var selectedFont: String = "San Francisco"
    @State private var selectedBackgroundImageName: String = "texture6"
    
    @State private var title: String = ""
    @State private var selectedMemoCategories: [String] = ["오늘의 주제"]
    @State private var selectedColumnCategories: [String] = ["오늘의 주제"]
    @State private var lineCount: Int = 0
    
    @State private var userMemos: [Memo] = [] // 사용자가 작성한 메모들
    @State private var userColumns: [Column] = [] // 사용자가 작성한 칼럼들
    
    @State var cropArea: CGRect = .init(x: 0, y: 0, width: 100, height: 100)
    @State var imageViewSize: CGSize = .zero
    @State var croppedImage: UIImage?
    
    
    
//    @State private var navigateToHome: Bool = false // 홈 뷰로의 이동 상태

    
    var body: some View {
        NavigationStack {
            ZStack {
                Color(.background)
                    .ignoresSafeArea()
                ScrollView {
                    VStack {
                        HStack {
                            Text("Post")
                                .font(.headline)
                            
                            Spacer()
                            Button(action: {
                                if selectedSegment == "메모" {
                                    // 메모 저장 처리
                                    let newMemo = Memo(content: memoText,
                                                       email: userInfoStore.userInfo?.email ?? "",
                                                       userNickname: userInfoStore.userInfo?.nickname ?? "",
                                                       font: selectedFont,
                                                       backgroundImageName: selectedBackgroundImageName,
                                                       categories: selectedMemoCategories,
                                                       likes: [],
                                                       date: Date(),
                                                       lineCount: lineCount,
                                                       comments: [])
                                    memoStore.addMemo(memo: newMemo) { error in
                                        if let error = error {
                                            print("Error adding memo: \(error)")
                                        } else {
                                            DispatchQueue.main.async {
                                                selectedTab = 0
                                            }
                                            restFields()
                                        }
                                    }
                                    
                                    if let croppedImage = self.crop(image: UIImage(named: selectedBackgroundImageName) ?? UIImage(), cropArea: cropArea, imageViewSize: imageViewSize) {
                                        self.croppedImage = self.combineImage(croppedImage: croppedImage, text: memoText, imageViewSize: imageViewSize)
                                        memoImageStore.UploadImage(image: self.croppedImage ?? UIImage(), imageName: newMemo.id)
                                    }
                                } else if selectedSegment == "칼럼" {
                                    let newColumn = Column(
                                        title: title,
                                        content: columnText,
                                        email: userInfoStore.userInfo?.email ?? "",
                                        userNickname: userInfoStore.userInfo?.nickname ?? "",
                                        categories: selectedColumnCategories,
                                        likes: [],
                                        date: Date(),
                                        comments: []
                                    )
                                    columnStore.addColumn(column: newColumn) { error in
                                        if let error = error {
                                            print("Error adding column: \(error)")
                                        } else {
                                            DispatchQueue.main.async {
                                                selectedTab = 0
                                            }
                                            restFields()
                                        }
                                    }
                                }
                            }) {
                                Text("발행")
                                    .foregroundColor(.accent)
                            }
                        }
                        .padding(.vertical, 10)
                        .padding(.horizontal, 16)
                        
                        CustomSegmentView(segment1: "메모", segment2: "칼럼", selectedSegment: $selectedSegment)
                        
                        if selectedSegment == "메모" {
                            MemoWritingView(memoText: $memoText, selectedFont: $selectedFont, selectedMemoCategories: $selectedMemoCategories, selectedBackgroundImageName: $selectedBackgroundImageName,
                                            lineCount: $lineCount, cropArea: $cropArea, imageViewSize: $imageViewSize)
                        } else if selectedSegment == "칼럼" {
                            ColumnWritingView(title: $title, columnText: $columnText, selectedColumnCategories: $selectedColumnCategories)
                        }
                        
                        if let croppedImage {
                            Image(uiImage: croppedImage)
                                .resizable()
                                .scaledToFit()
                                .frame(width: 100)
                        }
                    }
                }
            }
        }
        .onAppear {
            for family in UIFont.familyNames {
                print("Font Family: \(family)")
                for font in UIFont.fontNames(forFamilyName: family) {
                    print("  Font Name: \(font)")
                }
            }
            Task {
                // 유저의 메모 로드
                memoStore.loadMemosByUserEmail(email: authManager.email) { memos, error in
                    if let memos = memos {
                        userMemos = memos
                    }
                }
                
                // 유저의 칼럼 로드
                columnStore.loadColumnsByUserEmail(email: authManager.email) { columns, error in
                    if let columns = columns {
                        userColumns = columns
                    }
                }
            }
        }
        .onChange(of: selectedSegment) { newSegment in
            
            selectedMemoCategories = ["오늘의 주제"]
            selectedColumnCategories = ["오늘의 주제"]
            
            if newSegment == "메모" {
                selectedFont = "기본서체"
                selectedBackgroundImageName = "texture6"
            }
        }
    }
    
    private func restFields() {
        title = ""
        memoText = ""
        columnText = ""
        selectedMemoCategories = ["오늘의 주제"]
        selectedColumnCategories = ["오늘의 주제"]
        
        if selectedSegment == "메모" {
            selectedFont = "San Francisco"
            selectedBackgroundImageName = "texture6"
        }
    }
    
    private func crop(image: UIImage, cropArea: CGRect, imageViewSize: CGSize) -> UIImage? {
        
        let scaleX = image.size.width / imageViewSize.width * image.scale
        let scaleY = image.size.height / imageViewSize.height * image.scale
        let scaledCropArea = CGRect(
            x: cropArea.origin.x * scaleX,
            y: cropArea.origin.y * scaleY,
            width: cropArea.size.width * scaleX,
            height: cropArea.size.height * scaleY
        )
        
        guard let cutImageRef: CGImage = image.cgImage?.cropping(to: scaledCropArea) else {
            return nil
        }
         
        return UIImage(cgImage: cutImageRef)
    }
    
    private func combineImage(croppedImage: UIImage, text: String, imageViewSize: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: croppedImage.size)
        
        return renderer.image { context in
            croppedImage.draw(at: .zero)
            
            let fontSize: CGFloat = 20
            let attributes: [NSAttributedString.Key: Any] = [
                .font: UIFont(name: selectedFont, size: fontSize)!,
                .foregroundColor: UIColor.white
            ]
            
            let textRect = CGRect(
                x: 5,
                y: 8,
                width: croppedImage.size.width - 10,
                height: croppedImage.size.height - 16
            )
            
            text.draw(in: textRect, withAttributes: attributes)
        }
    }
}

//#Preview {
//    PostView()
//        .environmentObject(AuthManager())
//        .environmentObject(UserInfoStore())
//        .environmentObject(MemoStore())
//        .environmentObject(ColumnStore())
//        .environmentObject(CommentStore())
//        .environmentObject(MemoImageStore())
//}
