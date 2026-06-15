# MyFiPar

A manual-first personal expense tracker for iOS, built end-to-end in Swift and SwiftUI for the financial-independence / savings-minded audience.

The philosophy is **tracker first, AI second** — a calm, focused app where logging an expense is fast and pleasant, and the home screen answers one question: *am I okay this month?* It is deliberately the opposite of AI-maximalist budgeting apps. No bank connections, no statement parsing — manual entry is the core, on purpose, because the small friction of logging is what creates spending awareness.

<!-- TODO: Add a screen-recording GIF here showing the budget gauge updating live as an expense is logged. This is the headline — put it above the fold. e.g. ![Logging an expense updates the gauge](docs/demo.gif) -->

> **Status: in active development.** The core loop works (set goal → log expense → gauge and numbers update → data persists). The signature *forward-looking "on-pace-to-save" projection*, AI insights, and CloudKit sync are designed but not yet implemented — see [Roadmap](#roadmap).

## Why it's built this way

A few deliberate product decisions drive the whole design:

- **Manual entry, no Plaid / no bank linking.** Considered and rejected for v1 due to privacy and reliability concerns. The logging friction is a feature for the FIRE audience, not a bug.
- **The home screen is glanceable.** It shows month-to-date spend against a monthly goal and how much is left — not a wall of analytics. "Where did it go?" lives one screen deeper, in the transactions view.
- **A monthly goal gives spending meaning.** Every logged expense instantly updates the gauge; that immediate feedback is the intended retention loop.
- **No ads.** A free tier limited by scope; a planned paid tier adds power features (multiple goals, AI insights, multi-currency, export).

## Architecture

- **SwiftUI + SwiftData**, targeting recent iOS, Swift 6 with strict concurrency. No third-party dependencies.
- **MVVM with `@Observable`.** View models are `@MainActor @Observable` classes held by views via `@State` (`HomeViewModel`, `TransactionViewModel`). Views read data with `@Query` and route all mutations through the view model rather than mutating the context inline.
- **Feature-folder layout.** Code is grouped by feature under `MyFiPar/Features/<Feature>/`; shared domain models live in `MyFiPar/Core/Model/`; reusable UI in `MyFiPar/Core/UI/`. One type per file.
- **`Decimal` for all money** — never floating point.
- **CloudKit-ready model design.** Every `@Model` stored property has a default value, in preparation for enabling iCloud sync.

### Notable pieces

- **`TransactionsIndex`** — builds `byDay` / `byMonth` lookup dictionaries once from the transactions array for O(1) access, instead of repeatedly filtering. The calendar's marked-day indicators are *derived* from the index keys, so they can't drift from the underlying data.
- **`BudgetGaugeView`** — the home arc gauge showing month-to-date spend vs. the monthly goal, with an animated trim and full accessibility labelling.
- **`Goal`** — the monthly budget-cap model, exposing `spent`, `remaining`, and `progress` over a transactions array and a reference date (excluding income from spend).

## Project layout

```
MyFiPar/
  Core/
    Model/      Transaction, Goal, TransactionCat, TransactionsIndex
    UI/         Calendar / month components
  Features/
    Home/       HomeView, BudgetGaugeView, FocusCard, HomeViewModel
    Transactions/  TransactionView, QuickAdd entry, rows/sections, view model
  MyFiParApp.swift, ContentView.swift
MyFiParTests/   Unit tests (Swift Testing framework)
MyFiParUITests/ UI tests
```

## Running it

Requires a recent Xcode and an iOS simulator or device. Open `MyFiPar.xcodeproj`, select a simulator, and run. There are no secrets or config files required to build the current version.

<!-- TODO: Add a TestFlight link here once the core goal-entry flow is in, as a one-tap live demo. e.g. **[Try it on TestFlight](https://testflight.apple.com/join/XXXXXXXX)** -->

## Roadmap

- **Forward-looking on-pace-to-save metric** — the signature feature: a real-time projection of where month-end spending will land vs. the goal, replacing the current backward-looking burn-down. (Designing how to handle lumpy fixed costs like rent so early-month projections aren't misleading.)
- **Real goal-entry UI** — the app currently seeds a placeholder monthly goal; user-set goals are next.
- **iCloud / CloudKit sync** for single-user, multi-device.
- **Optional AI insights** as a quiet, paid-tier helper.

## License

All rights reserved. This repository is source-available for portfolio and review purposes; it is not licensed for reuse, redistribution, or republication.
