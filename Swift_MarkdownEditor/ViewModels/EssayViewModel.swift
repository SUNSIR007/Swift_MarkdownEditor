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
    
    /// 加载状态（首次加载时显示）
    @Published var isLoading = false
    
    /// 刷新状态（下拉刷新时使用）
    @Published var isRefreshing = false
    
    /// 错误信息
    @Published var errorMessage: String?
    
    /// 当前选中的 Essay（用于详情页）
    @Published var selectedEssay: Essay?
    
    /// 详情加载中
    @Published var isLoadingDetail = false
    
    /// 是否已加载过数据
    private var hasLoadedOnce = false
    
    /// 刷新任务
    private var refreshTask: Task<Void, Never>?
    
    // MARK: - Public Methods
    
    /// 加载 Essays 列表
    /// - Parameter forceRefresh: 是否强制刷新
    func loadEssays(forceRefresh: Bool = false) async {
        // 如果有缓存数据，先显示缓存
        if !hasLoadedOnce {
            let cachedData = await EssayService.shared.getCachedEssays()
            if !cachedData.isEmpty {
                essays = cachedData
                print("📦 先显示缓存数据，共 \(cachedData.count) 条")
            }
        }
        
        // 设置加载状态
        if forceRefresh {
            isRefreshing = true
        } else if essays.isEmpty {
            isLoading = true
        }
        
        errorMessage = nil
        
        do {
            let fetchedEssays = try await EssayService.shared.fetchEssays(forceRefresh: forceRefresh)
            
            // 更新数据
            essays = fetchedEssays
            errorMessage = nil
            hasLoadedOnce = true
            
        } catch {
            // 只有在没有数据时才显示错误
            if essays.isEmpty {
                errorMessage = error.localizedDescription
            }
            print("❌ 加载 Essays 失败: \(error)")
        }
        
        isLoading = false
        isRefreshing = false
    }
    
    /// 刷新列表 - 用于下拉刷新
    func refresh() async {
        // 取消之前的刷新任务
        refreshTask?.cancel()
        
        // 创建一个独立的 Task 来执行刷新
        refreshTask = Task.detached { [weak self] in
            guard let self = self else { return }
            
            do {
                let fetchedEssays = try await EssayService.shared.fetchEssays(forceRefresh: true)
                await MainActor.run {
                    self.essays = fetchedEssays
                    self.errorMessage = nil
                    // 刷新成功触觉反馈
                    HapticManager.notification(.success)
                }
            } catch {
                print("❌ 刷新 Essays 失败: \(error)")
                // 刷新失败时不显示错误，保持现有数据
                await MainActor.run {
                    // 刷新失败轻触觉反馈
                    HapticManager.notification(.warning)
                }
            }
        }
        
        // 等待任务完成（但如果被取消也没关系，后台任务会继续）
        _ = await refreshTask?.value
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
            print("❌ 加载 Essay 详情失败: \(error)")
        }
        
        isLoadingDetail = false
    }
    
    /// 清除选中状态
    func clearSelection() {
        selectedEssay = nil
    }
}

