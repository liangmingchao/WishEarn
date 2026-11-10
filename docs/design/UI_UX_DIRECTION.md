# WishEarn UI / UX Direction

> Status: Design proposal for product review
> Baseline: `main` after PR #6 merge
> Scope: Experience and presentation only. Existing Domain rules and data semantics remain authoritative.

## 1. Product promise

**让每一份想要，都有值得付出的努力。**

WishEarn is not a task manager, habit tracker, shopping list, or finance app. It is a personal reward journey:
- The **wish** is the emotional reason to return.
- The **conditions** explain what must happen before the reward is earned.
- The **records** are evidence of effort, not chores to clear.
- The **unlock** is a meaningful milestone, not a gamified score.

The interface must answer three questions quickly:
1. What am I working toward?
2. What progress have I already made?
3. What is the next meaningful action?

## 2. Audience and usage moments

Primary user: someone who has a personally meaningful reward and wants to connect it to deliberate effort.

High-frequency moments:
- Open the app and feel reminded of a wish.
- Check whether today's action is still outstanding.
- Record a completed activity in a few seconds.
- Review progress and feel that effort is accumulating.
- Reach unlock and decide whether to claim the reward.

Emotional requirements:
- Encourage without guilt.
- Celebrate without childish game mechanics.
- Make partial progress feel worthwhile.
- Never imply failure because a user skipped a day.

## 3. Direction evaluation

### Direction A — Editorial / Premium Wishlist

Characteristics:
- Strong wish photography and typography.
- Magazine-like composition and generous negative space.
- Restrained color; image and wish title carry the emotional weight.
- Progress shown as useful information rather than decoration.

Strengths: gives the product a recognizable identity; makes the reward feel tangible; differentiates WishEarn from task apps.

Risks: can become too static or shopping-catalog-like if actions are hidden.

### Direction B — Warm Progress Companion

Characteristics:
- Soft neutral canvas, friendly microcopy, small progress cues.
- Clear daily action affordances.
- Gentle completion feedback.

Strengths: approachable and effective for frequent logging.

Risks: can drift into generic habit tracker visuals, excessive badges, streak pressure, and repetitive cards.

### Recommendation — A as the visual identity, B as the interaction temperature

Adopt **Editorial Reward Journal**:
- A owns visual hierarchy, image treatment, typography, and page composition.
- B informs tone, feedback, and action affordances.
- The product remains calm, tactile, and optimistic; not luxurious to the point of coldness, and not cute or game-like.

## 4. Experience principles

1. **Wish-first:** On the home tab, wish image and title outrank metrics.
2. **Effort is evidence:** Show meaningful progress and recent records; avoid points, levels, leaderboards, or streak-loss warnings.
3. **One obvious next step:** Each screen has one primary action.
4. **Progressive disclosure:** Keep secondary actions in menus, swipe actions, or detail screens.
5. **Fast logging:** A common record should take one tap to open and one confirmation to save; only ask for fields relevant to the condition type.
6. **Respect user agency:** Pause, edit, archive, and delete actions must be clear and non-judgmental.
7. **Earned celebration:** Unlock is a distinct full-screen moment, but dismissible and never blocks access to the app.
8. **Native accessibility:** Dynamic Type, VoiceOver, Reduce Motion, sufficient contrast, and native navigation conventions.

## 5. Brand and visual language

Brand keywords: intentional, personal, tactile, calm, optimistic, earned.

Avoid:
- Dense dashboard grids.
- Rainbow progress colors.
- Multiple badges on one card.
- Heavy gradients and glass effects as decoration.
- Cartoon mascots, XP, coins, rankings, or punishment language.
- Making a missing wish image look like a broken image placeholder.

Use a soft ivory canvas with a single deep petrol-teal accent and eucalyptus-mint containers. The editorial composition stays; the palette should feel fresh and optimistic rather than warm/terracotta. Color must communicate role, not decorate every element.

## 6. Content and microcopy

Prefer:
- “继续为它努力”
- “今天想完成哪一步？”
- “已累计 12 次”
- “还差 8 次”
- “这个心愿已经解锁”
- “准备好领取这份奖励了吗？”

Avoid:
- “你落后了”
- “连续记录中断”
- “失败”
- “必须完成”
- “再不努力就……”

For STREAK, describe progress factually (e.g. “连续 6 / 30 天”) and never shame the user for a reset.

## 7. Information hierarchy by surface

### Wishes
1. Wish image and title.
2. Status / price only when useful.
3. Overall completion and completed-condition count.
4. Secondary metadata (target date, notes) only on detail.

### Today
1. What needs attention today.
2. Which wish the action supports.
3. Quick record action.
4. Completed-today items lower in the page.

### Wish detail
1. Wish hero.
2. Overall progress and status.
3. Conditions with per-condition progress.
4. Recent effort history.
5. Secondary lifecycle actions.

### Achievement
1. Earned / claimed wishes.
2. A few meaningful totals.
3. Chronological history.

## 8. Interaction tone

- Use short, specific labels.
- Confirm destructive actions; do not confirm reversible actions unnecessarily.
- After saving a record, show updated progress immediately and a subtle success acknowledgement.
- If a record completes a condition but not the wish, explain the next condition status.
- If a record unlocks the wish, hand off to the existing unlock coordinator.
- Errors must preserve user input and provide a retry path.

## 9. Scope guardrails

This design does not authorize:
- New business condition types or condition-combination logic.
- Social sharing, public profiles, leaderboards, points, levels, reminders, or cloud sync.
- Changing progress calculation or unlock rules.
- Replacing MVVM, Repository, SwiftData, or the existing navigation architecture.
- Removing existing filters, editing, pause/resume, export, or accessibility behavior.

## 10. Review decisions

Product review should confirm:
- Editorial Reward Journal as the direction.
- Home page prioritizes wishes, not today's task list.
- Today remains a dedicated action surface.
- Progress is shown with condition completion and meaningful values, not decorative metrics.
- Unlock remains celebratory but restrained.
