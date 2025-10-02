//
//  UploadViewModel.swift
//  iOS-Task
//
//  Created by Owais on 10/2/25.
//

import SwiftUI
internal import Combine

@MainActor
class UploadViewModel: ObservableObject {
    // MARK: - Published Properties
    @Published var selectedImage: UIImage?
    @Published var referenceName: String = ""
    @Published var showingImagePicker = false
    @Published var showingImagePreview = false
    @Published var showingAlert = false
    @Published var alertMessage = ""
    @Published var isLoading = false
    
    // MARK: - Private Properties
    private let firebaseService = FirebaseService.shared
    private var cancellables = Set<AnyCancellable>()
    
    // MARK: - Initialization
    init() {
        setupBindings()
    }
    
    // MARK: - Private Methods
    private func setupBindings() {
        // Bind to Firebase service loading state
        firebaseService.$isLoading
            .assign(to: \.isLoading, on: self)
            .store(in: &cancellables)
    }
    
    // MARK: - Public Methods
    func selectImageFromGallery() {
        showingImagePicker = true
    }
    
    func onImageSelected() {
        showingImagePreview = true
    }
    
    func cancelImageSelection() {
        showingImagePreview = false
        selectedImage = nil
        referenceName = ""
    }
    
    func submitImage() {
        guard let image = selectedImage, !referenceName.isEmpty else { return }
        
        Task {
            do {
                try await firebaseService.uploadImage(image, referenceName: referenceName)
                alertMessage = "Image uploaded successfully!"
                showingAlert = true
            } catch {
                alertMessage = "Upload failed: \(error.localizedDescription)"
                showingAlert = true
            }
        }
    }
    
    func handleAlertDismissal() {
        if alertMessage.contains("successfully") {
            resetUploadState()
        }
    }
    
    private func resetUploadState() {
        selectedImage = nil
        referenceName = ""
        showingImagePreview = false
    }
    
    // MARK: - Computed Properties
    var isSubmitDisabled: Bool {
        referenceName.isEmpty || isLoading
    }
    
    var submitButtonColor: Color {
        referenceName.isEmpty ? Color.gray : Color.green
    }
}
