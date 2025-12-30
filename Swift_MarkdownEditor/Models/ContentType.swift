//
//  ContentType.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/26.
//

import Foundation

/// 内容类型枚举，对应 PWA 中的 contentTypes
enum ContentType: String, CaseIterable, Identifiable {
    case blog = "blog"
    case essay = "essay"
    case gallery = "gallery"
    
    var id: String { rawValue }
    
    /// 显示标签
    var label: String {
        switch self {
        case .blog: return "Blogs"
        case .essay: return "Essays"
        case .gallery: return "Gallery"
        }
    }
    
    /// 图标名称 (SF Symbols)
    var iconName: String {
        switch self {
        case .blog: return "doc.text"
        case .essay: return "pencil.line"
        case .gallery: return "photo"
        }
    }
    
    /// 文件存储路径前缀
    var pathPrefix: String {
        switch self {
        case .blog: return "src/content/posts"
        case .essay: return "src/content/essays"
        case .gallery: return "src/content/photos"
        }
    }
}
