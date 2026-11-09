# WishEarn Information Architecture

> Status: Proposed; preserve existing four-tab navigation and current product scope.

## 1. Navigation model

Keep the current four-tab structure:

- **心愿** — what I am working toward.
- **行动** — what I can record today.
- **成就** — what I have earned and completed.
- **我的** — data and app settings.

Each tab owns an independent NavigationStack. Detail and editor flows remain native push / sheet navigation. Unlock remains a full-screen presentation driven by UnlockCoordinator.

## 2. Screen map

```text
Tab: 心愿
  Wish List
    ├─ Filter: 全部 / 进行中 / 已解锁 / 已兑现 / 已暂停
    ├─ Create Wish (sheet)
    │   └─ Add / Edit Wish
    └─ Wish Detail
        ├─ Edit Wish (sheet)
        ├─ Add / Edit Condition (sheet)
        ├─ Condition Detail
        │   └─ Add / Edit Record (sheet)
        ├─ Pause / Resume
        ├─ Archive (only if current behavior supports it)
        └─ Claim Reward (when UNLOCKED)

Tab: 行动
  Today
    └─ Record Editor (sheet)
        └─ Save → refresh → possible Unlock presentation

Tab: 成就
  Achievements
    └─ Wish history / detail (only if existing navigation supports it)

Tab: 我的
  Settings
    └─ Data Export
```

## 3. Surface responsibilities

### 3.1 Wishes tab

Question answered: **“我正在为哪些东西努力？”**

Primary content:
- Active wishes first.
- Unlocked wishes next when present.
- Paused / completed wishes are discoverable through filters.
- Wish image and title dominate; progress is supporting context.

Do not turn this into a task list. The list is a collection of personal rewards, not a queue of chores.

### 3.2 Today tab

Question answered: **“今天我可以做哪一步？”**

Primary content:
- Conditions for which a record is meaningful today, according to existing ViewModel output.
- Clear distinction between actionable and already-completed-today items.
- One-tap access to the appropriate record editor.
- Empty state links conceptually back to creating a wish; do not add a second wish-creation flow if navigation cannot support it cleanly.

Important: Do not invent a daily requirement for COUNT, AMOUNT, CHECKPOINT, or CUSTOM conditions. Display only the items returned by TodayViewModel and respect their current canRecord / isDone semantics.

### 3.3 Wish detail

Question answered: **“我离这个奖励还有多远，已经做了什么？”**

Order:
1. Wish hero: image, title, price (if set), status.
2. Overall progress: completed condition count / total condition count.
3. Condition list: title, type, current / target, progress.
4. Recent records / effort history.
5. Lifecycle and edit actions.

### 3.4 Achievements

Question answered: **“我已经为自己做到过什么？”**

Prioritize real completed / unlocked wishes and existing aggregate counts. Do not invent points, ranks, badges, or streak awards.

### 3.5 Settings

Question answered: **“如何管理我的数据和应用？”**

Keep data export and existing settings discoverable. Destructive data actions require explicit confirmation and clear consequences.

## 4. Core user journeys

### Journey A — Create a wish and define conditions

1. Tap “+” on Wishes.
2. Enter title; optionally add photo, target price, description, target date.
3. Save.
4. Add at least one condition from Wish Detail.
5. Save condition.
6. Return to Wish Detail and see it represented in the condition list.

Design requirement: The editor must not imply that the wish is fully configured if it has no conditions. Provide a gentle next-step prompt.

### Journey B — Record progress

1. Open Today or Wish Detail.
2. Tap the record affordance on an actionable condition.
3. Show a type-specific editor.
4. Pre-fill sensible defaults only where current business semantics permit.
5. Save.
6. Dismiss sheet and refresh progress.
7. If the domain unlock event is emitted, show the existing unlock celebration.

### Journey C — Review a wish

1. Tap a WishCard.
2. Read the wish hero and overall condition completion.
3. Scan each condition's current / target value.
4. Open a condition for history and record management.
5. Use secondary actions for edit / pause / delete.

### Journey D — Claim a reward

1. A wish enters UNLOCKED through domain logic.
2. Celebration presents the wish image/title and completed-condition summary.
3. User can dismiss and claim later, or claim now.
4. Claim action transitions through existing lifecycle logic.
5. Wish appears as COMPLETED in list and achievements.

### Journey E — Manage a record

1. Open Condition Detail.
2. Inspect chronological record history.
3. Edit or delete a record through explicit row actions.
4. Show confirmation only for destructive deletion.
5. Refresh progress and reflect the recalculated result; do not implement unlock rules in the view.

## 5. Page state matrix

| Page | Empty | Loading | Error | Normal | Completed / special |
|---|---|---|---|---|---|
| Wish List | No wishes / no filter results | Initial load | Retry | Wish cards | Unlocked, completed, paused |
| Wish Detail | No conditions | Initial load if applicable | Retry | Hero + conditions | Unlocked / completed |
| Today | No actionable conditions | Initial load | Retry | Actionable rows | Completed-today section |
| Condition Detail | No records | Initial load | Retry | Progress + records | Target reached |
| Wish Editor | N/A | Saving | Inline / alert | Form | Saved and dismissed |
| Condition Editor | N/A | Saving | Inline | Type-specific fields | Saved and dismissed |
| Record Editor | N/A | Saving | Inline | Type-specific input | Saved and dismissed |
| Achievements | No earned wishes | Initial load | Retry | History and totals | Empty-to-populated transition |
| Settings | N/A | Exporting | Export error | Settings rows | Export completed |

## 6. Navigation and presentation rules

- Use NavigationStack push for detail pages.
- Use sheet for create/edit/record tasks that are short and contextual.
- Use fullScreenCover only for the unlock moment, as already implemented.
- Do not stack multiple sheets for a single action.
- Every sheet has a clear title, primary save action, and dismiss/cancel behavior.
- On save failure, keep the sheet open and preserve entered values.
- Destructive actions use confirmationDialog / alert with a clear object name.
- Avoid custom back gestures or replacing system navigation controls.
- Tab switching should not reset unrelated tab state unless current router behavior explicitly does so.

## 7. Scope and semantic constraints

- Current Domain and ViewModel outputs define what is actionable.
- UI must not calculate condition completion, wish unlock, streak resets, or aggregate values independently.
- Do not create notification, calendar, reminder, or social surfaces.
- Do not change the four tabs without product approval.
