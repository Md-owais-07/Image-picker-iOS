//
//  UIImage+Extensions.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import UIKit

extension UIImage {
    /// Compress image to specified quality
    func compressed(quality: CGFloat = 0.8) -> Data? {
        return self.jpegData(compressionQuality: quality)
    }
    
    /// Create thumbnail with specified size
    func thumbnail(size: CGSize) -> UIImage? {
        let renderer = UIGraphicsImageRenderer(size: size)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: size))
        }
    }
    
    /// Resize image to fit within specified bounds while maintaining aspect ratio
    func resized(to targetSize: CGSize) -> UIImage? {
        let size = self.size
        let widthRatio = targetSize.width / size.width
        let heightRatio = targetSize.height / size.height
        let ratio = min(widthRatio, heightRatio)
        
        let newSize = CGSize(width: size.width * ratio, height: size.height * ratio)
        
        let renderer = UIGraphicsImageRenderer(size: newSize)
        return renderer.image { _ in
            self.draw(in: CGRect(origin: .zero, size: newSize))
        }
    }
}
