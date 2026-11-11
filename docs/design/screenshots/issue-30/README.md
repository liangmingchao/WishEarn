# Issue #30 — Colorful Lifestyle Editorial

Captured on iPhone 18 Pro Simulator (iOS 27.2), Debug build, on 2026-11-11.

所有数据都通过真实 App 的现有 UI 创建：心愿、条件、行动记录与 PhotoPicker 照片；没有向 App 加入种子数据或截图专用入口。数据保存在模拟器的真实本地 Store 中，截图来自 `XCUIScreen` 的运行画面。

## Light / Dark 截图

| 页面 / 状态 | Light | Dark |
|---|---|---|
| 心愿首页（首屏） | `home-light.png` | `home-dark.png` |
| 心愿首页（向下滚动，展示主题色 Banner 与双列卡） | `home-scrolled-light.png` | — |
| 心愿首页（空状态） | `home-empty-light.png` | — |
| 心愿详情（含水印照片与 2/3 进度） | `detail-light.png` | `detail-dark.png` |
| 心愿详情（长标题状态） | `detail-long-title-light.png` | — |
| 今天（行动 + 已完成分组） | `today-light.png` | `today-dark.png` |
| 今天（长条件文案状态） | `today-long-condition-light.png` | — |

## 与上一版的对比

| 页面 | Before | After |
|---|---|---|
| 首页 | `../issue-21/home-light.png` | `home-light.png` |
| 详情 | `../issue-21/detail-light.png` | `detail-light.png` |
| 今天 | `../issue-21/today-light.png` | `today-light.png` |

更早的 Petrol / Eucalyptus 版本仍在 `../palette-refresh/`。

## 数据与状态覆盖

- Featured Wish：`京都的秋天`，照片来自模拟器 Photos，2/3 条件完成，价格 ¥6,000。
- 普通心愿：`学会做提拉米苏`（横向 Banner，1/2）、`一个可以让周末慢下来的阅读角`（双列卡，长标题，0/1）、`一台新的相机`（双列卡，0/1）。
- Today：4 个可推进行动（含长条件文案），已完成条件分组在下方。
- 照片、无照片占位、长标题、长条件、Light / Dark 均已覆盖。

## 复现方式

`WishEarnUITests/DesignCaptureUITests` 提供可选的证据流程。它在 CI 中默认跳过；本地取证时先通过 UI seed 数据，再运行 Light / Dark 截图：

```bash
# 清空模拟器中的测试数据
xcrun simctl uninstall booted com.wishearn.app

# 逐个运行较短的 seed 测试（长会话在 Xcode 27 模拟器上不稳定）
TEST_RUNNER_WISH_SEED=1 xcodebuild test -project WishEarn.xcodeproj -scheme WishEarn \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath build/DerivedData \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testSeedCameraWish \
  CODE_SIGNING_ALLOWED=NO
# 依次运行 testSeedReadingCornerWish / testSeedTiramisuWish / testSeedFeaturedWish
# 可选：testSeedPhotoForFeaturedWish（需要先 xcrun simctl addmedia booted <photo>）

xcrun simctl ui booted appearance light
TEST_RUNNER_WISH_SCREENSHOTS=1 xcodebuild test ... \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testCaptureLightScreenshots

xcrun simctl ui booted appearance dark
TEST_RUNNER_WISH_SCREENSHOTS=1 xcodebuild test ... \
  -only-testing:WishEarnUITests/DesignCaptureUITests/testCaptureDarkScreenshots
```

截图通过 `xcresulttool export attachments` 导出。`home-empty-light.png` 来自同一构建、空 Store 的首次启动。

## 已知差距

- 没有为所有心愿添加真实照片；其余卡片使用主题色占位图。照片路径已在 Featured / Detail 中验证。
- 模拟器在 Xcode 27 下的长 UI 测试会话不稳定，已拆分为短流程；仍出现一次 `signal term`，因此 CI 不运行截图测试。
- App Icon 仅新增提案 `../assets/app-icon-colorful-proposal.png`，未替换生产图标。
