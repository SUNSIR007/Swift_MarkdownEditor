//
//  CameraView.swift
//  Swift_MarkdownEditor
//
//  相机视图 - 封装 UIImagePickerController
//

import SwiftUI
import UIKit
import Photos

struct CameraView: UIViewControllerRepresentable {
    @Environment(\.dismiss) private var dismiss
    let onCapture: (UIImage) -> Void
    
    func makeUIViewController(context: Context) -> UIImagePickerController {
        let picker = UIImagePickerController()
        picker.sourceType = .camera
        picker.delegate = context.coordinator
        picker.allowsEditing = false
        return picker
    }
    
    func updateUIViewController(_ uiViewController: UIImagePickerController, context: Context) {}
    
    func makeCoordinator() -> Coordinator {
        Coordinator(self)
    }
    
    class Coordinator: NSObject, UIImagePickerControllerDelegate, UINavigationControllerDelegate {
        let parent: CameraView
        
        init(_ parent: CameraView) {
            self.parent = parent
        }
        
        func imagePickerController(_ picker: UIImagePickerController, didFinishPickingMediaWithInfo info: [UIImagePickerController.InfoKey: Any]) {
            if let image = info[.originalImage] as? UIImage {
                // 异步保存到相册（不阻塞上传流程）
                Task.detached(priority: .background) {
                    await self.saveToPhotoLibrary(image)
                }
                
                // 立即回调给父视图开始上传
                parent.onCapture(image)
            }
            parent.dismiss()
        }
        
        func imagePickerControllerDidCancel(_ picker: UIImagePickerController) {
            parent.dismiss()
        }
        
        private func saveToPhotoLibrary(_ image: UIImage) async {
            // 检查当前权限状态
            let status = PHPhotoLibrary.authorizationStatus(for: .addOnly)
            
            switch status {
            case .authorized, .limited:
                // 已有权限，直接保存
                await MainActor.run {
                    UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                }
                print("📸 照片已保存到相册")
                
            case .notDetermined:
                // 请求权限
                let granted = await PHPhotoLibrary.requestAuthorization(for: .addOnly)
                if granted == .authorized || granted == .limited {
                    await MainActor.run {
                        UIImageWriteToSavedPhotosAlbum(image, nil, nil, nil)
                    }
                    print("📸 照片已保存到相册")
                } else {
                    print("⚠️ 用户拒绝相册写入权限")
                }
                
            default:
                print("⚠️ 无法保存照片：没有相册写入权限")
            }
        }
    }
}

// MARK: - 相机可用性检查

extension CameraView {
    static var isAvailable: Bool {
        UIImagePickerController.isSourceTypeAvailable(.camera)
    }
}
