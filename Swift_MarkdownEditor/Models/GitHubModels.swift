//
//  GitHubModels.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import Foundation

// MARK: - API 响应模型

/// GitHub API 错误响应
struct GitHubErrorResponse: Decodable, Sendable {
    let message: String
}

/// GitHub 文件响应
struct GitHubFileResponse: Decodable, Sendable {
    let name: String
    let path: String
    let sha: String
    let content: String
    let encoding: String
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, content, encoding
    }
}

/// 创建/更新文件响应
struct CreateFileResponse: Decodable, Sendable {
    let content: FileInfo
    
    struct FileInfo: Decodable, Sendable {
        let name: String
        let path: String
        let sha: String
        let htmlUrl: String
        
        enum CodingKeys: String, CodingKey {
            case name, path, sha
            case htmlUrl = "html_url"
        }
    }
}

// MARK: - 内部数据模型

/// 文件内容包装
struct FileContent: Sendable {
    let content: String
    let sha: String
}

/// 发布结果
struct PublishResult: Sendable {
    let success: Bool
    let filePath: String
    let url: String
    let action: String
}

/// 图片上传结果
struct ImageUploadResult: Sendable {
    let success: Bool
    let path: String
    let url: String
    let sha: String
}
