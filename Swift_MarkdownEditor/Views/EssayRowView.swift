//
//  EssayRowView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import SwiftUI

/// Essay 列表行视图
struct EssayRowView: View {
    let essay: Essay
    @StateObject private var themeManager = ThemeManager.shared
    
    var body: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 日期
            HStack {
                Image(systemName: "calendar")
                    .font(.caption)
                    .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
                
                Text(essay.formattedDate)
                    .font(.caption)
                    .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
                
                Spacer()
                
                Text(essay.relativeDate)
                    .font(.caption2)
                    .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary.opacity(0.7))
            }
            
            // 标题或预览
            if let title = essay.title {
                Text(title)
                    .font(.headline)
                    .foregroundColor(ThemeColors.current(themeManager.currentTheme).textMain)
                    .lineLimit(2)
            }
            
            // 内容预览
            Text(essay.preview)
                .font(.subheadline)
                .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
                .lineLimit(2)
        }
        .padding(.vertical, 8)
    }
}

#Preview {
    let sampleEssay = Essay(
        fileName: "2025-12-27-124830.md",
        title: nil,
        pubDate: Date(),
        content: "这是一段测试内容，用于预览 Essay 列表行的显示效果。",
        rawContent: "---\npubDate: 2025-12-27\n---\n这是一段测试内容。"
    )
    
    return EssayRowView(essay: sampleEssay)
        .padding()
        .background(Color.black)
}
