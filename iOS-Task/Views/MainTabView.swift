//
//  MainTabView.swift
//  iOS-Task
//
//  Created by Owais on 10/1/25.
//

import SwiftUI

struct MainTabView: View {
    @State private var selectedTab: Tab = .upload
    
    enum Tab: CaseIterable {
        case upload, images
        
        var title: String {
            switch self {
            case .upload: return "Upload"
            case .images: return "Images"
            }
        }
        
        var icon: String {
            switch self {
            case .upload: return "arrow.up.circle"
            case .images: return "photo.on.rectangle"
            }
        }
        
        var selectedIcon: String {
            switch self {
            case .upload: return "arrow.up.circle.fill"
            case .images: return "photo.on.rectangle.fill"
            }
        }
    }
    
    var body: some View {
        ZStack(alignment: .bottom) {
            // Content
            Group {
                switch selectedTab {
                case .upload:
                    UploadView()
                case .images:
                    ImagesView()
                }
            }
            .frame(maxWidth: .infinity, maxHeight: .infinity)
            
            // Custom Tab Bar
            customTabBar
        }
        .ignoresSafeArea(.keyboard, edges: .bottom)
    }
    
    private var customTabBar: some View {
        HStack(spacing: 0) {
            ForEach(Tab.allCases, id: \.self) { tab in
                Button(action: {
                    selectedTab = tab
                }) {
                    VStack(spacing: 4) {
                        Image(systemName: selectedTab == tab ? tab.selectedIcon : tab.icon)
                            .font(.system(size: 24))
                            .foregroundColor(selectedTab == tab ? .green : .gray)
                        
                        Text(tab.title)
                            .font(.system(size: 12, weight: .medium))
                            .foregroundColor(selectedTab == tab ? .green : .gray)
                    }
                    .frame(maxWidth: .infinity)
                    .frame(height: 60)
                }
                .buttonStyle(PlainButtonStyle())
            }
        }
        .background(
            Rectangle()
                .fill(Color(.systemBackground))
                .shadow(color: .black.opacity(0.1), radius: 1, x: 0, y: -1)
        )
        .frame(height: 83)
    }
}

#Preview {
    MainTabView()
}
