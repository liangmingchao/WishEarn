# WishEarn — App Store 上架材料

**版本：** 0.15.0  
**状态：** RC QA — **NO-GO / 上架材料未完成**
**最后更新：** 2026-11-10
**平台：** iPhone（iOS 17+）

## 基本信息

| 项目 | 内容 |
|---|---|
| App 名称 | WishEarn（**PENDING**，暂定） |
| 副标题 | 用行动解锁心愿奖励 |
| 主分类 | 生活 |
| 次分类 | 效率 |
| 年龄分级 | 4+ |
| 价格 | 免费（MVP） |
| 支持语言 | 简体中文（**PENDING** 最终确认） |
| Bundle ID | com.wishearn.app（**PENDING**，占位，上架前确认） |

## 应用描述

WishEarn 是一个把「想要」变成「努力」的个人激励工具。

把想买的东西记成心愿，为它设定自己的解锁条件：健身 20 次、连续 30 天不吃零食、兼职收入累计 5000 元……每次行动都记录在案，进度一点点靠近，全部条件完成时，心愿自动解锁。

你可以：

- 创建心愿，添加图片、参考价格和目标日期
- 用六种条件类型定义自己的努力方式
- 记录每一次行动，查看历史与今日待办
- 在心愿解锁时获得专属庆祝
- 在成就页回顾已经兑现的奖励

WishEarn 采用本地优先设计，心愿与行动记录只保存在你的设备上，不需要注册账号。

## 关键词

心愿,奖励,自律,习惯,目标,打卡,激励,心愿单,储蓄,成长

## 隐私说明

- 不收集、不上传任何个人数据。
- 心愿、条件、行动记录与图片仅保存在当前设备。
- 不接入第三方分析、广告或追踪 SDK。
- 已提供 `PrivacyInfo.xcprivacy`，声明不追踪、不收集数据。

## 截图清单

当前仅完成设计与 QA 用截图，**不是 App Store 提交素材**：

- 设计 QA 截图：`docs/design/screenshots/issue-21/`
- 覆盖 Home / Detail / Today / Editor / Unlock / Achievements / Settings 的 Light / Dark。
- 提交前仍需按 App Store 尺寸、文案和排序重新制作截图与预览视频。

建议使用 iPhone 17 / 18 Pro 尺寸截图，并准备深色模式版本。

## 待确认 / 阻塞项

| 项目 | 状态 |
|---|---|
| App 正式名称与 Bundle ID | **PENDING / BLOCKED** |
| App 图标最终版本 | **PENDING** — Playful 提案待品牌确认；生产 Asset 仍为旧 Petrol |
| App Store 截图 / 预览视频 | **PENDING** — 当前只有设计 QA 截图 |
| 支持 URL / 隐私政策 URL / 营销 URL | **PENDING / BLOCKED** |
| 首发语言范围 | **PENDING** — 当前 UI 为简体中文 |
| App Store Connect 应用记录 | **BLOCKED** — 账号 / 凭据未配置 |
| TestFlight 上传与测试 | **BLOCKED** — 账号 / 凭据未配置 |
| CI 绿色门禁 | **BLOCKED** — GitHub Actions billing / spending limit |
| 真机交互验收 | **NOT TESTED** — 当前构建未在设备完成图片选择 / 键盘 / 滚动 / 导航 / 重启 |

App Icon 方案预览：[`docs/design/assets/app-icon-playful-proposal.png`](design/assets/app-icon-playful-proposal.png)（未接入生产资产）。

## 发布结论

当前为 **NO-GO**，不得提交 App Store 或 TestFlight。详见 [`docs/qa/ISSUE_22_RC_REPORT.md`](qa/ISSUE_22_RC_REPORT.md) 与 [`docs/RELEASE_CHECKLIST.md`](RELEASE_CHECKLIST.md)。
