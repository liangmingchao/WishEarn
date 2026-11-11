# Editorial Paper v1 — 七个核心页面

Captured on iPhone 18 Pro Simulator (iOS 27.2), Debug build. The unlock
screenshots come from `CriticalJourneyUITests` using the `-ui-testing`
in-memory store and data created through the shipping UI; the other pages use
the same manual flow. No screenshot-only seeding hook ships in the app.

## Light

| Page | File |
|---|---|
| 心愿列表 | `list-light.png` |
| 心愿详情 | `detail-light.png` |
| 今天 | `today-light.png` |
| 新建心愿 | `editor-light.png` |
| 解锁庆祝（已达成） | `unlock-light.png` |
| 解锁庆祝（已领取） | `unlock-claimed-light.png` |
| 成就 | `achievements-light.png` |
| 我的 | `settings-light.png` |

## Dark

| Page | File |
|---|---|
| 心愿列表 | `list-dark.png` |
| 心愿详情 | `detail-dark.png` |
| 今天 | `today-dark.png` |

## 与上一版的差异

- 画布由 Violet 配色的奶油白 + 紫色主行动，改为暖纸白 + 墨黑行动 + 薄荷状态。
- 衬线标题改为系统无衬线 semibold，负字距。
- 卡片 + 阴影改为留白 + 0.5pt 分隔线；`CardModifier` 全局去掉投影。
- iOS 26 悬浮玻璃 Tab 栏改为自绘平铺栏（push 后自动隐藏）。
- 用户图片取代插画成为主视觉；首页 lead card 优先选择带照片的心愿。
- 表单字段改为「小标 + 下划线输入」，不再使用填充圆角框。
- 解锁庆祝改为两阶段纸张证书：已达成（照片 + 印章 + 一次性星屑）→ 已领取（回执 + 完成），主行动固定在底部安全区。
- 记录编辑器：COUNT / CUSTOM 新记录预填 1；DURATION / AMOUNT 保持空白，编辑记录保留原值。

## 未覆盖

- 成就 / 设置 / 编辑器的深色截图（token 已由对比度测试覆盖）。
- 条件详情页与记录编辑器的单独截图；记录默认值由 `RecordEditorViewModelTests` 覆盖。
- 解锁庆祝的 Dark 截图；已提供 Light 截图与 Accessibility Text Preview。
