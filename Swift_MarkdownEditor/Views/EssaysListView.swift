//
//  EssaysListView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import SwiftUI

/// Essays 列表视图
struct EssaysListView: View {
    @StateObject private var viewModel = EssayViewModel()
    @StateObject private var themeManager = ThemeManager.shared
    @State private var selectedEssay: Essay?
    
    var body: some View {
        NavigationStack {
            ZStack {
                // 背景色
                ThemeColors.current(themeManager.currentTheme).bgBody
                    .ignoresSafeArea()
                
                if viewModel.isLoading {
                    // 加载状态
                    loadingView
                } else if let error = viewModel.errorMessage {
                    // 错误状态
                    errorView(message: error)
                } else if viewModel.essays.isEmpty {
                    // 空状态
                    emptyView
                } else {
                    // 列表
                    essaysList
                }
            }
            .navigationTitle("随笔")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(
                ThemeColors.current(themeManager.currentTheme).bgSurface,
                for: .navigationBar
            )
            .toolbarBackground(.visible, for: .navigationBar)
            .toolbar {
                ToolbarItem(placement: .topBarTrailing) {
                    Button {
                        Task {
                            await viewModel.refresh()
                        }
                    } label: {
                        Image(systemName: "arrow.clockwise")
                            .foregroundColor(.primaryBlue)
                    }
                    .disabled(viewModel.isRefreshing)
                }
            }
            .navigationDestination(item: $selectedEssay) { essay in
                EssayDetailView(essay: essay)
            }
        }
        .task {
            await viewModel.loadEssays()
        }
    }
    
    // MARK: - Subviews
    
    private var loadingView: some View {
        VStack(spacing: 16) {
            ProgressView()
                .progressViewStyle(.circular)
                .scaleEffect(1.2)
                .tint(.primaryBlue)
            
            Text("加载中...")
                .font(.subheadline)
                .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
        }
    }
    
    private func errorView(message: String) -> some View {
        VStack(spacing: 16) {
            Image(systemName: "exclamationmark.triangle")
                .font(.system(size: 48))
                .foregroundColor(.orange)
            
            Text("加载失败")
                .font(.headline)
                .foregroundColor(ThemeColors.current(themeManager.currentTheme).textMain)
            
            Text(message)
                .font(.subheadline)
                .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
                .multilineTextAlignment(.center)
                .padding(.horizontal, 32)
            
            Button {
                Task {
                    await viewModel.loadEssays(forceRefresh: true)
                }
            } label: {
                Label("重试", systemImage: "arrow.clockwise")
                    .padding(.horizontal, 24)
                    .padding(.vertical, 12)
                    .background(Color.primaryBlue)
                    .foregroundColor(.white)
                    .cornerRadius(8)
            }
        }
    }
    
    private var emptyView: some View {
        VStack(spacing: 16) {
            Image(systemName: "doc.text")
                .font(.system(size: 48))
                .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
            
            Text("暂无随笔")
                .font(.headline)
                .foregroundColor(ThemeColors.current(themeManager.currentTheme).textMain)
            
            Text("去写一些随笔吧")
                .font(.subheadline)
                .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
        }
    }
    
    private var essaysList: some View {
        List {
            ForEach(viewModel.essays) { essay in
                Button {
                    selectedEssay = essay
                } label: {
                    EssayRowView(essay: essay)
                }
                .listRowBackground(ThemeColors.current(themeManager.currentTheme).bgSurface)
                .listRowSeparatorTint(Color.white.opacity(0.1))
            }
        }
        .listStyle(.plain)
        .scrollContentBackground(.hidden)
        .refreshable {
            await viewModel.refresh()
        }
    }
}

#Preview {
    EssaysListView()
}
