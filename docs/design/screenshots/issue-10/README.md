# Issue #10 — Wish Detail Screenshots

Captured on iPhone 18 Pro Simulator (iOS 27.2) with Xcode 27.2, except `checkpoint-recent-light.png`, which uses iPhone 18 Pro Max to show the full condition and recent-record section.

- `active-light.png`: active wish with hero image, progress, conditions and record actions.
- `paused-light.png`: paused state with preserved progress and resume CTA.
- `unlocked-light.png`: unlocked state with 3/3 progress and claim CTA.
- `completed-light.png`: completed state with completion date, no claim CTA.
- `active-dark.png`: active state in dark mode.
- `active-accessibility-large.png`: active state at Accessibility Large Dynamic Type.
- `no-conditions-light.png`: active wish without conditions, showing the first-condition CTA.
- `no-image-light.png`: missing-image placeholder.
- `checkpoint-recent-light.png`: completed CHECKPOINT row without fake numeric progress, plus the real recent-record section.

These screenshots use seeded in-memory preview data from a temporary Debug-only host. The production app still launches through `RootTabView`; no screenshot host or seed data is shipped.
