# WishEarn Design System

> Status: Active implementation baseline (Colorful Lifestyle Editorial, Issue #30)
> Platform: SwiftUI, iOS 17+
> Principle: Centralized semantic tokens; no per-screen ad hoc styling.

Issue #30 的方向是 **Sunny Wish Journal**：温暖纸感的生活方式杂志。视觉主角是用户照片与心愿；Wish Theme 以大面积卡片容器、图片相框、胶囊标签和进度参与页面节奏，而不是只做小色条。布局允许不同卡片形态，但圆角、间距、阴影、排版与触控目标必须来自同一套 token。

## 1. Foundations

### 1.1 Color tokens

Use semantic names. Values below are the validated implementation baseline; keep roles intact when adjusting.

| Token | Light | Dark | Use |
|---|---|---|---|
| canvasTop | #FFF9F1 | #171725 | 渐变画布起点 |
| canvasBottom | #F5F0FF | #1B1928 | 渐变画布终点 |
| canvas | #FFF9F1 | #171725 | 纯色回退 / 不适用渐变的表面 |
| surface | #FFFFFF | #222235 | 卡片、行、纸面进度面板 |
| elevated | #FFFDF9 | #2C2B42 | 需要抬升的小表面 |
| surfaceSecondary | #F7EFE5 | #2A293D | 输入与安静分组 |
| textPrimary | #2E3040 | #F7F3FF | 主文字 |
| textSecondary | #6A6878 | #C2BED2 | 说明文字 |
| textTertiary | #6C6978 | #A19CB5 | 元信息；在画布渐变两端也保持 4.5:1 |
| primary | #6554C0 | #A99AFF | 品牌行动 / 选中态 / 进度 |
| primaryPressed | #5142A8 | #8F7EE8 | 按下态 |
| primaryGradientStart | #7060CE | #B7AAFF | 主按钮渐变起点（对 onPrimary 复核） |
| primaryGradientEnd | #6554C0 | #9C8CF5 | 主按钮渐变终点 |
| primarySoft | #EFEBFF | #352F55 | 主行动容器 / 记录胶囊 |
| onPrimary | #FFFFFF | #171725 | 主色上的文字 |
| coral | #FF806B | #FF9A86 | 情绪点缀、装饰圆 |
| coralSoft | #FFE6E0 | #4B2A2E | 今日鼓励卡 |
| coralText | #B5412F | #FF9A86 | 珊瑚容器上的文字 |
| onCoral | #2E3040 | #171725 | 珊瑚实底上的文字 |
| success | #2F7F57 | #7BD3A6 | 完成态 |
| successSoft | #E7F4ED | #1F3A2C | 完成态容器 |
| warning | #A06017 | #E5B86E | 暂停 / 注意 |
| danger | #C24751 | #FF9AA5 | 破坏性 / 错误 |
| separator | #ECE4DA | #3A3852 | Hairline / 边框 |
| progressTrack | #F0E8DE | #38364E | 进度轨道 |

Rules:
- Primary 负责品牌交互与进度；每屏只保留一个填充主按钮。
- Coral 只做情绪与重点提示，不替代 success / warning / danger。
- Success 只用于完成态；警告与危险保持语义。
- 不得只靠颜色表达状态；进度与状态必须有文字。
- 画布是 `canvasTop -> canvasBottom` 的极轻渐变；正文与次级文字在两个端点都通过 4.5:1。装饰性光晕（`glowButter` / `glowMint`）只作为背景，不承载文字。
- Dark mode 是独立调色，不是反相；品牌渐变在深色下使用更亮的 Violet。
- `accent` / `accentSoft` / `onAccent` 是 primary 的兼容别名；新代码使用 primary 名称。

### 1.1.1 Wish theme colors

Each wish receives a stable decorative theme derived from its UUID. This is presentation-only and adds no persisted model field.

| Wish theme | Light container | Dark container | Light text | Dark text |
|---|---|---|---|---|
| Butter | #FFD66E | #3A3427 | Ink #2E3040 | #F6D57B |
| Mint | #A8E3CF | #223B33 | Ink #2E3040 | #9BDFC7 |
| Sky | #A9D7F2 | #22343F | Ink #2E3040 | #9CCBEA |
| Blush | #F6C6D1 | #3B2B31 | Ink #2E3040 | #F3B9C8 |
| Lavender | #DCD4FF | #302C45 | Ink #2E3040 | #C9BEFF |
| Peach | #FFE0D2 | #3B2D27 | Ink #2E3040 | #F8CBB7 |

Roles:
- `tint` / `onTint`: 小标记、图标底板、贴纸。两种外观都保持 pastel 实底 + 近黑前景。
- `softTint` / `onSoftTint`: 无照片占位图的柔和洗色。
- `container` / `onContainer`: 大面积卡片、图片相框和故事 Hero。Light 使用主题实底 + Ink；Dark 使用深色容器 + 主题浅色文字。
- `labelText`: 中性表面上的主题身份小字（例如条件类型标签），Light / Dark 单独验证。

Rules:
- 允许同一页面出现多种主题色；相邻卡片应有明度 / 饱和度节奏，避免整屏高饱和。
- 大块主题容器上的所有文字使用 `onContainer`，不要使用 `textSecondary`（在浅色主题底上不足 4.5:1）。
- 主题色负责身份，Primary 负责行动，Semantic 负责状态，三者不能互相替代。
- 照片上的必要文字放在实底 `surface` 胶囊中，不直接叠在任意照片像素上。
- 每个主题的 `onContainer/container`、`onTint/tint`、`onSoftTint/softTint`、`labelText/surface` 均在 `DesignSystemTests` 中做 Light / Dark 对比度断言。

### 1.2 Typography

Use system fonts with an editorial hierarchy. Chinese uses the system-available fallback; the design must not depend on Latin-only serif glyphs.

| Role | SwiftUI baseline | Use |
|---|---|---|
| Display | `.system(.largeTitle, design: .serif).weight(.bold)` | 页面大标题 / Featured 心愿标题 |
| Editorial title | `.system(.title2, design: .serif).weight(.semibold)` | 区块标题（其他心愿 / 解锁条件 / 今天可以推进） |
| Editorial headline | `.system(.title3, design: .serif).weight(.semibold)` | 横向 Banner 心愿标题 |
| Large title | `.largeTitle, .semibold` | 保留给非编辑页 |
| Title | `.title2, .semibold` | 对话框 / 说明标题 |
| Headline | `.headline, .semibold` | 卡片 / 条件 / 行动标题 |
| Body / Callout / Caption / Footnote | 系统默认 | 正文与元信息 |
| Kicker | `.caption, .semibold` + tracking 0.6–1.2 | 日期、栏目小标 |
| Metric | `.title3, .rounded, .bold, .monospacedDigit()` | 计数与进度数字 |

Implementation must use scalable text styles or a Dynamic Type-aware custom font strategy. Do not hard-code fixed-size text in reusable components without scaling support.

### 1.3 Spacing

Use a 4-point base scale:
- 4: icon/text micro-gap
- 8: compact control spacing
- 12: dense row spacing
- 16: standard content inset / card padding
- 20: screen inset / featured card internal padding
- 24: section spacing
- 32: major section separation / scroll bottom
- 40: hero breathing room

Default horizontal screen inset: 20 pt on standard iPhone widths. Reduce only where content needs it; never clip at accessibility sizes.

### 1.4 Radius and elevation

| Token | Value | Use |
|---|---:|---|
| radiusSmall | 8 | 小标签 / 紧凑控件 |
| radiusMedium | 14 | 输入框 / 图标底板 |
| radiusLarge | 20 | 小卡片 / 进度面板 |
| radiusCard | 22 | 行动卡 / 条件卡 |
| radiusHero | 26 | 图片 / Banner / 横向卡 |
| radiusXXL | 30 | Featured / Detail 故事 Hero |
| radiusPill | capsule | 筛选、按钮、记录胶囊、状态胶囊 |

Prefer a light diffused shadow plus a hairline border over heavy elevation. Use `AppElevation.cardColor` (low opacity), short blur, minimal vertical offset; never stack shadows.

### 1.5 Layout

- Content aligns to a consistent 20 pt horizontal grid.
- Full-width hero photography where the wish is the focal point.
- Standard list rows have a minimum 56 pt interactive height; primary touch targets are at least 44 × 44 pt.
- Use safe-area-aware scroll content; hide the tab bar on pushed detail screens so the story and last condition are never covered.
- Home rhythm: Featured cover → full-width theme Banner → two-column theme grid. At accessibility sizes the grid collapses to one column and cards switch to a horizontal layout.

## 2. Image treatment

Wish imagery is the strongest visual differentiator.
- Featured: 4:3 photo inside an 8–10 pt theme mat, radius 26; status pill over the photo top-left; sticker top-right must not cover the subject.
- Detail hero: 16:10 photo inside the same theme mat, radius 26; title, meta and progress sit on the themed card below the photo.
- Home Banner: 100 × 100 thumbnail on a theme container; at accessibility sizes the image moves below the text at a wider ratio.
- Home grid: 1.08:1 thumbnail at the top of a theme card; at accessibility sizes it becomes an 84 × 84 leading thumbnail.
- No-image state: a theme `softTint -> container` gradient with a restrained line photo symbol. No fake image, no broken-image glyph.
- Do not place body text directly on arbitrary photography. Overlays use solid `surface` capsules.
- Respect stored image data and existing image-loading path; do not add remote image dependencies.

## 3. Core components

### 3.1 Wish cards

Three intentional rhythms; they must not be the same card at different sizes.

**FeaturedWishCard**
1. Theme container + large photo mat.
2. Status pill on the photo.
3. Kicker “本期心愿” + condition completion detail.
4. Serif display title, price / target date, hero progress.
5. Theme sticker in the top-right corner, decorative only.

**WishSpotlightCard**
1. Full-width theme container.
2. Status label + serif headline + progress text on the left.
3. 100 pt photo thumbnail on the right.
4. Accessibility sizes: text first, then a 160 pt image.

**WishGridCard**
1. Theme container with a photo thumbnail.
2. Headline title (2 lines), progress text, inline progress bar.
3. Non-active wishes show a theme status label instead of progress.

Rules:
- Entire card opens detail; card press uses a light scale/opacity feedback, disabled under Reduce Motion.
- Progress percentage is secondary; condition completion count is primary.
- Do not use more than one decorative sticker per card.
- On theme containers, all text uses `theme.onContainer`; status dots use semantic colors without replacing the text color.

### 3.2 Progress indicator

- Height 4 pt inline; 6 pt for hero-level progress.
- Rounded ends.
- Track: `progressTrack` on neutral surfaces; on theme containers use `theme.onContainer.opacity(0.18)`.
- Fill: primary for active, success for completed.
- Always pair with a text value (e.g. “2 / 3 项条件完成”).
- Never show 100% progress as proof of unlock; status comes from Domain state.

### 3.3 ConditionRow

Anatomy:
- 42 pt rounded theme icon plate.
- Condition title.
- Type and target description.
- Current / target value.
- Compact progress line.
- Trailing “记录” capsule only when recording is valid.

Rules:
- Each condition is its own surface card on the Detail page; do not flatten all fields into a settings form.
- Do not repeat “必需” badge on every row when all conditions are required by default; show optional/required only when it changes behavior.
- Completed rows are quieter but remain readable; the icon plate switches to `successSoft`.
- Row tap opens condition detail; explicit record button opens record editor.

### 3.4 TodayActionCard

Anatomy:
- 42 pt theme icon plate.
- Wish title as eyebrow with theme dot.
- Condition title as primary.
- Progress / today's state summary.
- One trailing “记录” capsule (primarySoft + primary text).

Rules:
- Actionable items are separate surface cards with generous spacing; they must not read as a dense todo list.
- Completed / recorded items move to a quieter grouped container with success checkmarks.
- Do not label all conditions as “今日待办” if their business semantics do not require daily completion.
- The page opens with a warm encouragement card, not a wall of tasks.

### 3.5 Buttons

- Primary: Violet gradient capsule, 54 pt height, `onPrimary` label, one per screen.
- Secondary: surface capsule with primary outline, 52 pt.
- Tertiary: text-only, 44 pt minimum target.
- Destructive: system destructive role, never accent-colored.
- Press feedback: primary dims / slightly scales (Reduce Motion keeps opacity only); chips dim; cards use the shared `PressableCardButtonStyle`.

### 3.6 Chips and status

- Filter chips: selected = solid primary + onPrimary text + sparkle; unselected = elevated surface + border + textSecondary.
- Status on neutral surfaces: text + small dot (plain) or solid surface capsule (pill, safe over photos).
- On theme containers: `ThemeStatusLabel` uses `theme.onContainer` text + semantic dot.
- Do not use colored capsules for ordinary metadata.
- Avoid using a badge where a plain label is clearer.

### 3.7 Inputs

- Labels remain visible; placeholders are not labels.
- Use numeric keyboard only for numeric fields, but validate in ViewModel/Domain.
- Show unit next to value, not buried in helper text.
- Keep user input on validation or persistence error.
- Use inline error text adjacent to the field.

### 3.8 Empty / error / loading states

- Empty: editorial rounded-square art with coral / butter accents, short title, one sentence, one primary action.
- Error: explain what failed in plain language and provide Retry.
- Loading: use a restrained progress indicator or skeleton only when loading is perceptible; avoid layout jumps.
- No blank white screens.
- Empty copy is encouraging, never a failure message.

## 4. Motion and feedback

- Standard transitions: 180–260 ms, easeInOut.
- Card press: 0.985 scale + 0.92 opacity; Reduce Motion removes the scale and keeps opacity.
- Progress changes animate gently; do not animate every list refresh.
- Record success: subtle checkmark / haptic if already supported; no confetti.
- Unlock: existing full-screen celebration is the one intentionally elevated moment.
- Respect Reduce Motion; replace scale/particle effects with opacity or static state.
- Avoid sound by default.

## 5. Dark mode and accessibility

- Support system light/dark mode with independent surfaces and theme containers.
- Large theme surfaces in Dark use the deep container + pastel `onContainer`, never the light pastel as a full-card background.
- Support Dynamic Type through accessibility sizes without truncating critical actions; grids collapse to single column and banner images stack.
- VoiceOver: image alt labels describe the wish; cards expose title + status + progress; buttons use action-oriented labels.
- Progress accessibility value: e.g. “已完成 2 项，共 4 项”.
- Do not encode meaning with color alone.
- Minimum touch target 44 × 44 pt.
- Respect Reduce Motion and Increased Contrast (tokens are high-contrast by default; no low-opacity text).
- Test with VoiceOver on real navigation paths, not just isolated previews.

## 6. SwiftUI implementation contract

- Keep tokens in the existing DesignSystem module; extend/refactor AppTheme rather than scattering constants.
- Prefer semantic names such as `AppColors.canvasTop` / `theme.container` over visual names.
- Components accept domain presentation values; they must not fetch repositories or calculate business progress.
- Keep ViewModels and existing factories as the source of data and navigation dependencies.
- Avoid adding third-party UI packages.
- Provide previews for empty, typical, completed, paused, unlocked, long-text and accessibility sizes where relevant.
- Background: use `appScreenBackground()` (`EditorialBackground`) for all screens; do not hard-code a gradient in a View.
- On pushed detail screens, hide the tab bar with `.toolbar(.hidden, for: .tabBar)`.

## 7. Acceptance checklist

- [ ] Light and dark appearances have deliberate contrast.
- [ ] Dynamic Type does not clip key text/actions; grid → single column.
- [ ] VoiceOver announces title, progress, and action clearly.
- [ ] Every interactive target is at least 44 pt.
- [ ] Wish Theme is visible as a large card / photo mat / banner, not only a 4 pt mark or dot.
- [ ] Photography remains the visual focus and is not covered by decoration.
- [ ] Progress is always accompanied by a textual value.
- [ ] No decorative duplicate badges or redundant progress bars.
- [ ] Existing business state is rendered as supplied; no UI-side unlock inference.
- [ ] Contrast pairs are verified by `DesignSystemTests` / `testContrastAuditReport`.
