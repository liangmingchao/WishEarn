# WishEarn Project Status

> 本文件是项目进度的唯一事实源。每次完成有实际交付价值的任务后更新；未经验收的任务不得标记为 DONE。

## Project Overview

- Current Version: 0.15.0
- Current Phase: Phase 9 — 发布准备
- Current Branch: main
- Last Updated: 2026-11-09

## Current Milestone

- Milestone: M9 — 发布准备
- Description: 应用信息、数据导出、Release 构建、TestFlight 与 App Store 上架
- Status: IN_PROGRESS（Archive / IPA 完成，TestFlight 待账号与上传）

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
- Phase 2 UI redesign：Issue #8 设计系统、#9 心愿首页、#10 心愿详情（2026-11-09 已合并）

## In Progress

- Task ID: TASK-904
- Task Name: 发布验收
- Current Progress: Release 0.15.0 已安装并启动；TestFlight / App Store 提交待账号
- Modified Files: 无
- Remaining Work: TestFlight 上传、App Store 元数据与截图、最终真机检查

- Issue #11 Today 行动页：实现与测试完成，等待 PR Review；后续 #12 Editors、#13 Unlock / Achievements / Settings

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
- 真机图片选择、键盘遮挡、滚动性能尚未逐项确认（解锁即时性已确认）。
- 无 UI 自动化测试覆盖真实用户流程。

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
- Phase 2 设计系统、心愿首页、心愿详情改版；Today 行动页待 PR Review。
- 测试体系：261 项，业务层主要文件覆盖率 88%–100%。

## Last Verification

- Build: PASS — Debug / Release
- Unit Tests: PASS — 261 项，iPhone 18 Pro / iOS 27.2，2026-11-09 22:39
- Issue #11 Today: PASS — Debug / Release build；actionable / recorded / completed / empty 截图
- Integration Tests: PASS
- Archive: PASS — `build/WishEarn.xcarchive`（0.15.0 / 1）
- IPA: PASS — `build/export/WishEarn.ipa`
- Device: PASS — Release 0.15.0 安装并启动（iPhone 17）
- Privacy Manifest: PASS — 已打包
- Last Verified Commit: `9171422`（main，PR #16）；Issue #11 Today 在 `feat/issue-11-today` 验证

## Current Risks

- 后续工作（TASK-301～904）尚未提交，位于工作区。
- TestFlight / App Store 账号与凭据缺失。
- App Store 截图、支持 URL、隐私政策 URL 未准备。
- 真机图片选择 / 键盘 / 滚动仍需手动确认。

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

- Task ID: TASK-904
- Description: 配置 App Store Connect、上传 TestFlight 并完成截图 / 支持 URL / 隐私政策 URL
- Dependencies: Archive 与 IPA 已就绪
- Expected Outcome: TestFlight 可安装测试，App Store 元数据完整
- Acceptance Criteria: TestFlight 构建可用、截图与隐私信息完整、无 P0 缺陷
