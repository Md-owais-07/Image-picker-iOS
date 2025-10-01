//
//  FirebaseService.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import Foundation
import FirebaseFirestore
import UIKit
internal import Combine

@MainActor
class FirebaseService: ObservableObject {
    static let shared = FirebaseService()
    
    private let db = Firestore.firestore()
    
    @Published var images: [ImageModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    
    private var lastDocument: DocumentSnapshot?
    private var hasMoreImages = true
    private var hasInitiallyLoaded = false
    
    // MARK: - Upload Image
    func uploadImage(_ image: UIImage, referenceName: String) async throws {
        isLoading = true
        errorMessage = nil
        
        do {
            // Resize image if too large (max 1200x1200 for better compression)
            let resizedImage = resizeImageIfNeeded(image, maxSize: 1200)
            
            // Compress image for Firestore storage with progressive compression
            var compressionQuality: CGFloat = 0.8
            let imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            
            guard var data = imageData else {
                throw FirebaseError.imageCompressionFailed
            }
            
            // Progressive compression to fit within limits
            // Account for Base64 encoding overhead (33% increase) and metadata
            let maxRawSize = 700_000 // 700KB to account for Base64 + metadata
            
            while data.count > maxRawSize && compressionQuality > 0.05 {
                compressionQuality -= 0.05
                guard let compressedData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
                    throw FirebaseError.imageCompressionFailed
                }
                data = compressedData
            }
            
            // Final size check with Base64 overhead calculation
            let base64Size = (data.count * 4) / 3 // Base64 encoding adds ~33%
            let estimatedDocumentSize = base64Size + 1000 // Add buffer for metadata
            
            if estimatedDocumentSize > 1_000_000 { // 1MB Firestore limit
                throw FirebaseError.imageTooLarge
            }
            
            // Convert to Base64
            let base64Image = data.base64EncodedString()
            
            // Debug logging
            print("📊 Image Upload Debug:")
            print("   Original size: \(image.size)")
            print("   Resized to: \(resizedImage.size)")
            print("   Compressed data: \(data.count) bytes")
            print("   Base64 size: \(base64Image.count) bytes")
            print("   Compression quality: \(compressionQuality)")
            
            // Create thumbnail (very compressed and small)
            var base64Thumbnail: String?
            let thumbnailSize: CGFloat = 200 // Small thumbnail
            let thumbnailImage = resizeImageIfNeeded(resizedImage, maxSize: thumbnailSize)
            if let thumbnailData = thumbnailImage.jpegData(compressionQuality: 0.1) {
                base64Thumbnail = thumbnailData.base64EncodedString()
            }
            
            // Create ImageModel with Base64 data
            let imageModel = ImageModel(
                referenceName: referenceName,
                imageData: base64Image,
                thumbnailData: base64Thumbnail
            )
            
            // Save to Firestore
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
                hasInitiallyLoaded = true
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
    
    // MARK: - Initial Load (only if not loaded before)
    func loadImagesIfNeeded() async {
        guard !hasInitiallyLoaded && !isLoading else { return }
        await fetchImages(refresh: true)
    }
    
    // MARK: - Load More Images
    func loadMoreImages() async {
        await fetchImages(refresh: false)
    }
    
    // MARK: - Helper Functions
    private func resizeImageIfNeeded(_ image: UIImage, maxSize: CGFloat) -> UIImage {
        let size = image.size
        
        // If image is already smaller than maxSize, return original
        if size.width <= maxSize && size.height <= maxSize {
            return image
        }
        
        // Calculate new size maintaining aspect ratio
        let aspectRatio = size.width / size.height
        var newSize: CGSize
        
        if size.width > size.height {
            newSize = CGSize(width: maxSize, height: maxSize / aspectRatio)
        } else {
            newSize = CGSize(width: maxSize * aspectRatio, height: maxSize)
        }
        
        // Resize the image
        UIGraphicsBeginImageContextWithOptions(newSize, false, 0.0)
        image.draw(in: CGRect(origin: .zero, size: newSize))
        let resizedImage = UIGraphicsGetImageFromCurrentImageContext()
        UIGraphicsEndImageContext()
        
        return resizedImage ?? image
    }
}

// MARK: - Firebase Errors
enum FirebaseError: LocalizedError {
    case imageCompressionFailed
    case imageTooLarge
    
    var errorDescription: String? {
        switch self {
        case .imageCompressionFailed:
            return "Failed to compress image"
        case .imageTooLarge:
            return "Image is still too large after compression. Please select a smaller image or reduce the image quality."
        }
    }
}
