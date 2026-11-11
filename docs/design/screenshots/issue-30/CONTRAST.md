# Issue #30 — 对比度验证报告

> 生成方式：`DesignSystemTests.testContrastAuditReport`
> 运行命令：
> ```bash
> xcodebuild test -project WishEarn.xcodeproj -scheme WishEarn \
>   -destination 'platform=iOS Simulator,name=iPhone 18 Pro' \
>   -derivedDataPath build/DerivedData \
>   -only-testing:WishEarnTests/DesignSystemTests/testContrastAuditReport \
>   CODE_SIGNING_ALLOWED=NO
> ```
> 日期：2026-11-11；结果：**全部 PASS**。
>
> 阈值：正文 / 普通文字 `>= 4.5:1`，大字 / 大号标题 `>= 3:1`（本表对主题小标记与占位图前景使用 4.5:1，软底占位图使用 3:1）。
> 计算方式：WCAG 2.x sRGB 相对亮度与 `(L1 + 0.05) / (L2 + 0.05)`；Light / Dark 分别用 `UITraitCollection(userInterfaceStyle:)` 解析动态颜色。

## 1. Token 色值

| Token | Light | Dark |
|---|---|---|
| canvasTop | `#FFF9F1` | `#171725` |
| canvasBottom | `#F5F0FF` | `#1B1928` |
| surface | `#FFFFFF` | `#222235` |
| elevated | `#FFFDF9` | `#2C2B42` |
| surfaceSecondary | `#F7EFE5` | `#2A293D` |
| textPrimary | `#2E3040` | `#F7F3FF` |
| textSecondary | `#6A6878` | `#C2BED2` |
| textTertiary | `#6C6978` | `#A19CB5` |
| primary | `#6554C0` | `#A99AFF` |
| primaryPressed | `#5142A8` | `#8F7EE8` |
| primaryGradientStart | `#7060CE` | `#B7AAFF` |
| primaryGradientEnd | `#6554C0` | `#9C8CF5` |
| primarySoft | `#EFEBFF` | `#352F55` |
| onPrimary | `#FFFFFF` | `#171725` |
| coral | `#FF806B` | `#FF9A86` |
| coralSoft | `#FFE6E0` | `#4B2A2E` |
| coralText | `#B5412F` | `#FF9A86` |
| onCoral | `#2E3040` | `#171725` |
| success | `#2F7F57` | `#7BD3A6` |
| successSoft | `#E7F4ED` | `#1F3A2C` |
| warning | `#A06017` | `#E5B86E` |
| danger | `#C24751` | `#FF9AA5` |
| separator | `#ECE4DA` | `#3A3852` |
| progressTrack | `#F0E8DE` | `#38364E` |

### Wish Theme（Light 使用主题实底；Dark 使用深色容器）

| Theme | Light container | Dark container | Light text | Dark text |
|---|---|---|---|---|
| Butter | `#FFD66E` | `#3A3427` | `#2E3040` | `#F6D57B` |
| Mint | `#A8E3CF` | `#223B33` | `#2E3040` | `#9BDFC7` |
| Sky | `#A9D7F2` | `#22343F` | `#2E3040` | `#9CCBEA` |
| Blush | `#F6C6D1` | `#3B2B31` | `#2E3040` | `#F3B9C8` |
| Lavender | `#DCD4FF` | `#302C45` | `#2E3040` | `#C9BEFF` |
| Peach | `#FFE0D2` | `#3B2D27` | `#2E3040` | `#F8CBB7` |

## 2. 实测结果

| Pair | Light | Dark | 阈值 | 结果 |
|---|---:|---:|---:|---|
| textPrimary / canvasTop | 12.44 | 16.21 | 7.0 | PASS |
| textPrimary / canvasBottom | 11.65 | 15.80 | 7.0 | PASS |
| textSecondary / canvasTop | 5.19 | 9.77 | 4.5 | PASS |
| textSecondary / canvasBottom | 4.86 | 9.53 | 4.5 | PASS |
| textTertiary / canvasTop | 5.11 | 6.69 | 4.5 | PASS |
| textTertiary / canvasBottom | 4.78 | 6.53 | 4.5 | PASS |
| textPrimary / surface | 13.02 | 14.25 | 7.0 | PASS |
| textSecondary / surface | 5.43 | 8.60 | 4.5 | PASS |
| textTertiary / surface | 5.34 | 5.89 | 4.5 | PASS |
| primary / canvas | 5.60 | 7.38 | 4.5 | PASS |
| primary / surface | 5.86 | 6.49 | 4.5 | PASS |
| primary / primarySoft | 5.02 | 5.18 | 4.5 | PASS |
| onPrimary / primary | 5.86 | 7.38 | 4.5 | PASS |
| onPrimary / primaryGradientStart | 4.94 | 8.61 | 4.5 | PASS |
| onPrimary / primaryGradientEnd | 5.86 | 6.31 | 4.5 | PASS |
| onCoral / coral | 5.30 | 8.62 | 4.5 | PASS |
| coralText / canvas | 5.34 | 8.62 | 4.5 | PASS |
| coralText / coralSoft | 4.69 | 6.12 | 4.5 | PASS |
| success / canvas | 4.67 | 9.88 | 4.5 | PASS |
| success / surface | 4.89 | 8.69 | 4.5 | PASS |
| warning / canvas | 4.80 | 9.63 | 4.5 | PASS |
| warning / surface | 5.02 | 8.47 | 4.5 | PASS |
| danger / canvas | 4.65 | 8.79 | 4.5 | PASS |
| danger / surface | 4.87 | 7.73 | 4.5 | PASS |
| onContainer / container butter | 9.36 | 8.66 | 4.5 | PASS |
| labelText / surface butter | 5.37 | 10.92 | 4.5 | PASS |
| onTint / tint butter | 9.36 | 12.42 | 4.5 | PASS |
| onSoftTint / softTint butter | 11.49 | 8.66 | 3.0 | PASS |
| onContainer / container mint | 9.02 | 7.91 | 4.5 | PASS |
| labelText / surface mint | 6.42 | 10.22 | 4.5 | PASS |
| onTint / tint mint | 9.02 | 11.62 | 4.5 | PASS |
| onSoftTint / softTint mint | 11.21 | 7.91 | 3.0 | PASS |
| onContainer / container sky | 8.49 | 7.45 | 4.5 | PASS |
| labelText / surface sky | 6.95 | 9.01 | 4.5 | PASS |
| onTint / tint sky | 8.49 | 10.24 | 4.5 | PASS |
| onSoftTint / softTint sky | 11.00 | 7.45 | 3.0 | PASS |
| onContainer / container blush | 8.63 | 7.99 | 4.5 | PASS |
| labelText / surface blush | 6.64 | 9.33 | 4.5 | PASS |
| onTint / tint blush | 8.63 | 10.61 | 4.5 | PASS |
| onSoftTint / softTint blush | 10.70 | 7.99 | 3.0 | PASS |
| onContainer / container lavender | 9.24 | 7.82 | 4.5 | PASS |
| labelText / surface lavender | 7.66 | 9.12 | 4.5 | PASS |
| onTint / tint lavender | 9.24 | 10.37 | 4.5 | PASS |
| onSoftTint / softTint lavender | 11.03 | 7.82 | 3.0 | PASS |
| onContainer / container peach | 10.44 | 8.94 | 4.5 | PASS |
| labelText / surface peach | 6.09 | 10.55 | 4.5 | PASS |
| onTint / tint peach | 10.44 | 11.99 | 4.5 | PASS |
| onSoftTint / softTint peach | 11.71 | 8.94 | 3.0 | PASS |

## 3. 覆盖面说明

- 画布不是单一纯色，而是 `canvasTop -> canvasBottom` 的极轻渐变；两个端点分别测试，正文 / 次级 / 三级文字均通过。
- 品牌主行动按钮使用 `primaryGradientStart -> primaryGradientEnd` 渐变；`onPrimary` 对两个端点分别验证。
- 每个 Wish Theme 验证四组组合：`onContainer/container`（大卡片正文）、`labelText/surface`（中性表面上的主题小标签）、`onTint/tint`（图标底板）、`onSoftTint/softTint`（占位图洗色）。
- 语义状态色（success / warning / danger）同时验证在 canvas 与 surface 上的文字对比度。
- 未在图片上叠加需要阅读的业务文本；照片上的状态胶囊使用实底 `surface`，因此不依赖任意照片背景。
- 对比度测试覆盖代码中的实际 token，不依赖手工抄写色值。
