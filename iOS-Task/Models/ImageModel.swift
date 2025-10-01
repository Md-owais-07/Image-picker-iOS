//
//  ImageModel.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import Foundation
import FirebaseFirestore

struct ImageModel: Identifiable, Codable {
    @DocumentID var id: String?
    let referenceName: String
    let imageData: String // Base64 encoded image
    let thumbnailData: String? // Base64 encoded thumbnail
    let uploadDate: Date
    
    init(referenceName: String, imageData: String, thumbnailData: String? = nil) {
        self.referenceName = referenceName
        self.imageData = imageData
        self.thumbnailData = thumbnailData
        self.uploadDate = Date()
    }
}

// MARK: - Firestore Collection Reference
extension ImageModel {
    static let collectionName = "images"
}
