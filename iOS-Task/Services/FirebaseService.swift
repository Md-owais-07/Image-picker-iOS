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
    private let db = Firestore.firestore()
    
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
            // Resize image if too large (max 1200x1200 for better compression)
            let resizedImage = resizeImageIfNeeded(image, maxSize: 1200)
            
            // Compress image for Firestore storage with progressive compression
            var compressionQuality: CGFloat = 0.8
            var imageData = resizedImage.jpegData(compressionQuality: compressionQuality)
            
            guard var data = imageData else {
                throw FirebaseError.imageCompressionFailed
            }
            
            // Progressive compression to fit within limits
            while Double(data.count) / (1024 * 1024) > 0.9 && compressionQuality > 0.1 {
                compressionQuality -= 0.1
                guard let compressedData = resizedImage.jpegData(compressionQuality: compressionQuality) else {
                    throw FirebaseError.imageCompressionFailed
                }
                data = compressedData
            }
            
            // Final size check
            let imageSizeInMB = Double(data.count) / (1024 * 1024)
            if imageSizeInMB > 0.9 { // Leave room for other fields
                throw FirebaseError.imageTooLarge
            }
            
            // Convert to Base64
            let base64Image = data.base64EncodedString()
            
            // Create thumbnail (very compressed)
            var base64Thumbnail: String?
            if let thumbnailData = image.jpegData(compressionQuality: 0.2) {
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
