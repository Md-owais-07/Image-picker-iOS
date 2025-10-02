//
//  ImageGridItem.swift
//  iOS-Task
//
//  Created by Owais on 10/2/25.
//

import SwiftUI

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
                            .frame(width: geometry.size.width, height: 160)
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
