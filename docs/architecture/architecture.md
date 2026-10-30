# CreatorIQ — Architecture & Engineering Specification

## 1. Architectural Pattern: MVVM + Repository

CreatorIQ follows a layered architectural pattern to adhere to the Single Responsibility Principle (SRP) and separation of concerns.

```
┌────────────────────────────────────────────────────────┐
│                      Views (UI)                        │
│   DashboardView, ImportView, AnalyticsView, Planner    │
└───────────────────────────▲────────────────────────────┘
                            │ (Listenable / Notifiers)
┌───────────────────────────┴────────────────────────────┐
│                      ViewModels                        │
│  Coordinates UI state, filters, validation, & actions  │
└───────────────────────────▲────────────────────────────┘
                            │ (Contracts & Data flow)
┌───────────────────────────┴────────────────────────────┐
│                     Repositories                       │
│      PostRepository, ContentPlanRepository             │
└───────────────────────────▲────────────────────────────┘
                            │
┌───────────────────────────┴────────────────────────────┐
│                       Services                         │
│   AnalyticsService, SampleDataService, CsvValidator    │
└────────────────────────────────────────────────────────┘
```

## 2. Layer Responsibilities

- **`models/`**: Pure data entities (`SocialPost`, `ContentPlan`, `CreatorProfile`). Immutable with helper calculations like `engagementRateByReach`.
- **`views/`**: Declarative Flutter UI widgets with clean white card aesthetics, micro-interactions, and animations.
- **`viewmodels/`**: Manages state using Flutter's native `ChangeNotifier`. Exposes filtered data, chart summaries, and validation state without tightly coupling to UI.
- **`repositories/`**: Abstract interfaces (`PostRepository`, `ContentPlanRepository`) with swappable implementations (e.g. In-Memory or SQLite).
- **`services/`**: Pure analytical computations, median formulas, explainable recommendation heuristics, and CSV validation logic.
- **`core/`**: Shared theme definitions (`AppTheme`), number/date formatters, and custom exception classes.

## 3. Analytics Calculation Convention

CreatorIQ employs an explicit, reach-normalized interaction formula:

$$\text{Interactions} = \text{Likes} + \text{Comments} + \text{Shares}$$

$$\text{Engagement Rate by Reach (\%)} = \frac{\text{Interactions}}{\text{Reach}} \times 100$$

- **Outlier Mitigation**: Content format comparisons utilize statistical medians rather than arithmetic means to prevent individual viral posts from skewing strategy recommendations.
- **Edge-case Protection**: If reach is zero or negative, the engagement rate returns `null` rather than a falsified or infinite percentage.

