# WishEarn — Claude Code 开发入口

本文件是 Claude Code 等 AI Coding 工具的项目入口。详细规范以 [docs/AI_RULES.md](docs/AI_RULES.md) 为准；若本文件与权威文档冲突，以 `docs/` 下的对应文档为准。

## 项目一句话

WishEarn 是一个通过行动解锁心愿奖励的 iOS App：Swift + SwiftUI + SwiftData，iOS 17+，Local-first，无服务端。

## 每次任务开始前必读

1. [docs/AI_RULES.md](docs/AI_RULES.md)
2. [PROJECT_STATUS.md](PROJECT_STATUS.md)
3. [DECISIONS.md](DECISIONS.md)
4. 与本任务相关的 [docs/PRD.md](docs/PRD.md) 和 [docs/ARCHITECTURE.md](docs/ARCHITECTURE.md) 章节
5. [docs/DEVELOPMENT_PLAN.md](docs/DEVELOPMENT_PLAN.md) 中对应的任务条目
6. 当前代码、测试与 Git 状态

不要只凭聊天上下文推断项目状态，以仓库中的实际代码和文档为准。

## 文档优先级

1. 用户当前明确指令
2. PRD 业务规则 + DECISIONS.md 已确认决策
3. ARCHITECTURE 架构约束
4. DEVELOPMENT_PLAN 任务顺序与验收标准
5. AI_RULES 工程规范
6. AI 自己的实现偏好

发现冲突时先说明冲突、影响范围和推荐方案，等待确认；不得静默修改权威文档来让当前实现看起来合理。

## 硬性约束

- 不擅自改变产品规则、状态机、数据模型或技术栈。
- 业务逻辑不得写在 SwiftUI View 中；不得绕过 Repository / Domain Service。
- 核心计算（进度、连续天数、解锁）只能有统一入口。
- 金额使用 `Decimal`，不得用 `Double` 累计；日期计算使用 `Calendar`，不得用 86400 秒近似自然日。
- 解锁必须幂等，不得重复生成解锁事件。
- 不使用模拟数据冒充真实功能，不虚报编译或测试结果。
- 每次任务只做一个明确边界；完成后必须编译、运行相关测试、更新 `PROJECT_STATUS.md` 和 `CHANGELOG.md`。

## 当前阶段

Phase 9：发布准备。详见 [PROJECT_STATUS.md](PROJECT_STATUS.md)。

## 工程与命令

- 工程：`WishEarn.xcodeproj`
- Scheme：`WishEarn`（含 `WishEarnTests`）
- 源码根目录：`WishEarn/`
- 工程配置：`project.yml`（修改后运行 `xcodegen generate`）
- Bundle Identifier：`com.wishearn.app`（占位）
- Deployment Target：iOS 17.0
- Swift 语言模式：Swift 5

构建：

```bash
xcodebuild -project WishEarn.xcodeproj -scheme WishEarn \
  -destination 'generic/platform=iOS Simulator' \
  -derivedDataPath build/DerivedData build CODE_SIGNING_ALLOWED=NO
```

测试：

```bash
xcodebuild test -project WishEarn.xcodeproj -scheme WishEarn \
  -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
  -derivedDataPath build/DerivedData CODE_SIGNING_ALLOWED=NO
```

模拟器运行：

```bash
xcrun simctl boot "iPhone 18 Pro"
xcrun simctl install "iPhone 18 Pro" build/DerivedData/Build/Products/Debug-iphonesimulator/WishEarn.app
xcrun simctl launch "iPhone 18 Pro" com.wishearn.app
```

## 任务交付格式

```markdown
## 本次任务

## 实现内容

## 修改文件

## 测试结果
- Build:
- Unit Tests:
- UI Tests:

## Review 结果

## 文档更新

## 遗留问题

## 下一步
```

代码生成完成不等于任务完成；必须满足 [AI_RULES 第 22 节 Definition of Done](docs/AI_RULES.md)。
