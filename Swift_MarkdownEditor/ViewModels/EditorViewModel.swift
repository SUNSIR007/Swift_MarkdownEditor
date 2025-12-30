//
//  EditorViewModel.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/26.
//

import Foundation
import SwiftUI
import Combine

/// 编辑器视图模型
/// 对应 PWA 中的 Vue data 和 methods
@MainActor
class EditorViewModel: ObservableObject {
    
    // MARK: - 发布状态
    
    @Published var currentType: ContentType = .essay
    @Published var metadata = Metadata()
    @Published var bodyContent: String = ""
    
    // MARK: - UI 状态
    
    @Published var isPublishing: Bool = false
    @Published var showUploadHUD: Bool = false
    @Published var uploadStatus: UploadStatus = .idle
    @Published var showSuccessFeedback: Bool = false
    @Published var showErrorFeedback: Bool = false
    @Published var errorMessage: String = ""
    
    // MARK: - 内部任务引用
    
    private var errorDismissTask: Task<Void, Never>?
    
    // MARK: - 配置状态
    
    var isGitHubConfigured: Bool {
        AppConfig.isGitHubConfigured
    }
    
    var isImageServiceConfigured: Bool {
        AppConfig.isImageServiceConfigured
    }
    
    var hasBodyContent: Bool {
        !bodyContent.trimmingCharacters(in: .whitespacesAndNewlines).isEmpty
    }
    
    // MARK: - 初始化
    
    init() {
        resetMetadata()
    }
    
    // MARK: - 内容类型切换
    
    func selectType(_ type: ContentType) {
        currentType = type
        resetMetadata()
        bodyContent = ""
    }
    
    func resetMetadata() {
        metadata.reset(for: currentType)
    }
    
    // MARK: - 发布
    
    func publish() async {
        guard !isPublishing else { return }
        
        guard isGitHubConfigured else {
            showError("GitHub 配置缺失，请检查 AppConfig.swift")
            return
        }
        
        // 从 WebView 获取最新内容（解决内容同步延迟问题）
        let latestContent = await VditorManager.shared.getContent()
        if !latestContent.isEmpty {
            bodyContent = latestContent
        }
        
        // 调试：打印当前内容
        print("📝 当前内容长度: \(bodyContent.count)")
        print("📝 内容前100字符: \(String(bodyContent.prefix(100)))")
        
        guard hasBodyContent || currentType == .gallery else {
            showError("请先编写内容")
            return
        }
        
        if currentType == .blog && metadata.title.isEmpty {
            showError("请先设置标题")
            return
        }
        
        isPublishing = true
        
        do {
            // 生成完整内容
            let finalContent: String
            if currentType == .gallery {
                finalContent = bodyContent
            } else {
                let frontmatter = metadata.toFrontmatter(for: currentType)
                finalContent = frontmatter + bodyContent
            }
            
            // 发布到 GitHub
            let result = try await GitHubService.shared.publishContent(
                type: currentType,
                metadata: metadata,
                content: finalContent
            )
            
            if result.success {
                // 显示成功反馈
                showSuccessFeedback = true
                
                // 延迟重置
                try? await Task.sleep(nanoseconds: 1_500_000_000)
                showSuccessFeedback = false
                
                // 清除编辑器内容
                bodyContent = ""
                VditorManager.shared.clearContent()
            }
        } catch {
            // 打印详细错误信息用于调试
            print("❌ 发布失败: \(error)")
            print("❌ 错误描述: \(error.localizedDescription)")
            if let gitError = error as? GitHubError {
                print("❌ GitHub 错误详情: \(gitError)")
            }
            
            errorMessage = error.localizedDescription
            
            showErrorFeedback = true
            try? await Task.sleep(nanoseconds: 2_000_000_000)
            showErrorFeedback = false
        }
        
        isPublishing = false
    }
    
    // MARK: - 图片上传
    
    func uploadImage(_ image: UIImage) async -> String? {
        guard isImageServiceConfigured else {
            showError("图床配置缺失")
            return nil
        }
        
        showUploadHUD = true
        uploadStatus = .progress
        
        do {
            let result = try await ImageService.shared.uploadImage(image)
            
            uploadStatus = .success
            try? await Task.sleep(nanoseconds: 800_000_000)
            showUploadHUD = false
            uploadStatus = .idle
            
            return result.url
        } catch {
            uploadStatus = .error
            errorMessage = error.localizedDescription
            
            try? await Task.sleep(nanoseconds: 1_000_000_000)
            showUploadHUD = false
            uploadStatus = .idle
            
            return nil
        }
    }
    
    /// 批量上传图片（聚合显示一个上传窗口）
    func uploadImages(_ images: [UIImage]) async -> [String] {
        guard isImageServiceConfigured else {
            showError("图床配置缺失")
            return []
        }
        
        guard !images.isEmpty else { return [] }
        
        showUploadHUD = true
        uploadStatus = .progress
        
        var uploadedUrls: [String] = []
        
        for image in images {
            do {
                let result = try await ImageService.shared.uploadImage(image)
                uploadedUrls.append(result.url)
            } catch {
                print("图片上传失败: \(error)")
            }
        }
        
        // 上传完成后显示结果
        if uploadedUrls.count == images.count {
            uploadStatus = .success
            HapticManager.notification(.success)
        } else if uploadedUrls.isEmpty {
            uploadStatus = .error
            HapticManager.notification(.error)
        } else {
            // 部分成功
            uploadStatus = .success
            HapticManager.notification(.warning)
        }
        
        try? await Task.sleep(nanoseconds: 800_000_000)
        showUploadHUD = false
        uploadStatus = .idle
        
        return uploadedUrls
    }
    
    /// 插入图片到编辑器
    func insertImageMarkdown(_ url: String, altText: String = "image") {
        let markdown = "![\(altText)](\(url))"
        // 如果内容为空或已经以换行结尾，不添加额外换行
        if bodyContent.isEmpty {
            bodyContent = markdown
        } else if bodyContent.hasSuffix("\n") {
            bodyContent += markdown
        } else {
            bodyContent += "\n\(markdown)"
        }
    }
    
    // MARK: - 错误处理
    
    private func showError(_ message: String) {
        errorMessage = message
        showErrorFeedback = true
        
        // 取消之前的延迟任务
        errorDismissTask?.cancel()
        
        // 创建新的延迟任务并存储引用
        errorDismissTask = Task {
            try? await Task.sleep(nanoseconds: 2_500_000_000)
            if !Task.isCancelled {
                showErrorFeedback = false
            }
        }
    }
}

// MARK: - 上传状态

enum UploadStatus {
    case idle
    case progress
    case success
    case error
}
