//
//  ImagesView.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import SwiftUI

struct ImagesView: View {
    @ObservedObject private var firebaseService = FirebaseService.shared
    @State private var showingRefreshAlert = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    var body: some View {
        NavigationView {
            ZStack {
            VStack(spacing: 0) {
                // Images Grid - Only show when there are images
                if !firebaseService.images.isEmpty {
                    ScrollView {
                        LazyVGrid(columns: columns, spacing: 16) {
                            ForEach(firebaseService.images) { image in
                                ImageGridItem(imageModel: image)
                                    .onAppear {
                                        // Load more images when reaching the end
                                        if image.id == firebaseService.images.last?.id {
                                            Task {
                                                await firebaseService.loadMoreImages()
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        
                        // Loading indicator for pagination
                        if firebaseService.isLoading && !firebaseService.images.isEmpty {
                            ProgressView()
                                .padding(.vertical, 20)
                        }
                    }
                    .refreshable {
                        await firebaseService.fetchImages(refresh: true)
                    }
                }
            }
            
            // Centered Empty State
            if firebaseService.images.isEmpty && !firebaseService.isLoading {
                VStack(spacing: 16) {
                    Image(systemName: "photo.on.rectangle.angled")
                        .font(.system(size: 60))
                        .foregroundColor(.gray.opacity(0.6))
                    
                    Text("No images uploaded yet")
                        .font(.system(size: 18, weight: .medium))
                        .foregroundColor(.gray)
                    
                    Text("Upload your first image from the Upload tab")
                        .font(.system(size: 14))
                        .foregroundColor(.gray.opacity(0.8))
                        .multilineTextAlignment(.center)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
            
            // Centered Initial Loading
            if firebaseService.images.isEmpty && firebaseService.isLoading {
                VStack(spacing: 16) {
                    ProgressView()
                        .scaleEffect(1.2)
                    
                    Text("Loading images...")
                        .font(.system(size: 16))
                        .foregroundColor(.gray)
                }
                .frame(maxWidth: .infinity, maxHeight: .infinity)
                .background(Color(.systemBackground))
            }
            }
            .navigationBarHidden(true)
        }
        .task {
            // Only load images if not loaded before
            await firebaseService.loadImagesIfNeeded()
        }
        .alert("Error", isPresented: .constant(firebaseService.errorMessage != nil)) {
            Button("OK") {
                firebaseService.errorMessage = nil
            }
        } message: {
            if let errorMessage = firebaseService.errorMessage {
                Text(errorMessage)
            }
        }
    }
}


// MARK: - Image Grid Item
struct ImageGridItem: View {
    let imageModel: ImageModel
    @State private var displayImage: UIImage?
    
    var body: some View {
        GeometryReader { geometry in
            VStack(spacing: 10) {
                // Image - Dynamic width based on available space
                Group {
                    if let displayImage = displayImage {
                        Image(uiImage: displayImage)
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .clipped()
                            .cornerRadius(8)
                    } else {
                        RoundedRectangle(cornerRadius: 8)
                            .fill(Color.gray.opacity(0.2))
                            .frame(width: geometry.size.width, height: geometry.size.width)
                            .overlay(
                                ProgressView()
                                    .scaleEffect(0.8)
                            )
                    }
                }
                
                // Reference Name
                Text(imageModel.referenceName)
                    .font(.system(size: 12, weight: .regular))
                    .foregroundColor(.primary)
                    .lineLimit(2)
                    .multilineTextAlignment(.center)
                    .frame(width: geometry.size.width)
            }
        }
        .aspectRatio(1.2, contentMode: .fit)
        .onAppear {
            loadImageFromBase64()
        }
    }
    
    private func loadImageFromBase64() {
        // Use thumbnail if available, otherwise use full image
        let base64String = imageModel.thumbnailData ?? imageModel.imageData
        
        guard let imageData = Data(base64Encoded: base64String),
              let uiImage = UIImage(data: imageData) else {
            return
        }
        
        displayImage = uiImage
    }
}


#Preview {
    ImagesView()
}
