# Changelog

本项目的重要变更记录在此文件中。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循语义化版本。

## [Unreleased]

### Planned

- Phase 3：心愿管理（TASK-301 ～ TASK-307）。

## [0.3.0] - 2026-11-08

### Added

- Phase 2 领域枚举：`WishStatus`、`ConditionType`、`AmountDirection`、`ProgressUnit`。
- 领域实体：`Wish`、`Condition`、`ProgressRecord`、`UnlockEvent`、`WishPausePeriod`，含基础校验。
- 五类 Repository 协议与 SwiftData 实现：CRUD、按状态 / 所属关系查询、级联删除。
- SwiftData Entity、Domain ↔ Entity 映射器、`ModelContainerFactory`、`SwiftDataStore`、`SchemaMigrationPlan`。
- `AppContainer` 注册全部 Repository，并在启动失败时展示错误页。
- 单元测试扩展至 35 项，覆盖领域模型、映射、Repository 与级联删除。

## [0.2.0] - 2026-11-08

### Added

- Phase 1 架构目录：Domain、Data、Presentation、Infrastructure、Tests。
- 四 Tab 导航：心愿、行动、成就、我的。
- 基础设计系统：颜色、字体、间距、圆角、按钮、卡片、状态标签、空状态。
- 依赖注入：`AppContainer`、`AppDependencies`、live / preview 配置。
- 统一错误处理：`DomainError`、`PersistenceError`、`AppError`、`ErrorStateView`、`appErrorAlert`。
- 时间能力：`ClockProviding`、`SystemClock`、`FixedClock`；行动页 ViewModel 通过构造函数注入时钟。
- 单元测试 7 项：错误映射、时钟注入、容器工厂、路由默认值、工程冒烟。

### Changed

- `project.yml` 排除 `.gitkeep`，重新生成 Xcode 工程。

## [0.1.0] - 2026-11-08

### Added

- Phase 0：创建 `WishEarn.xcodeproj`、SwiftUI App 入口、Assets、单元测试 Target 与共享 Scheme。
- XcodeGen 工程配置 `project.yml`，最低 iOS 17，Swift 5 语言模式。
- AppIcon 占位图与 AccentColor。
- Git 仓库初始化（`main` 分支）。
- 项目指导文档：PRD、ARCHITECTURE、DEVELOPMENT_PLAN、AI_RULES。
- 工程协作文档：CLAUDE.md、PROJECT_STATUS.md、DECISIONS.md、CHANGELOG.md。
- 首批架构决策 ADR-001 ～ ADR-008，覆盖 STREAK 暂停语义、CUSTOM 完成判定、AMOUNT 方向、总体进度、ConditionStatus / weight、User 实体、枚举存储值、金额精度。

### Changed

- AI_RULES 合并第二轮讨论增量，从 V1.0 升级至 V1.1。
- ARCHITECTURE 按 ADR 补充 `WishPausePeriod`、移除 `ConditionStatus` / `weight`、明确 STREAK 暂停冻结语义，升级至 V1.1。
- DEVELOPMENT_PLAN 按 ADR 增加 TASK-209 并调整 TASK-201 / TASK-306 / TASK-507 / TASK-602，升级至 V1.1。

## [0.0.0] - 2026-11-08

### Added

- 项目启动，完成产品、架构、开发计划与 AI 协作规范。
- Xcode 工程尚未创建，等待 Phase 0 开始。
