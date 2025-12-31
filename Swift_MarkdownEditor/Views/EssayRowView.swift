//
//  EssayRowView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import SwiftUI

/// Essay 时间轴行视图 - 复刻网页 UI
struct EssayRowView: View {
    let essay: Essay
    let isLast: Bool
    
    // 时间轴样式常量
    private let timelineColor = Color(hex: "#6B7280")
    private let dotSize: CGFloat = 8
    private let lineWidth: CGFloat = 2
    private let timelineWidth: CGFloat = 30
    
    var body: some View {
        HStack(alignment: .top, spacing: 15) {
            // 左侧时间轴装饰
            timelineDecoration
            
            // 右侧内容区
            contentArea
        }
        .padding(.vertical, 12)
    }
    
    // MARK: - 时间轴装饰
    
    private var timelineDecoration: some View {
        VStack(spacing: 0) {
            // 节点圆点
            Circle()
                .fill(timelineColor)
                .frame(width: dotSize, height: dotSize)
            
            // 垂直连接线（非最后一条时显示）
            if !isLast {
                Rectangle()
                    .fill(timelineColor)
                    .frame(width: lineWidth)
                    .frame(maxHeight: .infinity)
            }
        }
        .frame(width: timelineWidth)
    }
    
    // MARK: - 内容区
    
    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 8) {
            // 元数据行（作者 + 日期）
            metadataRow
            
            // 标题（如果有）
            if let title = essay.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // 正文预览
            Text(essay.preview)
                .font(.body)
                .foregroundColor(.white)
                .lineLimit(nil)
                .fixedSize(horizontal: false, vertical: true)
        }
    }
    
    // MARK: - 元数据行
    
    private var metadataRow: some View {
        HStack(spacing: 8) {
            Text("Ryuichi")
                .font(.caption)
                .foregroundColor(timelineColor)
            
            Text(essay.webFormattedDate)
                .font(.caption)
                .foregroundColor(timelineColor)
        }
    }
}

// MARK: - Essay 扩展

extension Essay {
    /// 网页风格的日期格式（2025/12/27 12:48）
    var webFormattedDate: String {
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy/MM/dd HH:mm"
        formatter.locale = Locale(identifier: "zh_CN")
        return formatter.string(from: pubDate)
    }
}

#Preview {
    VStack(spacing: 0) {
        EssayRowView(
            essay: Essay(
                fileName: "test1.md",
                title: nil,
                pubDate: Date(),
                content: "这是一段测试内容，用于预览时间轴风格的 Essay 列表显示效果。",
                rawContent: ""
            ),
            isLast: false
        )
        
        EssayRowView(
            essay: Essay(
                fileName: "test2.md",
                title: "这是一个标题",
                pubDate: Date().addingTimeInterval(-86400),
                content: "第二条随笔的内容。",
                rawContent: ""
            ),
            isLast: true
        )
    }
    .padding()
    .background(Color.black)
}
