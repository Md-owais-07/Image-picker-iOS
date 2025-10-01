//
//  ImagesView.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import SwiftUI

struct ImagesView: View {
    @StateObject private var firebaseService = FirebaseService()
    @State private var showingRefreshAlert = false
    
    private let columns = [
        GridItem(.flexible(), spacing: 8),
        GridItem(.flexible(), spacing: 8)
    ]
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                // Images Grid
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
                    .padding(.horizontal, 16)
                    .padding(.top, 16)
                    
                    // Loading indicator
                    if firebaseService.isLoading && !firebaseService.images.isEmpty {
                        ProgressView()
                            .padding(.vertical, 20)
                    }
                }
                .refreshable {
                    await firebaseService.fetchImages(refresh: true)
                }
                
                // Empty state
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
                }
                
                // Initial loading
                if firebaseService.images.isEmpty && firebaseService.isLoading {
                    VStack(spacing: 16) {
                        ProgressView()
                            .scaleEffect(1.2)
                        
                        Text("Loading images...")
                            .font(.system(size: 16))
                            .foregroundColor(.gray)
                    }
                    .frame(maxWidth: .infinity, maxHeight: .infinity)
                }
                
                // Tab Bar Placeholder (will be handled by parent)
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 83)
            }
            .navigationBarHidden(true)
        }
        .task {
            // Load images when view appears
            if firebaseService.images.isEmpty {
                await firebaseService.fetchImages(refresh: true)
            }
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
    @State private var isLoading = true
    
    var body: some View {
        VStack(spacing: 8) {
            // Image
            AsyncImage(url: URL(string: imageModel.thumbnailURL ?? imageModel.imageURL)) { image in
                image
                    .resizable()
                    .aspectRatio(contentMode: .fill)
                    .frame(width: 160, height: 120)
                    .clipped()
                    .cornerRadius(12)
                    .onAppear {
                        isLoading = false
                    }
            } placeholder: {
                RoundedRectangle(cornerRadius: 12)
                    .fill(Color.gray.opacity(0.2))
                    .frame(width: 160, height: 120)
                    .overlay(
                        Group {
                            if isLoading {
                                ProgressView()
                                    .scaleEffect(0.8)
                            } else {
                                Image(systemName: "photo")
                                    .font(.system(size: 30))
                                    .foregroundColor(.gray.opacity(0.6))
                            }
                        }
                    )
            }
            
            // Reference Name
            Text(imageModel.referenceName)
                .font(.system(size: 12, weight: .medium))
                .foregroundColor(.primary)
                .lineLimit(2)
                .multilineTextAlignment(.center)
                .frame(width: 160)
        }
        .background(Color(.systemBackground))
    }
}

#Preview {
    ImagesView()
}
