//
//  UploadHUDView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/26.
//

import SwiftUI

// MARK: - 反馈类型

enum FeedbackType {
    case uploading
    case uploadSuccess
    case uploadError
    case publishing
    case publishSuccess
    case publishError
    
    var title: String {
        switch self {
        case .uploading: return "上传中"
        case .uploadSuccess: return "完成"
        case .uploadError: return "失败"
        case .publishing: return "发布中"
        case .publishSuccess: return "已发布"
        case .publishError: return "失败"
        }
    }
    
    var accentColor: Color {
        switch self {
        case .uploading, .publishing: return .white
        case .uploadSuccess, .publishSuccess: return .successGreen
        case .uploadError, .publishError: return .errorRed
        }
    }
    
    var isLoading: Bool {
        self == .uploading || self == .publishing
    }
    
    var isSuccess: Bool {
        self == .uploadSuccess || self == .publishSuccess
    }
    
    var isError: Bool {
        self == .uploadError || self == .publishError
    }
}

// MARK: - 极简反馈视图

/// 简洁优雅的反馈提示 - 极简设计
struct UnifiedFeedbackView: View {
    let type: FeedbackType
    @State private var appear = false
    @State private var iconRotation: Double = 0
    @State private var checkProgress: CGFloat = 0
    @State private var crossProgress: CGFloat = 0
    
    var body: some View {
        HStack(spacing: 14) {
            // 状态图标
            ZStack {
                if type.isLoading {
                    // 简约旋转圆环
                    Circle()
                        .trim(from: 0, to: 0.7)
                        .stroke(Color.white, style: StrokeStyle(lineWidth: 2.5, lineCap: .round))
                        .frame(width: 22, height: 22)
                        .rotationEffect(.degrees(iconRotation))
                } else if type.isSuccess {
                    // 成功：绿色对勾
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.successGreen)
                } else {
                    // 失败：红色叉号
                    Image(systemName: "xmark.circle.fill")
                        .font(.system(size: 24, weight: .medium))
                        .foregroundColor(.errorRed)
                }
            }
            .frame(width: 24, height: 24)
            
            // 状态文字
            Text(type.title)
                .font(.system(size: 15, weight: .medium))
                .foregroundColor(.white)
        }
        .frame(minWidth: 100)  // 保持窗口尺寸一致
        .padding(.horizontal, 20)
        .padding(.vertical, 14)
        .background(
            Capsule()
                .fill(Color(white: 0.15))
                .overlay(
                    Capsule()
                        .stroke(Color.white.opacity(0.25), lineWidth: 1)
                )
                .shadow(color: .black.opacity(0.5), radius: 20, x: 0, y: 10)
        )
        .scaleEffect(appear ? 1 : 0.8)
        .opacity(appear ? 1 : 0)
        .onAppear {
            withAnimation(.spring(response: 0.35, dampingFraction: 0.7)) {
                appear = true
            }
            
            if type.isLoading {
                withAnimation(.linear(duration: 0.8).repeatForever(autoreverses: false)) {
                    iconRotation = 360
                }
            } else if type.isSuccess {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                    checkProgress = 1
                }
                HapticManager.notification(.success)
            } else if type.isError {
                withAnimation(.spring(response: 0.4, dampingFraction: 0.6).delay(0.1)) {
                    crossProgress = 1
                }
                HapticManager.notification(.error)
            }
        }
    }
}

// MARK: - 上传 HUD（兼容接口）

struct UploadHUDView: View {
    let status: UploadStatus
    
    var body: some View {
        UnifiedFeedbackView(type: feedbackType)
    }
    
    private var feedbackType: FeedbackType {
        switch status {
        case .idle, .progress: return .uploading
        case .success: return .uploadSuccess
        case .error: return .uploadError
        }
    }
}

// MARK: - 全屏反馈覆盖层（发布成功/失败）

struct FeedbackOverlayView: View {
    let isSuccess: Bool
    @Binding var isVisible: Bool
    @State private var appear = false
    @State private var iconScale: CGFloat = 0.3
    @State private var ringProgress: CGFloat = 0
    @State private var checkProgress: CGFloat = 0
    @State private var crossProgress: CGFloat = 0
    
    private var accentColor: Color {
        isSuccess ? .successGreen : .errorRed
    }
    
    var body: some View {
        ZStack {
            // 半透明背景
            Color.black.opacity(appear ? 0.6 : 0)
                .ignoresSafeArea()
            
            // 中心反馈卡片
            VStack(spacing: 20) {
                // 动画图标
                ZStack {
                    // 外圈进度环
                    Circle()
                        .trim(from: 0, to: ringProgress)
                        .stroke(
                            accentColor.opacity(0.3),
                            style: StrokeStyle(lineWidth: 3, lineCap: .round)
                        )
                        .frame(width: 64, height: 64)
                        .rotationEffect(.degrees(-90))
                    
                    // 内部图标
                    if isSuccess {
                        // 成功勾选
                        Path { path in
                            path.move(to: CGPoint(x: 12, y: 32))
                            path.addLine(to: CGPoint(x: 26, y: 44))
                            path.addLine(to: CGPoint(x: 52, y: 20))
                        }
                        .trim(from: 0, to: checkProgress)
                        .stroke(accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round, lineJoin: .round))
                        .frame(width: 64, height: 64)
                    } else {
                        // 失败叉号
                        ZStack {
                            Path { path in
                                path.move(to: CGPoint(x: 18, y: 18))
                                path.addLine(to: CGPoint(x: 46, y: 46))
                            }
                            .trim(from: 0, to: crossProgress)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                            
                            Path { path in
                                path.move(to: CGPoint(x: 46, y: 18))
                                path.addLine(to: CGPoint(x: 18, y: 46))
                            }
                            .trim(from: 0, to: crossProgress)
                            .stroke(accentColor, style: StrokeStyle(lineWidth: 4, lineCap: .round))
                        }
                        .frame(width: 64, height: 64)
                    }
                }
                .scaleEffect(iconScale)
                
                // 状态文字
                Text(isSuccess ? "发布成功" : "发布失败")
                    .font(.system(size: 17, weight: .medium))
                    .foregroundColor(.white)
            }
            .padding(40)
            .background(
                RoundedRectangle(cornerRadius: 20)
                    .fill(Color(white: 0.12))  // 更亮的背景
                    .overlay(
                        RoundedRectangle(cornerRadius: 20)
                            .stroke(Color.white.opacity(0.2), lineWidth: 1)  // 更明显的边框
                    )
                    .shadow(color: .black.opacity(0.6), radius: 30, x: 0, y: 15)
            )
            .scaleEffect(appear ? 1 : 0.9)
            .opacity(appear ? 1 : 0)
        }
        .onAppear {
            withAnimation(.easeOut(duration: 0.25)) {
                appear = true
            }
            
            withAnimation(.spring(response: 0.4, dampingFraction: 0.6)) {
                iconScale = 1.0
            }
            
            withAnimation(.easeOut(duration: 0.5).delay(0.1)) {
                ringProgress = 1
            }
            
            if isSuccess {
                withAnimation(.easeOut(duration: 0.35).delay(0.25)) {
                    checkProgress = 1
                }
                HapticManager.notification(.success)
            } else {
                withAnimation(.easeOut(duration: 0.3).delay(0.2)) {
                    crossProgress = 1
                }
                HapticManager.notification(.error)
            }
        }
    }
}

// MARK: - Previews

#Preview("上传中") {
    ZStack {
        Color.bgBody.ignoresSafeArea()
        UnifiedFeedbackView(type: .uploading)
    }
    .preferredColorScheme(.dark)
}

#Preview("上传成功") {
    ZStack {
        Color.bgBody.ignoresSafeArea()
        UnifiedFeedbackView(type: .uploadSuccess)
    }
    .preferredColorScheme(.dark)
}

#Preview("发布成功") {
    ZStack {
        Color.bgBody.ignoresSafeArea()
        FeedbackOverlayView(isSuccess: true, isVisible: .constant(true))
    }
    .preferredColorScheme(.dark)
}

#Preview("发布失败") {
    ZStack {
        Color.bgBody.ignoresSafeArea()
        FeedbackOverlayView(isSuccess: false, isVisible: .constant(true))
    }
    .preferredColorScheme(.dark)
}
