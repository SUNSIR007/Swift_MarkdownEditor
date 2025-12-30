//
//  PixelGhostView.swift
//  Swift_MarkdownEditor
//
//  像素风格幽灵动画 - 用于图片上传加载
//

import SwiftUI

// MARK: - 像素幽灵加载视图

struct PixelGhostView: View {
    @State private var isUp = false
    @State private var eyePosition: CGFloat = 0
    
    private let pixelSize: CGFloat = 5
    private let ghostColor = Color.red
    
    var body: some View {
        ZStack {
            // 阴影
            Ellipse()
                .fill(Color.black.opacity(0.4))
                .frame(width: 60, height: 12)
                .blur(radius: 6)
                .offset(y: 45)
            
            // 幽灵主体
            ZStack {
                // 身体
                GhostBody(pixelSize: pixelSize, color: ghostColor)
                
                // 左眼
                GhostEye(pixelSize: pixelSize)
                    .offset(x: -12, y: -10)
                
                // 右眼
                GhostEye(pixelSize: pixelSize)
                    .offset(x: 12, y: -10)
                
                // 左瞳孔
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: pixelSize * 2, height: pixelSize * 2)
                    .offset(x: -12 + eyePosition, y: -3)
                
                // 右瞳孔
                Rectangle()
                    .fill(Color.blue)
                    .frame(width: pixelSize * 2, height: pixelSize * 2)
                    .offset(x: 12 + eyePosition, y: -3)
            }
            .offset(y: isUp ? -4 : 0)
        }
        .frame(width: 70, height: 90)
        .onAppear {
            // 上下浮动动画
            withAnimation(.easeInOut(duration: 0.6).repeatForever(autoreverses: true)) {
                isUp = true
            }
            
            // 眼睛移动动画
            withAnimation(.easeInOut(duration: 1.5).repeatForever(autoreverses: true)) {
                eyePosition = 5
            }
        }
    }
}

// MARK: - 幽灵身体

struct GhostBody: View {
    let pixelSize: CGFloat
    let color: Color
    
    private var bodyWidth: CGFloat { pixelSize * 12 }
    
    var body: some View {
        VStack(spacing: 0) {
            // 顶部圆弧
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelSize * 2, height: pixelSize)
                color.frame(width: pixelSize * 8, height: pixelSize)
                Color.clear.frame(width: pixelSize * 2, height: pixelSize)
            }
            .frame(width: bodyWidth)
            
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelSize, height: pixelSize)
                color.frame(width: pixelSize * 10, height: pixelSize)
                Color.clear.frame(width: pixelSize, height: pixelSize)
            }
            .frame(width: bodyWidth)
            
            // 主体
            ForEach(0..<8, id: \.self) { _ in
                color.frame(width: bodyWidth, height: pixelSize)
            }
            
            // 底部波浪（静态）
            HStack(spacing: 0) {
                // 波浪图案: ██ _ ██ __ ██ _ ██
                color.frame(width: pixelSize * 2, height: pixelSize)
                Color.clear.frame(width: pixelSize, height: pixelSize)
                color.frame(width: pixelSize * 2, height: pixelSize)
                Color.clear.frame(width: pixelSize * 2, height: pixelSize)
                color.frame(width: pixelSize * 2, height: pixelSize)
                Color.clear.frame(width: pixelSize, height: pixelSize)
                color.frame(width: pixelSize * 2, height: pixelSize)
            }
            .frame(width: bodyWidth)
        }
        .frame(width: bodyWidth)
    }
}

// MARK: - 幽灵眼睛

struct GhostEye: View {
    let pixelSize: CGFloat
    
    var body: some View {
        VStack(spacing: 0) {
            // 眼睛十字形
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelSize, height: pixelSize)
                Color.white.frame(width: pixelSize * 2, height: pixelSize)
                Color.clear.frame(width: pixelSize, height: pixelSize)
            }
            HStack(spacing: 0) {
                Color.white.frame(width: pixelSize * 4, height: pixelSize)
            }
            HStack(spacing: 0) {
                Color.white.frame(width: pixelSize * 4, height: pixelSize)
            }
            HStack(spacing: 0) {
                Color.clear.frame(width: pixelSize, height: pixelSize)
                Color.white.frame(width: pixelSize * 2, height: pixelSize)
                Color.clear.frame(width: pixelSize, height: pixelSize)
            }
        }
    }
}

// MARK: - 上传加载视图（使用幽灵动画）

struct GhostUploadHUDView: View {
    let status: UploadStatus
    
    var body: some View {
        // 只保留动画，去除背景和文字
        PixelGhostView()
    }
}

// MARK: - Preview

#Preview {
    ZStack {
        Color.black.ignoresSafeArea()
        PixelGhostView()
    }
}

#Preview("上传中") {
    ZStack {
        Color.bgBody.ignoresSafeArea()
        GhostUploadHUDView(status: .progress)
    }
    .preferredColorScheme(.dark)
}
