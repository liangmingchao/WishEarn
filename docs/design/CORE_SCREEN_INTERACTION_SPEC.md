# Core Screen Interaction & State Specification

> Companion to `SCREEN_SPECS.md` and `HIGH_FIDELITY_LAYOUTS.md`.
> This document defines behavior and state presentation for the Wishes Home and Wish Detail screens.
> It is a UI implementation contract, not a change to Domain rules.

## 1. Scope and source of truth

This specification covers:
- Wishes Home: initial, populated, filtered, empty, loading/error (only where supported by the existing data flow), and lifecycle states.
- Wish Detail: active, paused, unlocked, completed, no-condition, no-record, and mutation states.
- Navigation and presentation transitions between the two screens and existing editor/record flows.

Source of truth order:
1. Existing Domain model and business rules.
2. Existing ViewModel outputs and use cases.
3. `DESIGN_SYSTEM.md`, `SCREEN_SPECS.md`, and `HIGH_FIDELITY_LAYOUTS.md`.
4. This document for interaction details not already specified above.

If the current implementation cannot represent a state described here, do not fabricate it in the View. Report the mismatch and propose the smallest ViewModel/domain-compatible adjustment for review.

## 2. Global interaction principles

- Every tappable element must have one obvious outcome.
- The whole wish card is one navigation target. Do not nest separate buttons inside it.
- A primary action should be visually dominant; secondary actions use quiet text or toolbar affordances.
- Prefer reversible actions without confirmation. Confirm destructive actions.
- Preserve entered form values after validation or persistence errors.
- Do not use color as the only state indicator.
- State labels must be factual, concise, and consistent across Home and Detail.
- Do not derive progress, completion, unlock eligibility, or lifecycle transitions in SwiftUI Views.
- UI may format values already supplied by the ViewModel, but must not independently aggregate records or infer a lifecycle state.

## 3. Wishes Home

### 3.1 Information hierarchy

Order from highest to lowest emphasis:
1. Page title and concise active-wish context.
2. One featured active wish (only when one exists).
3. Other wishes in the current selected filter.
4. Filter control.
5. Add-wish affordance.

The Add affordance remains reachable in the navigation bar. The empty state may repeat the same create action as its single primary CTA.

Do not add a dashboard summary, streak summary, total effort chart, or multiple competing KPI cards.

### 3.2 Featured wish selection

- Feature only an active wish.
- Use the first eligible item from the existing ViewModel-provided ordering.
- Do not sort by price, progress percentage, target date, creation date, or a new relevance score in the View.
- If the current selected filter is not the active state, do not force an unrelated active wish into the featured slot. Render the selected result set consistently.
- When there is no eligible active wish, omit the featured section and allow the list/empty state to lead.
- The featured wish must not also appear in the secondary list.

If the ViewModel does not expose a stable order or a clear active-state classification, stop and report the gap rather than inventing view-side ranking logic.

### 3.3 Filter behavior

- Keep the filter set aligned with existing lifecycle filters. Do not introduce new categories.
- Selecting a filter updates the visible result set without navigating away.
- Preserve the selected filter when returning from Wish Detail during the same screen session, unless existing navigation behavior intentionally recreates the screen.
- The selected filter must be communicated accessibly (selected state, not color alone).
- A filter with zero results shows a filter-specific empty state:
  - Title: “这里暂时没有心愿”
  - Supporting text should name the selected state where practical.
  - Action: “查看全部” resets to the all-wishes filter.
- The first-use empty state is different and explains the product value; it offers “创建第一个心愿”.
- Do not show the first-use empty state when wishes exist but are excluded by the selected filter.

### 3.4 Wish card anatomy

Featured card:
- Image is the primary visual anchor.
- Wish title is the strongest text element.
- Price is optional and secondary; omit it when absent.
- Show one progress statement: “已完成 x / y 项条件”.
- Supporting status copy is optional and must not repeat the progress statement.
- Use a progress bar only when the ViewModel provides a meaningful progress value.
- Entire card navigates to Wish Detail.

Secondary row:
- Thumbnail, title, concise lifecycle label or progress summary.
- Avoid a second progress bar if it makes the list dense.
- Entire row navigates to Wish Detail.
- Long titles wrap or truncate gracefully without pushing essential status off-screen.

Image behavior:
- Missing image uses a designed neutral placeholder, not a random stock image.
- Preserve the image's intended crop and aspect ratio.
- Image loading failure must not collapse the card or block navigation.

### 3.5 Home transitions

| User action | Expected result |
|---|---|
| Tap Add | Present existing Wish Editor create flow |
| Save first wish | Follow existing flow to Wish Detail; do not silently create conditions |
| Tap featured/secondary wish | Navigate to its Wish Detail |
| Change filter | Update visible wishes in place |
| Tap “查看全部” | Reset filter to all |
| Return from Detail | Reflect latest ViewModel state; retain filter when possible |
| Delete/archive a wish, if supported | Remove/update it according to repository/ViewModel result; do not optimistically invent success |

### 3.6 Home state matrix

| State | Presentation | Primary action |
|---|---|---|
| First use, no wishes | Editorial empty state and short explanation | Create first wish |
| Populated, active wishes | Featured active wish + remaining list | Open a wish |
| Populated, no active wish | List and lifecycle context; no fake featured card | Open a wish |
| Selected filter has no results | Filter-specific empty state | View all |
| Image unavailable | Stable placeholder with normal card layout | Open a wish |
| Data loading/error | Use existing loading/error state if exposed | Existing retry behavior only |

## 4. Wish Detail

### 4.1 Information hierarchy

1. Navigation controls and wish image.
2. Wish title.
3. Lifecycle status and optional price.
4. Progress summary (only when meaningful).
5. Conditions and their record actions.
6. Recent effort records.
7. Secondary lifecycle/edit actions.

The page should read as a story of the reward and the effort behind it, not as a settings form.

### 4.2 Lifecycle-specific presentation

**Active**
- Show progress summary and all conditions.
- Record action appears only for conditions the ViewModel says can accept a record.
- If there are no conditions, show the dedicated onboarding empty state and “添加第一个解锁条件”.
- Avoid urgent or overdue language.

**Paused**
- Clearly label the wish as paused.
- Explain that existing progress is preserved only if that is the actual domain behavior.
- Replace active record prompts with a clear Resume action where supported.
- Do not visually imply progress was lost or reset.

**Unlocked**
- Present the unlocked state as a meaningful milestone.
- Replace effort-oriented primary CTA with “领取奖励”.
- Do not present “继续努力” or allow new effort actions unless current domain rules explicitly permit them.
- Claim action must go through the existing lifecycle/coordinator flow.

**Completed / redeemed**
- Use a quiet completed treatment.
- Show completion/redemption date only when available.
- Do not show a claim CTA after the reward has already been claimed.
- Keep historical conditions and records readable.

If the app's actual lifecycle enum differs, map these labels only through an explicit ViewModel presentation mapping. Do not compare ad-hoc strings in the View.

### 4.3 Condition rows

Each row should communicate, in order:
1. Condition name.
2. Condition type/target context.
3. Current progress and target, when the type has quantitative progress.
4. Completion status.
5. A contextual record action when allowed.

Behavior:
- Tapping the row opens Condition Detail/History.
- Tapping “记录一次” opens the existing Record Editor for that condition.
- Keep row navigation and record action as separate hit targets with no ambiguous overlap.
- Completed conditions remain visible; they are evidence of progress.
- If ordering is user-controlled or defined by the current model, preserve it. Do not introduce a new sort.
- CHECKPOINT-like conditions must not display a meaningless numeric progress bar.
- STREAK values must respect the existing positive-integer semantics.
- A condition that cannot accept a record must not show an enabled record CTA.

### 4.4 Recent effort records

- Render only persisted records supplied by the ViewModel.
- Use the existing ordering (expected newest first only if the current ViewModel guarantees it).
- Each record should show a concise date, condition/action context, and value where relevant.
- If there are no records, omit the section or show a quiet empty hint; do not insert sample records.
- If the ViewModel supplies a limited recent subset, do not fetch or aggregate additional history in the View.

### 4.5 Detail transitions

| User action | Expected result |
|---|---|
| Tap back | Return to Home with filter/context preserved where possible |
| Tap wish edit | Present existing Wish Editor in edit mode |
| Tap Add Condition | Present existing Condition Editor |
| Tap condition row | Navigate to Condition Detail/History |
| Tap record CTA | Present Record Editor for that condition |
| Save record | Dismiss editor, refresh detail from source of truth |
| Record causes unlock | Let existing Domain/coordinator flow trigger Unlock Celebration |
| Tap claim reward | Invoke existing claim/lifecycle flow |
| Resume paused wish | Invoke existing resume use case; refresh from returned state |
| Delete wish, if supported | Confirm destructive intent, then use existing delete flow |

### 4.6 Detail state matrix

| State | Progress area | Conditions | Primary action |
|---|---|---|---|
| Active with incomplete conditions | Current progress | Full list, eligible record actions | Record effort |
| Active, all conditions appear complete but lifecycle not yet changed | Trust ViewModel lifecycle; do not infer unlock | Full list | No fabricated claim CTA |
| Active, no conditions | Replace empty progress with guidance | Condition empty state | Add first condition |
| Paused | Preserve factual progress snapshot | Readable, no misleading active CTA | Resume |
| Unlocked | Milestone presentation | Read-only or domain-permitted actions | Claim reward |
| Completed/redeemed | Quiet completion summary | Historical list | No claim action |
| No recent records | No placeholder activity | Conditions remain primary | Record an eligible condition |

### 4.7 Mutation and error behavior

- Save operations are initiated through existing ViewModel actions.
- Disable duplicate submission while a save is in progress if the ViewModel exposes a saving state.
- Show errors close to the action/form that caused them.
- Never clear the current screen or user input on failure.
- On success, render the authoritative updated state from the ViewModel/repository.
- Avoid optimistic progress increments unless the existing architecture explicitly supports and reconciles them.
- If an operation changes lifecycle state, wait for the authoritative state/coordinator event before presenting the corresponding state.

## 5. Motion and feedback

- Navigation: native navigation transition.
- Filter change: short, subtle content transition; no springy card choreography.
- Record success: concise confirmation, then authoritative refreshed values.
- Unlock: use the dedicated Unlock Celebration; do not duplicate celebration effects on Home and Detail.
- Reduce Motion: remove nonessential movement while preserving state-change clarity.
- Haptics are optional and must remain subtle; do not make them the only success signal.

## 6. Accessibility and content

- Card and row accessibility labels should include wish title and relevant status/progress in a natural order.
- Do not expose decorative image placeholders as meaningful content.
- Use explicit accessibility actions for distinct controls; avoid one giant accessibility element that hides the Record action.
- Minimum interactive target: 44 × 44 pt.
- Support Dynamic Type without clipping titles, progress text, or primary actions.
- Localized dates/numbers/currency use existing formatters; do not hardcode a currency symbol or locale assumption.
- Avoid color-only distinctions between Active, Paused, Unlocked, and Completed.

## 7. Agent implementation checklist

- [ ] Read all five existing design documents before implementation.
- [ ] Inspect the current Home/Detail ViewModels and Domain lifecycle definitions.
- [ ] Record any mismatch between the current model and this specification before changing architecture.
- [ ] Implement Home and Detail without view-side business calculations.
- [ ] Preserve existing navigation, persistence, and coordinator flows.
- [ ] Add previews or fixtures for every state in the matrices where practical.
- [ ] Verify light and dark appearance.
- [ ] Verify Dynamic Type and VoiceOver.
- [ ] Verify Reduce Motion.
- [ ] Attach real simulator screenshots for populated, empty, paused, unlocked, and completed states where those states are reachable.
- [ ] Run the repository's required Build/Test workflow and report exact results.
- [ ] Do not expand scope into Today, editors, or new product features in this screen task.

## 8. Design review gate

The Home and Detail implementation is not ready for approval until:
- The visual hierarchy matches the Editorial Reward Journal direction.
- Every state above is either implemented or explicitly marked unsupported by the current Domain/ViewModel contract.
- No fabricated data, UI-side progress aggregation, or UI-side unlock inference exists.
- Screenshots demonstrate both the happy path and meaningful edge states.
