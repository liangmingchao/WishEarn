# Issue #30 — Visual Identity & UI Composition Refinement

> Status: implemented on branch, PR pending review (not merged)
> Branch: `design/issue-30-visual-identity-refinement`
> Base: `main` @ `16f390c`
> Reference: `docs/design/references/issue-30-colorful-lifestyle-editorial.svg`
> Date: 2026-11-11

本文件记录开工前的现状诊断、两套可区分方向、最终选择与实施映射。落地方案见同分支代码；截图与测试结果见 `docs/design/screenshots/issue-30/` 和 PR。

## 1. 开工前检查

- 工作区：干净；分支 `design/issue-30-visual-identity-refinement`（= `main` @ `16f390c` + 参考图提交 `58da4a6`）。
- PR #29（照片裁剪）变更范围为 `WishEditor*`、`ImageCropService`、`WishPhotoCrop*`、相关测试与文档；本分支不 cherry-pick、不修改这些文件，避免覆盖。
- 已复核 Issue #21 合并后的 `AppTheme`、`WishTheme`、`WishCard`、`WishListView`、`TodayView`、`WishDetailView`、`ConditionRow` 与 `DESIGN_SYSTEM.md`。

## 2. 现状诊断（可定位到代码）

| # | 问题 | 证据 |
|---|---|---|
| 1 | Wish Theme 几乎不可见：首页 Featured 卡只有 4pt 色条 + 76pt 圆点/缩略图底板，主题色无法形成页面节奏 | `WishCard.swift:15`（`WishThemeMark`）、`WishCard.swift:95`（`WishThemeDot`）、`WishCard.swift:179`（76×76 thumbnail） |
| 2 | 首页所有心愿共用同一种「白底 + 细线分隔」纵向模板，Featured 只是同一个形态放大，没有构图差异 | `WishListView.swift:193-242`、`WishCard.swift:13-58`、`WishCard.swift:61-126` |
| 3 | 首页页面框架仍是系统列表：大标题 + 一行统计 + 固定底部筛选条；筛选离内容远、视觉像系统控件 | `WishListView.swift:44`、`WishListView.swift:105-113`、`WishListView.swift:121-142` |
| 4 | Today 顶部只有日期 + 一行标题，缺少当天语境与鼓励；行动项是同一权重的 hairline 行，容易读成 Todo 清单 | `TodayView.swift:60-99`、`TodayView.swift:169-242` |
| 5 | Today 每行的「记录」按钮都是同一个浅紫胶囊，主行动与次要信息没有分层；已完成/已记录行与待行动行只在文案上区分 | `TodayView.swift:225-241`、`TodayView.swift:244-311` |
| 6 | Detail Hero 只是照片 + 4pt 色条 + 标题浮在画布上；条件行是小圆图标 + 列表单元格，缺少心愿的「故事感」 | `WishDetailView.swift:366-444`、`ConditionRow.swift:69-85` |
| 7 | Detail 进度只是标题 + 6pt 进度条；「离心愿还有多远」没有被组织成叙事层级 | `WishDetailView.swift:446-465` |
| 8 | Token 层明确把主题色限制在「小标记 / 占位图 / 图标底板」，设计系统没有授权大块主题色容器，导致实现必然单调 | `WishTheme.swift:6-8`、`DESIGN_SYSTEM.md:46-66` |
| 9 | 筛选 chip 选中态是 `primarySoft + primary`，主按钮是 14pt 圆角实心矩形；品牌识别接近系统默认控件 | `FilterChip.swift:13-28`、`ButtonStyles.swift:3-22` |
| 10 | Dark Mode 中主题色仍是浅色小标记；没有为深色主题设计大面积容器与可读前景 | `WishTheme.swift:27-66` |

## 3. 两套方向

### 方向 A — Sunny Wish Journal（最终选择）

**气质**：温暖纸感的生活方式杂志封面。首页像「本期封面 + 本期其他故事」，Today 像一张当天的手写鼓励卡，Detail 像一篇心愿专题。

**颜色**：暖奶油画布（`#FFF9F1 → #F5F0FF` 极轻渐变）；Violet `#6554C0` 负责品牌行动；Coral `#FF806B` 负责情绪点缀；六种 Wish Theme 作为大面积卡片底色/相框，而不是小圆点。深色模式使用深梅色画布 + 深色主题容器 + 浅色主题文字。

**卡片节奏**：Featured 是「照片 + 主题色相框 + 纸面信息区」的封面卡；第二个心愿是一条整宽的横向主题色 Banner；其余心愿进入双列主题色视觉卡。三种密度明确的节奏，主题各不相同但都用同一套圆角/间距/排版尺度。无照片时用主题色渐变 + 大号线性符号，不伪造图片。

**草图**：

```text
Home
┌ 心愿手账 · 我的心愿 ✦ ────────────── ○ +
│ 正在为 3 个想要的东西努力
│ [ 全部 ][ 进行中 ][ 已解锁 ][ 已兑现 ]
│ ┌───────────────────────────────┐
│ │   （主题色相框）        ★ 贴纸  │
│ │   [       心愿照片 4:3       ]  │
│ │   进行中                 2/3   │
│ │   京都的秋天                   │
│ │   ¥6,000 · 11 月出发           │
│ │   ███████░░░  2/3 项条件       │
│ └───────────────────────────────┘
│ ┌───────────────────────────────┐
│ │ 下一个心愿         ┌────────┐  │  ← 横向主题色 Banner
│ │ 一台新的相机       │  照片  │  │
│ │ 已完成 1 / 3 项    └────────┘  │
│ └───────────────────────────────┘
│ 其他心愿 ✦ 4
│ ┌────────────┐ ┌────────────┐
│ │  [照片]    │ │  [照片]    │       ← 双列主题色卡
│ │  阅读角    │ │  提拉米苏  │
│ │  2/4 条件  │ │  0/3 条件  │
│ └────────────┘ └────────────┘

Today
│ 11月11日 星期三
│ 今天，慢慢来
│ ┌───────────────────────────────┐
│ │ 按自己的节奏，走一小步    ☀    │  ← 暖桃色鼓励卡
│ │ 今天有 3 个小行动，可以推进心愿 │
│ └───────────────────────────────┘
│ 今天可以推进  3
│ ┌───────────────────────────────┐
│ │ ● 京都的秋天                   │
│ │ (图标) 每天读 20 页书    [记录] │  ← 白色行动卡
│ │        连续 2 / 20 天           │
│ └───────────────────────────────┘
│ 今天已记录 · 一组更安静的容器

Detail
│ ┌───────────────────────────────┐
│ │ 我的心愿              进行中   │
│ │  [       心愿照片 16:10      ] │
│ │  京都的秋天                    │
│ │  ¥6,000 · 目标 2026/11/20      │
│ │  ┌─────────────────────────┐  │
│ │  │ 2 / 3 项条件完成         │  │  ← 纸面进度面板
│ │  │ ████████░░              │  │
│ │  └─────────────────────────┘  │
│ └───────────────────────────────┘  ← 主题色故事卡
│ 解锁条件  3                     +
│ ┌───────────────────────────────┐
│ │ (图标) 每天读 20 页书    [记录] │
│ │        连续 2 / 20 天 ███░     │
│ └───────────────────────────────┘
│ 最近的努力 · 一组安静记录卡
```

**风险**：大面积主题色需要严格对比度验证；双列卡片在 Dynamic Type 大字下必须降级为单列；图片相框与贴纸不能遮挡真实照片主体。

### 方向 B — Wish in Bloom（备选）

**气质**：收藏册 / 章节式海报。每个心愿是一章，用大号序号（01、02）、不对称照片与斜切主题色块组成连续的纵向叙事；Today 是编号时间线；Detail 是「章节页」，条件按章节编号。

**颜色**：与 A 共用品牌色，但主题色以「宽色带 + 留白」出现，整体更低饱和、更排版驱动；装饰更少。

**草图**：

```text
Home
┌ 第 01 章 · 京都的秋天 ──────────────┐
│ [ 照片 ]      斜切主题色块            │
│ 01 / 进行中   ███████░░░  2/3        │
│ 「想去看一次真正的秋天。」            │
└──────────────────────────────────────┘
┌ 第 02 章 · 一台新的相机 ─────────────┐
│ 主题色宽色带 + 文字 + 小照片          │
└──────────────────────────────────────┘

Today
│ 01 ── 每天读 20 页书    [记录]
│ 02 ── 存下这个月的旅行基金 [记录]
│ 03 ── 完成一次长距离散步  [记录]

Detail
│ 01 关于这个心愿
│ 02 我正在做的事（条件）
│ 03 走过的路（记录）
```

**风险**：章节序号在大列表里会变成噪音；页面纵向更长，心愿多时检索效率低；不对称斜切在长文案与辅助功能字号下更难稳定；与参考图要求的「双列主题色节奏」偏离。

### 最终选择

选择 **A — Sunny Wish Journal**。理由：

1. 与参考图的「封面卡 + 主题色 Banner + 双列色卡」节奏一致，主题色真正进入页面结构。
2. 照片仍是视觉主角，符合产品「心愿是主角」的定位；B 的章节排版会让序号和色带抢走注意力。
3. 在现有数据与导航结构下可直接落地，不需要改 Domain 或新增功能。
4. 双列卡在辅助功能字号下可降级为单列横向卡，风险可控。

## 4. 实施映射

| 层 | 改动 |
|---|---|
| Token | `AppTheme.swift`：画布渐变、品牌渐变、更深的 light tertiary、`kicker`/`metric`/`editorialTitle` 字体、`AppRadius.xxl`、全局 editorial 背景 |
| Wish Theme | `WishTheme.swift`：新增 `container` / `onContainer`（Light 主题色实底 + Ink；Dark 深色容器 + 浅色文字），保留小标记用途 |
| 组件 | `WishCard.swift` 拆为 Featured / Spotlight / Grid 三种卡片；新增 `EditorialSectionHeader`、`StatusBadge` pill 样式、`WishPhoto`、`WishThemeSticker`；`ProgressIndicator` 增加主题色上下文；`FilterChip` 选中态改为品牌实底；`PrimaryButtonStyle` 改胶囊 |
| Home | `WishListView`：自绘页头、筛选条上移、Featured + Banner + 双列节奏、空状态插画升级 |
| Today | `TodayView`：日期 kicker + 鼓励卡 + 白色行动卡 + 更安静的已完成分组；保留全部现有状态与记录语义 |
| Detail | `WishDetailView`：主题色故事 Hero + 纸面进度面板 + 独立条件卡 + 记录分组；保留 List 的排序/滑动删除 |
| 其它 | Tab bar 配色与背景、按钮/筛选/空状态统一；不改 Domain / Repository / SwiftData / 解锁状态机；不新增功能 |
| App Icon | 仅新增提案图 `docs/design/assets/app-icon-colorful-proposal.png`，不替换生产图标 |

## 5. 验证计划

- Build / Unit / Integration / UI Test 全部真实运行并记录命令与结果；无法运行的项目写 NOT RUN。
- Light / Dark 截图覆盖 Home / Today / Detail，并补长文案状态；截图来自真实模拟器与真实 UI 创建的数据。
- `DesignSystemTests` 扩展：主题容器前景/背景、品牌渐变、画布渐变端点、按钮与筛选组合；正文 ≥ 4.5:1，大字 ≥ 3:1。
- 更新 `DESIGN_SYSTEM.md`、`PROJECT_STATUS.md`、`CHANGELOG.md`；PR 不合并。

## 6. 实施结果（2026-11-11）

- 方向 A 已落地：Featured Wish 使用大图 + 主题色相框；第二个心愿为整宽主题色 Banner；其余心愿进入双列主题色卡；Today 使用暖珊瑚鼓励卡 + 白色行动卡；Detail 使用主题色故事 Hero + 纸面进度面板 + 独立条件卡。
- 主题色现在以 `container` / `onContainer` 参与大面积卡片；Light 使用主题实底 + Ink，Dark 使用深色容器 + 主题浅色文字。
- 首页 / Today / Detail 的 Light / Dark 与长文案截图见 `docs/design/screenshots/issue-30/`；对比度实测见同目录 `CONTRAST.md`（48 组 pair × 2 外观，全部 PASS）。
- 验证：Build PASS；Unit / Integration 275 项 PASS；Critical Journey UI Test PASS；DesignCapture UI Tests 在 CI 默认 skipped，本地 Light / Dark 截图流程 PASS。
- App Icon 仅新增提案 `docs/design/assets/app-icon-colorful-proposal.png`，未替换生产图标；未修改 Domain / Repository / SwiftData / 解锁状态机 / 产品功能。
