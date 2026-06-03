# MyFiPar — Agent Guide

## What this app is

MyFiPar is a personal-finance / expense-tracking iOS app. Users log
transactions (amount, merchant, category, date), view them in a list, and tap
in for details. A `Goal` model exists for upcoming budget-goal features but is
not yet wired into the UI.

## Platform and language targets

- iOS 26.0+
- Swift 6.2+ with strict concurrency
- SwiftUI + SwiftData (no UIKit unless explicitly requested)
- No third-party dependencies — ask before adding any

## Architecture

- **MVVM with `@Observable`.** View models are `@MainActor @Observable` classes
  held by views with `@State` (see `TransactionViewModel`). Do not use
  `ObservableObject` / `@Published` / `@StateObject`.
- **SwiftData for persistence.** The `Transaction` model is registered in
  `MyFiParApp.swift` via `.modelContainer(for: Transaction.self)`. Views read
  with `@Query` and mutate through `@Environment(\.modelContext)`. Mutations
  are routed through the view model, not done inline in the view.
- **Feature-folder layout.** Code is grouped by feature under
  `MyFiPar/Features/<FeatureName>/`. Shared models live in
  `MyFiPar/Core/Model/`.
- **One type per file.** Keep structs/classes/enums in their own files.

## Domain models

- `Transaction` (`@Model`) — `id: UUID`, `amount: Decimal`, `category: TransactionCat`,
  `date: Date`, `merchant: String?`. All stored properties have defaults so the
  model is CloudKit-ready if enabled later.
- `TransactionCat` — `String, Codable, CaseIterable` enum (Housing, Food,
  Transportation, Utilities, Healthcare, Entertainment, Shopping, Education,
  Income, Other).
- `Goal` (`@Model`) — placeholder for budget goals. Not yet shown in UI.

## Conventions already in use (keep consistent)

- Duplicate-transaction guard in `TransactionViewModel.addTransaction` uses a
  same-day + same-amount `FetchDescriptor` predicate. Preserve this pattern
  when adding new write paths.
- Search uses `localizedStandardContains` (see `filtered(transactions:)`).
- Currency formatting uses
  `.currency(code: Locale.current.currency?.identifier ?? "USD")`.
- Dates use `FormatStyle` (`.dateTime`, `.formatted(...)`) — never
  `DateFormatter`.
- The add flow is a sheet presenting `QuickAdd`, which calls back via
  `onsave: (Transaction) -> Void` rather than mutating the context itself.

## SwiftData + CloudKit readiness

If/when CloudKit sync is enabled:

- Never use `@Attribute(.unique)`.
- All `@Model` stored properties must have defaults or be optional.
- All relationships must be optional.

## Style

Project-wide SwiftUI/Swift style is enforced by the `swiftui-pro` skill on
review — invoke it for comprehensive checks rather than duplicating its rule
list here. The non-negotiables worth calling out:

- Modern Swift concurrency only — no `DispatchQueue.main.async`, no
  closure-based APIs where async/await exists.
- `FormatStyle` for all formatting (numbers, currency, dates).
- No force unwraps / force `try` outside truly unrecoverable paths.
- Dynamic Type — don't hard-code font sizes.
- `NavigationStack` + `navigationDestination(for:)`, never `NavigationView`.

## Testing

- Use the **Testing** framework (`@Test`) for unit tests, not XCTest.
- Use **XCUIAutomation** for UI tests only when unit tests can't cover it.
- Put view logic in the view model so it is testable.

## Tooling — Xcode MCP

Prefer Xcode MCP tools over generic alternatives:

- `DocumentationSearch` — verify Apple APIs before writing code (especially
  for iOS 26 / Liquid Glass / FoundationModels).
- `BuildProject` / `GetBuildLog` — confirm builds and inspect errors.
- `XcodeRefreshCodeIssuesInFile` — fast per-file diagnostics.
- `RenderPreview` — visually verify SwiftUI views.
- `XcodeRead` / `XcodeWrite` / `XcodeUpdate` — prefer over generic file tools.

## Secrets and localization

- Never commit API keys or secrets.
- If `Localizable.xcstrings` is added, use symbol keys with
  `extractionState: "manual"` and access via generated symbols
  (`Text(.someKey)`).
