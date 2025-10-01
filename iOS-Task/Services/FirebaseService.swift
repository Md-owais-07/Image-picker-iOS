//
//  FirebaseService.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import Foundation
import FirebaseFirestore
import FirebaseStorage
import UIKit
internal import Combine

@MainActor
class FirebaseService: ObservableObject {
    private let db = Firestore.firestore()
    private let storage = Storage.storage()
    
    @Published var images: [ImageModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var lastDocument: DocumentSnapshot?
    private var hasMoreImages = true
    
    // MARK: - Upload Image
    func uploadImage(_ image: UIImage, referenceName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Compress image
            guard let imageData = image.jpegData(compressionQuality: 0.8) else {
                throw FirebaseError.imageCompressionFailed
            }
            
            // Create unique filename
            let filename = "\(UUID().uuidString).jpg"
            let storageRef = storage.reference().child("images/\(filename)")
            
            // Upload image to Firebase Storage
            let metadata = StorageMetadata()
            metadata.contentType = "image/jpeg"
            
            let _ = try await storageRef.putDataAsync(imageData, metadata: metadata)
            
            // Get download URL
            let downloadURL = try await storageRef.downloadURL()
            
            // Create thumbnail (optional - for better performance)
            let thumbnailData = image.jpegData(compressionQuality: 0.3)
            var thumbnailURL: String?
            
            if let thumbnailData = thumbnailData {
                let thumbnailRef = storage.reference().child("thumbnails/thumb_\(filename)")
                let _ = try await thumbnailRef.putDataAsync(thumbnailData, metadata: metadata)
                thumbnailURL = try await thumbnailRef.downloadURL().absoluteString
            }
            
            // Save metadata to Firestore
            let imageModel = ImageModel(
                referenceName: referenceName,
                imageURL: downloadURL.absoluteString,
                thumbnailURL: thumbnailURL
            )
            
            try await db.collection(ImageModel.collectionName).addDocument(from: imageModel)
            
            // Add to local array for immediate UI update
            images.insert(imageModel, at: 0)
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
            throw error
        }
    }
    
    // MARK: - Fetch Images (with pagination and caching)
    func fetchImages(refresh: Bool = false) async {
        guard !isLoading && (hasMoreImages || refresh) else { return }
        
        isLoading = true
        errorMessage = nil
        
        do {
            var query = db.collection(ImageModel.collectionName)
                .order(by: "uploadDate", descending: true)
                .limit(to: 20)
            
            if refresh {
                lastDocument = nil
                hasMoreImages = true
            } else if let lastDocument = lastDocument {
                query = query.start(afterDocument: lastDocument)
            }
            
            let snapshot = try await query.getDocuments()
            
            let newImages = try snapshot.documents.compactMap { document in
                try document.data(as: ImageModel.self)
            }
            
            if refresh {
                images = newImages
            } else {
                images.append(contentsOf: newImages)
            }
            
            lastDocument = snapshot.documents.last
            hasMoreImages = newImages.count == 20
            
            isLoading = false
        } catch {
            isLoading = false
            errorMessage = error.localizedDescription
        }
    }
    
    // MARK: - Load More Images
    func loadMoreImages() async {
        await fetchImages(refresh: false)
    }
}

// MARK: - Firebase Errors
enum FirebaseError: LocalizedError {
    case imageCompressionFailed
    
    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "Failed to compress image"
        }
    }
}
