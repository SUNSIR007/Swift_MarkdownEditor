//
//  Metadata.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/26.
//

import Foundation

/// 内容元数据模型
/// 对应 PWA 中的 metadata 对象
struct Metadata {
    var title: String = ""
    var categories: String = "Daily"
    var pubDate: String = ""
    var description: String = ""
    var date: String = ""
    
    /// 根据内容类型重置元数据
    mutating func reset(for contentType: ContentType) {
        let now = Date()
        let dateFormatter = DateFormatter()
        
        switch contentType {
        case .blog:
            dateFormatter.dateFormat = "yyyy-MM-dd"
            title = ""
            categories = "Daily"
            pubDate = dateFormatter.string(from: now)
            description = ""
            date = ""
            
        case .essay:
            dateFormatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
            title = ""
            categories = ""
            pubDate = dateFormatter.string(from: now)
            description = ""
            date = ""
            
        case .gallery:
            dateFormatter.dateFormat = "yyyy-MM-dd"
            title = ""
            categories = ""
            pubDate = ""
            description = ""
            date = dateFormatter.string(from: now)
        }
    }
    
    /// 生成 YAML Frontmatter
    func toFrontmatter(for contentType: ContentType) -> String {
        var lines: [String] = []
        
        switch contentType {
        case .blog:
            if !title.isEmpty {
                lines.append("title: \(title)")
            }
            if !categories.isEmpty {
                let cats = categories.split(separator: ",")
                    .map { $0.trimmingCharacters(in: .whitespaces) }
                    .filter { !$0.isEmpty }
                if !cats.isEmpty {
                    lines.append("categories: [\(cats.map { "\"\($0)\"" }.joined(separator: ", "))]")
                }
            }
            if !pubDate.isEmpty {
                lines.append("pubDate: \"\(pubDate)\"")
            }
            
        case .essay:
            if !pubDate.isEmpty {
                lines.append("pubDate: \"\(pubDate)\"")
            }
            
        case .gallery:
            // Gallery 使用 JSON 格式，不需要 frontmatter
            break
        }
        
        guard !lines.isEmpty else { return "" }
        return "---\n\(lines.joined(separator: "\n"))\n---\n\n"
    }
}
