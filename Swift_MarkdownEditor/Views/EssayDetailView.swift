//
//  EssayDetailView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import SwiftUI
import WebKit

/// Essay 详情视图
struct EssayDetailView: View {
    let essay: Essay
    @StateObject private var themeManager = ThemeManager.shared
    @Environment(\.dismiss) private var dismiss
    
    var body: some View {
        ZStack {
            // 背景色
            ThemeColors.current(themeManager.currentTheme).bgBody
                .ignoresSafeArea()
            
            VStack(spacing: 0) {
                // 日期信息
                HStack {
                    Image(systemName: "calendar")
                        .font(.caption)
                        .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
                    
                    Text(essay.formattedDate)
                        .font(.caption)
                        .foregroundColor(ThemeColors.current(themeManager.currentTheme).textSecondary)
                    
                    Spacer()
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 8)
                
                // Markdown 内容
                MarkdownWebView(content: essay.content, theme: themeManager.currentTheme)
                    .clipShape(RoundedRectangle(cornerRadius: 16))
                    .overlay(
                        RoundedRectangle(cornerRadius: 16)
                            .stroke(Color.white.opacity(0.12), lineWidth: 1)
                    )
                    .padding(.horizontal, 16)
                    .padding(.bottom, 16)
            }
        }
        .navigationTitle(essay.title ?? "随笔详情")
        .navigationBarTitleDisplayMode(.inline)
        .toolbarBackground(
            ThemeColors.current(themeManager.currentTheme).bgSurface,
            for: .navigationBar
        )
        .toolbarBackground(.visible, for: .navigationBar)
    }
}

// MARK: - Markdown WebView

/// 用于渲染 Markdown 内容的 WebView
struct MarkdownWebView: UIViewRepresentable {
    let content: String
    let theme: AppTheme
    
    func makeUIView(context: Context) -> WKWebView {
        let config = WKWebViewConfiguration()
        config.allowsInlineMediaPlayback = true
        
        let webView = WKWebView(frame: .zero, configuration: config)
        webView.isOpaque = false
        webView.backgroundColor = .clear
        webView.scrollView.backgroundColor = .clear
        webView.scrollView.showsVerticalScrollIndicator = true
        webView.scrollView.showsHorizontalScrollIndicator = false
        
        return webView
    }
    
    func updateUIView(_ webView: WKWebView, context: Context) {
        let isDark = (theme == .slate || theme == .oled)
        let html = generateHTML(content: content, isDark: isDark)
        webView.loadHTMLString(html, baseURL: nil)
    }
    
    private func generateHTML(content: String, isDark: Bool) -> String {
        let bgColor = isDark ? "#1a1a1a" : "#ffffff"
        let textColor = isDark ? "#e0e0e0" : "#333333"
        let linkColor = isDark ? "#64b5f6" : "#1976d2"
        let codeBackground = isDark ? "#2d2d2d" : "#f5f5f5"
        
        // 转义内容中的特殊字符
        let escapedContent = content
            .replacingOccurrences(of: "\\", with: "\\\\")
            .replacingOccurrences(of: "`", with: "\\`")
            .replacingOccurrences(of: "$", with: "\\$")
        
        return """
        <!DOCTYPE html>
        <html>
        <head>
            <meta charset="UTF-8">
            <meta name="viewport" content="width=device-width, initial-scale=1.0, maximum-scale=1.0, user-scalable=no">
            <script src="https://cdn.jsdelivr.net/npm/marked/marked.min.js"></script>
            <style>
                * {
                    box-sizing: border-box;
                }
                body {
                    font-family: -apple-system, BlinkMacSystemFont, 'Segoe UI', Roboto, sans-serif;
                    font-size: 16px;
                    line-height: 1.6;
                    color: \(textColor);
                    background-color: \(bgColor);
                    padding: 16px;
                    margin: 0;
                    word-wrap: break-word;
                }
                h1, h2, h3, h4, h5, h6 {
                    margin-top: 1.5em;
                    margin-bottom: 0.5em;
                    font-weight: 600;
                }
                h1 { font-size: 1.5em; }
                h2 { font-size: 1.3em; }
                h3 { font-size: 1.1em; }
                p {
                    margin: 1em 0;
                }
                a {
                    color: \(linkColor);
                    text-decoration: none;
                }
                img {
                    max-width: 100%;
                    height: auto;
                    border-radius: 8px;
                    margin: 1em 0;
                }
                code {
                    font-family: 'SF Mono', Menlo, Monaco, monospace;
                    font-size: 0.9em;
                    background-color: \(codeBackground);
                    padding: 2px 6px;
                    border-radius: 4px;
                }
                pre {
                    background-color: \(codeBackground);
                    padding: 16px;
                    border-radius: 8px;
                    overflow-x: auto;
                }
                pre code {
                    background: none;
                    padding: 0;
                }
                blockquote {
                    margin: 1em 0;
                    padding-left: 16px;
                    border-left: 4px solid \(linkColor);
                    color: \(isDark ? "#a0a0a0" : "#666666");
                }
                ul, ol {
                    padding-left: 24px;
                }
                li {
                    margin: 0.5em 0;
                }
                hr {
                    border: none;
                    border-top: 1px solid \(isDark ? "#333" : "#eee");
                    margin: 2em 0;
                }
            </style>
        </head>
        <body>
            <div id="content"></div>
            <script>
                document.getElementById('content').innerHTML = marked.parse(`\(escapedContent)`);
            </script>
        </body>
        </html>
        """
    }
}

#Preview {
    NavigationStack {
        EssayDetailView(essay: Essay(
            fileName: "test.md",
            title: "测试随笔",
            pubDate: Date(),
            content: "# 这是标题\\n\\n这是正文内容，包含一些 **粗体** 和 *斜体* 文字。\\n\\n![图片](https://example.com/image.jpg)",
            rawContent: ""
        ))
    }
}
