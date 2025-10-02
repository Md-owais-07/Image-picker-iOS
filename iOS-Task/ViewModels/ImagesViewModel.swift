//
//  ImagesViewModel.swift
//  iOS-Task
//
//  Created by Owais on 10/2/25.
//

import SwiftUI
internal import Combine

@MainActor
class ImagesViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var images: [ImageModel] = []
    @Published var isLoading = false
    @Published var errorMessage: String?
    @Published var showingRefreshAlert = false
    
    // MARK: - Private Properties
    private let firebaseService = FirebaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Grid Configuration
    let columns = [
        GridItem(.flexible(), spacing: 12),
        GridItem(.flexible(), spacing: 12)
    ]
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Bind to Firebase service properties
        firebaseService.$images
            .assign(to: \.images, on: self)
            .store(in: &cancellables)
        
        firebaseService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
        
        firebaseService.$errorMessage
            .assign(to: \.errorMessage, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func loadImagesIfNeeded() async {
        await firebaseService.loadImagesIfNeeded()
    }
    
    func refreshImages() async {
        await firebaseService.fetchImages(refresh: true)
    }
    
    func loadMoreImages() async {
        await firebaseService.loadMoreImages()
    }
    
    func clearError() {
        firebaseService.errorMessage = nil
    }
    
    func shouldLoadMoreImages(for imageModel: ImageModel) -> Bool {
        return imageModel.id == images.last?.id
    }
    
    // MARK: - Computed Properties
    var hasImages: Bool {
        !images.isEmpty
    }
    
    var showEmptyState: Bool {
        images.isEmpty && !isLoading
    }
    
    var showInitialLoading: Bool {
        images.isEmpty && isLoading
    }
    
    var showPaginationLoading: Bool {
        isLoading && !images.isEmpty
    }
    
    var hasError: Bool {
        errorMessage != nil
    }
}
