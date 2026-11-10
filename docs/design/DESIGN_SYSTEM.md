# WishEarn Design System

> Status: Active implementation baseline (Playful Editorial, Issue #21)
> Platform: SwiftUI, iOS 17+
> Principle: Centralized semantic tokens; no per-screen ad hoc styling.

## 0. 当前方向：Editorial Paper（v2）

> 2026-11-11 起，本节 token 为唯一实现基线，取代下方 Playful Editorial 章节的色值、字号与组件规则；旧值仅作历史参考。当前落地范围：全局 token、今日页、心愿详情页、底部 Tab 栏；其余页面沿用布局、继承新配色。

### 0.1 颜色

| Token | Light | Dark | 用途 |
|---|---|---|---|
| canvas | #FAF6EF | #14120F | 纸张底色 |
| surface | #FFFDF8 | #1D1A16 | 弹层与输入 |
| elevated | #FFFDF8 | #221E19 | 需要抬升的容器（少用） |
| surfaceSecondary | #F2EBDF | #26221C | 次要分组 |
| textPrimary | #16120E | #F7F1E6 | 主文字（墨） |
| textSecondary | #6B6459 | #C4BCAE | 说明文字 |
| textTertiary | #767063 | #A79E90 | 元信息 |
| primary | #191512 | #F2ECDF | 唯一行动色：胶囊按钮、选中态 |
| primarySoft | #DEEDE3 | #24352C | 薄荷底（状态横幅） |
| chipText | #2B6A4D | #9BDFC7 | 状态横幅文字 |
| onPrimary | #FFFCF5 | #16120E | 墨底上的文字 |
| success | #2B6A4D | #7BD3A6 | 完成态 |
| warning | #8A5210 | #E5B86E | 仅提示 |
| danger | #B23B45 | #FF9AA5 | 破坏性操作 |
| separator | #E9E1D4 | #332F27 | 0.5pt 分隔线 |
| progressTrack | #ECE4D6 | #36322A | 进度轨道 |

规则：
- 每屏只有一个填充胶囊主行动（墨底），其余操作用描边胶囊或纯文字。
- 薄荷只表达状态与进度，不承担主行动。
- 不再用投影表达层级：层级由字号、留白与 hairline 建立。
- 所有文字/背景组合必须通过 `DesignSystemTests` 的 WCAG 断言（Light + Dark）。

### 0.2 排版

| Role | 基线 | 用途 |
|---|---|---|
| display | `.largeTitle` semibold，tracking −1.2 | 页面大标题、心愿标题 |
| title | `.title2` semibold | 卡片/段落标题 |
| headline | `.headline` semibold | 按钮、行标题 |
| kicker | `.caption` semibold，tracking +1 | 段落小标（“继续这个心愿”） |
| chipNumber | `.title3` bold，monospacedDigit | 状态横幅数字 |
| body / callout / caption / footnote | 系统默认 | 正文、元信息 |

- 移除衬线显示字体；中文标题使用系统无衬线 semibold + 负字距。
- 数字使用等宽数字，避免跳动。

### 0.3 组件

| 组件 | 规则 |
|---|---|
| `StatusChip` | 薄荷 56pt 圆角 19，星标 + 数字 + 单位 + 右侧说明 |
| `PrimaryButtonStyle` | 墨黑胶囊，56pt，全宽，每屏唯一 |
| `PillButtonStyle` | 行内次级操作，描边胶囊，44pt 命中区 |
| `HairlineDivider` | 0.5pt `separator`，替代卡片分隔 |
| `SegmentedProgress` | 必需条件 ≤ 8 项时使用分段条，否则连续进度条 |
| `WishHeroPhoto` | 4:3 用户图片，圆角 26；无图时主题色 wash + 轻图标，不生成插画 |
| `AppTabBar` | 自绘平铺 Tab 栏：hairline、线性图标、选中墨色 + 顶部 14×3 横条 |

### 0.4 图像与插画

- 不使用装饰插画；主视觉一律来自用户上传的心愿图片。
- 心愿主题色（`WishTheme`）仅用于小色点、无图 wash 与标识，不用于状态语义。

## 1. Foundations

### 1.1 Color tokens

Use semantic names. Values below are the validated implementation baseline; keep roles intact when adjusting.

| Token | Light | Dark | Use |
|---|---|---|---|
| canvas | #FFF9F1 | #171725 | App background |
| surface | #FFFFFF | #222235 | Sheets and primary rows |
| elevated | #FFFDF9 | #2C2B42 | Cards / raised surfaces |
| surfaceSecondary | #F7EFE5 | #2A293D | Inputs / quiet grouped surfaces |
| textPrimary | #2E3040 | #F7F3FF | Primary text |
| textSecondary | #6A6878 | #C2BED2 | Supporting text |
| textTertiary | #716E7C | #A19CB5 | Metadata only |
| primary | #6554C0 | #A99AFF | Main action / active progress |
| primaryPressed | #5142A8 | #8F7EE8 | Primary pressed state |
| primarySoft | #EFEBFF | #352F55 | Primary container |
| onPrimary | #FFFFFF | #171725 | Text on primary |
| coral | #FF806B | #FF9A86 | Secondary emphasis / decorative fill |
| coralSoft | #FFE6E0 | #4B2A2E | Secondary container |
| coralText | #B5412F | #FF9A86 | Coral text on light surfaces |
| onCoral | #2E3040 | #171725 | Text on coral fills |
| success | #2F7F57 | #7BD3A6 | Completed state |
| successSoft | #E7F4ED | #1F3A2C | Completed container |
| warning | #A06017 | #E5B86E | Caution only |
| danger | #C24751 | #FF9AA5 | Destructive / error |
| separator | #ECE4DA | #3A3852 | Hairlines |
| progressTrack | #F0E8DE | #38364E | Progress background |

Rules:
- Primary is used for one main action and active progress, not every icon.
- Coral is secondary emphasis only; it must not replace success, warning, or danger.
- Success is reserved for completed states; warning and danger remain semantic.
- Never rely on color alone to communicate state.
- Verify text contrast at normal and large text sizes.
- Dark mode is a deliberate palette, not a simple inversion.
- `accent` / `accentSoft` / `onAccent` are compatibility aliases for primary tokens; new code should use the primary names.

### 1.1.1 Wish theme colors

Each wish receives a stable decorative theme derived from its UUID. This is presentation-only and adds no persisted model field. Theme colors are limited to small marks, thumbnail/placeholder washes, and icon plates; they are never used for semantic status.

| Wish theme | Light tint | Dark tint | Foreground |
|---|---|---|---|
| Butter | #FFD66E | #F6D57B | Ink / dark canvas |
| Mint | #A8E3CF | #9BDFC7 | Ink / dark canvas |
| Sky | #A9D7F2 | #9CCBEA | Ink / dark canvas |
| Blush | #F6C6D1 | #F3B9C8 | Ink / dark canvas |
| Lavender | #DCD4FF | #C9BEFF | Ink / dark canvas |
| Peach | #FFE0D2 | #F8CBB7 | Ink / dark canvas |

Rules:
- Do not place multiple wish palette colors on the same card.
- Solid wish tints may carry only the validated dark foreground.
- Large placeholder areas use `softTint`; small marks use the solid tint.
- Theme color never replaces primary action color or semantic state color.
- Brand primary remains the main action; wish color is identity, not status.
- Gradients are limited to Unlock, hero, and empty-state decoration.

### 1.2 Typography

Use system fonts with a restrained editorial hierarchy. Avoid applying rounded design to every text style.

| Role | SwiftUI baseline | Use |
|---|---|---|
| Display | .system(size: 32, weight: .semibold, design: .serif) | Hero wish title / key empty state |
| Large title | .largeTitle, .semibold | Main page heading |
| Title | .title2, .semibold | Section title |
| Headline | .headline, .semibold | Wish / condition title |
| Body | .body | Explanatory content |
| Callout | .callout | Supporting UI |
| Caption | .caption | Metadata |
| Footnote | .footnote | Secondary metadata |

Implementation must use scalable text styles or a Dynamic Type-aware custom font strategy. Do not hard-code fixed-size text in reusable components without scaling support.

### 1.3 Spacing

Use a 4-point base scale:
- 4: icon/text micro-gap
- 8: compact control spacing
- 12: dense row spacing
- 16: standard content inset
- 20: card internal spacing
- 24: section spacing
- 32: major section separation
- 40: hero breathing room

Default horizontal screen inset: 20 pt on standard iPhone widths. Reduce only where content needs it; never clip at accessibility sizes.

### 1.4 Radius and elevation

| Token | Value | Use |
|---|---:|---|
| radiusSmall | 8 | Chips, compact controls |
| radiusMedium | 14 | Input fields, small surfaces |
| radiusLarge | 20 | Wish cards and grouped content |
| radiusHero | 26 | Hero image / feature surface |
| radiusPill | capsule | Filters and compact status |

Prefer subtle border separation over drop shadows. If shadow is needed: low opacity, short blur, minimal vertical offset. Avoid stacked shadows.

### 1.5 Layout

- Content aligns to a consistent 20 pt horizontal grid.
- Use full-width hero photography where the wish is the focal point.
- Standard list rows have a minimum 56 pt interactive height; primary touch targets should be at least 44 × 44 pt.
- Use safe-area-aware scroll content; no content should be hidden behind the tab bar or keyboard.

## 2. Image treatment

Wish imagery is the strongest visual differentiator.
- Detail hero: wide crop, 16:10 target, rounded 26 pt corners; preserve subject via center crop and allow user-selected image focal behavior if available.
- Home card: 104 × 116 pt editorial thumbnail on standard width; do not force 64 pt generic icon tiles.
- No-image state: a soft wish-theme tinted surface with a restrained line illustration / symbol and a subtle “Add a photo” affordance only in edit context.
- Do not show broken-image glyphs.
- Respect stored image data and existing image-loading path; do not add remote image dependencies.

## 3. Core components

### 3.1 WishCard

Purpose: make the reward desirable and progress legible at a glance.

Anatomy:
1. Wish image.
2. Title (max 2 lines).
3. Optional target price as secondary metadata.
4. Progress label: “2 / 4 条件完成”.
5. Thin progress bar or segmented completion indicator.
6. Small status label only when not ACTIVE.

Rules:
- Entire card opens detail.
- Avoid a status badge plus a second badge plus multiple metadata rows.
- Progress percentage is secondary; condition completion count is primary.
- For UNLOCKED / COMPLETED, use distinct restrained state treatment.
- For PAUSED, use neutral styling and explicit text.

### 3.2 Progress indicator

- Height 4 pt for inline progress; 6 pt only for hero-level progress.
- Rounded ends.
- Track uses progressTrack; fill uses accent; completed uses success.
- Always pair with a text value (e.g. “2 / 3 条件完成”).
- Never show a 100% progress bar as proof of unlock; status comes from Domain state.

### 3.3 ConditionRow

Anatomy:
- Condition title.
- Type and target description.
- Current / target value.
- Compact progress line.
- Trailing action affordance only when recording is valid.

Rules:
- Do not repeat “必需” badge on every row when all conditions are required by default; show optional/required only when it changes behavior.
- Completed rows are quieter but remain readable.
- Row tap opens condition detail; explicit record button opens record editor.

### 3.4 TodayActionRow

Anatomy:
- Wish title as eyebrow/context.
- Condition title as primary.
- Today's state / progress summary.
- One trailing action: “记录” or a completed check state.

Rules:
- The entire row is not an ambiguous button if there are multiple actions.
- Completed-today items are moved to a separate lower section.
- Do not label all conditions as “今日待办” if their business semantics do not require daily completion.

### 3.5 Buttons

- Primary: solid accent, high-contrast label, 50–52 pt height, radius 14.
- Secondary: surface with border or text button.
- Tertiary: text-only, used for low-emphasis actions.
- Destructive: system destructive role, never accent-colored.
- One primary action per screen/sheet.

### 3.6 Chips and status

- Filter chips: selected = accent fill; unselected = quiet surface with border.
- Status should use text + optional small icon.
- Do not use colored capsules for ordinary metadata.
- Avoid using a badge where a plain label is clearer.

### 3.7 Inputs

- Labels remain visible; placeholders are not labels.
- Use numeric keyboard only for numeric fields, but validate in ViewModel/Domain.
- Show unit next to value, not buried in helper text.
- Keep user input on validation or persistence error.
- Use inline error text adjacent to the field.

### 3.8 Empty / error / loading states

- Empty: short title, one sentence, one primary action.
- Error: explain what failed in plain language and provide Retry.
- Loading: use a restrained progress indicator or skeleton only when loading is perceptible; avoid layout jumps.
- No blank white screens.

## 4. Motion and feedback

- Standard transitions: 180–260 ms, easeInOut.
- Progress changes animate gently; do not animate every list refresh.
- Record success: subtle checkmark / haptic if already supported; no confetti.
- Unlock: existing full-screen celebration is the one intentionally elevated moment.
- Respect Reduce Motion; replace scale/particle effects with opacity or static state.
- Avoid sound by default.

## 5. Dark mode and accessibility

- Support system light/dark mode.
- Support Dynamic Type through accessibility sizes without truncating critical actions.
- VoiceOver: image alt label should describe wish title; buttons must use action-oriented labels.
- Progress accessibility value: e.g. “已完成 2 项，共 4 项”.
- Do not encode meaning with color alone.
- Minimum touch target 44 × 44 pt.
- Respect Reduce Motion and increased contrast.
- Test with VoiceOver on real navigation paths, not just isolated previews.

## 6. SwiftUI implementation contract

- Keep tokens in the existing DesignSystem module; extend/refactor AppTheme rather than scattering constants.
- Prefer semantic names such as AppColors.canvas / AppColors.accent over visual names like orange2.
- Components should accept domain presentation values; they must not fetch repositories or calculate business progress.
- Keep ViewModels and existing factories as the source of data and navigation dependencies.
- Avoid adding third-party UI packages.
- Provide previews for empty, typical, completed, paused, unlocked, and long-text states where relevant.

## 7. Acceptance checklist

- [ ] Light and dark appearances have deliberate contrast.
- [ ] Dynamic Type does not clip key text/actions.
- [ ] VoiceOver announces title, progress, and action clearly.
- [ ] Every interactive target is at least 44 pt.
- [ ] Accent color is used consistently and sparingly.
- [ ] Progress is always accompanied by a textual value.
- [ ] No decorative duplicate badges or redundant progress bars.
- [ ] Existing business state is rendered as supplied; no UI-side unlock inference.
