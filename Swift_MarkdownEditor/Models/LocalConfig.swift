//
//  LocalConfig.swift
//  Swift_MarkdownEditor
//
//  ⚠️ 重要：此文件包含敏感信息，已添加到 .gitignore
//  请在首次运行时配置你的 GitHub Token
//

import Foundation

/// 本地配置 - 运行时初始化 Token
/// 此文件不会被提交到 Git 仓库
enum LocalConfig {
    
    /// 你的 GitHub Personal Access Token
    /// 请在这里填入你的真实 Token
    private static let myGitHubToken = "YOUR_GITHUB_TOKEN_HERE"
    
    /// 初始化配置（在 App 启动时调用）
    static func initializeIfNeeded() {
        // 检查是否已配置
        if !AppConfig.isGitHubConfigured {
            // 如果本地配置了 Token，则保存到 Keychain
            if myGitHubToken != "YOUR_GITHUB_TOKEN_HERE" && !myGitHubToken.isEmpty {
                AppConfig.saveGitHubToken(myGitHubToken)
                print("✅ GitHub Token 已保存到 Keychain")
            } else {
                print("⚠️ 请在 LocalConfig.swift 中配置你的 GitHub Token")
            }
        }
    }
}
