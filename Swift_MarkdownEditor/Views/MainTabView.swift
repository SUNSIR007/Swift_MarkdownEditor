//
//  MainTabView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import SwiftUI

/// 主 TabBar 视图
struct MainTabView: View {
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedTab = 0
    
    var body: some View {
        TabView(selection: $selectedTab) {
            // 编辑器 Tab
            ContentView()
                .tabItem {
                    Label("编辑", systemImage: "square.and.pencil")
                }
                .tag(0)
            
            // Essays Tab
            EssaysListView()
                .tabItem {
                    Label("随笔", systemImage: "book.fill")
                }
                .tag(1)
        }
        .tint(.primaryBlue)
        .onAppear {
            // 自定义 TabBar 外观
            configureTabBarAppearance()
        }
        .onChange(of: themeManager.currentTheme) { _, _ in
            configureTabBarAppearance()
        }
    }
    
    private func configureTabBarAppearance() {
        let appearance = UITabBarAppearance()
        appearance.configureWithOpaqueBackground()
        
        // 根据主题设置颜色
        let bgColor: UIColor
        let itemColor: UIColor
        let selectedColor: UIColor
        
        switch themeManager.currentTheme {
        case .slate:
            bgColor = UIColor(red: 0.06, green: 0.09, blue: 0.16, alpha: 1.0)
            itemColor = UIColor(white: 0.6, alpha: 1.0)
            selectedColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1.0)
        case .oled:
            bgColor = .black
            itemColor = UIColor(white: 0.5, alpha: 1.0)
            selectedColor = UIColor(red: 0.23, green: 0.51, blue: 0.96, alpha: 1.0)
        }
        
        appearance.backgroundColor = bgColor
        appearance.stackedLayoutAppearance.normal.iconColor = itemColor
        appearance.stackedLayoutAppearance.normal.titleTextAttributes = [.foregroundColor: itemColor]
        appearance.stackedLayoutAppearance.selected.iconColor = selectedColor
        appearance.stackedLayoutAppearance.selected.titleTextAttributes = [.foregroundColor: selectedColor]
        
        UITabBar.appearance().standardAppearance = appearance
        UITabBar.appearance().scrollEdgeAppearance = appearance
    }
}

#Preview {
    MainTabView()
}
