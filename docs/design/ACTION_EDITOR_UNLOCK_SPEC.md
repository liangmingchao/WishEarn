# Action, Editor & Unlock Interaction Specification

> Companion to `SCREEN_SPECS.md`, `HIGH_FIDELITY_LAYOUTS.md`, and `CORE_SCREEN_INTERACTION_SPEC.md`.
> Defines the user experience contract for Today, Wish/Condition/Record editors, and Unlock Celebration.
> This document does not authorize new Domain behavior or product scope.

## 1. Scope and non-negotiable constraints

Covered:
- Today action companion.
- Wish create/edit.
- Condition create/edit for the existing condition types.
- Progress Record create/edit where the existing product supports it.
- Unlock Celebration and claim-later behavior.

Source-of-truth order:
1. Domain models, services, lifecycle rules, and existing use cases.
2. Existing ViewModels and coordinator events.
3. The established design system and screen specifications.
4. This document for presentation and interaction details.

Architecture constraints:
- SwiftUI Views render state and forward user intent; they do not calculate progress, validate business invariants, or decide whether a wish unlocks.
- ViewModels orchestrate existing use cases and expose presentation-ready state.
- Domain owns validation, progress, streak, and lifecycle semantics.
- Repository/persistence changes are out of scope.
- If a required state or field is not supported by the existing ViewModel/Domain, report the mismatch before implementation. Do not silently invent a new model field or behavior.
- No reminders, notifications, recurring schedules, social features, points, levels, or gamification are introduced by this work.

## 2. Today — action companion

### 2.1 Product role

Today answers: **“What meaningful action can I take today for the things I want?”**

It is not:
- A task manager with due dates.
- A daily habit checklist.
- A streak pressure dashboard.
- A list of every condition regardless of whether it can accept a record.

The page should make recording an action feel quick and low-friction, while preserving the wish as the reason behind the action.

### 2.2 Layout hierarchy

1. Header: “今天” and localized date.
2. Short contextual line: “今天可以推进这些心愿”.
3. Actionable conditions, grouped or ordered exactly as supplied by TodayViewModel.
4. A quieter “今天已记录” section when there are completed-today items.
5. Empty state when no actionable or completed-today content exists.

Action row anatomy:
- Wish title as a small context label.
- Condition title as the primary label.
- Current/target progress and unit as supporting text when meaningful.
- One “记录” action, enabled only when `canRecord` is true.
- Avoid redundant type/status badges.

Do not introduce a new sorting algorithm in the View. Preserve ViewModel ordering. If the ViewModel returns separate actionable and completed-today collections, render those collections without recomputing membership.

### 2.3 Actionable vs completed-today

Actionable:
- Render only items the ViewModel explicitly exposes as actionable.
- Show the condition's current progress snapshot if supplied.
- Record button opens the existing Record Editor for that exact condition.
- Do not label an item “今日必做”, “逾期”, or “未完成” unless the current domain explicitly supplies that meaning.

Completed today:
- Render only records/items that the ViewModel identifies as completed today.
- Use a quieter visual hierarchy, but retain readable condition and wish context.
- Do not show an active Record CTA for an item that cannot accept another record.
- For STREAK, respect the one-valid-record-per-local-natural-day rule; the UI must reflect ViewModel `canRecord` rather than independently comparing dates.

### 2.4 Today state matrix

| State | Presentation | Behavior |
|---|---|---|
| Actionable items exist | Action list first | Record an eligible item |
| Some items recorded today | Completed-today section below | Read-only confirmation unless ViewModel allows another record |
| No actionable items, completed items exist | Completed-today content with calm contextual copy | No fabricated task |
| No content | Editorial empty state: “心愿创建后，你的行动会出现在这里” | Go to Wishes tab or existing create flow only if navigation supports it |
| Paused wish | Follow ViewModel exclusion/inclusion behavior | Never invent a pause rule in View |
| Archived wish | Must not appear if existing Today use case excludes archived wishes | No special UI workaround |
| Loading/error | Existing loading/error state only | Existing retry action only |

### 2.5 Today interaction transitions

| Action | Result |
|---|---|
| Tap Record | Present Record Editor with wish and condition context preselected |
| Save record | Dismiss editor after success; refresh from ViewModel/source of truth |
| Save fails | Keep editor and entered values; show actionable error |
| Tap wish context, if currently navigable | Open corresponding Wish Detail |
| Tap condition title/row | Open Condition Detail only if that is current navigation behavior |
| Switch tabs | Preserve native tab behavior |

### 2.6 Today acceptance

- [ ] Actionable items are supplied by TodayViewModel.
- [ ] Completed-today items are not reconstructed by the View.
- [ ] Wish context is visually secondary to condition title.
- [ ] Only eligible items show an enabled Record action.
- [ ] No invented due dates, reminders, daily obligations, or overdue states.
- [ ] Empty state does not shame or pressure the user.
- [ ] Long titles, large text, and dark mode remain usable.


## 2.6 Current implementation contract and known gaps (reviewed against main)

The current main-branch implementation was inspected before planning UI work. The following are explicit integration facts; they do not change the intended product direction:

- `TodayViewModel.items` currently contains every condition for ACTIVE wishes, in repository-provided order. It does not expose separate actionable/completed-today collections or a cumulative progress snapshot for each condition. UI work must not claim those richer semantics already exist.
- `TodayConditionItem.isDone` currently treats STREAK as done when a record exists today, CHECKPOINT as done when any historical record exists, and COUNT/DURATION/AMOUNT/CUSTOM as never done for the day. This means CHECKPOINT's current “done” meaning is lifetime completion, not “recorded today”; do not relabel it as a completed-today fact. This should be reviewed as a ViewModel/product-semantics gap before redesigning Today grouping.
- COUNT/DURATION/AMOUNT/CUSTOM Today rows currently show today's recorded amount when present, not the condition's cumulative progress. A cumulative snapshot requires a presentation-ready value from the existing progress service/ViewModel; it must not be aggregated in the View.
- `ConditionEditorView` currently makes condition type read-only while editing. Preserve this behavior. Type-specific controls apply to creation and to the existing type when editing; do not expose type switching during edit without an explicit Domain migration/update decision.
- `RecordEditorViewModel` currently receives a Condition, not a Wish, and the editor has no wish-title context. Adding that context requires a small presentation-factory/ViewModel contract change. Keep the condition context as the current baseline until that change is explicitly included in the implementation issue.
- The current Record Editor has no delete-record action. Do not add record deletion as part of visual redesign. If product wants it later, create a separate business/UX task with recalculation and unlock-regression rules.
- `UnlockCoordinator` currently presents a Wish and the count of all conditions, claims via the existing lifecycle `complete` use case, and dismisses the presentation for “later”. It does not expose a persisted unlock snapshot in the presentation model. Do not describe the count as an immutable unlock-time snapshot unless the implementation is changed and approved.

These gaps must be listed in the implementation plan with an owner and disposition (preserve current behavior, make a scoped ViewModel enhancement, or defer). They must not be hidden by view-side calculations.

## 3. Wish Editor — create and edit

### 3.1 User job

Capture a desired reward before asking the user to define the effort behind it.

The editor should feel like writing a short personal intention, not filling out a product database form.

### 3.2 Information hierarchy

1. Navigation bar: Cancel / “新建心愿” or “编辑心愿” / Save.
2. Wish image picker area.
3. Required wish title.
4. Optional price.
5. Optional reason/description.
6. Optional target date only if currently supported.

Do not add category, tags, shopping URL, budget, account, or recommendation fields.

### 3.3 Field behavior

| Field | Required | Interaction | Guidance |
|---|---|---|---|
| Image | No | Existing PhotosPicker/image flow | Large visual invitation; never block save |
| Title | Yes | Single-line text input, may expand/scroll for long content | Placeholder: “例如：Kindle Paperwhite” |
| Target price | No | Decimal/currency-aware input if supported | Optional metadata; do not assume a currency |
| Description/reason | No | Multiline text | Prompt: “为什么这件事对你重要？” |
| Target date | No | Native date picker if supported | Must not imply a deadline or overdue behavior |

Currency:
- Use the wish's existing currency code and formatter.
- Do not hardcode ¥ or infer currency from locale.
- If the model stores price and currency separately, preserve both on edit.
- If the current UI does not support currency selection, do not add it as part of this visual task without product review.

### 3.4 Validation and save behavior

- Title is the only required field according to the current screen contract.
- Trim whitespace for validation using existing ViewModel rules.
- Inline validation should be concise and placed adjacent to the title.
- Save is disabled while title is invalid or a save is in progress, if the ViewModel exposes these states.
- Cancel with no edits dismisses immediately.
- Cancel with unsaved edits follows the existing discard policy; if none exists, propose a minimal confirmation for review rather than silently losing input.
- Persistence failure keeps all entered values and image selection.
- Successful creation follows the existing navigation flow to Wish Detail.
- Do not auto-create conditions after wish creation. A gentle next-step prompt may be shown on Detail.

### 3.5 Image selection states

| State | Presentation |
|---|---|
| No image | Neutral surface, restrained photo symbol, “添加心愿照片” |
| Picker open | Use native PhotosPicker |
| Image selected | Preview crop consistent with Home and Detail |
| Replacing image | Allow selecting another image through existing flow |
| Image load/save error | Keep title and other fields; show a local error and allow retry |
| Existing image during edit | Show current image before replacement |

- Do not add remote image search or external image dependencies.
- Do not discard the existing image merely because the picker is opened and cancelled.
- If the current implementation has image size/format limits, preserve them and expose a clear error.

## 4. Condition Editor — type-aware configuration

### 4.1 User job

Help the user define a clear, achievable condition for unlocking a wish.

The user should understand what counts as progress before saving.

### 4.2 Shared form hierarchy

1. Navigation bar: Cancel / “添加解锁条件” or “编辑解锁条件” / Save.
2. Condition title.
3. Condition type.
4. Type-specific target/configuration.
5. Optional description.
6. Existing progress context when editing and when supplied by the ViewModel.

The form must adapt to the selected type. Never show a generic numeric target field for every type.

### 4.3 Type-specific interaction matrix

| Type | Main input | Unit/semantics | UI guidance |
|---|---|---|---|
| STREAK | Positive integer target | Consecutive local calendar days | Explain “连续完成”，not total accumulated days |
| COUNT | Positive numeric target | Existing unit field | Example: “完成 20 次运动” |
| DURATION | Positive decimal-safe target | Existing time unit | Example: “累计阅读 30 小时” |
| AMOUNT | Decimal-safe target | Existing currency and direction fields | Explain whether it represents income/saving/other only as defined by Domain |
| CHECKPOINT | Completion-based; no numeric target control | One explicit completion action | Example: “完成个人项目” |
| CUSTOM | Existing custom configuration only | Follow current model semantics | Do not invent custom fields or interpretation |

### 4.4 Type switching

- During creation, when the user changes type, show only fields relevant to the selected type. During edit, preserve the current implementation's read-only type display.
- Preserve compatible values only when the existing ViewModel explicitly supports that mapping.
- Do not silently reinterpret a COUNT value as a DURATION or AMOUNT value.
- Do not implement type switching during edit; any future support requires a separately reviewed Domain update contract.
- When editing an existing condition, initialize all controls from persisted values.
- Do not change a condition's type as a side effect of opening the editor.

### 4.5 Editing an existing target

- Show a compact “当前进度” context if the ViewModel provides a snapshot.
- Make it clear that the target is being edited, not the historical records.
- Preserve current progress and records according to Domain behavior.
- Do not add a custom destructive confirmation unless current business logic requires it.
- If reducing the target can affect completion/unlock state, defer to the existing use case and show its returned result. Do not calculate the impact in the View.
- Any unsupported target mutation behavior must be reported before implementation.

### 4.6 Validation

- Reuse Domain/ViewModel validation and error types.
- STREAK target must remain a positive integer.
- COUNT/DURATION/AMOUNT must follow existing positivity, precision, and unit constraints.
- CHECKPOINT must not display a meaningless numeric field.
- Inline validation appears next to the relevant field.
- Invalid submission must not erase any entered value.
- Disable repeated Save while a submission is in progress if that state is exposed.

### 4.7 Condition editor acceptance

- [ ] Every condition type has a distinct, relevant input experience.
- [ ] STREAK explicitly communicates consecutive-day semantics.
- [ ] Amount direction/currency controls appear only where supported.
- [ ] CHECKPOINT is completion-based.
- [ ] Type changes do not silently reinterpret values.
- [ ] Editing preserves persisted configuration and progress context.
- [ ] All validation comes from existing ViewModel/Domain rules.

## 5. Record Editor — record the effort

### 5.1 User job

Make it effortless to record a real action, with enough context to trust the result.

The editor should answer:
- Which wish am I advancing?
- Which condition am I recording?
- What value should I enter?
- On what date did it happen?

### 5.2 Common layout

1. Navigation bar: Cancel / “记录行动” / Save.
2. Wish context (read-only).
3. Condition title and type context (read-only).
4. Type-specific value input.
5. Date only if supported by the existing RecordEditorViewModel.
6. Optional note only if supported.
7. Inline validation/error feedback.

Avoid repeating the same wish/condition information in multiple cards.

### 5.3 Type-specific record interaction

| Condition type | Record interaction | Do not show |
|---|---|---|
| COUNT | Numeric amount for this occurrence + unit | Duration or amount-direction controls |
| DURATION | Decimal-safe duration + time unit | Generic count-only wording |
| AMOUNT | Decimal-safe amount with existing currency/direction context | Unrelated duration controls |
| STREAK | One explicit “今天完成”/valid-day action, respecting ViewModel eligibility | Arbitrary multi-day numeric entry |
| CHECKPOINT | One clear completion action | Numeric amount input |
| CUSTOM | Only the fields already supported by the current model/ViewModel | Invented custom controls |

New-record defaults:
- COUNT and CUSTOM prefill `1`; the user can save immediately for the common single action.
- DURATION and AMOUNT remain blank; a default of 1 would be too easy to save as an unintended 1 minute / 1 unit.
- Editing an existing record always initializes the stored value and never replaces it with the default.

For STREAK:
- Respect local-calendar-day semantics from Domain.
- Respect the one-valid-record-per-natural-day rule.
- If already recorded today, show a non-editable “今天已记录” state unless the existing edit flow permits changing that record.
- Do not independently calculate whether today is eligible.

For CHECKPOINT:
- Use a clear completion confirmation action.
- If the current model permits a note/date, show them only when supported.
- Never render “1 / 1” as a fake numeric metric unless that is the actual ViewModel presentation.

### 5.4 Date and note

- Date and note are optional UI fields only if the existing RecordEditorViewModel supports them.
- Use native date/time controls and localized formatting.
- Do not allow a date outside the existing business constraints.
- Editing an existing record must initialize the original date/value/note.
- Date editing must not bypass STREAK duplicate-day validation.

### 5.5 Save, edit, and delete behavior

Create:
- Validate before submission using the ViewModel.
- Keep entered values on failure.
- On success, dismiss and refresh the parent screen from authoritative state.
- If the new record causes unlock, rely on the existing domain event/coordinator. Do not present an unlock screen from the Record Editor itself.

Edit:
- Prepopulate all fields from the selected record.
- Save changes through the existing update flow.
- Recalculate progress through Domain after success.
- Do not locally patch progress totals in the View.

Delete:
- Destructive action is secondary and visually separated from Save.
- Require explicit confirmation.
- Confirmation names the consequence in plain language, e.g. “删除这条记录后，相关心愿进度可能发生变化。”
- On failure, keep the record visible and report the error.
- On success, refresh parent state and allow the Domain lifecycle result to determine any state change.

### 5.6 Record editor acceptance

- [ ] Wish and condition context are clear and read-only.
- [ ] Input controls match condition type.
- [ ] Units and decimal precision are explicit.
- [ ] STREAK eligibility is supplied by ViewModel.
- [ ] Save errors preserve all values.
- [ ] Edit initializes original record values.
- [ ] Delete is confirmed and uses the existing flow.
- [ ] Parent progress refreshes from authoritative state.
- [ ] Unlock is triggered only through existing event/coordinator flow.

## 6. Unlock Celebration — the emotional payoff

### 6.1 Product role

Unlock is the emotional payoff of WishEarn: the user has completed the conditions they chose for something they genuinely wanted.

It should feel meaningful, personal, and warmly celebratory — not like a casino reward, game achievement, or financial transaction. The celebration may be more expressive than the rest of the app, but it must stay in the paper editorial language.

### 6.2 Visual composition

Recommended hierarchy:
1. Small kicker: “心愿达成” with two small sparkles.
2. Wish image as the visual anchor, framed as a paper photo card with an “已达成” stamp.
3. Short emotional headline: “你做到了”.
4. Wish title: “「{wish title}」已解锁”.
5. Factual supporting line based on the unlock snapshot, if available.
6. Primary CTA: “领取这份奖励”.
7. Secondary text action: “稍后再说”.

Layout:
- Centered composition with generous vertical whitespace; content scrolls, while the primary CTA is pinned above the safe area.
- Image uses a large rounded crop, max width around 320 pt on standard iPhone.
- Headline uses the editorial display style.
- A brief one-shot star burst radiates from the photo; it fades out and must not remain over the text.
- The CTA uses the ink capsule and the established 56 pt height.
- Secondary action remains visible but quiet.
- Do not place unrelated metrics, progress charts, or navigation tabs in the celebration surface.

### 6.2.1 Claimed state

After a successful claim, keep the celebration on screen and switch to a second state:
- Kicker “奖励已领取” + an “已领取” stamp on the photo.
- Headline: “这份奖励，属于你了”.
- A small receipt with 领取日期 and 完成条件.
- Copy: “它会留在成就页，提醒你曾经认真对待过这个心愿。”
- Primary CTA: “完成”. Only this action dismisses; the wish is already completed at this point.
- A success haptic and, under VoiceOver, an announcement “奖励已领取”。

This second state is presentation-only; completion is still performed by the existing lifecycle service.

### 6.3 Copy rules

Preferred:
- “你做到了”
- “「{心愿名称}」已解锁”
- “你完成了为它设定的 {N} 项条件” only when the unlock snapshot supplies that factual count.
- “领取这份奖励”
- “稍后再说”

Avoid:
- “恭喜升级”
- “获得 XX 积分”
- “连续打卡挑战成功”
- “再接再厉，不要松懈”
- Any claim about time saved, money earned, or effort spent unless the event snapshot provides it.

### 6.4 Entry and dismissal behavior

- Celebration is presented only from the existing UnlockCoordinator/domain event path.
- It must not be triggered by a View comparing progress values.
- If the user chooses “稍后再说” or dismisses the surface, the wish remains in the authoritative UNLOCKED state.
- The app must preserve the ability to claim later through the existing Wish Detail entry point.
- Avoid showing the same celebration repeatedly on every navigation/re-render. Respect the coordinator's existing event-consumption semantics.
- If an unlock event is pending on app launch, follow existing recovery behavior; do not create a second event.

### 6.5 Claim behavior

- Primary CTA invokes the existing claim/complete lifecycle use case.
- Disable repeated claim submission while in progress if exposed by the ViewModel.
- On success, dismiss celebration and render the authoritative completed state.
- On failure, keep the celebration visible and show a concise recoverable error; do not mark the wish completed locally.
- Do not assume claiming means purchasing, shipping, or external fulfillment. It means the user acknowledges/claims the reward according to current Domain semantics.

### 6.6 Motion and haptics

- Entry: restrained fade + small scale transition.
- Image may receive a subtle reveal; avoid continuous motion.
- No coins, confetti storms, fireworks, spinning wheels, or loud sound.
- Haptic feedback is optional and subtle.
- Reduce Motion removes nonessential scale/movement while preserving the reveal and clear state transition.
- Never make motion/haptics the only indication that unlock succeeded.

### 6.7 Accessibility

- VoiceOver order: wish image description (if meaningful), headline, wish title, factual supporting text, primary CTA, secondary action.
- Decorative image treatment may be hidden from accessibility if it adds no information.
- CTA labels must describe the action, not merely “按钮”.
- Support Dynamic Type and high contrast.
- Focus should move into the presented celebration and return predictably when dismissed.

## 7. Cross-flow state and transition contract

| Starting point | Action | Expected result |
|---|---|---|
| Today | Record an eligible condition | Record Editor opens with context |
| Record Editor | Save success, no unlock | Dismiss; Today and Detail refresh |
| Record Editor | Save success, unlock event | Existing coordinator presents celebration |
| Record Editor | Save failure | Stay open; preserve input |
| Wish Detail | Add condition | Condition Editor opens |
| Condition Editor | Save success | Dismiss; Detail refreshes authoritative state |
| Wish Detail | Edit wish | Wish Editor opens in edit mode |
| Wish Editor | Save success | Dismiss; Detail reflects saved data |
| Unlock Celebration | Later/dismiss | Wish remains UNLOCKED; can claim later |
| Unlock Celebration | Claim success | Existing lifecycle flow marks completed; stay on the “已领取” receipt state; 完成 dismisses and Detail refreshes |
| Unlock Celebration | Claim failure | Remain unlocked; show recoverable error and keep the claim action available |

## 8. Preview and QA matrix

Provide SwiftUI previews or test fixtures where practical. Do not create fake production data.

### Today
- [ ] Actionable COUNT item.
- [ ] Actionable DURATION item.
- [ ] STREAK already recorded today.
- [ ] Completed-today section populated.
- [ ] Empty state.
- [ ] Long wish/condition titles.

### Wish Editor
- [ ] Create, no image.
- [ ] Create, selected image.
- [ ] Edit, existing image.
- [ ] Invalid/empty title.
- [ ] Save failure retaining input.

### Condition Editor
- [ ] STREAK.
- [ ] COUNT.
- [ ] DURATION.
- [ ] AMOUNT.
- [ ] CHECKPOINT.
- [ ] CUSTOM only if supported.
- [ ] Editing existing condition with progress context.
- [ ] Validation failure.

### Record Editor
- [ ] COUNT/DURATION/AMOUNT numeric entry.
- [ ] STREAK eligible and already-recorded-today states.
- [ ] CHECKPOINT completion.
- [ ] Edit existing record.
- [ ] Delete confirmation.
- [ ] Save failure.
- [ ] Save success causing unlock event.

### Unlock
- [ ] First presentation.
- [ ] Dismiss/later and return to Detail.
- [ ] Claim success.
- [ ] Claim failure.
- [ ] Reduce Motion.
- [ ] Dynamic Type and VoiceOver.

For all applicable screens:
- [ ] Light and dark appearance.
- [ ] Small and large device widths.
- [ ] Dynamic Type accessibility sizes.
- [ ] VoiceOver labels and focus order.
- [ ] Minimum 44 × 44 pt interaction targets.
- [ ] Real simulator screenshots for review.
- [ ] Required Build/Test workflow passes.

## 9. Implementation boundary

This design task does not authorize:
- New Domain fields or enum cases.
- New progress calculation logic.
- New unlock or claim semantics.
- New notification/reminder scheduling.
- Cloud sync, accounts, or remote image search.
- New product features or additional tabs.

When a specification and current implementation disagree:
1. Identify the exact ViewModel/Domain contract involved.
2. Explain the user-facing impact.
3. Propose the smallest compatible solution.
4. Wait for product/architecture approval before expanding scope.
