//
//  ImagesView.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import SwiftUI

struct ImagesView: View {
    @StateObject private var viewModel = ImagesViewModel()
    
    var body: some View {
        NavigationView {
            ZStack {
            VStack(spacing: 0) {
                // Images Grid - Only show when there are images
                if viewModel.hasImages {
                    ScrollView {
                        LazyVGrid(columns: viewModel.columns, spacing: 45) {
                            ForEach(viewModel.images) { image in
                                ImageGridItem(imageModel: image)
                                    .onAppear {
                                        // Load more images when reaching the end
                                        if viewModel.shouldLoadMoreImages(for: image) {
                                            Task {
                                                await viewModel.loadMoreImages()
                                            }
                                        }
                                    }
                            }
                        }
                        .padding(.horizontal, 12)
                        .padding(.top, 16)
                        
                        // Loading indicator for pagination
                        if viewModel.showPaginationLoading {
                            ProgressView()
                                .padding(.vertical, 20)
                        }
                    }
                    .refreshable {
                        await viewModel.refreshImages()
                    }
                }
            }
            
            // Centered Empty State
            if viewModel.showEmptyState {
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
            if viewModel.showInitialLoading {
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
            await viewModel.loadImagesIfNeeded()
        }
        .alert("Error", isPresented: .constant(viewModel.hasError)) {
            Button("OK") {
                viewModel.clearError()
            }
        } message: {
            if let errorMessage = viewModel.errorMessage {
                Text(errorMessage)
            }
        }
    }
}


#Preview {
    ImagesView()
}
