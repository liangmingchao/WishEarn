# WishEarn — 决策记录（DECISIONS）

**版本：** V1.0  
**用途：** 记录已经确认的产品与架构决策，解决 PRD / ARCHITECTURE 中未明确或互相冲突的规则。  
**效力：** 标记为 Accepted 的决策与 PRD / ARCHITECTURE 具有同等约束力；若与 PRD 的明确规则冲突，以 PRD 为准，并应先修订本文件与 PRD。  
**日期：** 2026-11-08

## 决策索引

| ADR | 主题 | 状态 |
|---|---|---|
| ADR-001 | STREAK 暂停后的连续周期语义 | Accepted |
| ADR-002 | CUSTOM 条件的完成判定 | Accepted |
| ADR-003 | AMOUNT 的方向与累计规则 | Accepted |
| ADR-004 | 心愿总体进度的分母 | Accepted |
| ADR-005 | ConditionStatus 与 weight 的取舍 | Accepted |
| ADR-006 | MVP 是否实现 User 实体 | Accepted |
| ADR-007 | 枚举存储值与显示值 | Accepted |
| ADR-008 | 金额精度与舍入 | Accepted |
| ADR-009 | 行动记录规则 | Accepted |
| ADR-010 | 解锁与历史事件规则 | Accepted |

---

# ADR-001: STREAK 暂停后的连续周期语义

## Status

Accepted

## Context

PRD §7.5 规定“暂停期间不计算连续天数”，FR-005 规定“暂停不自动视为失败”；ARCHITECTURE §5.2 写的是“恢复时重新开始新的连续周期”。两者对暂停后是冻结还是重置存在冲突。连续型条件是产品核心体验之一，如果暂停直接清空已有连续天数，会违背 PRD “不制造焦虑”的设计原则。

## Decision

MVP 采用**暂停冻结**语义：

- 暂停期间不产生打卡要求，也不视为中断。
- 恢复后从暂停前最后一个有效连续日继续累计，而不是从 0 重新开始。
- 暂停和恢复本身不改变心愿状态为失败；心愿状态仍按 PRD §7.8 流转。
- 历史最长连续天数始终保留，用于成就展示。
- 实现上新增 `WishPausePeriod` 概念（`id`、`wishID`、`startedAt`、`endedAt?`），记录每一次暂停区间；`StreakCalculator` 在计算连续天数时跳过暂停区间覆盖的自然日。
- 暂停区间内的打卡记录不用于延长连续天数，也不打断连续天数。
- 恢复当天属于非暂停日，正常打卡可以继续累计。

## Alternatives

1. **恢复后重置当前连续周期。** 实现简单、无需新增实体，但与 PRD 的“暂停不视为失败”冲突，用户体验偏惩罚。
2. **按历史最长连续天数判定完成。** 可以避免进度回退，但会改变 STREAK 的完成语义，且与 ARCHITECTURE 的“当前连续天数”定义不一致。

## Consequences

- ARCHITECTURE 需补充 `WishPausePeriod` 实体和 Repository 查询能力。
- DEVELOPMENT_PLAN 需在 Phase 2 / Phase 6 增加暂停区间的存储与测试任务。
- StreakCalculator 的测试必须覆盖：暂停一天、暂停跨多天、多次暂停、暂停期间打卡、恢复当天打卡、暂停后中断。

## Date

2026-11-08

---

# ADR-002: CUSTOM 条件的完成判定

## Status

Accepted

## Context

PRD 将 CUSTOM 定义为“自由定义条件及完成方式”，但数据模型仍给它 `target_value`；FR-011 只说明“允许用户填写数值或备注”。如果不明确，开发时无法实现统一的进度计算和验收。

## Decision

MVP 将 CUSTOM 定义为**自定义数值型条件**：

- 条件包含名称、自定义单位、目标值。
- 用户每次记录一个数值，当前值 = 所有有效记录求和。
- 完成条件 = 当前值 >= 目标值。
- 一次性“完成/未完成”事项使用 CHECKPOINT，不用 CUSTOM 模拟。
- CUSTOM 不引入额外的计算公式，复用 COUNT 的累计逻辑，仅去掉预设业务语义。

## Alternatives

1. CUSTOM 为布尔型手动完成：会与 CHECKPOINT 重复，失去存在意义。
2. CUSTOM 为纯文本记录：无法计算进度，也无法参与自动解锁。

## Consequences

- 六种条件类型的计算路径保持一致，便于测试。
- UI 需要提供“自定义单位”输入，并在条件配置页说明其与 CHECKPOINT 的区别。

## Date

2026-11-08

---

# ADR-003: AMOUNT 的方向与累计规则

## Status

Accepted

## Context

PRD FR-024 要求金额条件支持 INCOME / SAVING / OTHER 三种方向；数据模型把 `amount_direction` 放在 Condition 上，而 ProgressRecord 没有方向字段。需要明确同一条件内是否混合累计、不同方向是否互相抵扣。

## Decision

- 金额方向是**条件级属性**：一个 AMOUNT 条件只有一个方向，其所有记录都属于该方向。
- 当前金额 = 该条件下所有有效记录的数值之和。
- 不进行跨方向抵扣或净额计算；需要同时追踪“兼职收入”和“节省开支”时，创建两个 AMOUNT 条件。
- 金额记录允许为 0，不允许负数；负数输入在 UI 层阻止。
- 金额使用 `Decimal` 存储与累计，禁止 `Double`。

## Alternatives

1. 方向放在 ProgressRecord 上，同一条件内混合累计：灵活但 UI 与计算复杂度更高，MVP 不需要。
2. 跨方向净额计算：会让“节省”抵消“收入”，不符合用户直觉。

## Consequences

- Condition 的 `amountDirection` 在非 AMOUNT 类型下必须为 nil。
- 编辑条件时，一旦存在记录，不允许修改金额方向；只能新建条件。

## Date

2026-11-08

---

# ADR-004: 心愿总体进度的分母

## Status

Accepted

## Context

PRD FR-017 写“总体进度 = 已完成条件数量 / 条件总数量”，DEVELOPMENT_PLAN TASK-606 与 ARCHITECTURE 写“已完成必需条件数量 / 必需条件总数”。MVP 下所有条件默认为必需，两种算法结果相同；但一旦引入可选条件就会分叉。

## Decision

- 总体进度的分母统一为**必需条件总数**。
- 总体进度 = 已完成必需条件数 / 必需条件总数。
- 没有必需条件时，总体进度显示为“未配置”，数值为 0，且心愿不能自动解锁。
- 总体进度只用于展示，不作为解锁判断依据；解锁必须逐项检查必需条件的真实完成状态。
- PRD FR-017 的公式按本决策修订。

## Alternatives

1. 使用全部条件作为分母：会稀释可选条件的影响，且与解锁逻辑不一致。

## Consequences

- 后续若支持可选条件，展示逻辑无需再改。
- PRD 与 DEVELOPMENT_PLAN 的表述需要同步修订。

## Date

2026-11-08

---

# ADR-005: ConditionStatus 与 weight 的取舍

## Status

Accepted

## Context

ARCHITECTURE 的目录结构列出了 `ConditionStatus.swift`，但第 4 章没有定义该枚举；PRD 的 Condition 数据模型包含 `weight` 字段，ARCHITECTURE 的 Condition 属性列表没有该字段。MVP 又不开放条件权重和复杂组合。

## Decision

- **不引入持久化的 `ConditionStatus` 枚举。** 条件的“未开始 / 进行中 / 已完成”是由 `ProgressCalculator` 根据记录实时计算的展示状态，不写入数据库。
- 从 ARCHITECTURE 的目录结构中移除 `ConditionStatus.swift`；如果 UI 需要展示状态，使用 `ProgressSnapshot.isCompleted` 与 `progressRatio` 派生。
- **MVP 移除 `weight` 字段。** 所有条件默认必需且权重相同；保留 `sortOrder` 用于展示排序。
- 如果 V2.1 引入权重，再新增字段并设计迁移。

## Alternatives

1. 保留 `ConditionStatus` 作为持久化字段：会与实时计算出的完成状态形成双重事实源，容易不一致。
2. 保留 `weight` 但不使用：会增加模型噪音和迁移成本。

## Consequences

- PRD §8.3 与 ARCHITECTURE §4.2 需要同步修订。
- 条件完成状态只有一个事实源：ProgressRecord + ProgressCalculator。

## Date

2026-11-08

---

# ADR-006: MVP 是否实现 User 实体

## Status

Accepted

## Context

PRD §8.1 建议预留 `User` 概念，使用本地匿名用户；但 ARCHITECTURE 的领域模型没有 User，MVP 也不要求登录和云同步。

## Decision

- MVP **不实现 User 实体**，使用本地单用户模型；所有 Wish 直接属于当前安装实例。
- PRD 中的 User 表视为后续云端同步的预留设计，不在 MVP 建表。
- 如果后续引入多用户或 iCloud，再增加 `UserProfile` 与 `userID` 迁移。

## Alternatives

1. 现在就建一个本地匿名 User：增加无实际收益的模型与查询复杂度。

## Consequences

- 数据模型更精简。
- 未来加多用户时需要进行一次 schema 迁移，需在 ARCHITECTURE 中记录。

## Date

2026-11-08

---

# ADR-007: 枚举存储值与显示值

## Status

Accepted

## Context

PRD 用大写形式描述状态（如 `ACTIVE`），ARCHITECTURE 的 Swift 枚举使用小写 rawValue（如 `active`）。如果不统一，持久化值和 UI 映射容易混乱。

## Decision

- 持久化与代码中使用 ARCHITECTURE 定义的小写 rawValue（`active`、`unlocked`、`completed`、`paused`、`archived`、`count`、`duration`、`amount`、`streak`、`checkpoint`、`custom` 等）。
- UI 层通过统一的本地化映射显示中文标签，不在 View 中散落字符串。
- 数据迁移时以 rawValue 为准，不依赖枚举的 `CaseIterable` 顺序。

## Alternatives

1. 使用大写 rawValue：与 ARCHITECTURE 现有定义冲突，需要更大范围修改。

## Consequences

- PRD 的大写名称仅作为业务概念，不直接作为存储值。
- 所有枚举集中定义，避免各模块自行映射。

## Date

2026-11-08

---

# ADR-008: 金额精度与舍入

## Status

Accepted

## Context

PRD 要求金额使用 `Decimal` 或最小货币单位整数，禁止浮点数；但没有明确 MVP 的币种、精度和舍入规则。

## Decision

- 金额统一使用 `Decimal`。
- MVP 默认币种为 CNY，金额保留两位小数。
- 用户输入金额时按“四舍五入到分”处理；累计过程中不逐步舍入，只在最终展示时格式化。
- 金额格式化统一走一个 Formatter / 工具，不在各页面重复实现。
- 不支持多币种换算；`currencyCode` 字段保留，MVP 固定为 `CNY`。

## Alternatives

1. 使用最小货币单位整数（分）：精度可靠，但与 SwiftData `Decimal` 模型和现有字段定义不一致，MVP 不采用。

## Consequences

- 所有金额相关测试必须覆盖小数累计、舍入边界和零值。
- 未来支持多币种时，需要重新设计精度与舍入策略。

## Date

2026-11-08

---

# ADR-009: 行动记录规则

## Status

Accepted

## Context

Phase 5 需要统一六种条件的记录语义。PRD 对 COUNT / DURATION / AMOUNT / STREAK / CHECKPOINT / CUSTOM 的记录方式描述不完全一致，尤其是时长单位与重复记录，需要在实现前收敛。

## Decision

- DURATION 的记录值与条件目标值使用同一单位，MVP 不做小时 / 分钟自动换算；UI 按条件的 `unit` 输入与展示。
- STREAK 每自然日最多一条有效记录，记录值固定为 1；按用户本地时区判断自然日，暂停区间不产生打卡要求。
- CHECKPOINT 只允许一条完成记录，记录值固定为 1；删除记录后条件回到未完成。
- COUNT / CUSTOM 记录值必须大于 0；AMOUNT 记录值允许 0，不允许负数。
- 不允许记录未来日期（超过用户本地当天结束时间）。
- 记录的新增、修改、删除都由 `ProgressRecordService` 统一校验；修改或删除后由进度计算重新得出条件状态。
- 暂不强制 COUNT 为整数，UI 使用 decimalPad；后续如需整数可在服务层收紧。

## Alternatives

1. DURATION 统一换算为分钟存储：需要迁移已有条件与 UI，MVP 不采用。
2. CHECKPOINT 允许重复记录：会产生冗余数据，不采用。

## Consequences

- 每个条件的单位在其生命周期内保持一致；修改条件单位需同步考虑已有记录。
- 同一自然日的重复打卡由服务层拒绝，UI 显示可理解的错误。
- 未来若引入时长换算，需要增加迁移与数据兼容处理。

## Date

2026-11-08

---

# ADR-010: 解锁与历史事件规则

## Status

Accepted

## Context

PRD 要求自动解锁、保留历史解锁事件，并且不静默撤销已经发生的奖励。行动记录和条件在解锁后仍可能被修改或删除，需要明确这些操作对心愿状态和解锁事件的影响。

## Decision

- 每次新增或修改行动记录后，重新评估对应心愿是否满足解锁条件。
- 条件的创建、修改、删除后也重新评估解锁；删除记录不会触发新的解锁（删除只能降低进度）。
- 只有所有必需条件都完成、且心愿处于 `active` 时才会生成解锁事件。
- 解锁事件只追加，不因后续记录或条件变化而删除。
- 心愿一旦 `unlocked` 或 `completed`，后续记录 / 条件变更不自动回退状态，也不撤销兑现记录；界面展示当前条件状态供用户参考。
- 总体进度只用于展示，解锁判断必须逐项检查必需条件。
- 解锁事件写入与心愿状态更新分两步保存；如果事件已写入但状态更新失败，下次评估会补写状态。
- 解锁庆祝页在心愿状态从非 `unlocked` 变为 `unlocked` 时触发；首次加载已解锁心愿不重复庆祝。

## Alternatives

1. 删除记录后自动回退为 `active`：会让用户丢失已获得的奖励事实，违反 PRD，不采用。
2. 只依赖总体进度判断解锁：无法处理必需条件与部分完成条件，且 PRD 明确禁止，不采用。

## Consequences

- 解锁事件是激励历史的唯一事实来源。
- 条件被删除后，历史解锁仍然有效；UI 需要允许没有条件的已解锁心愿存在。
- 后续若需要撤销解锁，必须设计显式的管理流程，而不是静默回退。

## Date

2026-11-08

---

# 仍待决定（不阻塞 Phase 0–2）

| 事项 | 最晚决定时间 | 说明 |
|---|---|---|
| App 正式名称、Bundle Identifier、App 图标 | Phase 0 | 当前使用 WishEarn 作为占位 |
| 是否只支持中文界面 | Phase 7 | MVP 可先中文，后续再做本地化 |
| 本地通知策略（提醒时间、频率） | Phase 7 | PRD 只列为后续增强，MVP 可不实现 |
| 数据导出文件格式 | Phase 9 | DEVELOPMENT_PLAN TASK-902 要求基础 JSON 导出 |
| 隐私说明与 App Store 文案 | Phase 9 | 上架前完成 |
