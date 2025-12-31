//
//  GitHubModels.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import Foundation

// MARK: - 响应模型

struct GHErrorResponse: Decodable, Sendable {
    let message: String
}

struct GHFileResponse: Decodable, Sendable {
    let name: String
    let path: String
    let sha: String
    let content: String
    let encoding: String
    
    enum CodingKeys: String, CodingKey {
        case name, path, sha, content, encoding
    }
}

struct GHCreateFileResponse: Decodable, Sendable {
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

struct FileContent: Sendable {
    let content: String
    let sha: String
}

struct PublishResult: Sendable {
    let success: Bool
    let filePath: String
    let url: String
    let action: String
}

struct ImageUploadResult: Sendable {
    let success: Bool
    let path: String
    let url: String
    let sha: String
}
