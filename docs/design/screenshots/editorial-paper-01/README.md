# Editorial Paper v1 — 七个核心页面

Captured on iPhone 18 Pro Simulator (iOS 27.2), Debug build. Data came from a
temporary in-memory seeding hook that was removed before the commit; reproduce
by creating a few wishes with conditions and records in the simulator.

## Light

| Page | File |
|---|---|
| 心愿列表 | `list-light.png` |
| 心愿详情 | `detail-light.png` |
| 今天 | `today-light.png` |
| 新建心愿 | `editor-light.png` |
| 解锁庆祝 | `unlock-light.png` |
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

## 未覆盖

- 成就 / 设置 / 编辑器的深色截图（token 已由对比度测试覆盖）。
- 条件详情页与记录编辑器的单独截图。
