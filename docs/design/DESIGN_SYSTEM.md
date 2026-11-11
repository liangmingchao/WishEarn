# WishEarn Design System

> Status: Active implementation baseline (Paper & Sage, Issue #30 follow-up)
> Platform: SwiftUI, iOS 17+
> Principle: Centralized semantic tokens; no per-screen ad hoc styling.

Issue #30 初始方案是 **Sunny Wish Journal**（多彩生活方式杂志）。用户复审后指出首页卡片的颜色体系过多、过杂，并将品牌紫色列为需要替换的色系。当前基线因此收敛为 **Paper & Sage**：

- 画布是暖纸色，文字是墨色，行动只有一种深鼠尾草绿。
- 黏土色（clay）只做少量编辑性点缀，不再出现大面积珊瑚色块。
- Wish Theme 从 6 种高饱和主题收敛为 3 种低饱和色调（Sage / Clay / Stone）。
- 所有首页卡片统一使用白色纸面；层级由尺寸、照片和信息密度建立，而不是由整卡底色建立。
- 主题只作为 3–4 pt 短标记、图标底板、占位图洗色或详情 Hero 的安静底色存在。
- 新增「我的 → 外观」设置：跟随系统 / 浅色 / 深色，持久化到 `@AppStorage("appAppearance")`，在 App 根视图应用 `.preferredColorScheme`。

## 1. Foundations

### 1.1 Color tokens

Use semantic names. Values below are the validated implementation baseline; keep roles intact when adjusting.

| Token | Light | Dark | Use |
|---|---|---|---|
| canvasTop | #FAF8F3 | #171815 | 纸感画布起点 |
| canvasBottom | #F3F0E8 | #1D1E1A | 纸感画布终点 |
| canvas | #FAF8F3 | #171815 | 纯色回退 / 不适用渐变的表面 |
| surface | #FFFFFF | #232420 | 卡片、行、纸面进度面板 |
| elevated | #FFFDF8 | #2B2C27 | 需要抬升的小表面 |
| surfaceSecondary | #F1EEE6 | #2E2F2A | 输入、安静分组、进度面板 |
| textPrimary | #24251F | #F3F1E9 | 主文字 |
| textSecondary | #5E6056 | #C3C0B5 | 说明文字 |
| textTertiary | #67695F | #A7A498 | 元信息；在画布渐变两端也保持 4.5:1 |
| primary | #3C6252 | #9CC6B1 | 品牌行动 / 选中态 / 进度 |
| primaryPressed | #2E4D40 | #87B29D | 按下态 |
| primarySoft | #E7EFE9 | #293A32 | 主行动容器 / 记录胶囊 |
| onPrimary | #FFFFFF | #14201A | 主色上的文字 |
| clay | #A25C42 | #D99C82 | 少量暖色编辑点缀 / 今日鼓励条 |
| claySoft | #F3E7DF | #3A2B25 | 暖色柔底 / 空状态装饰 |
| clayText | #84442E | #E7B39B | 暖色柔底上的文字 |
| onClay | #FFFFFF | #17110E | 黏土实底上的文字 |
| success | #2F6B4F | #7BC6A3 | 完成态 |
| successSoft | #E6F0EA | #1E3A2D | 完成态容器 |
| warning | #8A5A18 | #E0B368 | 暂停 / 注意 |
| danger | #B4454E | #F09AA3 | 破坏性 / 错误 |
| separator | #E7E2D8 | #393A34 | Hairline / 边框 |
| progressTrack | #ECE7DD | #363732 | 进度轨道 |

Rules:
- Primary 是唯一的品牌行动色；每屏只保留一个填充主按钮。主按钮使用纯色，不再使用渐变。
- Clay 只做少量情绪与重点提示，不替代 success / warning / danger，不铺满整张卡片。
- Success 只用于完成态；警告与危险保持语义。
- 不得只靠颜色表达状态；进度与状态必须有文字。
- 画布是 `canvasTop -> canvasBottom` 的极轻纸感渐变；没有彩色光晕，正文与次级文字在两个端点都通过 4.5:1。
- Dark mode 是独立调色，不是反相；深色下 primary 变为浅鼠尾草绿，onPrimary 变为深墨色。
- `accent` / `accentSoft` / `onAccent` 是 primary 的兼容别名；新代码使用 primary 名称。

### 1.1.1 Wish theme colors

Each wish receives a stable decorative theme derived from its UUID. This is presentation-only and adds no persisted model field. The palette is deliberately limited to three muted tones.

| Wish theme | Light tint | Dark tint | Light container | Dark container | Light label | Dark label |
|---|---|---|---|---|---|---|
| Sage | #9DB9A7 | #9DB9A7 | #EEF2EA | #242F29 | #3E6654 | #A9CBB8 |
| Clay | #C99A80 | #C99A80 | #F6EEE8 | #302620 | #83452F | #DFAC93 |
| Stone | #B9B6A8 | #B2AFA1 | #F2F1EB | #2B2C27 | #5A5C53 | #C0C2B7 |

Roles:
- `tint` / `onTint`: 3–4 pt 短标记、小圆点、图标底板。两种外观都保持低饱和实底 + 近黑前景。
- `softTint` / `onSoftTint`: 无照片占位图的柔和洗色。
- `container` / `onContainer`: 详情 Hero 的安静底色；不再用于首页卡片整卡填充。
- `labelText`: 中性纸面上的主题身份小字（例如详情页 Kicker）。

Rules:
- 首页三张卡片都使用 `surface`，主题只作为一条短标记（`WishThemeMark`）或占位图洗色出现。
- 同一页面最多出现三种低饱和主题；不要再用主题色铺满整张卡片。
- 主题容器上的文字使用 `onContainer`；纸面上的主题小字使用 `labelText`。
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

Prefer a hairline border over heavy elevation. `AppElevation.cardColor` remains available but the current cards rely on `separator` borders; never stack shadows.

### 1.5 Layout

- Content aligns to a consistent 20 pt horizontal grid.
- Full-width hero photography where the wish is the focal point.
- Standard list rows have a minimum 56 pt interactive height; primary touch targets are at least 44 × 44 pt.
- Use safe-area-aware scroll content; hide the tab bar on pushed detail screens so the story and last condition are never covered.
- Home rhythm: white Featured cover → white paper Banner → two-column white paper grid. Hierarchy comes from card size and photo framing, not fill color. At accessibility sizes the grid collapses to one column and cards switch to a horizontal layout.
- Appearance: Settings 提供「跟随系统 / 浅色 / 深色」，根视图用 `preferredColorScheme` 统一应用；选择写入 `@AppStorage`。

## 2. Image treatment

Wish imagery is the strongest visual differentiator.
- Featured: 16:10 full-bleed photo at the top of a white paper card; status pill over the photo top-left; no decorative sticker.
- Detail hero: 16:10 photo inside a 10 pt mat on a white paper card; title, meta and progress sit below the photo.
- Home Banner: 100 × 100 thumbnail on a white paper card; at accessibility sizes the image moves below the text at a wider ratio.
- Home grid: 1.08:1 thumbnail at the top of a white paper card; at accessibility sizes it becomes an 84 × 84 leading thumbnail.
- No-image state: a theme `softTint -> container` gradient with a restrained line photo symbol. No fake image, no broken-image glyph.
- Do not place body text directly on arbitrary photography. Overlays use solid `surface` capsules.
- Respect stored image data and existing image-loading path; do not add remote image dependencies.

## 3. Core components

### 3.1 Wish cards

Three intentional rhythms; they must not be the same card at different sizes. All three share the same white paper surface and hairline border.

**FeaturedWishCard**
1. White paper card; full-bleed 16:10 photo at the top.
2. Status pill on the photo.
3. Theme mark + Kicker “本期心愿” + condition completion detail.
4. Serif display title, price / target date, hero progress.
5. No theme sticker; the theme mark and photo placeholder carry identity.

**WishSpotlightCard**
1. Full-width white paper card.
2. Theme mark + status + serif headline + progress text on the left.
3. 100 pt photo thumbnail on the right.
4. Accessibility sizes: text first, then a 160 pt image.

**WishGridCard**
1. White paper card with a photo thumbnail.
2. Theme mark, headline title (2 lines), progress text, inline progress bar.
3. Non-active wishes show a status badge instead of progress.

Rules:
- Entire card opens detail; card press uses a light scale/opacity feedback, disabled under Reduce Motion.
- Progress percentage is secondary; condition completion count is primary.
- Do not use more than one decorative mark per card.
- On white paper cards, all text uses `textPrimary` / `textSecondary`; theme color stays in the mark and photo wash.
- No large themed card fills, no more than three muted theme tones.

### 3.2 Progress indicator

- Height 4 pt inline; 6 pt for hero-level progress.
- Rounded ends.
- Track: `progressTrack` on all cards.
- Fill: primary for active, success for completed. Do not tint progress per wish theme.
- Always pair with a text value (e.g. “2 / 3 项条件完成”).
- Never show 100% progress as proof of unlock; status comes from Domain state.

### 3.3 ConditionRow

Anatomy:
- 42 pt muted theme icon plate.
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
- 42 pt muted theme icon plate.
- Wish title as eyebrow with theme dot.
- Condition title as primary.
- Progress / today's state summary.
- One trailing “记录” capsule (primarySoft + primary text).

Rules:
- Actionable items are separate surface cards with generous spacing; they must not read as a dense todo list.
- Completed / recorded items move to a quieter grouped container with success checkmarks.
- Do not label all conditions as “今日待办” if their business semantics do not require daily completion.
- The page opens with a white encouragement card with a narrow clay accent bar, not a large saturated block and not a wall of tasks.

### 3.5 Buttons

- Primary: solid primary capsule, 54 pt height, `onPrimary` label, one per screen. No gradient.
- Secondary: surface capsule with primary outline, 52 pt.
- Tertiary: text-only, 44 pt minimum target.
- Destructive: system destructive role, never accent-colored.
- Press feedback: primary dims / slightly scales (Reduce Motion keeps opacity only); chips dim; cards use the shared `PressableCardButtonStyle`.

### 3.6 Chips and status

- Filter chips: selected = solid primary + onPrimary text + sparkle; unselected = elevated surface + border + textSecondary.
- Status on neutral surfaces: text + small dot (plain) or solid surface capsule (pill, safe over photos).
- Do not use colored capsules for ordinary metadata.
- Avoid using a badge where a plain label is clearer.
- The old `ThemeStatusLabel` was removed; status always uses `StatusBadge` with semantic tone.

### 3.7 Inputs

- Labels remain visible; placeholders are not labels.
- Use numeric keyboard only for numeric fields, but validate in ViewModel/Domain.
- Show unit next to value, not buried in helper text.
- Keep user input on validation or persistence error.
- Use inline error text adjacent to the field.
- New COUNT / CUSTOM records prefill `1` so the common single action can be saved immediately. DURATION / AMOUNT stay blank to avoid accidentally saving 1 minute or 1 unit; editing always preserves the stored value.

### 3.8 Empty / error / loading states

- Empty: editorial rounded-square art with sage / clay accents, short title, one sentence, one primary action.
- Error: explain what failed in plain language and provide Retry.
- Loading: use a restrained progress indicator or skeleton only when loading is perceptible; avoid layout jumps.
- No blank white screens.

### 3.9 Unlock celebration

The unlock surface is a paper certificate with two states:

1. **已达成**：photo frame, 已达成 stamp, one-shot star burst, proof pill (“N 项必需条件，全部完成”), warm copy, pinned “领取这份奖励” CTA.
2. **已领取**：same photo with 已领取 stamp, receipt (领取日期 / 完成条件), “完成” CTA. The wish is already completed when this state appears; 完成 only dismisses the celebration.

Rules:
- The full celebration appears only when the wish unlocks (all required conditions complete), not after every single record.
- Keep the primary CTA pinned above the bottom safe area; content scrolls.
- The star burst is brief and fades out; it must not remain over the text.
- Respect Reduce Motion: skip the burst and use a static composition.
- Announce “奖励已领取” under VoiceOver and use the success haptic.
- Empty copy is encouraging, never a failure message.

## 4. Motion and feedback

- Standard transitions: 180–260 ms, easeInOut.
- Card press: 0.985 scale + 0.92 opacity; Reduce Motion removes the scale and keeps opacity.
- Progress changes animate gently; do not animate every list refresh.
- Record success: subtle haptic; the row/condition state is the visible confirmation. No full-screen celebration for a single condition.
- Unlock: the full-screen paper certificate is the one intentionally elevated moment. It uses a brief one-shot star burst, a stamp, and a second “已领取” receipt state; the page stays visible after claiming until 完成.
- Respect Reduce Motion; skip particle motion and use opacity/static composition instead.
- Avoid sound by default.

## 5. Dark mode, appearance and accessibility

- Settings → 外观：`跟随系统` / `浅色` / `深色`。选择持久化到 `@AppStorage("appAppearance")`，App 根视图用 `.preferredColorScheme(AppAppearance.colorScheme)` 应用；手动选择优先于系统设置。
- Support system light/dark mode with independent surfaces and muted theme containers.
- Dark surfaces are independent values, not inverted light colors; primary becomes light sage and `onPrimary` becomes dark ink.
- Support Dynamic Type through accessibility sizes without truncating critical actions; grids collapse to single column and banner images stack.
- VoiceOver: image alt labels describe the wish; cards expose title + status + progress; buttons use action-oriented labels.
- Progress accessibility value: e.g. “已完成 2 项，共 4 项”.
- Do not encode meaning with color alone.
- Minimum touch target 44 × 44 pt.
- Respect Reduce Motion and Increased Contrast (tokens are high-contrast by default; no low-opacity text).
- Test with VoiceOver on real navigation paths, not just isolated previews.

## 6. SwiftUI implementation contract

- Keep tokens in the existing DesignSystem module; extend/refactor AppTheme rather than scattering constants.
- Prefer semantic names such as `AppColors.canvasTop` / `theme.labelText` over visual names.
- Components accept domain presentation values; they must not fetch repositories or calculate business progress.
- Keep ViewModels and existing factories as the source of data and navigation dependencies.
- Avoid adding third-party UI packages.
- Provide previews for empty, typical, completed, paused, unlocked, long-text and accessibility sizes where relevant.
- Background: use `appScreenBackground()` (`EditorialBackground`) for all screens; do not hard-code a gradient in a View.
- On pushed detail screens, hide the tab bar with `.toolbar(.hidden, for: .tabBar)`.
- Appearance is app-level state: `AppAppearance` + `@AppStorage` + `.preferredColorScheme`; do not reimplement per-screen overrides.

## 7. Acceptance checklist

- [ ] Light and dark appearances have deliberate contrast.
- [ ] Settings can switch 跟随系统 / 浅色 / 深色, and the choice survives relaunch.
- [ ] Dynamic Type does not clip key text/actions; grid → single column.
- [ ] VoiceOver announces title, progress, and action clearly.
- [ ] Every interactive target is at least 44 pt.
- [ ] Wish Theme is present as a quiet mark / photo wash / detail hero, never a large saturated card.
- [ ] Photography remains the visual focus and is not covered by decoration.
- [ ] Progress is always accompanied by a textual value.
- [ ] No decorative duplicate badges or redundant progress bars.
- [ ] Existing business state is rendered as supplied; no UI-side unlock inference.
- [ ] Contrast pairs are verified by `DesignSystemTests` / `testContrastAuditReport`.
