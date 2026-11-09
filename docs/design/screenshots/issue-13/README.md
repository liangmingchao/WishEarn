# Issue #13 — Unlock, Achievements & Settings Screenshots

Captured on iPhone 18 Pro Simulator (iOS 27.2) with Xcode 27.2.

- `unlock-light.png`: unlock celebration with the factual required-condition count, primary claim CTA, quiet “稍后再说”, and top-trailing close action.
- `unlock-dark.png`: unlock celebration in dark mode.
- `unlock-accessibility-large.png`: unlock celebration at Accessibility Large Dynamic Type; content is scrollable.
- `achievements-light.png`: real completed/unlocked wishes, compact unlocked/claimed summary, aggregate effort line, and dated editorial rows.
- `achievements-empty-light.png`: supportive empty state without a zero-score dashboard.
- `achievements-dark.png`: achievements in dark mode.
- `achievements-accessibility-large.png`: summary metrics stack vertically at Accessibility Large Dynamic Type.
- `settings-light.png`: grouped native settings with export format and limitations, JSON row, and disclosure affordance.
- `settings-dark.png`: settings in dark mode.

Claim success, claim failure, dismiss/claim-later, and duplicate-event behavior are covered by unit tests; no claim-failure alert screenshot was captured. These screenshots use an in-memory Debug-only host. Production still presents unlock through the existing `UnlockCoordinator` full-screen flow and uses the same tab views. No seed or screenshot host ships.
