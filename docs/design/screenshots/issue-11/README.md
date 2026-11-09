# Issue #11 — Today Screenshots

Captured on iPhone 18 Pro Simulator (iOS 27.2) with Xcode 27.2.

- `actionable-light.png`: active wishes with cumulative conditions and a streak that has not been recorded today; each actionable row has a record CTA.
- `recorded-light.png`: actionable rows above plus the quieter “今天已记录” section for a STREAK condition with a record today.
- `completed-light.png`: a CHECKPOINT completed on a previous day. It is shown under “已完成条件”, never as “today recorded”.
- `empty-light.png`: no wishes exist; calm empty state plus the existing wish editor CTA.
- `actionable-dark.png`: actionable state in dark mode.
- `recorded-accessibility-large.png`: actionable and recorded-today sections at Accessibility Large Dynamic Type; content scrolls under the floating tab bar.

These screenshots use an in-memory seed and a temporary Debug-only host. The production app still launches through `RootTabView`; no seed data or screenshot host is shipped.
