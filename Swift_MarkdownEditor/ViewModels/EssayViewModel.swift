//
//  EssayViewModel.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import Foundation
import SwiftUI
import Combine

/// Essay 视图模型
@MainActor
class EssayViewModel: ObservableObject {
    
    /// Essays 列表
    @Published var essays: [Essay] = []
    
    /// 加载状态
    @Published var isLoading = false
    
    /// 刷新状态
    @Published var isRefreshing = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 当前选中的 Essay（用于详情页）
    @Published var selectedEssay: Essay?
    
    /// 详情加载中
    @Published var isLoadingDetail = false
    
    // MARK: - Public Methods
    
    /// 加载 Essays 列表
    /// - Parameter forceRefresh: 是否强制刷新
    func loadEssays(forceRefresh: Bool = false) async {
        if forceRefresh {
            isRefreshing = true
        } else if essays.isEmpty {
            isLoading = true
        }
        
        errorMessage = nil
        
        do {
            let fetchedEssays = try await EssayService.shared.fetchEssays(forceRefresh: forceRefresh)
            essays = fetchedEssays
        } catch {
            errorMessage = error.localizedDescription
            print("加载 Essays 失败: \(error)")
        }
        
        isLoading = false
        isRefreshing = false
    }
    
    /// 加载 Essay 详情
    /// - Parameter essay: 要加载的 Essay
    func loadEssayDetail(_ essay: Essay) async {
        selectedEssay = essay
        
        // 如果内容已经完整，无需重新加载
        if !essay.content.isEmpty {
            return
        }
        
        isLoadingDetail = true
        
        do {
            let fullEssay = try await EssayService.shared.fetchEssayContent(fileName: essay.fileName)
            selectedEssay = fullEssay
        } catch {
            print("加载 Essay 详情失败: \(error)")
        }
        
        isLoadingDetail = false
    }
    
    /// 清除选中状态
    func clearSelection() {
        selectedEssay = nil
    }
    
    /// 刷新列表
    func refresh() async {
        await loadEssays(forceRefresh: true)
    }
}
