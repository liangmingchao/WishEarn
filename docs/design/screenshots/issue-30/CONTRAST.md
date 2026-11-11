# Issue #30 — 对比度验证报告（Paper & Sage 修订）

> 生成方式：`DesignSystemTests.testContrastAuditReport`
> 运行命令：
> ```bash
> xcodebuild test -project WishEarn.xcodeproj -scheme WishEarn \
>   -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
>   -derivedDataPath build/Issue30DD \
>   -only-testing:WishEarnTests/DesignSystemTests/testContrastAuditReport \
>   CODE_SIGNING_ALLOWED=NO
> ```
> 日期：2026-11-11；结果：**全部 PASS**。
>
> 阈值：正文 / 普通文字 `>= 4.5:1`，大字 / 大号标题 `>= 3:1`。主题 tint / softTint 仅用于装饰与占位图，仍分别按 4.5:1 / 3:1 验证。
> 计算方式：WCAG 2.x sRGB 相对亮度与 `(L1 + 0.05) / (L2 + 0.05)`；Light / Dark 分别用 `UITraitCollection(userInterfaceStyle:)` 解析动态颜色。

## 1. Token 色值

| Token | Light | Dark |
|---|---|---|
| canvasTop | `#FAF8F3` | `#171815` |
| canvasBottom | `#F3F0E8` | `#1D1E1A` |
| surface | `#FFFFFF` | `#232420` |
| elevated | `#FFFDF8` | `#2B2C27` |
| surfaceSecondary | `#F1EEE6` | `#2E2F2A` |
| textPrimary | `#24251F` | `#F3F1E9` |
| textSecondary | `#5E6056` | `#C3C0B5` |
| textTertiary | `#67695F` | `#A7A498` |
| primary | `#3C6252` | `#9CC6B1` |
| primaryPressed | `#2E4D40` | `#87B29D` |
| primarySoft | `#E7EFE9` | `#293A32` |
| onPrimary | `#FFFFFF` | `#14201A` |
| clay | `#A25C42` | `#D99C82` |
| claySoft | `#F3E7DF` | `#3A2B25` |
| clayText | `#84442E` | `#E7B39B` |
| onClay | `#FFFFFF` | `#17110E` |
| success | `#2F6B4F` | `#7BC6A3` |
| successSoft | `#E6F0EA` | `#1E3A2D` |
| warning | `#8A5A18` | `#E0B368` |
| danger | `#B4454E` | `#F09AA3` |
| separator | `#E7E2D8` | `#393A34` |
| progressTrack | `#ECE7DD` | `#363732` |

### Wish Theme（低饱和主题；不用于大面积卡片底色）

| Theme | Light tint | Dark tint | Light container | Dark container | Light label | Dark label |
|---|---|---|---|---|---|---|
| Sage | `#9DB9A7` | `#9DB9A7` | `#EEF2EA` | `#242F29` | `#3E6654` | `#A9CBB8` |
| Clay | `#C99A80` | `#C99A80` | `#F6EEE8` | `#302620` | `#83452F` | `#DFAC93` |
| Stone | `#B9B6A8` | `#B2AFA1` | `#F2F1EB` | `#2B2C27` | `#5A5C53` | `#C0C2B7` |

## 2. 实测结果

| Pair | Light | Dark | 阈值 | 结果 |
|---|---:|---:|---:|---|
| textPrimary / canvasTop | 14.55 | 15.76 | 7.0 | PASS |
| textPrimary / canvasBottom | 13.56 | 14.82 | 7.0 | PASS |
| textSecondary / canvasTop | 6.03 | 9.79 | 4.5 | PASS |
| textSecondary / canvasBottom | 5.62 | 9.20 | 4.5 | PASS |
| textTertiary / canvasTop | 5.26 | 7.14 | 4.5 | PASS |
| textTertiary / canvasBottom | 4.90 | 6.71 | 4.5 | PASS |
| textPrimary / surface | 15.45 | 13.81 | 7.0 | PASS |
| textSecondary / surface | 6.40 | 8.57 | 4.5 | PASS |
| textTertiary / surface | 5.58 | 6.25 | 4.5 | PASS |
| primary / canvas | 6.46 | 9.45 | 4.5 | PASS |
| primary / surface | 6.86 | 8.27 | 4.5 | PASS |
| primary / primarySoft | 5.85 | 6.37 | 4.5 | PASS |
| onPrimary / primary | 6.86 | 8.89 | 4.5 | PASS |
| onPrimary / primaryPressed | 9.33 | 7.10 | 4.5 | PASS |
| onClay / clay | 5.07 | 8.04 | 4.5 | PASS |
| clayText / canvas | 6.95 | 9.61 | 4.5 | PASS |
| clayText / surface | 7.38 | 8.42 | 4.5 | PASS |
| clayText / claySoft | 6.08 | 7.29 | 4.5 | PASS |
| success / canvas | 5.93 | 8.87 | 4.5 | PASS |
| success / surface | 6.29 | 7.77 | 4.5 | PASS |
| warning / canvas | 5.56 | 9.18 | 4.5 | PASS |
| warning / surface | 5.90 | 8.04 | 4.5 | PASS |
| danger / canvas | 5.07 | 8.37 | 4.5 | PASS |
| danger / surface | 5.38 | 7.33 | 4.5 | PASS |
| onContainer / container sage | 13.63 | 10.40 | 4.5 | PASS |
| labelText / surface sage | 6.49 | 8.87 | 4.5 | PASS |
| onTint / tint sage | 7.31 | 8.68 | 4.5 | PASS |
| onSoftTint / softTint sage | 13.17 | 9.50 | 3.0 | PASS |
| onContainer / container clay | 13.47 | 10.41 | 4.5 | PASS |
| labelText / surface clay | 7.35 | 7.78 | 4.5 | PASS |
| onTint / tint clay | 6.49 | 6.49 | 4.5 | PASS |
| onSoftTint / softTint clay | 12.73 | 10.20 | 3.0 | PASS |
| onContainer / container stone | 13.65 | 10.33 | 4.5 | PASS |
| labelText / surface stone | 6.80 | 8.66 | 4.5 | PASS |
| onTint / tint stone | 7.59 | 7.11 | 4.5 | PASS |
| onSoftTint / softTint stone | 13.28 | 10.33 | 3.0 | PASS |

## 3. 覆盖面说明

- 画布是 `canvasTop -> canvasBottom` 的极轻纸感渐变；两个端点分别测试，正文 / 次级 / 三级文字均通过。
- 主行动按钮改为纯色 `primary`（悬停/按压为 `primaryPressed`），不再使用渐变；`onPrimary` 对两者分别验证。
- 每个 Wish Theme 只保留三种低饱和色调，并验证四组组合：`onContainer/container`、`labelText/surface`、`onTint/tint`、`onSoftTint/softTint`。
- 首页卡片全部使用 `surface` 纸面，主题只作为 3–4pt 短标记和占位图洗色出现；文字对比度不再依赖主题容器。
- 语义状态色（success / warning / danger）同时验证在 canvas 与 surface 上的文字对比度。
- 照片上的状态胶囊使用实底 `surface`，因此不依赖任意照片背景。
- 对比度测试覆盖代码中的实际 token，不依赖手工抄写色值。
