# WishEarn Project Status

> 本文件是项目进度的唯一事实源。每次完成有实际交付价值的任务后更新；未经验收的任务不得标记为 DONE。

## Project Overview

- Current Version: 0.15.0
- Current Phase: Phase 9 — 发布准备（RC 验收）
- Current Branch: design/issue-30-visual-identity-refinement
- Last Updated: 2026-11-11

## Current Milestone

- Milestone: M9 — 发布准备
- Description: 应用信息、数据导出、Release 构建、TestFlight 与 App Store 上架
- Status: IN_PROGRESS — RC NO-GO（Archive / IPA 与 main CI 完成；真机交互、上架材料与账号仍阻塞）

## Completed Tasks

- TASK-000 ～ TASK-001 工程初始化（2026-11-08）
- TASK-101 ～ TASK-105 基础架构（2026-11-08）
- TASK-201 ～ TASK-209 领域模型与持久化（2026-11-08）
- TASK-301 ～ TASK-307 心愿管理（2026-11-08）
- TASK-401 ～ TASK-406 条件管理（2026-11-08）
- TASK-501 ～ TASK-509 行动记录（2026-11-08）
- TASK-601 ～ TASK-607 进度与解锁（2026-11-08）
- TASK-701 ～ TASK-709 核心 UI 与交互（2026-11-08）
- TASK-801 ～ TASK-805 测试与质量保障（2026-11-08）
- TASK-806 真机测试（2026-11-08，安装 / 启动 / 解锁即时性通过）
- TASK-901 应用信息（2026-11-08，图标 / 隐私清单 / App Store 文案）
- TASK-902 数据导出（2026-11-08，JSON 导出 + 文件导出 UI）
- TASK-903 发布构建（2026-11-08，Release Archive + Development IPA）
- Phase 2 UI redesign：Issue #8 设计系统、#9 心愿首页、#10 心愿详情、#11 Today 行动页、#12 Editors、#13 Unlock / Achievements / Settings（2026-11-09 已合并）
- Issue #20 首页主图比例与过渡配色（已合并，随后由 #21 取代品牌主色）
- Issue #21 Playful Editorial / Sunny Pop Journal 配色与七个核心页面（2026-11-10 已合并）
- Issue #22 Phase 2 RC QA：自动化回归、Release Archive / IPA 完成，结论 NO-GO；报告已合并（2026-11-10）
- Issue #25 关键旅程 UI 自动化：新增 `WishEarnUITests`，修复领取后详情状态不刷新；PR #26 已合并（2026-11-10）

## In Progress

- Task ID: Issue #30
- Task Name: Visual Identity & UI Composition Refinement（Paper & Sage）
- Current Progress: Home / Today / Wish Detail 与共享 Design System 已完成 Paper & Sage 复审修订；新增「我的 → 外观」跟随系统 / 浅色 / 深色切换；Light / Dark 截图、辅助功能 XXXL 截图与对比度报告已产出；PR 待审阅，未合并。Paper & Sage Release 0.15.0 (1) 已于 2026-11-11 重新安装并启动于 iPhone 17（iOS 27.0）；真机交互未逐项验收。
- Modified Files: `AppTheme.swift`、`WishTheme.swift`、`WishCard.swift`、`WishListView.swift`、`TodayView.swift`、`WishDetailView.swift`、`ConditionRow.swift`、`FilterChip.swift`、`StatusBadge.swift`、`ProgressIndicator.swift`、`ButtonStyles.swift`、`CardModifier.swift`、`EmptyStateView.swift`、`RootTabView.swift`、`ConditionDetailView.swift`、`WishStatus+Presentation.swift`、`WishEarnApp.swift`、`SettingsView.swift`、新增 `AppAppearance.swift`、`EditorialComponents.swift`、`DesignSystemTests.swift`、`DesignCaptureUITests.swift`、设计文档与截图。
- Remaining Work: 用户审阅 PR；确认后再合并。若需要，后续单独评估 App Icon 替换与真机照片验证。

- Task ID: TASK-907
- Task Name: 记录默认值与解锁庆祝反馈增强（Paper & Sage）
- Current Progress: NEEDS_REVIEW — COUNT / CUSTOM 新记录预填 1；解锁庆祝改为「已达成 → 已领取」两阶段纸张证书；Build / 278 单元测试 / Critical Journey UI 测试通过；截图 `unlock-light.png` + `unlock-claimed-light.png`
- Modified Files: `RecordEditorViewModel.swift`、`RecordEditorView.swift`、`UnlockCelebrationView.swift`、`UnlockCoordinator.swift`、`RecordEditorViewModelTests.swift`、`UnlockCoordinatorTests.swift`、`CriticalJourneyUITests.swift`、设计文档与截图
- Remaining Work: PR 审阅；真机确认星屑动画、触觉与 Reduce Motion

- Task ID: TASK-904
- Task Name: 发布验收
- Current Progress: Release 0.15.0 已归档；TestFlight / App Store 提交待账号
- Modified Files: 无
- Remaining Work: TestFlight 上传、App Store 元数据与截图、最终真机检查

- RC 真机验收：Playful Release 0.15.0 已在 iPhone 17 安装并启动（2026-11-10）；PhotosPicker、键盘、滚动、导航、重启仍未验收

## Pending Tasks

- TASK-904 发布验收（TestFlight / App Store）
- App Store Connect 创建 App 记录
- 截图 / 预览视频 / 支持 URL / 隐私政策 URL
- 正式 App 名称与 Bundle ID 确认
- TASK-806 剩余真机项：图片选择、键盘、滚动确认

## Known Issues

- TestFlight 上传与 App Store 提交需要 App Store Connect 账号与凭据，当前未配置。
- App 名称 `WishEarn` 与 Bundle ID `com.wishearn.app` 仍为占位，上架前确认。
- App Store 截图、支持 URL、隐私政策 URL 尚未准备。
- Playful Release 0.15.0 已在 iPhone 17 安装并启动；图片选择、键盘、滚动、导航与重启仍未验收。
- UI 自动化仅覆盖一条关键旅程；其它页面与真实设备交互仍未自动化。
- App Icon 仍为 petrol 版本；Playful Editorial 图标提案待品牌确认后替换。Issue #30 新增 `docs/design/assets/app-icon-colorful-proposal.png` 提案，同样未替换生产图标。
- Issue #30 的截图取证 UI 测试（`DesignCaptureUITests`）默认在 CI 跳过；Xcode 27 模拟器在长会话中偶发 `signal term`，因此拆分为多个短测试运行。
- Issue #30 Paper & Sage Release 0.15.0 (1) 已在 iPhone 17 / iOS 27.0 重新安装并启动（2026-11-11）；新增外观设置与新版配色尚未在真机手动验收。
- Issue #30 复审新增「外观」设置，覆盖 Issue #30 原文「不新增用户可配置主题切换功能」的约束；这是用户明确要求，未改动 Domain / Repository / SwiftData / 解锁状态机。
- 外观设置已通过真实 UI 测试验证：系统浅色下切到深色立即生效，再切回跟随系统恢复；尚未在真机 + 系统外观切换组合下逐项验收。
- GitHub Actions billing 已恢复；PR #26 与 main 合并后 CI 均已绿色（274 单元/集成 + 1 UI 测试）。
- 构建存在非致命方向声明警告：All interface orientations must be supported unless the app requires full screen。

## Technical Debt

- 项目使用 Swift 5 语言模式；Swift 6 严格并发迁移留待后续评估。
- `WishEarn.xcodeproj` 由 XcodeGen（`project.yml`）生成；修改工程结构后需运行 `xcodegen generate`。
- 设计系统颜色使用代码定义，后续可迁移到 Asset Catalog 以支持主题扩展。
- `WishEarnMigrationPlan` 目前只有 Schema V1，尚无实际迁移阶段；后续修改模型时需补充。
- 列表 / 详情 / 今日 / 成就存在按条件逐条查询的 N+1 模式，后续可批量查询或增加汇总字段。
- 图片使用 `_PhotosUI_SwiftUI` 模块导入 `PhotosPickerItem`，属于当前 SDK 的 SwiftUI Photos 集成方式。
- 图片压缩与读取仍在主线程执行，后续可移到后台任务。
- `WishLifecycleService` 跨 Repository 的操作采用尽力回滚，尚未引入统一事务边界。
- 解锁事件写入与心愿状态更新分两步保存；事件已持久化时可恢复状态，但尚无统一事务。
- 数据导出为 JSON 文本，不包含图片二进制；图片路径会随导出保留。

## Architecture Decisions

- 见 [DECISIONS.md](DECISIONS.md)（ADR-001 ～ ADR-010）
- 解锁与历史事件规则见 ADR-010

## Implemented Features

- 领域模型、SwiftData 持久化、Repository 与映射。
- 心愿管理、条件管理、行动记录、进度计算、连续打卡、自动解锁、总体进度与兑现。
- 解锁庆祝由 `UnlockCoordinator` 即时触发（真机确认）。
- 成就页、我的页、深色模式。
- App 图标：爱心 + 星光正式占位设计。
- 隐私清单：不追踪、不收集数据。
- 数据导出：JSON 文件导出，包含心愿、条件、记录、解锁事件、暂停区间。
- 发布材料：`docs/APP_STORE.md`、`docs/RELEASE_CHECKLIST.md`。
- Release Archive 与 Development IPA 构建成功。
- Phase 2 设计系统、心愿首页、心愿详情、Today 行动页、Editors、Unlock / Achievements / Settings 改版。
- Paper & Sage 配色：暖纸画布、墨色文字、深鼠尾草绿行动色、低饱和 clay 点缀、三种 Wish Theme 与 WCAG 对比度测试。
- 首页、详情、Today、Editor、Unlock、Achievements、Settings 已完成 Light / Dark 配色落地；首页三种卡片统一白纸面。
- 「我的 → 外观」支持跟随系统 / 浅色 / 深色，选择持久化并在 App 根视图应用。
- 测试体系：276 项单元 / 集成 + 1 项关键旅程 UI 测试，业务层主要文件覆盖率 88%–100%。

## Last Verification

- Build: PASS — Debug / Release
- TASK-907: Build PASS — Debug（iOS Simulator，2026-11-12 00:10）
- TASK-907: Unit Tests PASS — 278 项（新增记录默认值与领取确认态）
- TASK-907: UI Test PASS — CriticalJourneyUITests 覆盖 解锁 → 领取 → 已领取 → 完成（38.4s）
- TASK-907: Screenshots — `unlock-light.png`（已达成）与 `unlock-claimed-light.png`（已领取）
- Unit Tests: PASS — 276 项，iPhone 18 Pro / iOS 27.2，2026-11-11 21:35（Paper & Sage 复审修订）
- UI Test: PASS — 1 项关键旅程（创建 → 条件 → 记录 → 解锁 → 领取），29.083s，2026-11-11 21:35
- Design Evidence UI Tests: 10 项在未设置 opt-in 环境变量时 skipped；本地 Light / Dark / 设置 / 辅助功能截图流程 PASS
- Contrast Audit: PASS — 36 组 pair × Light / Dark（72 个实测值），见 `docs/design/screenshots/issue-30/CONTRAST.md`
- Issue #30 Screenshots: PASS — Home / Today / Detail / Settings / Achievements Light / Dark、长文案、App 内外观覆盖、辅助功能 XXXL、解锁已达成/已领取；iPhone 18 Pro Simulator / iOS 27.2；空状态 iPhone 17e 空 Store
- Playful Editorial: PASS — 七个核心页面 Light / Dark 模拟器截图（历史首轮 #30 设计，已被 Paper & Sage 取代）
- Archive: PASS — `build/Issue22.xcarchive`（0.15.0 / 1）
- IPA: PASS — `build/Issue22Export/WishEarn.ipa`
- Device Install / Launch: PASS — Paper & Sage Release 0.15.0 (1) 在 iPhone 17 / iOS 27.0 重新安装并启动（2026-11-11，devicectl）
- Device Interaction: NOT TESTED — PhotosPicker、键盘、滚动、导航、重启、新版外观切换
- CI: PASS — Paper & Sage PR #31 run [43032317777](https://github.com/liangmingchao/WishEarn/actions/runs/43032317777)（commit `72c8e57`；276 单元/集成 + 10 UI：1 passed, 9 skipped, 0 failed；14m09s）
- CI (首轮): PASS — run [43022177657](https://github.com/liangmingchao/WishEarn/actions/runs/43022177657)（284 tests: 276 passed, 8 skipped, 0 failed, 12m03s）
- Main CI: PASS — run 42840733123（274 单元/集成 + 1 UI 测试）
- Privacy Manifest: PASS — 已打包
- Last Verified Commit: `72c8e57`（Paper & Sage 复审修订；main 基线 `16f390c`）
- RC 报告：`docs/qa/ISSUE_22_RC_REPORT.md`

## Current Risks

- 真机图片选择 / 键盘 / 滚动 / 导航 / 重启仍需手动确认。
- Paper & Sage 新配色、主按钮纯色化与「外观」设置在真机上尚未逐项验收。
- 解锁庆祝的星屑动画、两次触觉反馈与 Reduce Motion 表现需真机手动验收；记录默认值由单元测试覆盖。
- main CI 已确认绿色；后续提交仍需维持门禁。
- TestFlight / App Store 账号与凭据缺失。
- App Store 截图、支持 URL、隐私政策 URL 未准备。
- App Icon 仍为 petrol 版本；Paper & Sage 图标提案未替换生产资产。

## Files Changed（Phase 9）

- `WishEarn/Resources/Assets.xcassets/AppIcon.appiconset/AppIcon.png`
- `WishEarn/Resources/PrivacyInfo.xcprivacy`
- `WishEarn/Infrastructure/Export/DataExportService.swift`
- `WishEarn/Presentation/Settings/{SettingsView,WishEarnExportDocument}.swift`
- `WishEarn/App/AppContainer.swift`
- `WishEarn/Presentation/Navigation/RootTabView.swift`
- `WishEarnTests/IntegrationTests/DataExportTests.swift`
- `docs/APP_STORE.md`
- `docs/RELEASE_CHECKLIST.md`
- `project.yml`（0.15.0）

## Next Recommended Action

- Task ID: Issue #22 / TASK-904
- Description: 审阅 Issue #30 Paper & Sage PR；在 iPhone 17 上重装最新构建并完成真机交互清单（PhotosPicker、键盘、滚动、导航、重启、外观切换）；确认 App Store 名称 / Bundle ID / 截图 / 支持 URL / 隐私政策 URL
- Dependencies: `build/Issue22.xcarchive`、`build/Issue22Export/WishEarn.ipa`、可用真机、App Store Connect
- Expected Outcome: 真机清单完成、上架材料与凭据就绪、RC 从 NO-GO 转为 GO
- Acceptance Criteria: 无 P0/P1；CI Build/Test 通过；真机图片选择 / 键盘 / 滚动 / 导航 / 重启通过；App Store 材料完整
