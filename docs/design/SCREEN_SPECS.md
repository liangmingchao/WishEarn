# WishEarn Screen Specifications & Low-Fidelity Prototypes

> This is the implementation contract for the first UI redesign pass.
> Wireframes are structural, not pixel-perfect. Follow DESIGN_SYSTEM.md for visual tokens.

## 1. Global shell

### Prototype

```text
┌──────────────────────────────────┐
│                                  │
│           Current Screen         │
│                                  │
│                                  │
│                                  │
├──────────────────────────────────┤
│   ♡ 心愿   ✓ 行动   ♜ 成就   ◉ 我的 │
└──────────────────────────────────┘
```

- Preserve four tabs.
- Navigation title may be hidden or compact where the editorial page header already provides the title; do not show duplicate headings.
- Each tab uses the same canvas and semantic tokens.
- Tab bar remains native.

## 2. Wishes — home

### User job
Recognize the reward that matters and understand progress without reading a task dashboard.

### Prototype: populated

```text
┌──────────────────────────────────┐
│ 我的心愿                    [+]  │
│ 正在为 3 个想要的东西努力         │
│                                  │
│ 继续你的旅程                     │
│ ┌──────────────────────────────┐ │
│ │ ┌──────────┐                 │ │
│ │ │          │  Kindle         │ │
│ │ │  PHOTO   │  Paperwhite     │ │
│ │ │          │  ¥1,099         │ │
│ │ └──────────┘                 │ │
│ │  2 / 3 项条件完成             │ │
│ │  ━━━━━━━━━━━━━━━────         │ │
│ │  还差最后一项                 │ │
│ └──────────────────────────────┘ │
│                                  │
│ 其他心愿                         │
│ ┌──────────────────────────────┐ │
│ │ [PHOTO]  周末去京都           │ │
│ │          1 / 4 项条件完成      │ │
│ └──────────────────────────────┘ │
│                                  │
│ 全部  进行中  已解锁  已兑现      │
└──────────────────────────────────┘
```

### Prototype: first-use empty

```text
┌──────────────────────────────────┐
│ 我的心愿                    [+]  │
│                                  │
│                                  │
│          [quiet illustration]    │
│                                  │
│       给自己一个值得期待的目标    │
│   选一件真正想要的东西，          │
│   再决定要为它付出哪些努力。      │
│                                  │
│          [ 创建第一个心愿 ]       │
│                                  │
└──────────────────────────────────┘
```

### Layout and behavior
- Page title: “我的心愿”. Supporting line uses active wish count; avoid generic “你好” greeting.
- If there is at least one active wish, feature the most relevant active wish as the lead card. Selection order must be deterministic and based on existing list ordering; do not add new ranking logic in View.
- Remaining wishes appear in a compact vertical list.
- Filters remain available, but should not compete with the hero content; place below the list or as a quiet horizontal filter row depending on viewport.
- Card image is approximately 104 × 116 pt on standard width; title is primary; price is optional metadata.
- Progress label is “已完成 x / y 项条件”. Do not show both large percentage and duplicate progress text.
- Entire card navigates to detail.
- Add button and empty-state CTA both open the existing WishEditor flow.
- Filter with no matches shows a filter-specific empty state and a “查看全部” action.

### Acceptance
- [ ] Wish image/title are the strongest visual focus.
- [ ] Active wish count is factual and not overstated.
- [ ] Filters retain all existing states.
- [ ] Empty and no-filter-result states are distinct.
- [ ] Card has one clear tap behavior.
- [ ] Long wish names and missing images render cleanly.

## 3. Wish Detail

### User job
Understand why the wish matters, how far along it is, and what to do next.

### Prototype

```text
┌──────────────────────────────────┐
│ ‹                         •••    │
│ ┌──────────────────────────────┐ │
│ │                              │ │
│ │          WISH PHOTO          │ │
│ │                              │ │
│ └──────────────────────────────┘ │
│ Kindle Paperwhite                │
│ ¥1,099 · 进行中                  │
│                                  │
│ 你的努力                         │
│ 2 / 3 项条件完成                 │
│ ━━━━━━━━━━━━━━━━━━━────         │
│                                  │
│ 解锁条件                    [+]  │
│ ┌──────────────────────────────┐ │
│ │ ✓ 阅读 30 小时                │ │
│ │   已完成 30 / 30 小时         │ │
│ ├──────────────────────────────┤ │
│ │ ◔ 健身 20 次                  │ │
│ │   已完成 12 / 20 次           │ │
│ │   [记录一次]                  │ │
│ ├──────────────────────────────┤ │
│ │ ○ 完成个人项目                │ │
│ │   尚未开始                    │ │
│ └──────────────────────────────┘ │
│                                  │
│ 最近的努力                       │
│ · 今天  跑步 5 公里              │
│ · 昨天  健身 1 次                │
└──────────────────────────────────┘
```

### Layout and behavior
- Hero photo uses 16:10 wide crop; title below image.
- Status and price are inline secondary metadata.
- Overall progress uses completed-condition count / total condition count; display ratio supplied by ViewModel, not recalculated.
- Condition rows show condition name, type/target, current/target, and a compact progress bar.
- A record CTA is available only when the condition can accept a record.
- Row tap opens Condition Detail; record CTA opens Record Editor.
- “+” adds a condition. Edit wish belongs in an overflow menu or existing toolbar action.
- For UNLOCKED, replace progress CTA with “领取奖励”; do not show “继续努力”.
- For COMPLETED, show a quiet completed state and the completion date if available.
- For PAUSED, explain that progress is preserved and offer Resume.
- Empty conditions: clear next step “添加第一个解锁条件”.

### Acceptance
- [ ] Image/title/status appear before progress metrics.
- [ ] All conditions remain accessible and sortable if current behavior supports it.
- [ ] Completed, unlocked, paused, and active states are distinct.
- [ ] No UI-side unlock inference.
- [ ] Recent records are real persisted records, not placeholder examples.

## 4. Today — action companion

### User job
Find a useful action and record it quickly.

### Prototype

```text
┌──────────────────────────────────┐
│ 今天                             │
│ 星期一 · 11 月 9 日              │
│                                  │
│ 今天可以推进这些心愿             │
│                                  │
│ KINDLE                           │
│ 阅读                             │
│ 累计 18 / 30 小时                │
│                         [记录 +] │
│ ──────────────────────────────── │
│ 跑鞋                             │
│ 跑步                             │
│ 累计 12 / 20 次                  │
│                         [记录 +] │
│                                  │
│ 今天已记录                       │
│ ✓ 不吃零食                       │
│   Kindle · 连续 6 / 30 天        │
└──────────────────────────────────┘
```

### Layout and behavior
- Heading uses date, not motivational greeting.
- Group actionable items first; completed-today items below.
- Wish title is context (eyebrow); condition title is primary.
- Show current progress / target and a single record action.
- “已完成” rows are visually quieter but remain readable.
- If TodayViewModel returns no items, use a calm empty state with “心愿创建后，你的行动会出现在这里”.
- Never infer daily obligation for condition types whose ViewModel semantics do not require it.
- Tap Record opens type-specific RecordEditor sheet.

### Acceptance
- [ ] User can distinguish wish context from condition title.
- [ ] Actionable and completed-today states are distinct.
- [ ] Record affordance is only enabled when canRecord is true.
- [ ] No duplicated “必需” badges on every row.
- [ ] No invented reminders or overdue states.

## 5. Wish Editor

### User job
Capture the reward with as little friction as possible.

### Prototype

```text
┌──────────────────────────────────┐
│ 取消       新建心愿          保存 │
│                                  │
│          [添加心愿照片]           │
│                                  │
│ 心愿名称                         │
│ [例如：Kindle Paperwhite       ] │
│                                  │
│ 参考价格（选填）                 │
│ [¥ 1,099                       ] │
│                                  │
│ 想要它的原因（选填）             │
│ [                              ] │
│                                  │
│ 目标日期（选填）                 │
│ [选择日期                       ] │
│                                  │
└──────────────────────────────────┘
```

### Rules
- Title is the only required field.
- Photo is encouraged but optional.
- After picking a photo, show a 16:10 crop screen with drag and pinch; Cancel must preserve the previous image.
- Price, description, and target date are secondary and visibly optional.
- Save remains disabled until title is valid; validation text is inline.
- Do not add category, tags, budget tracking, or shopping links.
- After first save, return to detail and gently prompt to add a condition.

## 6. Condition Editor

### Shared layout

```text
┌──────────────────────────────────┐
│ 取消       添加解锁条件      保存 │
│                                  │
│ 条件名称                         │
│ [例如：每周健身                 ] │
│                                  │
│ 条件类型                         │
│ [累计次数 ▾]                     │
│                                  │
│ 目标                             │
│ [20                         次] │
│                                  │
│ 说明（选填）                     │
│ [                              ] │
│                                  │
│                                  │
└──────────────────────────────────┘
```

Type-specific controls:
- STREAK: integer target, unit “天”; clearly explain consecutive-day semantics without guilt language.
- COUNT: numeric target and unit.
- DURATION: numeric target and time unit.
- AMOUNT: decimal-safe amount and currency/direction fields already supported by the domain.
- CHECKPOINT: completion-based configuration; do not show meaningless numeric input.
- CUSTOM: existing custom fields only.

Rules:
- Preserve current validation and Domain constraints.
- When editing a condition, show current progress context if changing target may affect completion.
- Do not invent a new confirmation workflow for target changes unless existing business logic requires it.

## 7. Record Editor

### Common structure

```text
┌──────────────────────────────────┐
│ 取消       记录行动          保存 │
│                                  │
│ 为这个心愿                         │
│ Kindle Paperwhite                │
│                                  │
│ 条件                             │
│ 阅读                             │
│                                  │
│ 本次完成                         │
│ [  1.5                       ] h │
│                                  │
│ 日期                             │
│ [今天                            ]│
│                                  │
│ 备注（选填）                     │
│ [                              ] │
│                                  │
│            [ 保存记录 ]           │
└──────────────────────────────────┘
```

### Type-specific behavior
- COUNT / DURATION / AMOUNT: show only relevant numeric input and unit.
- STREAK: one-tap completion for the valid day; prevent duplicate same-day completion according to existing ViewModel behavior.
- CHECKPOINT: clear completion action; avoid numeric field.
- CUSTOM: use only fields already supported by current model.
- Date and note appear only where supported by existing RecordEditorViewModel.
- Save error preserves all entered values.
- Successful save closes sheet and refreshes parent state.

### Acceptance
- [ ] No irrelevant input fields for a condition type.
- [ ] Units are visible beside values.
- [ ] Numeric entry uses appropriate keyboard and validation.
- [ ] Errors do not erase user input.
- [ ] Success refreshes condition, wish, and Today state.
- [ ] Unlock presentation is triggered only by existing coordinator/domain flow.

## 8. Condition Detail / History

### Prototype

```text
┌──────────────────────────────────┐
│ ‹                         编辑   │
│ 阅读                             │
│ 累计时长 · 目标 30 小时           │
│                                  │
│ 18 / 30 小时                     │
│ ━━━━━━━━━━━━━──────              │
│ 还差 12 小时                     │
│                                  │
│ 行动记录                    [+]  │
│ 今天       阅读       1.5 小时    │
│ 昨天       阅读       1 小时      │
│ 11 月 6 日  阅读       2 小时      │
└──────────────────────────────────┘
```

- Summary uses the current condition snapshot.
- Records are chronological according to current product behavior; newest first.
- Editing/deleting records uses existing flows.
- Delete requires confirmation.
- Empty history includes one clear “记录第一次行动” CTA.

## 9. Unlock Celebration

### Prototype

```text
┌──────────────────────────────────┐
│                            关闭  │
│                                  │
│          [Wish photo]            │
│                                  │
│         你做到了                 │
│                                  │
│   “Kindle Paperwhite” 已解锁     │
│                                  │
│   你完成了为它设定的 3 项条件     │
│                                  │
│        [ 领取这份奖励 ]           │
│             稍后再说             │
│                                  │
└──────────────────────────────────┘
```

- This is the one intentionally emotional moment.
- Use restrained scale/fade motion; no coins, points, or loud game visuals.
- User can dismiss and claim later.
- Claim button invokes existing UnlockCoordinator / lifecycle flow.
- Respect Reduce Motion.

## 10. Achievements

### Prototype

```text
┌──────────────────────────────────┐
│ 成就                             │
│                                  │
│ 你为自己完成了这些事             │
│                                  │
│  4 个已解锁      2 个已兑现       │
│                                  │
│ 已兑现                           │
│ [PHOTO] Kindle                   │
│         2026.10.12               │
│                                  │
│ 已解锁                           │
│ [PHOTO] 跑鞋                     │
│         2026.11.08               │
└──────────────────────────────────┘
```

- Real wishes and existing aggregate data only.
- No points, levels, invented medals, or leaderboard.
- Prioritize the wish image and title; dates are secondary.

## 11. Settings / My

- Keep current data export behavior.
- Use grouped settings rows with clear labels and native disclosure affordances.
- Explain export format and limitations accurately (JSON export; image binary inclusion must not be implied if not supported).
- Do not introduce account, sync, or profile requirements.

## 12. Global interaction checklist

- [ ] One primary action per screen.
- [ ] Destructive actions have explicit confirmation.
- [ ] Reversible actions do not create unnecessary confirmation friction.
- [ ] Sheets preserve input on failure.
- [ ] No duplicate navigation titles.
- [ ] All controls have VoiceOver labels and 44 pt targets.
- [ ] Dynamic Type does not truncate key actions.
- [ ] Reduce Motion is respected.
- [ ] No state is inferred in the View when the ViewModel / Domain already provides it.
- [ ] Every screenshot used for review comes from a real simulator build.
