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
    private let timelineWidth: CGFloat = 24
    
    var body: some View {
        HStack(alignment: .top, spacing: 16) {
            // 左侧时间轴装饰
            timelineDecoration
            
            // 右侧内容区
            contentArea
        }
    }
    
    // MARK: - 时间轴装饰（连续垂直线）
    
    private var timelineDecoration: some View {
        ZStack(alignment: .top) {
            // 垂直连接线（贯穿整个区域）
            if !isLast {
                Rectangle()
                    .fill(timelineColor)
                    .frame(width: lineWidth)
                    .offset(x: (timelineWidth - lineWidth) / 2 - timelineWidth / 2)
            }
            
            // 节点圆点（在顶部）
            Circle()
                .fill(timelineColor)
                .frame(width: dotSize, height: dotSize)
                .padding(.top, 6)
        }
        .frame(width: timelineWidth)
        .frame(maxHeight: .infinity, alignment: .top)
    }
    
    // MARK: - 内容区
    
    private var contentArea: some View {
        VStack(alignment: .leading, spacing: 10) {
            // 元数据行（作者 + 日期）
            metadataRow
            
            // 标题（如果有）
            if let title = essay.title, !title.isEmpty {
                Text(title)
                    .font(.headline)
                    .foregroundColor(.white)
            }
            
            // 图片预览（如果有）
            if let imageURL = essay.firstImageURL {
                AsyncImage(url: imageURL) { phase in
                    switch phase {
                    case .empty:
                        ProgressView()
                            .frame(height: 150)
                    case .success(let image):
                        image
                            .resizable()
                            .aspectRatio(contentMode: .fill)
                            .frame(maxWidth: .infinity)
                            .frame(height: 180)
                            .clipped()
                            .cornerRadius(8)
                    case .failure:
                        EmptyView()
                    @unknown default:
                        EmptyView()
                    }
                }
            }
            
            // 正文预览（如果有文字内容且不只是图片）
            if essay.preview != "（图片）" {
                Text(essay.preview)
                    .font(.body)
                    .foregroundColor(.white)
                    .lineLimit(3)
                    .fixedSize(horizontal: false, vertical: true)
            }
        }
        .padding(.vertical, 16)
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
    ScrollView {
        VStack(spacing: 0) {
            EssayRowView(
                essay: Essay(
                    fileName: "test1.md",
                    title: nil,
                    pubDate: Date(),
                    content: "![image](https://example.com/image.jpg)",
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
                isLast: false
            )
            
            EssayRowView(
                essay: Essay(
                    fileName: "test3.md",
                    title: nil,
                    pubDate: Date().addingTimeInterval(-172800),
                    content: "最后一条随笔。",
                    rawContent: ""
                ),
                isLast: true
            )
        }
        .padding()
    }
    .background(Color.black)
}
