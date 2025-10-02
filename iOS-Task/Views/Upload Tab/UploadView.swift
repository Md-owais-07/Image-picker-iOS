//
//  UploadView.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import SwiftUI
import PhotosUI

struct UploadView: View {
    @ObservedObject private var firebaseService = FirebaseService.shared
    @State private var selectedImage: UIImage?
    @State private var referenceName: String = ""
    @State private var showingImagePicker = false
    @State private var showingImagePreview = false
    @State private var showingAlert = false
    @State private var alertMessage = ""
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if showingImagePreview && selectedImage != nil {
                    imagePreviewView
                } else {
                    uploadOptionsView
                }
                
                Spacer()
                
                // Tab Bar Placeholder (will be handled by parent)
                Rectangle()
                    .fill(Color.clear)
                    .frame(height: 83)
            }
            .navigationBarHidden(true)
        }
        .sheet(isPresented: $showingImagePicker) {
            ImagePicker(selectedImage: $selectedImage) {
                showingImagePreview = true
            }
        }
        .alert("Upload Status", isPresented: $showingAlert) {
            Button("OK") {
                if alertMessage.contains("successfully") {
                    resetUploadState()
                }
            }
        } message: {
            Text(alertMessage)
        }
    }
    
    // MARK: - Upload Options View
    private var uploadOptionsView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                // Browser Gallery Button
                Button(action: {
                    showingImagePicker = true
                }) {
                    VStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.5), style: StrokeStyle(lineWidth: 2, dash: [12, 6]))
                            .frame(height: 150)
                            .overlay(
                                VStack(spacing: 8) {
                                    Image(systemName: "photo.on.rectangle")
                                        .font(.system(size: 40))
                                        .foregroundColor(.green)
                                    
                                    Text("Browser Gallery")
                                        .font(.system(size: 16, weight: .medium))
                                        .foregroundColor(.primary)
                                }
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
                
                // OR Divider
                HStack {
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                    
                    Text("OR")
                        .font(.system(size: 14, weight: .medium))
                        .foregroundColor(.gray)
                        .padding(.horizontal, 20)
                    
                    Rectangle()
                        .fill(Color.gray.opacity(0.3))
                        .frame(height: 1)
                }
                
                // Open Camera Button (UI only)
                Button(action: {
                    // Camera functionality not implemented as requested
                }) {
                    VStack(spacing: 15) {
                        RoundedRectangle(cornerRadius: 12)
                            .stroke(Color.green.opacity(0.5), style: StrokeStyle(lineWidth: 1.5, dash: [12, 6]))
                            .frame(height: 55)
                            .overlay(
                                HStack(spacing: 10) {
                                    Image(systemName: "camera.fill")
                                        .font(.system(size: 18))
                                        .foregroundColor(.green)
                                    
                                    Text("Open camera")
                                        .font(.system(size: 16, weight: .regular))
                                        .foregroundColor(.primary.opacity(0.6))
                                }
                            )
                    }
                }
                .buttonStyle(PlainButtonStyle())
            }
            .padding(.horizontal, 20)
            
            Spacer()
        }
        .background(Color(.systemBackground))
    }
    
    // MARK: - Image Preview View
    private var imagePreviewView: some View {
        VStack(spacing: 0) {
            // Image Preview Area - Dynamic size from top to text field
            if let selectedImage = selectedImage {
                GeometryReader { geometry in
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .overlay(
                            // Close Button with absolute positioning - Always visible
                            Button(action: {
                                showingImagePreview = false
                                self.selectedImage = nil
                                referenceName = ""
                            }) {
                                Image(systemName: "xmark")
                                    .font(.system(size: 12, weight: .medium))
                                    .foregroundColor(.white)
                                    .frame(width: 24, height: 24)
                                    .background(Color.red)
                                    .clipShape(Circle())
                                    .shadow(color: .black.opacity(0.3), radius: 2, x: 0, y: 1)
                            }
                            .position(
                                x: geometry.size.width - 35,
                                y: 35
                            )
                        )
                }
            }
            
            // Reference Name Input and Submit - Fixed at bottom with 20px spacing
            VStack(spacing: 20) {
                TextField("Reference Name", text: $referenceName)
                    .padding(.horizontal, 16)
                    .frame(height: 42)
                    .background(Color(.systemBackground))
                    .cornerRadius(8)
                    .overlay(
                        RoundedRectangle(cornerRadius: 8)
                            .stroke(Color.black, lineWidth: 0.5)
                    )
                    .padding(.horizontal, 30)
                
                Button(action: {
                    submitImage()
                }) {
                    Text("Submit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(height: 45)
                        .padding(.horizontal, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(referenceName.isEmpty ? Color.gray : Color.green)
                        )
                }
                .disabled(referenceName.isEmpty || firebaseService.isLoading)
                .padding(.horizontal, 20)
                
                if firebaseService.isLoading {
                    ProgressView("Uploading...")
                        .padding(.top, 10)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 0)
            .background(Color(.systemBackground))
        }
    }
    
    // MARK: - Helper Methods
    private func submitImage() {
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
    
    private func resetUploadState() {
        selectedImage = nil
        referenceName = ""
        showingImagePreview = false
    }
}

// MARK: - Image Picker
struct ImagePicker: UIViewControllerRepresentable {
    @Binding var selectedImage: UIImage?
    let onImageSelected: () -> Void
    @Environment(\.presentationMode) var presentationMode
    
    func makeUIViewController(context: Context) -> PHPickerViewController {
        var config = PHPickerConfiguration()
        config.filter = .images
        config.selectionLimit = 1
        
        let picker = PHPickerViewController(configuration: config)
        picker.delegate = context.coordinator
        return picker
    }
    
    func updateUIViewController(_ uiViewController: PHPickerViewController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, PHPickerViewControllerDelegate {
        let parent: ImagePicker
        
        init(_ parent: ImagePicker) {
            self.parent = parent
        }
        
        func picker(_ picker: PHPickerViewController, didFinishPicking results: [PHPickerResult]) {
            parent.presentationMode.wrappedValue.dismiss()
            
            guard let provider = results.first?.itemProvider else { return }
            
            if provider.canLoadObject(ofClass: UIImage.self) {
                provider.loadObject(ofClass: UIImage.self) { image, _ in
                    DispatchQueue.main.async {
                        self.parent.selectedImage = image as? UIImage
                        self.parent.onImageSelected()
                    }
                }
            }
        }
    }
}

#Preview {
    UploadView()
}
