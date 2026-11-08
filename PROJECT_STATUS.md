# WishEarn Project Status

> 本文件是项目进度的唯一事实源。每次完成有实际交付价值的任务后更新；未经验收的任务不得标记为 DONE。

## Project Overview

- Current Version: 0.3.0
- Current Phase: Phase 3 — 心愿管理
- Current Branch: main
- Last Updated: 2026-11-08

## Current Milestone

- Milestone: M3 — 心愿管理
- Description: 心愿列表、创建、编辑、删除、暂停 / 恢复、心愿详情
- Status: TODO

## Completed Tasks

- TASK-000 准备开发环境（2026-11-08）
- TASK-001 创建项目工程（2026-11-08）
- TASK-101 建立目录结构（2026-11-08）
- TASK-102 建立 App 入口与导航（2026-11-08）
- TASK-103 建立依赖注入（2026-11-08）
- TASK-104 建立统一错误处理（2026-11-08）
- TASK-105 建立基础设计系统（2026-11-08）
- TASK-201 实现领域枚举（2026-11-08）
- TASK-202 实现 Wish Domain Model（2026-11-08）
- TASK-203 实现 Condition Domain Model（2026-11-08）
- TASK-204 实现 ProgressRecord Domain Model（2026-11-08）
- TASK-205 实现 UnlockEvent（2026-11-08）
- TASK-206 建立 SwiftData Model（2026-11-08）
- TASK-207 实现 Repository（2026-11-08）
- TASK-208 实现数据映射（2026-11-08）
- TASK-209 实现 WishPausePeriod（2026-11-08）

## In Progress

- Task ID: TASK-301
- Task Name: 心愿列表查询
- Current Progress: 未开始
- Modified Files: 无
- Remaining Work: 实现 WishListViewModel 与真实列表展示，按状态筛选、按创建时间排序

## Pending Tasks

- TASK-301 心愿列表查询
- TASK-302 创建心愿
- TASK-303 图片管理
- TASK-304 编辑心愿
- TASK-305 删除心愿
- TASK-306 心愿暂停与恢复
- TASK-307 心愿生命周期管理

## Known Issues

- Bundle Identifier `com.wishearn.app` 为占位值，正式签名前需确认。
- App 图标为纯色占位图，正式发布前需替换。
- 尚未配置 Apple Developer Team；当前仅验证模拟器构建。
- 心愿列表与详情仍为占位页面，尚未接入已实现的 Repository。
- 图片管理（PhotosPicker、压缩、沙盒存储）尚未实现。

## Technical Debt

- 项目使用 Swift 5 语言模式；Swift 6 严格并发迁移留待后续评估。
- `WishEarn.xcodeproj` 由 XcodeGen（`project.yml`）生成；修改工程结构后需运行 `xcodegen generate`。
- 设计系统颜色使用代码定义，后续可迁移到 Asset Catalog 以支持主题扩展。
- `WishEarnMigrationPlan` 目前只有 Schema V1，尚无实际迁移阶段；后续修改模型时需补充。

## Architecture Decisions

- 见 [DECISIONS.md](DECISIONS.md)（ADR-001 ～ ADR-008）
- 决策结论已收敛，开发时按 DECISIONS.md 执行

## Implemented Features

- 领域枚举：`WishStatus`、`ConditionType`、`AmountDirection`、`ProgressUnit`。
- 领域实体：`Wish`、`Condition`、`ProgressRecord`、`UnlockEvent`、`WishPausePeriod`，含基础校验。
- 领域 Repository 协议：Wish / Condition / Progress / UnlockEvent / PausePeriod。
- SwiftData 持久化模型与 `ModelContainerFactory`（支持内存数据库与迁移计划）。
- SwiftData Repository 实现：CRUD、按状态 / 所属关系查询、级联删除。
- Domain ↔ Entity 映射器。
- `AppContainer` 已注册全部 Repository。
- 四 Tab 导航与基础设计系统。
- 统一错误处理与启动失败兜底页面。
- 单元测试 35 项通过（领域模型、映射、Repository、错误处理、依赖注入）。

## Last Verification

- Build: PASS — `xcodebuild build`，generic iOS Simulator，2026-11-08 19:56
- Unit Tests: PASS — 35 项，iPhone 18 Pro / iOS 27.2，2026-11-08 19:56
- Integration Tests: NOT RUN
- Simulator Launch: PASS — SwiftData 容器初始化成功，四 Tab 正常
- Last Verified Commit: N/A（工作区尚未提交）

## Current Risks

- 未提交 Git，当前成果仅存在于工作区；建议 Phase 3 Gate 后提交。
- 心愿管理 UI 尚未接入 Repository，Phase 3 需重点验证真实数据读写。
- 图片存储、删除级联和暂停区间尚未在 UI 流程中联调。

## Files Changed（Phase 2）

- `WishEarn/Domain/Enums/`：WishStatus、ConditionType、AmountDirection、ProgressUnit
- `WishEarn/Domain/Entities/`：Wish、Condition、ProgressRecord、UnlockEvent、WishPausePeriod
- `WishEarn/Domain/Repositories/`：五类 Repository 协议
- `WishEarn/Data/Models/`：五类 SwiftData Entity
- `WishEarn/Data/Database/`：ModelContainerFactory、SwiftDataStore、SchemaMigrationPlan
- `WishEarn/Data/Mappers/`：五类 Mapper
- `WishEarn/Data/Repositories/`：五类 SwiftData Repository
- `WishEarn/App/AppContainer.swift`：注册 Repository
- `WishEarn/App/WishEarnApp.swift`：启动失败兜底
- `WishEarnTests/{DomainTests,RepositoryTests}/`

## Next Recommended Action

- Task ID: TASK-301
- Description: 实现心愿列表查询与展示
- Dependencies: Phase 2 已完成
- Expected Outcome: 心愿列表读取真实 Repository 数据，支持状态筛选与创建时间排序
- Acceptance Criteria: 不同状态正确显示、空数据状态正确、不影响其他数据扩展设计
