//
//  SettingsView.swift
//  Swift_MarkdownEditor
//
//  Created by Ryuichi on 2025/12/31.
//

import SwiftUI

/// 设置页面视图
struct SettingsView: View {
    @ObservedObject private var themeManager = ThemeManager.shared
    @State private var githubToken: String = ""
    @State private var isTokenVisible: Bool = false
    @State private var isVerifying: Bool = false
    @State private var verificationResult: VerificationResult?
    
    enum VerificationResult {
        case success(String) // 用户名
        case failure(String) // 错误信息
    }
    
    var body: some View {
        NavigationView {
            ScrollView {
                VStack(spacing: 24) {
                    // 外观设置
                    appearanceSection
                    
                    // GitHub 配置
                    githubSection
                    
                    // 关于
                    aboutSection
                }
                .padding(.horizontal, 20)
                .padding(.top, 20)
                .padding(.bottom, 40)
            }
            .background(Color.bgBody)
            .navigationTitle("设置")
            .navigationBarTitleDisplayMode(.large)
            .toolbarBackground(Color.bgBody, for: .navigationBar)
            .toolbarBackground(.visible, for: .navigationBar)
        }
        .onAppear {
            loadToken()
        }
    }
    
    // MARK: - 外观设置
    
    private var appearanceSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("外观")
            
            HStack(spacing: 12) {
                // 深蓝主题卡片
                themeCard(
                    theme: .slate,
                    icon: "moon.stars.fill",
                    isSelected: themeManager.currentTheme == .slate
                )
                
                // 纯黑主题卡片
                themeCard(
                    theme: .oled,
                    icon: "circle.fill",
                    isSelected: themeManager.currentTheme == .oled
                )
            }
        }
    }
    
    private func themeCard(theme: AppTheme, icon: String, isSelected: Bool) -> some View {
        Button {
            HapticManager.impact(.light)
            withAnimation(.easeInOut(duration: 0.2)) {
                themeManager.currentTheme = theme
            }
        } label: {
            VStack(spacing: 12) {
                Image(systemName: icon)
                    .font(.system(size: 28))
                    .foregroundColor(isSelected ? .primaryBlue : .textSecondary)
                
                Text(theme.displayName)
                    .font(.system(size: 14, weight: .medium))
                    .foregroundColor(isSelected ? .textMain : .textSecondary)
            }
            .frame(maxWidth: .infinity)
            .frame(height: 100)
            .background(
                RoundedRectangle(cornerRadius: ThemeStyle.radiusMd)
                    .fill(Color.bgSurface)
                    .overlay(
                        RoundedRectangle(cornerRadius: ThemeStyle.radiusMd)
                            .stroke(isSelected ? Color.primaryBlue : Color.borderColor, lineWidth: isSelected ? 2 : 1)
                    )
            )
            .overlay(alignment: .topTrailing) {
                if isSelected {
                    Image(systemName: "checkmark.circle.fill")
                        .font(.system(size: 20))
                        .foregroundColor(.primaryBlue)
                        .padding(8)
                }
            }
        }
        .buttonStyle(.plain)
    }
    
    // MARK: - GitHub 配置
    
    private var githubSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("GitHub 配置")
            
            VStack(spacing: 12) {
                // Token 输入框
                HStack(spacing: 12) {
                    if isTokenVisible {
                        TextField("输入 GitHub Token", text: $githubToken)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.textMain)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    } else {
                        SecureField("输入 GitHub Token", text: $githubToken)
                            .font(.system(size: 14, design: .monospaced))
                            .foregroundColor(.textMain)
                            .autocapitalization(.none)
                            .autocorrectionDisabled()
                    }
                    
                    // 显示/隐藏按钮
                    Button {
                        isTokenVisible.toggle()
                    } label: {
                        Image(systemName: isTokenVisible ? "eye.slash.fill" : "eye.fill")
                            .font(.system(size: 16))
                            .foregroundColor(.textSecondary)
                    }
                    .buttonStyle(.plain)
                }
                .padding(.horizontal, 16)
                .padding(.vertical, 14)
                .background(
                    RoundedRectangle(cornerRadius: ThemeStyle.radiusSm)
                        .fill(Color.bgSurface)
                        .overlay(
                            RoundedRectangle(cornerRadius: ThemeStyle.radiusSm)
                                .stroke(Color.borderColor, lineWidth: 1)
                        )
                )
                
                // 验证结果
                if let result = verificationResult {
                    HStack(spacing: 8) {
                        switch result {
                        case .success(let username):
                            Image(systemName: "checkmark.circle.fill")
                                .foregroundColor(.successGreen)
                            Text("已验证：\(username)")
                                .foregroundColor(.successGreen)
                        case .failure(let error):
                            Image(systemName: "xmark.circle.fill")
                                .foregroundColor(.errorRed)
                            Text(error)
                                .foregroundColor(.errorRed)
                        }
                    }
                    .font(.system(size: 13))
                    .frame(maxWidth: .infinity, alignment: .leading)
                }
                
                // 保存和验证按钮
                HStack(spacing: 12) {
                    Button {
                        saveToken()
                    } label: {
                        Text("保存")
                            .font(.system(size: 14, weight: .medium))
                            .foregroundColor(.textMain)
                            .frame(maxWidth: .infinity)
                            .padding(.vertical, 12)
                            .background(
                                RoundedRectangle(cornerRadius: ThemeStyle.radiusSm)
                                    .fill(Color.bgSurfaceHover)
                            )
                    }
                    .buttonStyle(.plain)
                    
                    Button {
                        verifyToken()
                    } label: {
                        HStack(spacing: 6) {
                            if isVerifying {
                                ProgressView()
                                    .progressViewStyle(CircularProgressViewStyle(tint: .white))
                                    .scaleEffect(0.7)
                            }
                            Text("验证")
                                .font(.system(size: 14, weight: .medium))
                        }
                        .foregroundColor(.white)
                        .frame(maxWidth: .infinity)
                        .padding(.vertical, 12)
                        .background(
                            RoundedRectangle(cornerRadius: ThemeStyle.radiusSm)
                                .fill(Color.primaryBlue)
                        )
                    }
                    .buttonStyle(.plain)
                    .disabled(githubToken.isEmpty || isVerifying)
                    .opacity(githubToken.isEmpty ? 0.6 : 1)
                }
            }
            
            // 提示信息
            Text("Token 将安全存储在设备 Keychain 中")
                .font(.system(size: 12))
                .foregroundColor(.textMuted)
        }
    }
    
    // MARK: - 关于
    
    private var aboutSection: some View {
        VStack(alignment: .leading, spacing: 12) {
            sectionHeader("关于")
            
            VStack(spacing: 0) {
                infoRow(title: "版本", value: Bundle.main.infoDictionary?["CFBundleShortVersionString"] as? String ?? "1.0.0")
                
                Divider()
                    .background(Color.borderColor)
                
                infoRow(title: "构建", value: Bundle.main.infoDictionary?["CFBundleVersion"] as? String ?? "1")
            }
            .background(
                RoundedRectangle(cornerRadius: ThemeStyle.radiusMd)
                    .fill(Color.bgSurface)
            )
        }
    }
    
    private func infoRow(title: String, value: String) -> some View {
        HStack {
            Text(title)
                .font(.system(size: 15))
                .foregroundColor(.textMain)
            
            Spacer()
            
            Text(value)
                .font(.system(size: 15))
                .foregroundColor(.textSecondary)
        }
        .padding(.horizontal, 16)
        .padding(.vertical, 14)
    }
    
    // MARK: - 辅助视图
    
    private func sectionHeader(_ title: String) -> some View {
        Text(title)
            .font(.system(size: 13, weight: .semibold))
            .foregroundColor(.textSecondary)
            .textCase(.uppercase)
    }
    
    // MARK: - Token 操作
    
    private func loadToken() {
        // 优先从 Keychain 读取
        if let savedToken = KeychainHelper.get(key: "github_token"), !savedToken.isEmpty {
            githubToken = savedToken
        } else {
            // 否则使用硬编码的 Token
            githubToken = AppConfig.githubToken
        }
    }
    
    private func saveToken() {
        HapticManager.impact(.light)
        if AppConfig.saveGitHubToken(githubToken) {
            verificationResult = .success("Token 已保存")
            // 3秒后清除结果提示
            DispatchQueue.main.asyncAfter(deadline: .now() + 3) {
                if case .success("Token 已保存") = verificationResult {
                    verificationResult = nil
                }
            }
        } else {
            verificationResult = .failure("保存失败")
        }
    }
    
    private func verifyToken() {
        guard !githubToken.isEmpty else { return }
        
        isVerifying = true
        verificationResult = nil
        HapticManager.impact(.light)
        
        Task {
            do {
                let username = try await verifyGitHubToken(githubToken)
                await MainActor.run {
                    isVerifying = false
                    verificationResult = .success(username)
                    HapticManager.notification(.success)
                }
            } catch {
                await MainActor.run {
                    isVerifying = false
                    verificationResult = .failure("Token 无效或已过期")
                    HapticManager.notification(.error)
                }
            }
        }
    }
    
    private func verifyGitHubToken(_ token: String) async throws -> String {
        let url = URL(string: "https://api.github.com/user")!
        var request = URLRequest(url: url)
        request.setValue("Bearer \(token)", forHTTPHeaderField: "Authorization")
        request.setValue("application/vnd.github.v3+json", forHTTPHeaderField: "Accept")
        
        let (data, response) = try await URLSession.shared.data(for: request)
        
        guard let httpResponse = response as? HTTPURLResponse,
              httpResponse.statusCode == 200 else {
            throw URLError(.badServerResponse)
        }
        
        struct GitHubUser: Decodable {
            let login: String
        }
        
        let user = try JSONDecoder().decode(GitHubUser.self, from: data)
        return user.login
    }
}

#Preview {
    SettingsView()
        .preferredColorScheme(.dark)
}
