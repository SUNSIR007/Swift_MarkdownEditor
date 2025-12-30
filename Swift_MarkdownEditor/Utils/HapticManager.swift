//
//  HapticManager.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/26.
//

import UIKit

/// 触觉反馈管理器
enum HapticManager {
    
    /// 冲击反馈
    static func impact(_ style: UIImpactFeedbackGenerator.FeedbackStyle) {
        DispatchQueue.main.async {
            let generator = UIImpactFeedbackGenerator(style: style)
            generator.prepare()
            generator.impactOccurred()
        }
    }
    
    /// 通知反馈
    static func notification(_ type: UINotificationFeedbackGenerator.FeedbackType) {
        let generator = UINotificationFeedbackGenerator()
        generator.prepare()
        generator.notificationOccurred(type)
    }
    
    /// 选择反馈
    static func selection() {
        let generator = UISelectionFeedbackGenerator()
        generator.prepare()
        generator.selectionChanged()
    }
}
