//
//  UploadView.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import SwiftUI

struct UploadView: View {
    @StateObject private var viewModel = UploadViewModel()
    
    var body: some View {
        NavigationView {
            VStack(spacing: 0) {
                if viewModel.showingImagePreview && viewModel.selectedImage != nil {
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
        .sheet(isPresented: $viewModel.showingImagePicker) {
            ImagePicker(selectedImage: $viewModel.selectedImage) {
                viewModel.onImageSelected()
            }
        }
        .alert("Upload Status", isPresented: $viewModel.showingAlert) {
            Button("OK") {
                viewModel.handleAlertDismissal()
            }
        } message: {
            Text(viewModel.alertMessage)
        }
    }
    
    // MARK: - Upload Options View
    private var uploadOptionsView: some View {
        VStack(spacing: 40) {
            Spacer()
            
            VStack(spacing: 30) {
                // Browser Gallery Button
                Button(action: {
                    viewModel.selectImageFromGallery()
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
            if let selectedImage = viewModel.selectedImage {
                GeometryReader { geometry in
                    Image(uiImage: selectedImage)
                        .resizable()
                        .aspectRatio(contentMode: .fill)
                        .frame(width: geometry.size.width, height: geometry.size.height)
                        .clipped()
                        .overlay(
                            // Close Button with absolute positioning - Always visible
                            Button(action: {
                                viewModel.cancelImageSelection()
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
                TextField("Reference Name", text: $viewModel.referenceName)
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
                    viewModel.submitImage()
                }) {
                    Text("Submit")
                        .font(.system(size: 16, weight: .semibold))
                        .foregroundColor(.white)
                        .frame(height: 45)
                        .padding(.horizontal, 30)
                        .background(
                            RoundedRectangle(cornerRadius: 8)
                                .fill(viewModel.submitButtonColor)
                        )
                }
                .disabled(viewModel.isSubmitDisabled)
                .padding(.horizontal, 20)
                
                if viewModel.isLoading {
                    ProgressView("Uploading...")
                        .padding(.top, 10)
                }
            }
            .padding(.top, 20)
            .padding(.bottom, 0)
            .background(Color(.systemBackground))
        }
    }
    
}

#Preview {
    UploadView()
}
