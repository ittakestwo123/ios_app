# GitHub Actions 模拟器视觉产物设计

## 目标

在不改动 QingJian 运行时代码的前提下，让 GitHub Actions 在 `macos-26` 上启动 `iPhone 17` 模拟器、安装并运行 Debug App，并上传可下载查看的 PNG 截图与 MP4 录屏。

## 方案

继续复用现有 `Build for iOS Simulator` 步骤产出的 App。视觉验证步骤使用 `xcrun simctl` 完成模拟器启动、安装、启动和截图：

1. 从 `build/DerivedData/Build/Products/Debug-iphonesimulator` 定位 `QingJian.app`。
2. 启动一个干净的 `iPhone 17` 模拟器并等待 Booted 状态。
3. 在默认首次启动状态下保存 `01-onboarding.png`。
4. 通过模拟器的 app defaults 写入 `hasCompletedOnboarding = true`，重新启动 App，保存 `02-today.png`。这样既能看到 onboarding，也能看到主界面，不需要给工程新增 UI Test target。
5. 录制一次启动后的短视频 `qingjian-launch.mp4`，用于快速观察转场和背景表现。
6. 用 `actions/upload-artifact` 上传 `build/visuals/*`，并与现有 `.xcresult`、日志放在同一次 CI 运行中。

## 约束与失败策略

- 视觉步骤只在 build 成功后执行；截图失败应让工作流失败，避免产生“看似成功但没有画面”的产物。
- 不依赖第三方服务、网络图片或签名；仍然只构建 iOS Simulator，不生成 IPA。
- 采集前使用 `simctl shutdown` 和 `simctl erase` 清空系统预置模拟器，确保 Onboarding 状态可重复；采集结束使用 `simctl shutdown` 释放 runner 资源。
- 上传的产物包含两个 PNG、一个 MP4、`.xcresult` 和构建日志；用户可在 Actions 运行详情页的 Artifacts 中下载。

## 验证标准

- GitHub Actions 的 Build、视觉采集和 XCTest 步骤均为 success。
- Artifact 中存在 `01-onboarding.png`、`02-today.png`、`qingjian-launch.mp4`。
- Windows 本机不要求安装 Xcode；本地只能检查 YAML 和 Git 状态，最终视觉采集以 GitHub macOS runner 为准。
