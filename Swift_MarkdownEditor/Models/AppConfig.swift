//
//  AppConfig.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/26.
//

import Foundation
import Security

/// 应用配置，包含 GitHub Token 和仓库配置
/// 对应 PWA 中的 runtime-config.js
struct AppConfig {
    
    // MARK: - GitHub 配置（内容仓库）
    
    /// GitHub Personal Access Token
    static var githubToken: String {
        // 直接返回 Token（个人使用）
        return "YOUR_GITHUB_TOKEN_HERE"
    }
    
    /// GitHub 用户名
    static let githubOwner = "SUNSIR007"
    
    /// 内容仓库名称
    static let githubRepo = "astro_blog"
    
    /// 分支名称
    static let githubBranch = "main"
    
    // MARK: - 图床配置（图片仓库）
    
    /// 图片仓库名称
    static let imageRepo = "picx-images-hosting"
    
    /// 图片分支
    static let imageBranch = "master"
    
    /// 图片存储路径前缀
    static let imagePath = "images"
    
    /// CDN 类型: "jsdelivr", "statically", "raw"
    static let cdnType = "jsdelivr"
    
    // MARK: - 图片压缩配置
    
    /// 最大图片宽度
    static let maxImageWidth: CGFloat = 1920
    
    /// 最大图片高度
    static let maxImageHeight: CGFloat = 1080
    
    /// 图片压缩质量 (0.0 - 1.0)
    static let imageQuality: CGFloat = 0.85
    
    /// 最大文件大小 (字节) - 5MB
    static let maxFileSize: Int = 5 * 1024 * 1024
    
    // MARK: - API 配置
    
    /// GitHub API 基础 URL
    static let githubAPIBaseURL = "https://api.github.com"
    
    // MARK: - 辅助方法
    
    /// 检查 GitHub 是否已配置
    static var isGitHubConfigured: Bool {
        let token = githubToken
        return !token.isEmpty &&
        token != "YOUR_GITHUB_TOKEN_HERE" &&
        !githubOwner.isEmpty &&
        githubOwner != "YOUR_GITHUB_USERNAME" &&
        !githubRepo.isEmpty &&
        githubRepo != "YOUR_CONTENT_REPO"
    }
    
    /// 检查图床是否已配置
    static var isImageServiceConfigured: Bool {
        isGitHubConfigured &&
        !imageRepo.isEmpty &&
        imageRepo != "YOUR_IMAGE_REPO"
    }
    
    /// 生成图片 CDN 链接
    static func generateImageCDNUrl(path: String) -> String {
        switch cdnType {
        case "jsdelivr":
            return "https://cdn.jsdelivr.net/gh/\(githubOwner)/\(imageRepo)@\(imageBranch)/\(path)"
        case "statically":
            return "https://cdn.statically.io/gh/\(githubOwner)/\(imageRepo)/\(imageBranch)/\(path)"
        default:
            return "https://raw.githubusercontent.com/\(githubOwner)/\(imageRepo)/\(imageBranch)/\(path)"
        }
    }
    
    /// 保存 GitHub Token 到 Keychain
    static func saveGitHubToken(_ token: String) -> Bool {
        KeychainHelper.save(key: "github_token", value: token)
    }
    
    /// 删除 GitHub Token
    static func deleteGitHubToken() -> Bool {
        KeychainHelper.delete(key: "github_token")
    }
}

// MARK: - Keychain Helper

/// Keychain 辅助类，用于安全存储敏感信息
enum KeychainHelper {
    
    /// 保存值到 Keychain
    @discardableResult
    static func save(key: String, value: String) -> Bool {
        guard let data = value.data(using: .utf8) else { return false }
        
        // 先删除已存在的项
        delete(key: key)
        
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.app.markdowneditor",
            kSecValueData as String: data,
            kSecAttrAccessible as String: kSecAttrAccessibleWhenUnlockedThisDeviceOnly
        ]
        
        let status = SecItemAdd(query as CFDictionary, nil)
        return status == errSecSuccess
    }
    
    /// 从 Keychain 读取值
    static func get(key: String) -> String? {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.app.markdowneditor",
            kSecReturnData as String: true,
            kSecMatchLimit as String: kSecMatchLimitOne
        ]
        
        var result: AnyObject?
        let status = SecItemCopyMatching(query as CFDictionary, &result)
        
        guard status == errSecSuccess,
              let data = result as? Data,
              let value = String(data: data, encoding: .utf8) else {
            return nil
        }
        
        return value
    }
    
    /// 从 Keychain 删除值
    @discardableResult
    static func delete(key: String) -> Bool {
        let query: [String: Any] = [
            kSecClass as String: kSecClassGenericPassword,
            kSecAttrAccount as String: key,
            kSecAttrService as String: Bundle.main.bundleIdentifier ?? "com.app.markdowneditor"
        ]
        
        let status = SecItemDelete(query as CFDictionary)
        return status == errSecSuccess || status == errSecItemNotFound
    }
}
