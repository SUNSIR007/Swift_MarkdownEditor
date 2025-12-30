//
//  HeaderView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/26.
//

import SwiftUI

/// Header 组件 - 匹配 PWA 简洁布局
/// 显示上传按钮、相机按钮、主题切换按钮和 Post 按钮
struct HeaderView: View {
    @ObservedObject var viewModel: EditorViewModel
    @ObservedObject var themeManager = ThemeManager.shared
    var onImageUpload: () -> Void
    var onCameraCapture: () -> Void
    
    var body: some View {
        HStack(spacing: 12) {
            // 左侧：图片上传按钮
            uploadButton
            
            // 拍照按钮
            cameraButton
            
            // 主题切换按钮
            themeToggleButton
            
            Spacer()
            
            // 右侧：发布按钮
            publishButton
        }
        .padding(.horizontal, 20)
        .padding(.vertical, 16)
    }
    
    // MARK: - 上传按钮
    
    @State private var isUploadPressed = false
    
    private var uploadButton: some View {
        Button {
            HapticManager.impact(.medium)
            onImageUpload()
        } label: {
            Image(systemName: "photo.on.rectangle.angled")
                .font(.system(size: 20, weight: .regular))
                .foregroundColor(.textMain)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect()
        .scaleEffect(isUploadPressed ? 1.15 : 1.0)
        .brightness(isUploadPressed ? 0.15 : 0)
        .animation(.easeInOut(duration: 0.06), value: isUploadPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isUploadPressed = true }
                .onEnded { _ in isUploadPressed = false }
        )
    }
    
    // MARK: - 拍照按钮
    
    @State private var isCameraPressed = false
    
    private var cameraButton: some View {
        Button {
            HapticManager.impact(.medium)
            onCameraCapture()
        } label: {
            Image(systemName: "camera.fill")
                .font(.system(size: 18, weight: .regular))
                .foregroundColor(.textMain)
                .frame(width: 44, height: 44)
        }
        .buttonStyle(.plain)
        .glassEffect()
        .scaleEffect(isCameraPressed ? 1.15 : 1.0)
        .brightness(isCameraPressed ? 0.15 : 0)
        .animation(.easeInOut(duration: 0.06), value: isCameraPressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isCameraPressed = true }
                .onEnded { _ in isCameraPressed = false }
        )
        .opacity(CameraView.isAvailable ? 1 : 0.5)
        .disabled(!CameraView.isAvailable)
    }
    
    // MARK: - 主题切换按钮
    
    @State private var isThemePressed = false
    @State private var rotationAngle: Double = 0
    
    private var themeToggleButton: some View {
        Button {
            HapticManager.impact(.light)
            withAnimation(.easeInOut(duration: 0.3)) {
                rotationAngle += 180
            }
            themeManager.toggle()
        } label: {
            ZStack {
                // 深蓝主题图标
                Image(systemName: "moon.stars.fill")
                    .font(.system(size: 18, weight: .regular))
                    .foregroundColor(.textMain)
                    .opacity(themeManager.currentTheme == .slate ? 1 : 0)
                    .scaleEffect(themeManager.currentTheme == .slate ? 1 : 0.5)
                
                // 纯黑主题图标
                Image(systemName: "circle.fill")
                    .font(.system(size: 16, weight: .regular))
                    .foregroundColor(.textMain)
                    .opacity(themeManager.currentTheme == .oled ? 1 : 0)
                    .scaleEffect(themeManager.currentTheme == .oled ? 1 : 0.5)
            }
            .frame(width: 44, height: 44)
            .rotationEffect(.degrees(rotationAngle))
        }
        .buttonStyle(.plain)
        .glassEffect()
        .scaleEffect(isThemePressed ? 1.15 : 1.0)
        .brightness(isThemePressed ? 0.15 : 0)
        .animation(.easeInOut(duration: 0.06), value: isThemePressed)
        .simultaneousGesture(
            DragGesture(minimumDistance: 0)
                .onChanged { _ in isThemePressed = true }
                .onEnded { _ in isThemePressed = false }
        )
    }
    
    // MARK: - 发布按钮
    
    private var publishButton: some View {
        Button {
            guard !viewModel.isPublishing && !viewModel.showSuccessFeedback && !viewModel.showErrorFeedback else { return }
            HapticManager.impact(.medium)
            Task {
                await viewModel.publish()
            }
        } label: {
            // 使用 Post 文字作为基准大小
            Text("Post")
                .font(.system(size: 15, weight: .semibold))
                .opacity(viewModel.isPublishing || viewModel.showSuccessFeedback || viewModel.showErrorFeedback ? 0 : 1)
                .overlay {
                    if viewModel.showSuccessFeedback {
                        // 发布成功：显示绿色对勾
                        Image(systemName: "checkmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.successGreen)
                    } else if viewModel.showErrorFeedback {
                        // 发布失败：显示红色叉号
                        Image(systemName: "xmark")
                            .font(.system(size: 15, weight: .bold))
                            .foregroundColor(.errorRed)
                    } else if viewModel.isPublishing {
                        // 发布中：显示 loading
                        ProgressView()
                            .progressViewStyle(CircularProgressViewStyle(tint: .textMain))
                            .scaleEffect(0.8)
                    }
                }
                .frame(minWidth: 70)
                .padding(.horizontal, 20)
                .padding(.vertical, 10)
                .foregroundColor(.textMain)
        }
        .buttonStyle(.plain)
        .glassEffect()
        .disabled(!viewModel.isGitHubConfigured || viewModel.isPublishing || viewModel.showSuccessFeedback || viewModel.showErrorFeedback)
        .opacity(viewModel.isGitHubConfigured ? 1 : 0.6)
    }
}

// MARK: - 系统风格高亮按钮样式

/// 按下时放大并高亮的按钮效果
struct HighlightButtonStyle: ButtonStyle {
    func makeBody(configuration: Configuration) -> some View {
        configuration.label
            .scaleEffect(configuration.isPressed ? 1.15 : 1.0)
            .brightness(configuration.isPressed ? 0.2 : 0)
            .animation(.easeInOut(duration: 0.15), value: configuration.isPressed)
    }
}

#Preview {
    HeaderView(
        viewModel: EditorViewModel(),
        onImageUpload: { print("Upload image tapped") },
        onCameraCapture: { print("Camera tapped") }
    )
    .preferredColorScheme(.dark)
    .background(Color.bgBody)
}
