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
    @Published var image: UIImage = UIImage()
    
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
                self.image = tempImage
                print("성공")
                print(self.image)
            }
        }
    }
}
