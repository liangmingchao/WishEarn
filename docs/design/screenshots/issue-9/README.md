# Issue #9 — Wishes Home Screenshots

Captured on iPhone 18 Pro Simulator (iOS 27.2) with Xcode 27.2.

- `populated-light.png` / `populated-dark.png`: featured active wish plus the compact secondary list, with the bottom filter bar and native tab bar.
- `populated-accessibility-large.png`: populated home at Accessibility Large Dynamic Type.
- `empty-light.png`: first-use empty state with the create CTA.
- `filter-empty-light.png`: filter-specific empty state with “查看全部”. Captured with a temporary host that preselects the filter; the production tab bar is unchanged.
- `no-image-light.png`: missing-image placeholder on the featured card.

These screenshots use seeded in-memory preview data from a temporary Debug-only host. The production app still launches through `RootTabView`; no screenshot host or seed data is shipped.
