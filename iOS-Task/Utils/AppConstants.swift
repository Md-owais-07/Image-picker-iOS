//
//  AppConstants.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import Foundation

struct AppConstants {
    // MARK: - Firebase
    struct Firebase {
        static let imagesCollection = "images"
        static let imagesStoragePath = "images"
        static let thumbnailsStoragePath = "thumbnails"
    }
    
    // MARK: - Image Settings
    struct ImageSettings {
        static let compressionQuality: CGFloat = 0.8
        static let thumbnailCompressionQuality: CGFloat = 0.3
        static let maxImageSize: CGFloat = 1024
        static let thumbnailSize: CGFloat = 300
    }
    
    // MARK: - UI Settings
    struct UI {
        static let gridSpacing: CGFloat = 16
        static let gridItemWidth: CGFloat = 160
        static let gridItemHeight: CGFloat = 120
        static let tabBarHeight: CGFloat = 83
    }
    
    // MARK: - Pagination
    struct Pagination {
        static let pageSize = 20
    }
}
