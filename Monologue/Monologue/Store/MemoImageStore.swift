//
//  MemoImageStore.swift
//  Monologue
//
//  Created by 김종혁 on 10/16/24.
//

import Foundation
import FirebaseStorage
import SwiftUI

class MemoImageStore: ObservableObject {
    @Published var images: [UIImage] = []
    
    // 스토리지에 이미지 파일
    func UploadImage(image: UIImage ,imageName: String) {
        let uploadRef = Storage.storage().reference(withPath: "img/\(imageName)")
        guard let imageData = image.jpegData(compressionQuality: 0.75) else { return }
        let uploadMetaData = StorageMetadata.init()
        uploadMetaData.contentType = "image/jpeg"
        
        uploadRef.putData(imageData, metadata: uploadMetaData) { (downloadMetaData, error) in
            if let error = error {
                print("Error! \(error.localizedDescription)")
                return
            }
            print("complete: \(String(describing: downloadMetaData))")
        }
    }
    
    func loadImage(imageName: String) {
        let storagRef = Storage.storage().reference(withPath: "img/\(imageName)")
        storagRef.getData(maxSize: 4 * 1024 * 1024) { (data, error) in
            if let error = error {
                print("에러 발생")
                return
            }
            if let tempImage = UIImage(data: data!) {
                self.images.append(tempImage)
            }
        }
    }
}

// 메모 글 쓰기 -> 이미지 생성 -> 이미지 받아서 저장 -> 메인뷰나 내정보뷰에서 부를때 로드해서 이미지 배열에 담기
