# iOS Task - Image Upload App

A SwiftUI-based iOS application for uploading and managing images with Firebase integration.

## Features

- **Upload Tab**: Select images from photo library with preview and reference naming
- **Images Tab**: Grid layout displaying uploaded images with reference names
- **Firebase Integration**: Secure image storage and metadata management
- **Efficient Caching**: Only fetches new images, not all images every time
- **Clean Architecture**: Well-structured code with separation of concerns

## Architecture

### Models
- `ImageModel`: Data model for image metadata with Firestore integration

### Services
- `FirebaseService`: Handles image upload, storage, and retrieval
- `SharedFirebaseService`: Singleton instance for data consistency across tabs

### Views
- `MainTabView`: Custom tab bar navigation
- `UploadView`: Photo picker, preview, and upload functionality
- `ImagesView`: Grid layout for displaying uploaded images
- `ImagePicker`: UIKit wrapper for photo selection

## Setup Instructions

1. **Firebase Configuration**
   - Ensure `GoogleService-Info.plist` is properly configured
   - Firebase dependencies are already included:
     - FirebaseCore
     - FirebaseFirestore
     - FirebaseStorage

2. **Permissions**
   - Photo library access is handled automatically by PhotosUI framework

3. **Build and Run**
   - Open `iOS-Task.xcodeproj` in Xcode
   - Select your target device/simulator
   - Build and run the project

## Usage

1. **Upload Images**
   - Tap "Browser Gallery" to select an image from photo library
   - Enter a reference name for the image
   - Tap "Submit" to upload to Firebase

2. **View Images**
   - Navigate to "Images" tab to see uploaded images
   - Pull to refresh to check for new images
   - Scroll down to load more images (pagination)

## Technical Highlights

- **Async/Await**: Modern Swift concurrency for Firebase operations
- **Pagination**: Efficient loading of images in batches
- **Image Compression**: Automatic compression for storage optimization
- **Thumbnail Generation**: Creates thumbnails for better performance
- **Error Handling**: Comprehensive error handling with user feedback
- **Memory Management**: Efficient image loading with AsyncImage

## Code Quality Features

- Clean architecture with MVVM pattern
- Separation of concerns
- Reusable components
- Comprehensive error handling
- Modern Swift best practices
- Proper memory management
