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
    let imageURL: String
    let uploadDate: Date
    let thumbnailURL: String?
    
    init(referenceName: String, imageURL: String, thumbnailURL: String? = nil) {
        self.referenceName = referenceName
        self.imageURL = imageURL
        self.thumbnailURL = thumbnailURL
        self.uploadDate = Date()
    }
}

// MARK: - Firestore Collection Reference
extension ImageModel {
    static let collectionName = "images"
}
