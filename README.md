# 晴笺 QingJian

> 专注、打卡与诗意陪伴

晴笺是一款离线优先的原生 iOS 学习专注应用。它以专注计时、可见的日历足迹和克制的文字陪伴服务长期学习，不要求注册、不需要网络、没有广告与第三方分析。

## 已实现的 V1 功能

- 三步首次引导：目标日、每日学习目标与科目编辑。
- 25 / 50 / 90 分钟、自定义倒计时与自由计时。
- 以真实 `Date` 差值计算的暂停、前后台切换、冷启动恢复与超时自动完成。
- SwiftData 持久化的学习记录、科目、每日记录、诗句收藏。
- Today：目标日、每日固定诗句、学习进度、连续点亮、科目摘要与梅竹纸笺背景。
- Journey：月历、日详情/备注、连续天数、最近 7 天、近 4 周、科目分布 Swift Charts。
- Quotes：12 条公共领域古典作品、30 条晴笺原创鼓励语、分类、随机、收藏、文本分享。
- Settings：目标、科目、可选本地通知、声音/触感、外观、CSV 导出、隐私与素材说明。

## 工程结构

```text
QingJian/
  App/                 应用入口、根路由与 TabView
  Core/
    DesignSystem/      色彩、字体、纸笺背景、共享控件
    Models/            SwiftData 数据模型与计时状态
    Services/          计时、统计、日期、语录、通知、CSV
    Extensions/        格式化辅助
  Features/            Onboarding、Today、Focus、Journey、Quotes、Settings
  Resources/           quotes.json 与离线梅竹资源
QingJianTests/         日期、统计、计时与语录单元测试
```

## 在 Xcode 26 中运行

1. 将整个目录复制到 macOS。
2. 用 Xcode 26 或更新版本打开 [QingJian.xcodeproj](QingJian.xcodeproj)。
3. 在 Signing & Capabilities 中替换 `com.qingjian.app` 为自己的唯一 Bundle ID，并选择开发团队。
4. 选择一个 iOS 17 及以上模拟器，再运行 `QingJian` scheme。

命令行验证：

```bash
xcrun simctl list devices available
xcodebuild -scheme QingJian -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -scheme QingJian -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

如果本机不存在 `iPhone 16 Pro`，使用第一条命令列出的任一可用 iPhone 名称替换它。

## 当前工作区验证状态

当前交付环境是 Windows，未安装 Xcode、Swift、`xcrun` 或 iOS Simulator，因此无法在此处执行上述构建和 XCTest 命令。工程、共享 scheme、资源、单元测试和 macOS 验证命令均已准备完毕；首次在 Mac 打开后应优先运行测试，再处理 Xcode 的编译诊断。

本轮 Phase 1 另外集中封装了 `PersistenceController`，并在已完成 Onboarding 的安装启动时幂等补齐默认科目。Onboarding 的科目输入会自动去除首尾空格、忽略空行和重复名称；每日目标与目标日继续通过注入的 `UserDefaults` 持久化，科目与学习模型通过 SwiftData 持久化。

## GitHub Actions 云端构建

`.github/workflows/ios.yml` 使用 GitHub 的 `macos-26` Runner 和 Xcode 26.6，自动执行 iOS Simulator build 与 XCTest，并将 `.xcresult` 上传为构建产物。将本目录推送到 GitHub 后，`push`、Pull Request 或手动运行 `QingJian iOS CI` 即可触发。

该工作流仅用于模拟器编译和测试，不需要签名；生成 IPA、TestFlight 或 App Store 上传需要另行配置 Apple Developer 证书、Provisioning Profile 或 App Store Connect API Key，并通过 GitHub Secrets 注入。

规格逐项对照见 [docs/SPEC_AUDIT.md](docs/SPEC_AUDIT.md)。

## 隐私

晴笺不注册账户，也不收集邮箱、手机号、定位、联系人、照片、健康数据、广告标识符或使用行为。学习数据只保存在设备本地；通知仅在用户主动开启后由 iOS 本地调度。详细文本见 [PRIVACY.md](PRIVACY.md)。

## 部署隐私政策网页

[privacy-policy.html](privacy-policy.html) 是无需构建的静态页面。上传该文件到 GitHub Pages、Cloudflare Pages、Netlify 或任何静态主机后，将生成的 HTTPS 地址填入 App Store Connect 的 Privacy Policy URL。部署前把页面中的联系邮箱占位内容替换为自己的支持邮箱。

## 上架前人工事项

- 在真机和至少两种动态字体大小下完整跑完 Onboarding、计时、后台恢复、通知、日历与导出。
- 在 Xcode 中设置发行团队、唯一 Bundle ID、版本号与构建号；工程已附带完整尺寸的 App Icon，归档前仍应在 Assets 中确认显示正常。
- 为浅色、深色及较大文字尺寸检查所有页面的对比度。
- 在 App Store Connect 填写实际支持邮箱、隐私政策 URL、年龄分级、通知用途和数据收集问卷。
- 为 App Store 制作截图、预览文案和审核备注；审核备注应说明应用没有账户与服务器，学习记录仅保存在本机。

## 素材与版权

Today 的离线梅竹背景来自陈继儒《梅竹图》（17 世纪，公共领域）。详情和来源链接见 [ATTRIBUTIONS.md](ATTRIBUTIONS.md)。内置古诗文均标明作者与出处；现代鼓励语均为晴笺原创。
