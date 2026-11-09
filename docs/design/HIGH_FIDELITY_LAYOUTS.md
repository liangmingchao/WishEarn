# WishEarn High-Fidelity Layout Specifications

> Companion to SCREEN_SPECS.md and DESIGN_SYSTEM.md.
> This document turns the approved Editorial Reward Journal direction into implementation-level layout guidance.
> Measurements are target values for a standard iPhone viewport; use adaptive SwiftUI layout and Dynamic Type rather than fixed screen coordinates.

## 1. Design composition rules

### Visual rhythm
- Page canvas: cool mist neutral background.
- Main content horizontal inset: 20 pt.
- Section spacing: 28–32 pt.
- Card internal inset: 16–20 pt.
- Text-to-control gap: 8–12 pt.
- Avoid placing more than two strong visual anchors in one viewport.
- Prefer whitespace and typography over borders and shadows to create hierarchy.

### Three-level hierarchy
1. **Editorial anchor:** wish title, hero image, or page title.
2. **Functional anchor:** progress summary or next action.
3. **Supporting detail:** status, date, units, helper text.

Do not give all three levels equal font weight or color contrast.

## 2. Wishes home — detailed layout

### Header
- Top safe-area inset + 8 pt.
- Title “我的心愿”, large title style, semibold.
- Supporting sentence directly below, caption/callout color secondary.
- Add button is a 44 × 44 pt hit target; visually simple plus symbol in a quiet surface, not a large floating action button.
- Header bottom spacing: 20–24 pt.

### Featured wish card
- One lead active wish when active wishes exist.
- Image aspect ratio: 2:1 for lead card; width fills content. Detail hero remains 16:10.
- Image radius: 22–26 pt.
- Image overlays are prohibited unless needed for legibility; title and price should sit below the image.
- Wish title: 25–28 pt serif semibold; max 2 lines, natural wrapping.
- Price: 14–15 pt secondary.
- Progress summary: 14 pt semibold.
- Progress track: 5 pt high; 8 pt gap from summary.
- Supporting progress sentence: 12–13 pt secondary.
- Card content vertical rhythm: 12 / 8 / 12 / 8 pt.
- Entire card is one navigation target. Do not put a nested record button inside the card.

### Secondary wish rows
- Minimum row height: 100–112 pt.
- Thumbnail: 76 × 76 pt, radius 14 pt.
- Title: 17 pt semibold, max 2 lines.
- Progress: 13 pt secondary.
- Trailing chevron is decorative; the whole row is tappable.
- 16 pt vertical separation or a subtle separator, not both.

### Filters
- Horizontal scroll chips, 32–36 pt height.
- Selected chip uses soft accent surface and accent text; avoid full saturation.
- Place after featured/secondary wish content or at the top only when the active filter is not “全部”.
- Filter labels: 全部 / 进行中 / 已解锁 / 已兑现 / 已暂停.
- Filter state must remain visible to VoiceOver.

### Home empty state
- No oversized illustration. Use a simple line symbol or typographic treatment.
- Heading: “给自己一个值得期待的目标”.
- Body: “选一件真正想要的东西，再决定要为它付出哪些努力。”
- Primary CTA: “创建第一个心愿”.
- CTA width fills content; height 50–52 pt.
- Do not show active-wish count when zero.

## 3. Wish detail — detailed layout

### Hero
- Hero image width fills content; 16:10; radius 24 pt.
- Top toolbar uses native back and overflow controls.
- Title below image: 28–32 pt serif semibold; line spacing comfortable.
- Metadata row: price and status, 13–14 pt; separate with dot only if both exist.
- 20–24 pt gap before progress section.

### Overall progress
- Section title “你的努力”, 18 pt semibold.
- Primary value: “2 / 3 项条件完成”, 15 pt semibold.
- Progress track: 6 pt; 10 pt top gap.
- Do not display percentage as a second prominent metric.
- If total conditions = 0, replace progress with onboarding prompt and add-condition CTA. Do not divide by zero or display 0%.

### Condition list
- Section heading “解锁条件”; add action as a 44 pt target.
- Group conditions in a single surface with subtle separators.
- Each condition row:
  - 16 pt vertical padding.
  - Name 16 pt semibold.
  - Type/target 12–13 pt secondary.
  - Current / target 13 pt.
  - Progress bar 4 pt.
  - Row action is a small text button “记录一次” where valid.
- Completed condition uses a small check icon and success text; do not reduce opacity below readable contrast.
- Reordering affordance appears only in current edit/reorder mode.
- Keep the whole row tap target distinct from the record action to avoid ambiguous nested controls.

### Recent records
- Show at most 3 recent records in the detail summary if current data supports it.
- Use date + record title/value + optional note.
- “查看全部” navigates to condition history only when a specific condition context exists; otherwise omit.
- Do not fabricate records or display placeholder dates.

## 4. Today — detailed layout

### Header
- Title “今天” 30–32 pt semibold.
- Date 13 pt secondary, localized using the app's existing date formatter.
- Supporting title “今天可以推进这些心愿” 17 pt semibold, 24 pt top gap.

### Action group
- Each row has:
  1. Wish title eyebrow, 11–12 pt uppercase only for Latin names; Chinese names remain natural case.
  2. Condition title, 17 pt semibold.
  3. Current / target summary, 13 pt secondary.
  4. Trailing action button.
- Row minimum height: 84 pt; content padding vertical 14 pt.
- Use separators between rows, not individual floating cards.
- Record button minimum 44 × 44 pt; compact pill or text button with plus icon.
- If cannot record, do not show an enabled-looking button.

### Completed today
- Separate section with a 24 pt top gap.
- Completed row shows check icon, condition title, wish context, and “已记录”.
- Do not show a green full-width banner or celebration card.
- Do not show streak break warnings or overdue labels.

### Today empty state
- Heading: “今天暂时没有需要记录的行动”.
- Body: “继续按自己的节奏前进。新的行动会在这里出现。”
- If no wishes exist, provide a CTA to create a wish.
- If wishes exist but there are no actionable items, do not imply that the user is behind.

## 5. Editors — detailed sheet behavior

### Shared sheet chrome
- Use native sheet with medium/large detents only if the form content fits; otherwise large.
- Use a clear navigation title, Cancel leading action, Save trailing action.
- Save disabled while invalid or saving; show progress state while saving.
- Interactive dismissal should not silently discard dirty input; use existing app conventions and a confirmation only when necessary.
- Keyboard must not cover the focused field or Save action.

### Wish editor
- Photo picker is optional and sits first, but should not dominate the form.
- Title field is first required field.
- Price, description, date appear as optional grouped fields.
- Field labels remain visible above inputs.
- Error appears directly below the relevant field.
- Save returns to detail; after first creation, show an unobtrusive add-condition prompt.

### Condition editor
- Type selection precedes type-specific target input.
- Dynamic fields animate only when Reduce Motion permits.
- STREAK target uses integer-only entry and explicit unit “天”.
- Validation text is specific, e.g. “连续天数必须是正整数”.
- Preserve current value when switching type only if semantically valid; otherwise clear invalid dependent fields with clear UI feedback.

### Record editor
- Wish and condition context appears at top in a quiet grouped header.
- The primary value input is the dominant field.
- Unit is visually attached to the value.
- Date and note are secondary and shown only when supported.
- Numeric keyboard and decimal separator follow the active locale and field semantics.
- Save button is full width at the bottom or in the navigation toolbar, never both as competing primary actions.

## 6. Condition history

- Header title is condition name.
- Target/type metadata sits directly below.
- Progress summary is a single strong value.
- History list uses date grouping only if there are enough records to justify it.
- Record rows have 56–64 pt minimum height.
- Edit and delete are contextual actions; deletion requires confirmation.
- Empty history uses a compact icon, one explanatory sentence, and “记录第一次行动”.

## 7. Unlock — detailed composition

- Full-screen presentation remains driven by existing UnlockCoordinator.
- Wish image uses 4:3 or 16:10 crop, centered, max width 320 pt.
- Main heading “你做到了” uses 30–34 pt serif semibold.
- Wish title uses 20–22 pt semibold.
- Supporting line names the number of completed conditions only when known and accurate.
- Primary CTA “领取这份奖励” is 52 pt high.
- Secondary action “稍后再说” is text-only.
- Close action remains accessible at top trailing edge.
- Animation: image fade/scale subtle; text stagger only if Reduce Motion is off.
- No confetti, coins, sound, or artificial score.

## 8. Achievements and settings

### Achievements
- Use a compact summary row for existing real aggregates.
- Avoid a grid of decorative badges.
- Completed wishes appear as editorial rows with image, title, and date.
- If no achievements exist, use a supportive empty state rather than a zero-score dashboard.

### Settings
- Native grouped list.
- Row height 52–56 pt.
- Use system disclosure indicators.
- Export explanation must state actual format and known limitations.
- Destructive actions use system destructive styling and confirmation.

## 9. Responsive and accessibility behavior

- At accessibility Dynamic Type sizes, stack image and text vertically; never force side-by-side card layouts that truncate titles.
- WishCard may change from horizontal to vertical composition based on available width / content size category.
- Keep all primary actions reachable without horizontal scrolling.
- Use scroll containers for long forms and detail pages.
- VoiceOver order follows visual hierarchy: wish title → status → progress → conditions → actions.
- Progress labels expose numeric accessibility values.
- Image accessibility label uses the wish title, not “image”.
- Reduce Motion disables nonessential scale and stagger effects.
- Validate contrast in both appearances, including accent text on accentSoft surfaces.

## 10. Implementation review checklist

- [ ] Header and content align to the 20 pt grid.
- [ ] Lead wish image is visually dominant without hiding title or progress.
- [ ] Secondary rows are compact and scan-friendly.
- [ ] Today uses row-based action layout, not a dashboard of cards.
- [ ] Condition and record editors show only semantically relevant fields.
- [ ] One primary action per surface.
- [ ] All primary hit targets are at least 44 pt.
- [ ] Large Dynamic Type preserves hierarchy and action access.
- [ ] Light/dark screenshots reviewed at standard and accessibility text sizes.
- [ ] No hardcoded sample content appears in production views.
