# Changelog

本项目的重要变更记录在此文件中。

格式参考 [Keep a Changelog](https://keepachangelog.com/zh-CN/1.1.0/)，版本号遵循语义化版本。

## [Unreleased]

### Changed

- Today 行动页重构为低摩擦行动入口：Wish 作为次要上下文、条件标题主导、单一记录 CTA。
- TodayViewModel 输出 actionable / 今天已记录 / 已完成条件三组状态，并暴露累计进度快照；CHECKPOINT 历史完成不再显示为今日完成。
- 保持 STREAK 每日唯一记录和 COUNT / DURATION / AMOUNT / CUSTOM 可多次记录的现有语义。
- Today 空态、加载、错误态、深色模式与 Dynamic Type 调整；测试扩展至 261 项。
- Wish Editor 改为图片邀请、必填名称、价格 / 原因 / 目标日期分组；取消图片选择不再清空已有图片；保存按钮按校验状态禁用。
- Condition Editor 改为类型优先的字段布局：STREAK 整数输入与“天”单位、CHECKPOINT 完成型卡片、金额方向菜单；编辑时类型保持只读。
- Record Editor 将单位贴近数值、完成型条件使用完成卡片、日期使用中文本地化，并增加字段内联校验。
- 编辑器测试扩展至 270 项；六种条件类型均提供 Condition / Record Editor Preview。

### Planned

- TestFlight 上传与 App Store 提交。
- App Store 截图、支持 URL、隐私政策 URL。
- 正式 App 名称与 Bundle ID 确认。
- 真机图片选择 / 键盘 / 滚动逐项确认。

## [0.15.0] - 2026-11-08

### Added

- 正式占位 App 图标：渐变爱心 + 星光。
- `PrivacyInfo.xcprivacy`：不追踪、不收集数据。
- JSON 数据导出：心愿、条件、行动记录、解锁事件、暂停区间；设置页文件导出。
- App Store 上架材料与发布检查清单。
- Release Archive 与 Development IPA。
- 测试扩展至 207 项。

### Device

- Release 0.15.0 已在 iPhone 17 安装并启动。
- 解锁庆祝即时性已在真机确认符合预期。

## [0.14.1] - 2026-11-08

### Fixed

- 解锁庆祝页改为由解锁事件即时触发，不再依赖列表刷新后的状态差异检测。
- 新增 `UnlockCoordinator`：记录或条件变更产生新解锁时立即全屏展示庆祝页。
- 庆祝页「领取我的奖励」直接完成心愿；失败时保留页面并提示错误。
- 移除 WishListView 的延迟解锁检测，避免庆祝页延后弹出或重复弹出。

### Tests

- 新增 UnlockCoordinator、解锁事件发布与幂等测试，总计 205 项通过。

## [0.14.0] - 2026-11-08

### Added

- 完整业务流程集成测试：创建心愿 → 条件 → 记录 → 自动解锁 → 兑现。
- 暂停 / 恢复流程、金额累计流程、条件目标变更触发解锁测试。
- 删除记录 / 条件后保留解锁事件与已解锁状态的测试。
- RecordEditor 各条件类型文案与金额异常测试。
- ADR-010：解锁与历史事件规则。
- 测试总数扩展至 199 项，业务层主要文件覆盖率 88%–100%。

### Fixed

- 条件创建 / 修改 / 删除后现在会重新评估心愿解锁。

### Device

- iPhone 17 真机安装与启动通过（个人团队签名，`com.wishearn.app`）；手动交互检查待确认。

## [0.13.0] - 2026-11-08

### Added

- 心愿首页问候、进行中心愿数与总体进度卡片。
- 解锁庆祝页：动画、心愿图片、完成条件摘要、领取奖励 / 稍后再说。
- 解锁状态变化检测与全屏庆祝展示。
- 成就页：已解锁 / 已兑现 / 完成条件 / 行动记录统计与心愿列表。
- 我的页：应用信息、数据存储、隐私说明、版本信息。
- 深色模式适配并完成截图验证。
- ViewModel 测试扩展至 186 项。

## [0.12.0] - 2026-11-08

### Added

- `ProgressCalculator`：六种条件的进度快照、比例、剩余值与完成状态。
- `StreakCalculator`：当前 / 最长连续天数，暂停日冻结、恢复日继续累计。
- `WishProgressService`：条件进度与心愿总体进度。
- `WishUnlockService`：必需条件全部完成时自动解锁、生成 `UnlockEvent`、幂等恢复。
- 记录新增 / 修改后自动重新评估解锁。
- 心愿列表与详情展示总体进度；条件行展示当前进度条。
- 详情页新增「我已领取奖励」按钮，兑现写入 `completedAt`。
- 单元测试扩展至 180 项。

## [0.11.0] - 2026-11-08

### Added

- `ProgressRecordService`：统一六种条件的记录校验与创建 / 修改 / 删除。
- 记录编辑器：按条件类型输入数值、完成状态、备注与记录时间。
- 条件详情页：累计进度、行动记录历史、编辑 / 删除记录。
- 今日行动：ACTIVE 心愿的条件列表、今日记录汇总、STREAK / CHECKPOINT 完成状态、快速记录。
- STREAK 同日唯一、CHECKPOINT 单次完成、金额非负、未来日期拒绝等记录规则（ADR-009）。
- 真实磁盘持久化测试：容器重建后数据完整。
- 单元测试扩展至 147 项。

## [0.10.0] - 2026-11-08

### Added

- `ConditionLifecycleService`：统一条件创建、编辑、删除与排序。
- 六种条件类型的动态配置表单：类型、名称、目标值、单位、金额方向、必需标记。
- 心愿详情页：心愿信息、图片、条件列表、添加 / 编辑 / 删除 / 拖拽排序。
- 心愿卡片点击进入详情页。
- 条件类型、金额方向与目标值展示映射。
- 单元测试扩展至 112 项，新增条件生命周期、条件编辑与详情页 ViewModel 测试。

## [0.9.0] - 2026-11-08

### Added

- `WishLifecycleService`：统一管理创建、编辑、删除、暂停、恢复、归档、兑现。
- 暂停时创建 `WishPausePeriod`，恢复时关闭区间；支持多次暂停。
- 归档暂停中的心愿时自动关闭未结束的暂停区间。
- 兑现奖励写入 `completedAt`。
- 心愿卡片长按菜单新增暂停、恢复、归档、兑现操作。
- 创建 / 编辑流程改为通过生命周期服务写入。
- 单元测试扩展至 83 项，新增生命周期服务与暂停 / 恢复测试。

## [0.8.0] - 2026-11-08

### Added

- 删除心愿：长按菜单、二次确认、删除后列表自动刷新。
- 删除失败通过独立 action error 提示，不影响列表展示。
- 复用 Repository 级联删除条件、行动记录、解锁事件、暂停区间与图片。
- ViewModel 单元测试扩展至 65 项，新增删除成功与删除失败测试。

## [0.7.0] - 2026-11-08

### Added

- 编辑心愿：复用创建表单，自动预填名称、描述、价格、目标日期与图片。
- 编辑时保留心愿 ID、状态、创建时间与解锁 / 兑现记录。
- 支持保留、替换、移除心愿图片，并在保存成功后清理旧图片。
- 心愿卡片长按菜单提供编辑入口。
- ViewModel 单元测试扩展至 63 项，新增编辑预填、状态保留、图片保留 / 替换 / 移除测试。

## [0.6.0] - 2026-11-08

### Added

- 图片存储服务：PhotosPicker 数据、最长边 1600 压缩、JPEG 0.8、Application Support 沙盒存储、加载与删除。
- 创建心愿支持选择 / 更换 / 移除图片。
- 心愿卡片展示真实图片，加载失败或未设置时显示占位图。
- 删除心愿时自动清理关联图片。
- 图片错误类型与 `AppError.image` 映射。
- 单元测试扩展至 57 项，新增图片存储与图片加载测试。

## [0.5.0] - 2026-11-08

### Added

- 创建心愿表单：名称、描述、参考价格、目标日期、币种说明。
- `WishEditorViewModel`：名称必填、价格解析、目标日期校验、保存与错误映射。
- 心愿页新增 `+` 入口与空状态「创建第一个心愿」按钮。
- 创建成功后关闭表单并自动刷新列表。
- ViewModel 单元测试扩展至 46 项。

## [0.4.0] - 2026-11-08

### Added

- 心愿列表接入真实 Repository 数据，支持全部 / 进行中 / 已解锁 / 已兑现 / 已暂停筛选。
- 心愿卡片：图片占位、名称、参考价格、条件数量、状态标签。
- 加载、空数据、错误与重试状态。
- `WishListViewModel`、`WishFilter`、`WishCard` 与状态展示映射。
- ViewModel 单元测试扩展至 40 项。

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
