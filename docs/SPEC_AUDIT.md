# 晴笺 v1.0 规格对照

更新时间：2026-08-10

## 已完成

- 原生 SwiftUI 工程、iOS 17 Deployment Target、四 Tab 导航与三屏 Onboarding。
- SwiftData 的 `StudySession`、`Subject`、`DailyRecord`、`QuoteFavorite` 模型和本地 `ModelContainer`。
- 25/50/90/自定义/自由计时，真实 `Date` 差值、暂停/恢复、后台返回、重启恢复和提前结束规则。
- Today 首页：问候、目标日、固定每日语句、进度环、连续学习日、开始专注/自由计时、科目摘要。
- 梅竹主题成长反馈：种子、嫩芽、花苞、初绽、盛放；没有普通花朵素材。
- Journey 月历、跨午夜统计、历史每日目标快照、Day Detail、最近 7 天柱状图、近 4 周趋势、科目分布和本月总时长。
- Quotes：12 条古典句、30 条原创文案、六分类、固定每日一句、收藏、ShareLink 文本分享、随机语句短期去重。
- Settings：每日目标 15–720 分钟、目标日、科目新增/改名/归档/排序、可选通知、声音/触感、外观、CSV、隐私和关于页面。
- 本地提醒、倒计时结束提醒、完成页、每日达标和 7/30/100 天里程碑（同一自然日只触发一次）。
- Dynamic Type、深色模式、Reduce Motion、主要按钮/进度/日历状态的基础无障碍标签与值。
- 9 组 XCTest 源文件，覆盖日期切分、跨年/跨月统计、streak、目标变化、计时暂停恢复/重启、语录、梅枝成长阈值、设置持久化、SwiftData 容器与科目清理。
- App Icon 资源、隐私政策静态页、素材归属说明和 Xcode 运行 README。
- `PrivacyInfo.xcprivacy`：声明无跟踪、无收集数据，并登记本地 UserDefaults 的使用原因。

## 明确后置到 V1.1/V2

- Widget、Live Activity、分享图片卡、iCloud/CloudKit 同步、账号、社交和服务器。

## 外部环境待执行

- 当前工作区是 Windows，未安装 Xcode、xcodebuild、xcrun、Swift 或 iOS Simulator。
- WSL2/Ubuntu 可用，但 Apple SDK 不可在 Linux 获得；Docker daemon 当前也未运行，且 Linux 容器不能替代 Apple SDK。
- 因此 XCTest 和 iOS 编译必须在 macOS + Xcode 26 上完成。工程已配置共享 scheme；打开后需设置 Apple Developer Team 和唯一 Bundle ID。

## 本轮 Phase 1 增量

- 新增 `PersistenceController`，统一生产与内存测试容器的 SwiftData schema。
- 新增 `DefaultDataSeeder`，仅在已完成 Onboarding 且本地没有科目时写入五个默认科目，重复启动不会重复插入。
- 新增 `SubjectCatalog`，统一默认科目与 Onboarding 名称清理规则。
- 新增设置跨实例持久化、SwiftData schema、默认科目幂等初始化和科目名称清理测试。

## macOS 验证命令

```bash
xcrun simctl list devices available
xcodebuild -scheme QingJian -destination 'platform=iOS Simulator,name=iPhone 16 Pro' build
xcodebuild -scheme QingJian -destination 'platform=iOS Simulator,name=iPhone 16 Pro' test
```

最近一次已通过的云端验证为 GitHub Actions [31378754276](https://github.com/ittakestwo123/ios_app/actions/runs/31378754276)；加入 UI 烟测与隐私清单后的结果以当前提交触发的最新 Actions 为准。
