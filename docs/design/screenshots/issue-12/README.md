# Issue #12 — Editor Screenshots

Captured on iPhone 18 Pro Simulator (iOS 27.2) with Xcode 27.2.

- `wish-editor-create-light.png`: new wish with image invitation, title, price, reason, and optional target date.
- `wish-editor-edit-light.png`: existing wish prefilled in edit mode.
- `condition-streak-light.png`: STREAK uses integer input, attached “天” unit, and consecutive-day guidance.
- `condition-checkpoint-light.png`: CHECKPOINT has no numeric target field and uses a completion-based card.
- `condition-amount-light.png`: AMOUNT uses the existing amount direction menu and attached “元” unit.
- `condition-streak-accessibility-large.png`: STREAK form at Accessibility Large Dynamic Type.
- `record-count-light.png`: COUNT value field with attached unit, localized date, note, and secondary metadata.
- `record-streak-light.png`: STREAK uses a completion card instead of a numeric field.
- `record-checkpoint-light.png`: CHECKPOINT uses a completion card and no fake numeric metric.
- `record-count-dark.png`: COUNT record editor in dark mode.

All six condition types have dedicated SwiftUI Previews for both the Condition Editor and Record Editor. These screenshots use an in-memory Debug-only host that presents the editor directly; production presents the same views through the existing native sheets. No seed or screenshot host ships. Keyboard-avoidance and full VoiceOver traversal remain manual QA.
