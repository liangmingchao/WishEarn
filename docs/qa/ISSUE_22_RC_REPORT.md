# Issue #22 — Phase 2 RC QA Report

> Update: Issue #25 later added a critical-journey UI test target. Sections 2–8 describe the #22 snapshot; see section 10 for the current UI-test status.

**Date:** 2026-11-10  
**Code commit:** `d9b1888` (`main`, merge of PR #23)  
**QA branch:** `qa/issue-22-rc` (documentation/evidence only; no product-code changes)

## 1. Environment

| Item | Value |
|---|---|
| Xcode | 27.2 |
| Simulator | iPhone 18 Pro, iOS 27.2 |
| Physical device | iPhone 17 (iPhone18,3), iOS 27.0 (24A437), UDID `00008150-000611A8368A401C` |
| Device state during QA | **Unavailable / not connected** |
| Signing | Apple Development, Team `4BRBR7NXJL` |

The previous device installation was an earlier Petrol build. It is not counted as verification of the current Playful Editorial build.

## 2. Build and tests

| Check | Command / artifact | Result |
|---|---|---|
| Full tests | `xcodebuild test -project WishEarn.xcodeproj -scheme WishEarn -destination 'platform=iOS Simulator,name=iPhone 18 Pro' -derivedDataPath build/DerivedData -resultBundlePath build/Issue22Tests.xcresult CODE_SIGNING_ALLOWED=NO` | **PASS — 274 tests, 0 failures** |
| Release simulator build | `xcodebuild -project WishEarn.xcodeproj -scheme WishEarn -configuration Release -destination 'generic/platform=iOS Simulator' -derivedDataPath build/DerivedData-Release build CODE_SIGNING_ALLOWED=NO` | **PASS** |
| Release archive | `build/Issue22.xcarchive` | **PASS** |
| Development IPA | `build/Issue22Export/WishEarn.ipa` | **PASS** |
| Test result bundle | `build/Issue22Tests.xcresult` | Available locally |

Non-fatal build warning:

> All interface orientations must be supported unless the app requires full screen.

This is a pre-existing orientation configuration warning, not a test failure.

## 3. CI status

- Latest `main` run: [42758365159](https://github.com/liangmingchao/WishEarn/actions/runs/42758365159) — **failure before any step**.
- GitHub annotation: *“The job was not started because recent account payments have failed or your spending limit needs to be increased.”*
- Last successful CI run was on `359e6db` ([42658989350](https://github.com/liangmingchao/WishEarn/actions/runs/42658989350)), which predates the merged Playful Editorial code.
- **There is no green CI run for the latest main commit.**

This is an account billing limitation, not a code/test failure. It blocks the CI gate for RC.

## 4. Core journey regression

Automated coverage is domain/ViewModel/Repository-level. It does not exercise real SwiftUI taps.

| # | Journey | Evidence | Status |
|---|---|---|---|
| 1 | Wish → conditions → record → unlock → claim | `EndToEndFlowTests.testFullFlowUnlockAndComplete` | PASS (automated) |
| 2 | COUNT / DURATION / AMOUNT multi-record and cumulative | `ProgressRecordServiceTests`, `ProgressCalculatorTests`, `EndToEndFlowTests.testAmountFlowUnlocks` | PASS (automated) |
| 3 | STREAK same-day uniqueness, next-day continuation, pause/resume | `StreakCalculatorTests`, `ProgressRecordServiceTests`, `TodayViewModelTests` | PASS (automated) |
| 4 | CHECKPOINT historical completion and Today presentation | `ProgressCalculatorTests`, `TodayViewModelTests` CHECKPOINT cases | PASS (automated) |
| 5 | Edit a historical record and recompute progress/unlock | `ProgressRecordServiceTests.testUpdateRecordValidatesAndSaves`, `RecordEditorViewModelTests.testEditPrefillsAndUpdatesRecord` | PASS (automated) |
| 6 | Image choose/replace/remove/missing/restart | `WishEditorViewModelTests` image cases, `ImageStorageServiceTests`, persistence tests | PASS (automated); PhotosPicker UI **NOT TESTED** |
| 7 | JSON export | `DataExportTests` | PASS (automated) |
| 8 | Light / Dark core pages | Issue #21 screenshots, 7 pages × 2 appearances | PASS (simulator screenshots); system alerts **NOT TESTED** |

## 5. Real-device acceptance

Device was unavailable at QA time. No current-build install, launch, or interaction is claimed.

| Check | Status |
|---|---|
| Current Playful build install / launch | **NOT TESTED — device unavailable** |
| PhotosPicker select / cancel / replace / remove | **NOT TESTED** |
| Keyboard, scrolling, focus, Save visibility | **NOT TESTED** |
| Long title / long note / Dynamic Type | **NOT TESTED** |
| Dark mode / system appearance switch | **NOT TESTED on device** (simulator screenshots exist) |
| Today / Detail / Editor / Unlock navigation and back | **NOT TESTED** |
| Long list scrolling and image loading | **NOT TESTED** |
| Local data survives App restart | **NOT TESTED on device**; automated disk-container persistence covers the repository layer |

## 6. UI automation assessment

- No `WishEarnUITests` or UI automation target exists.
- The current CI gate cannot run at all because of the GitHub Actions account billing block, so a newly added UI test target could not be validated in CI.
- Adding a minimal UI test target is recommended as a separate follow-up once billing is restored. It should use a Debug-only in-memory launch seed and cover the critical unlock journey, not broad snapshot tests.
- **No UI Test coverage is claimed for this RC.**

## 7. Defects / risks

- No P0/P1 defect was found by the automated suite.
- Unverified real-device interactions remain release-blocking until manually checked.
- App Store metadata, screenshots, support/privacy URLs, and App Store Connect/TestFlight credentials remain missing.
- The App Icon is still the previous Petrol asset; the Playful proposal is not approved or wired.
- Orientation warning remains.

## 8. RC recommendation

### **NO-GO for App Store / TestFlight submission**

Reasons:

1. No green CI on the latest `main` commit; GitHub Actions is blocked by account billing.
2. Real-device PhotosPicker, keyboard, scrolling, navigation, and restart checks are not verified.
3. App Store Connect, TestFlight, screenshots, support URL, privacy policy URL, final name, and Bundle ID are not ready.
4. App Icon is pending brand confirmation.
5. No UI automation coverage.

### Conditional internal QA build

The code is buildable and all 274 automated tests pass. An internal QA build can proceed once:

- the physical device is available and the real-device checklist in section 5 is completed;
- GitHub Actions billing is restored and CI is green on `d9b1888` or a later code commit;
- any newly found P0/P1 defects are fixed.

## 9. Evidence links

- [Issue #21 visual screenshots](../design/screenshots/issue-21/)
- [Design system baseline](../design/DESIGN_SYSTEM.md)
- [Release checklist](../RELEASE_CHECKLIST.md)
- [App Store materials](../APP_STORE.md)


## 10. Issue #25 follow-up — UI automation (2026-11-10)

- Added a `WishEarnUITests` target and a Debug-only `-ui-testing` in-memory launch mode.
- Added one critical-journey test: create wish → add CHECKPOINT condition → record completion → unlock → claim.
- Local result: **1 UI test passed, 0 failures** (`xcodebuild test-without-building ... -only-testing:WishEarnUITests/CriticalJourneyUITests/testCreateConditionRecordUnlockAndClaim`).
- The test found a stale Wish Detail state after claiming from the full-screen celebration; the detail now reloads when the coordinator presentation closes.
- Full local suite: **274 unit/integration + 1 UI test**, all passing.
- CI billing was restored during Issue #25; PR #26 run [42761975702](https://github.com/liangmingchao/WishEarn/actions/runs/42761975702) passed with 274 unit/integration tests + 1 UI test (8m27s). Real-device checks remain NOT TESTED; the main-branch run should be confirmed after merge.
