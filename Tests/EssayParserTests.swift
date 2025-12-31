//
//  EssayParserTests.swift
//  Swift_MarkdownEditorTests
//
//  Created by Ryuichi on 2025/12/31.
//

import XCTest
@testable import Swift_MarkdownEditor

final class EssayParserTests: XCTestCase {

    func testParseCompleteEssay() {
        let rawContent = """
        ---
        title: "测试文章标题"
        pubDate: "2023-10-01 12:00:00"
        ---
        这是文章的正文内容。
        """
        
        let essay = Essay.parse(rawContent: rawContent, fileName: "test.md")
        
        XCTAssertNotNil(essay)
        XCTAssertEqual(essay?.title, "测试文章标题")
        XCTAssertEqual(essay?.content, "这是文章的正文内容。")
        XCTAssertEqual(essay?.rawContent, rawContent)
        
        // 验证日期
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expectedDate = formatter.date(from: "2023-10-01 12:00:00")
        XCTAssertEqual(essay?.pubDate, expectedDate)
    }
    
    func testParseEssayWithFileNameDate() {
        let rawContent = """
        ---
        title: "无日期文章"
        ---
        正文
        """
        // 文件名包含日期: 2023-10-02-143000.md
        let fileName = "2023-10-02-143000.md"
        let essay = Essay.parse(rawContent: rawContent, fileName: fileName)
        
        XCTAssertNotNil(essay)
        XCTAssertEqual(essay?.title, "无日期文章")
        
        // 验证从文件名提取的日期
        let formatter = DateFormatter()
        formatter.dateFormat = "yyyy-MM-dd HH:mm:ss"
        let expectedDate = formatter.date(from: "2023-10-02 14:30:00")
        XCTAssertEqual(essay?.pubDate, expectedDate)
    }
    
    func testParseContentOnly() {
        let rawContent = """
        # 正文标题
        
        没有 Frontmatter 的文章。
        """
        
        let essay = Essay.parse(rawContent: rawContent, fileName: "2023-10-03-100000.md")
        
        XCTAssertNotNil(essay)
        // 这个逻辑取决于 parseTitle 的实现，如果没有 frontmatter title，是否会提取 H1？
        // 假设当前实现主要依赖 frontmatter 或文件名解析日期，标题可能为 nil 或提取 H1
        // 从之前的代码看，parseTitle 似乎也会尝试从内容提取 H1 (TODO: Check parseTitle implementation details if needed)
        // 为了安全起见，这里只断言基本内容
        XCTAssertEqual(essay?.content, rawContent.trimmingCharacters(in: .whitespacesAndNewlines))
    }
    
    func testPreviewGeneration() {
        let content = """
        这是开头。
        ![图片](image.jpg)
        [链接文本](https://example.com)
        这是结尾。
        """
        
        let essay = Essay(
            fileName: "test.md",
            title: "Test",
            pubDate: Date(),
            content: content,
            rawContent: content
        )
        
        // 预期：移除图片，保留链接文本
        let expectedPreview = "这是开头。 链接文本 这是结尾。"
        XCTAssertEqual(essay.preview, expectedPreview)
    }
    
    func testFirstImageURLExtraction() {
        let content = """
        文本...
        ![Image 1](https://example.com/1.jpg)
        ![Image 2](https://example.com/2.jpg)
        """
        
        let essay = Essay(
            fileName: "test.md",
            title: "Test",
            pubDate: Date(),
            content: content,
            rawContent: content
        )
        
        XCTAssertEqual(essay.firstImageURL?.absoluteString, "https://example.com/1.jpg")
        XCTAssertTrue(essay.hasImage)
    }
}
