# WishEarn

通过行动解锁心愿奖励的个人激励 iOS App。

**核心循环：** 心愿创建 → 条件设定 → 持续行动 → 进度追踪 → 心愿解锁 → 奖励兑现。

## 项目指导文档

所有开发（包括 AI Coding）都必须以以下四份文档为唯一依据：

| 文档 | 内容 | 路径 |
|---|---|---|
| 产品需求文档（PRD） | 产品定位、功能需求、业务规则、数据模型、验收标准、AI Coding 规范 | [docs/PRD.md](docs/PRD.md) |
| 技术架构设计文档 | 分层架构、目录结构、领域模型、核心服务、Repository、测试架构、架构约束 | [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) |
| 开发实施计划（DEVELOPMENT_PLAN） | 阶段划分、任务依赖、每个任务的交付物与验收标准、质量门禁 | [docs/DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) |
| AI 开发规则（AI_RULES） | 上下文管理、编码规范、架构约束、任务执行、测试、Git、Code Review、跨会话交接 | [docs/AI_RULES.md](docs/AI_RULES.md) |

冲突时的处理：产品行为以 PRD / DECISIONS 为准，技术架构以 ARCHITECTURE 为准，任务顺序与验收以 DEVELOPMENT_PLAN 为准，AI 的工作方式以 AI_RULES 为准。详细优先级与冲突处理见 [AI_RULES 第 0.1 / 1.2 节](docs/AI_RULES.md)。

## 工程协作文档

| 文件 | 作用 |
|---|---|
| [CLAUDE.md](CLAUDE.md) | Claude Code 等 AI 工具的项目入口、必读顺序与硬性约束 |
| [PROJECT_STATUS.md](PROJECT_STATUS.md) | 项目进度与验证状态的唯一事实源 |
| [DECISIONS.md](DECISIONS.md) | 已确认的产品 / 架构决策（ADR-001 ～ ADR-008） |
| [CHANGELOG.md](CHANGELOG.md) | 版本变更记录 |

## 当前阶段

**Phase 3 — 心愿管理。** Phase 0–2 已完成：工程骨架、四 Tab、设计系统、错误处理、领域模型与 SwiftData 持久化均已就绪。详见 [PROJECT_STATUS.md](PROJECT_STATUS.md)。

## 技术栈（MVP）

- 平台：iOS 17+
- 语言 / UI：Swift + SwiftUI
- 持久化：SwiftData（Local-first，无服务端）
- 架构模式：MVVM + Repository + Domain Service
- 测试：XCTest / Swift Testing

## 开发方式

按 [DEVELOPMENT_PLAN](docs/DEVELOPMENT_PLAN.md) 的 Phase 0–9 逐阶段推进，按 [AI_RULES](docs/AI_RULES.md) 的任务执行规范工作，不允许一次性生成整个 App。每个任务完成后必须汇报：

1. 本次实现内容
2. 修改和新增的文件
3. 核心设计说明
4. 编译结果
5. 单元测试结果（实际执行情况）
6. 尚未解决的问题
7. 下一步计划

代码生成完成不等于任务完成，必须满足 AI_RULES 第 22 节的 Definition of Done。

## 文档来源

- 第一轮完整讨论（产品、架构、开发计划与 AI 规范）：[ChatGPT 分享对话「设计奖励心愿App」](https://chatgpt.com/share/6af055aa-6378-83ea-8507-eaff92d04eaa)
- 第二轮讨论（AI 规范完善）：[ChatGPT 分享对话「继续完善AI规范」](https://chatgpt.com/share/6af056e0-57f8-83e9-903f-a337b51cb1d4)
- 早期分享链接（内容已包含在第一轮中）：[设计奖励心愿App](https://chatgpt.com/share/6af04420-4cb8-83ea-be37-814592261e9f)
- 导出时间：2026-11-08
- 文档版本：PRD V1.0 / ARCHITECTURE V1.1 / DEVELOPMENT_PLAN V1.1 / AI_RULES V1.1
