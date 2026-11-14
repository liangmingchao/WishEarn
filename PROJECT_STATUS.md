# WishEarn Project Status

> 本文件是项目进度的唯一事实源。每次完成有实际交付价值的任务后更新；未经验收的任务不得标记为 DONE。

## Project Overview

- Current Version: 0.15.0
- Current Phase: Phase 9 — 发布准备（RC 验收）
- Current Branch: main
- Last Updated: 2026-11-10

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

- Task ID: TASK-904
- Task Name: 发布验收
- Current Progress: Release 0.15.0 已归档；TestFlight / App Store 提交待账号
- Modified Files: 无
- Remaining Work: TestFlight 上传、App Store 元数据与截图、最终真机检查

- RC 真机验收：Playful Release 0.15.0 已在 iPhone 17 安装并启动（2026-11-10）；PhotosPicker、键盘、滚动、导航、重启仍未验收

- Task ID: TASK-905
- Task Name: Today 进度口径修复 + 外观切换（分支 `ui/daylight-ledger`）
- Current Progress: 代码完成并已构建安装到 iPhone 17（2026-11-13）；单元测试未执行
- Modified Files: `TodayViewModel.swift`、`TodayView.swift`、`AppearanceSettings.swift`（新增）、`SettingsView.swift`、`RootTabView.swift`、`WishEarnApp.swift`、`AppContainer.swift`、`TodayViewModelTests.swift`、`AppearanceSettingsTests.swift`（新增）、`WishEarn.xcodeproj/project.pbxproj`（xcodegen）
- Verification: Debug 真机构建 BUILD SUCCEEDED；`build-for-testing` TEST BUILD SUCCEEDED；模拟器实测「跟随系统 / 强制深色」三态渲染通过（画布 223,221,213 ↔ 46,49,43）
- Remaining Work: 单元测试未跑（模拟器测试服务被 macOS 开发者模式禁用拦截，真机测试包缺 Apple ID 签名）；真机交互与视觉验收

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
- App Icon 仍为 petrol 版本；Playful Editorial 图标提案待品牌确认后替换。
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
- Playful Editorial / Sunny Pop Journal 配色：Violet 主色、Coral 辅助色、六种 Wish 主题色与 WCAG 对比度测试。
- 首页、详情、Today、Editor、Unlock、Achievements、Settings 已完成 Light / Dark 配色落地。
- 测试体系：274 项单元 / 集成 + 1 项关键旅程 UI 测试，业务层主要文件覆盖率 88%–100%。

## Last Verification

- Build: PASS — Debug / Release
- Unit Tests: PASS — 274 项，iPhone 18 Pro / iOS 27.2，2026-11-10 13:22
- UI Test: PASS — 1 项关键旅程（创建 → 条件 → 记录 → 解锁 → 领取）
- Playful Editorial: PASS — 七个核心页面 Light / Dark 模拟器截图
- Archive: PASS — `build/Issue22.xcarchive`（0.15.0 / 1）
- IPA: PASS — `build/Issue22Export/WishEarn.ipa`
- Device Install / Launch: PASS — Release 0.15.0 在 iPhone 17 / iOS 27.0 安装并启动（2026-11-10）
- Device Interaction: NOT TESTED — PhotosPicker、键盘、滚动、导航、重启
- CI: PASS — main run 42840733123（274 单元/集成 + 1 UI 测试）
- Privacy Manifest: PASS — 已打包
- Last Verified Commit: `2592574`（main，PR #26）
- RC 报告：`docs/qa/ISSUE_22_RC_REPORT.md`

## Current Risks

- 真机图片选择 / 键盘 / 滚动 / 导航 / 重启仍需手动确认。
- main CI 已确认绿色；后续提交仍需维持门禁。
- TestFlight / App Store 账号与凭据缺失。
- App Store 截图、支持 URL、隐私政策 URL 未准备。
- App Icon 尚未替换为 Playful 方案。

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
- Description: 在 iPhone 17 上完成真机交互清单（PhotosPicker、键盘、滚动、导航、重启）；确认 App Store 名称 / Bundle ID / 截图 / 支持 URL / 隐私政策 URL
- Dependencies: `build/Issue22.xcarchive`、`build/Issue22Export/WishEarn.ipa`、可用真机、App Store Connect
- Expected Outcome: 真机清单完成、上架材料与凭据就绪、RC 从 NO-GO 转为 GO
- Acceptance Criteria: 无 P0/P1；CI Build/Test 通过；真机图片选择 / 键盘 / 滚动 / 导航 / 重启通过；App Store 材料完整
