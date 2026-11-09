# WishEarn Design System

> Status: Proposed implementation specification
> Platform: SwiftUI, iOS 17+
> Principle: Centralized semantic tokens; no per-screen ad hoc styling.

## 1. Foundations

### 1.1 Color tokens

Use semantic names. Values below are initial targets; verify contrast in implementation and adjust only while preserving roles.

| Token | Light | Dark | Use |
|---|---|---|---|
| canvas | #F7F4EF | #151412 | App background |
| surface | #FFFEFC | #211F1C | Main cards and sheets |
| surfaceSecondary | #EEEAE3 | #2B2824 | Quiet grouped surfaces |
| textPrimary | #282521 | #F4F0E9 | Primary text |
| textSecondary | #746F66 | #B9B2A8 | Supporting text |
| textTertiary | #989187 | #8E877E | Metadata only |
| accent | #B85F3D | #E08A65 | Primary action / active progress |
| accentSoft | #F1DED4 | #422B22 | Accent container |
| success | #397B5B | #76B994 | Completed state |
| warning | #A96E24 | #D9A65C | Caution only |
| danger | #B94A45 | #E47C75 | Destructive / error |
| separator | #E4DED5 | #39352F | Hairlines |
| progressTrack | #EAE4DC | #39352F | Progress background |

Rules:
- Accent is used for one primary action and active progress, not every icon.
- Success is reserved for completed states.
- Never rely on color alone to communicate state.
- Verify text contrast at normal and large text sizes.
- Dark mode is a deliberate palette, not a simple inversion.

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
- No-image state: warm neutral surface with a restrained line illustration / symbol and a subtle “Add a photo” affordance only in edit context.
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
