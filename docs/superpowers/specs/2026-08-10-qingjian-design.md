# 晴笺（QingJian）V1 设计规格

## 目标与边界

晴笺是离线优先的原生 iOS 学习专注应用。它记录可验证的专注时间，以日历、统计和克制的文字反馈陪伴长期学习；不包含账户、网络服务、广告、第三方 UI 库、行为分析或个人资料收集。

本次确认的视觉基线是“梅竹纸笺”：纸白背景、松墨正文、雾青控件、浅杏晨光与低透明度的公共领域梅竹水墨画。第二、第三屏不使用独立兰花或菊花插画；其余界面只保留低对比度竹影、叶片和抽象光斑。学习进度反馈使用小型梅枝/嫩叶和明确文字、对勾，不使用普通通用花朵。

## 运行平台与工程

- 工程名 `QingJian`，应用中文名 `晴笺`，最低部署 iOS 17.0。
- 原生 Swift 6 风格、SwiftUI、SwiftData、Swift Charts、UserNotifications；无运行时第三方依赖。
- 当前 Windows 工作区没有 Xcode、Swift 或模拟器。因此工程以标准 `.xcodeproj` 文件和可读的 Swift 源文件交付；最终的 `xcodebuild` 和测试需在 Xcode 26/macOS 上执行。
- 内容、统计、设置和当前计时器均可在无网络时使用；唯一下载过的梅竹图片会打包进应用资源。

## 信息架构

根视图先读取 `hasCompletedOnboarding`。首次启动展示三步 Onboarding：品牌、目标日/每日目标、科目管理；结束后进入四栏 `TabView`：今日、专注、足迹、拾光。设置从 Today 工具栏打开。

Today 依次呈现问候与设置、目标日、每日固定诗句、圆形学习进度、专注入口、梅竹纸笺花圃和科目分钟摘要。Focus 支持 25/50/90 分钟、自定义和自由计时。Journey 提供月历与统计。Quotes 提供分类、收藏、随机与 ShareLink。设置负责每日目标、目标日、科目、通知、声音/触感、外观、CSV 导出和隐私说明。

## 数据与持久化

SwiftData 模型：

- `StudySession`：UUID、开始/结束时间、秒数、科目快照、模式、计划秒数、完成标记。
- `Subject`：UUID、名称、主题色 token、排序、归档标记。
- `DailyRecord`：本地日历日的 dateKey、当日目标快照、可选备注。
- `QuoteFavorite`：内置 quote ID 与收藏时间。

`UserDefaults` 通过 `AppStorage` / `Codable` 保存每日目标、目标日、最近科目、提醒、声音/触感、外观和 Onboarding 状态。`ActiveTimerState` 也单独编码到 UserDefaults，避免依赖 SwiftData 自动保存时机。

日期聚合只使用 `Calendar.current.startOfDay(for:)` 和日期间隔，绝不以 UTC 字符串判断学习日。跨午夜 session 按与每个本地日的真实重叠秒数拆分，保证日历、周/月图表和连续天数正确。

## 专注计时器

`FocusTimerEngine` 接收可注入的 `NowProviding`，状态由 `startDate`、累计 paused seconds、可选 planned seconds、暂停时间和模式组成。显示值和完成判断从当前时间差计算，`Timer` 仅负责刷新界面。暂停时冻结累计时长；恢复时重新设置运行锚点。冷启动先恢复 active state：倒计时已经结束则创建完成 session、清空 active state；否则继续显示剩余时间。

结束规则：少于 60 秒直接放弃；60 秒或以上的提前结束让用户选择保存或放弃。完成 session 保存 SwiftData 后显示一次奖励 sheet，必要时包含每日目标或 7/30 天连续学习里程碑。倒计时运行期间安排一次本地通知，结束、取消或完成后移除该通知。

## 视觉、可访问性与素材

设计 token 集中在 `Theme`：颜色、间距、圆角、阴影、字体、动态字号下限。正文使用系统文本样式；诗句和大标题优先 `Songti SC`，无此字体时回退 `.serif`。背景由 `PaperBackground` 自绘：纸张颜色、两层径向光、细颗粒、右下梅竹图片；透明度小于 22%。深色模式使用深松墨背景及提高后的文字对比。

梅竹资源采用 Chen Jiru《Plum Blossoms and Bamboo》（17 世纪，公共领域）离线打包。资源来源、公共领域标记及作者在应用“关于晴笺”、README 和 `ATTRIBUTIONS.md` 中标注。没有其他外部图像依赖。

每个关键操作、环形进度、花圃状态、计时按钮、日历日期都会提供 accessibility label/value；状态除色彩外还有文本、图标和形状。Reduce Motion 打开时取消非必要缩放、飘动及进度装饰动画。

## 测试与验收

单元测试覆盖：日期拆分（跨月/年/午夜）、连续天数（空数据、断签、连续 7 天、不同目标）、周/月统计和 FocusTimerEngine（前后台时间差、暂停/恢复、冷启动到点、少于 60 秒）。UI 通过 Preview 覆盖 Onboarding、Today、Focus、Journey、Quotes、Settings 和完成 sheet。

验收在 Xcode 26 上运行 `xcodebuild -scheme QingJian -destination 'platform=iOS Simulator,name=<available iPhone>' build` 与 `test`。如果主机缺少该环境，README 列出完整命令与预期结果。

