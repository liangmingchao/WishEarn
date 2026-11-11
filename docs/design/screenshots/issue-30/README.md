# Issue #30 — Paper & Sage（2026-11-11 复审修订）

Captured on iPhone 18 Pro Simulator (iOS 27.2), Debug build, unless noted. The empty state was captured on a fresh iPhone 17e Simulator (iOS 27.2) with a newly installed app and an empty Store.

所有数据都通过真实 App 的现有 UI 创建：心愿、条件、行动记录与 PhotoPicker 照片；没有向 App 加入种子数据或截图专用入口。数据保存在模拟器的真实本地 Store 中，截图来自 `XCUIScreen` 的运行画面。

## Light / Dark 截图

| 页面 / 状态 | Light | Dark |
|---|---|---|
| 心愿首页（首屏） | `home-light.png` | `home-dark.png` |
| 心愿首页（向下滚动） | `home-scrolled-light.png` | — |
| 心愿首页（空状态，iPhone 17e 新安装） | `home-empty-light.png` | — |
| 心愿详情（含水印照片与 2/3 进度） | `detail-light.png` | `detail-dark.png` |
| 心愿详情（长标题状态） | `detail-long-title-light.png` | — |
| 今天（行动 + 已完成分组，含长条件文案） | `today-light.png` | `today-dark.png` |
| 我的 / 外观设置 | `settings-light.png` | `settings-dark.png` |
| 我的 / 固定浅色外观 | `settings-light-fixed.png` | — |
| 成就（空状态） | `achievements-light.png` | — |
| 首页（辅助功能 XXXL） | `home-accessibility-light.png` | — |
| 今天（辅助功能 XXXL） | `today-accessibility-light.png` | — |

`settings-dark.png` 是在系统仍为浅色时，通过 App 内「外观 → 深色」切换后截取；这验证了手动外观覆盖真实生效。`settings-light-fixed.png` 随后验证「浅色」覆盖，最后切回「跟随系统」。

## 与上一版的对比

| 页面 | Before | After |
|---|---|---|
| 首页 | `../issue-21/home-light.png` | `home-light.png` |
| 详情 | `../issue-21/detail-light.png` | `detail-light.png` |
| 今天 | `../issue-21/today-light.png` | `today-light.png` |

Issue #30 首轮的 Sunny Wish Journal 截图已由本目录的新截图取代；首轮设计保留在 Git 历史中。

## 设计变化

- **Palette**：从 Violet + Coral + 6 种高饱和 Wish Theme 收敛为 Paper & Sage：暖纸画布、墨色文字、深鼠尾草绿行动色、低饱和 clay 点缀。
- **Home cards**：Featured / Spotlight / Grid 全部改为白色纸面；层级由照片尺寸与信息密度建立。Wish Theme 只保留 3–4 pt 短标记与占位图洗色。
- **Today**：鼓励卡从整块珊瑚底改为白纸卡 + 窄 clay 色条。
- **Detail**：故事 Hero 从主题色大卡改为白纸卡；主题只保留 kicker 颜色、短标记与占位图。
- **Appearance**：新增「我的 → 外观」：跟随系统 / 浅色 / 深色；选择持久化并在 App 根视图应用。
- **Buttons**：主按钮改为纯色胶囊，取消紫色渐变与重阴影。

## 数据与状态覆盖

- Featured Wish：`京都的秋天`，照片来自模拟器 Photos，2/3 条件完成，价格 ¥6,000。
- 普通心愿：`学会做提拉米苏`（横向 Banner，1/2）、`一个可以让周末慢下来的阅读角`（双列卡，长标题，0/1）、`一台新的相机`（双列卡，0/1）。
- Today：4 个可推进行动，其中第三张卡是长条件文案；已完成条件分组在下方。
- 照片、无照片占位、长标题、长条件、Light / Dark、App 内外观覆盖、辅助功能 XXXL 均已覆盖。
- 对比度：36 组 pair × Light / Dark，共 72 个实测值全部 PASS；见 `CONTRAST.md`。

## 复现方式

`WishEarnUITests/DesignCaptureUITests` 提供可选的证据流程。它在 CI 中默认跳过；本地取证时先通过 UI seed 数据，再运行 Light / Dark / 设置 / 辅助功能截图：

```bash
# 清空模拟器中的测试数据（会删除本地 Store）
xcrun simctl uninstall booted com.wishearn.app

# 逐个运行较短的 seed 测试（长会话在 Xcode 27 模拟器上不稳定）
TEST_RUNNER_WISH_SEED=1 xcodebuild test -project WishEarn.xcodeproj -scheme WishEarn \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath build/Issue30DD \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testSeedCameraWish \
  CODE_SIGNING_ALLOWED=NO
# 依次运行 testSeedReadingCornerWish / testSeedTiramisuWish / testSeedFeaturedWish
# 可选：testSeedPhotoForFeaturedWish（需要先 xcrun simctl addmedia booted <photo>）

xcrun simctl ui booted appearance light
TEST_RUNNER_WISH_SCREENSHOTS=1 xcodebuild test ... \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testCaptureLightScreenshots
TEST_RUNNER_WISH_SCREENSHOTS=1 xcodebuild test ... \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testCaptureSettingsScreenshots
TEST_RUNNER_WISH_SCREENSHOTS=1 xcodebuild test ... \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testCaptureAccessibilityScreenshots

xcrun simctl ui booted appearance dark
TEST_RUNNER_WISH_SCREENSHOTS=1 xcodebuild test ... \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testCaptureDarkScreenshots
```

截图通过 `xcresulttool export attachments` 导出。主截图来自 iPhone 18 Pro；`home-empty-light.png` 来自同一构建、空 Store 的 iPhone 17e 首次启动。

## 已知差距

- 没有为所有心愿添加真实照片；其余卡片使用低饱和主题占位图。照片路径已在 Featured / Detail 中验证。
- 模拟器在 Xcode 27 下的长 UI 测试会话不稳定，已拆分为短流程；仍出现偶发 `signal term`，因此 CI 不运行截图测试。
- 主流程截图与辅助功能截图来自模拟器；真机 PhotosPicker、滚动、导航与外观切换尚未逐项手动验收。
- App Icon 仅保留提案 `../assets/app-icon-colorful-proposal.png`，未替换生产图标。
