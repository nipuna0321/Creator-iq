# CreatorIQ — Social Media Content Intelligence

An advanced, modern mobile application built with **Flutter & Dart** following the **MVVM + Repository** architecture pattern. CreatorIQ empowers content creators by ingesting social media performance datasets, calculating explainable performance metrics, discovering high-engagement formats, and generating data-backed weekly publishing roadmaps.

---

## 🎨 UI & Design Philosophy

- **Clean White Palette ("Clean Sudu Paata")**: Designed with an ultra-clean, minimal aesthetic utilizing crisp `#FFFFFF` card surfaces, subtle slate borders (`#E2E8F0`), and soft slate canvas (`#F8FAFC`).
- **Card-Based Hierarchy**: Information is grouped in rounded, elevated cards with subtle shadow depth and frosted status badges.
- **Micro-Interactions & Animations**:
  - Number counter animations from 0 to target metrics (Views, Reach, Engagement).
  - Custom-painted interactive bar charts with smooth ease-out growth animations.
  - Scale press animations on buttons and interactive cards.
  - Seamless animated platform filtering (Instagram, YouTube, TikTok).

---

## 📱 Core Features & Screens

1. **Dashboard View**
   - Creator profile header with greeting and quick platform filter chips.
   - 4 Animated Metric Cards: Total Views, Total Reach, Median Engagement, Total Interactions.
   - Interactive Performance Trend Chart with Views vs Engagement toggle.
   - AI Content Intelligence summary banner.
   - Top-performing posts ranking.

2. **Data Import View**
   - Modern file upload zone with sample CSV quick-loader.
   - In-app CSV parser with comprehensive schema checking and row-by-row validation reports.
   - Manual post metric entry form with instant validation.
   - Clear feedback status and immediate database commitment.

3. **Analytics View**
   - Platform filters (All, Instagram, YouTube, TikTok).
   - Median engagement breakdown across content formats (Reels, Videos, Shorts, Carousels).
   - Explainable AI recommendation cards detailing findings, evidence, and actionable next steps.
   - In-depth engagement formula modal.

4. **Content Planner View**
   - Data-backed weekly content production schedule.
   - Status filtering (Planned, In Production, Ready to Post, Published).
   - Post planning modal with platform selection, format selection, goal metrics, and data-backed rationale.
   - Status transitions and plan management.

---

## 🏛️ Project Architecture

```
mobile_app/
├── .github/
│   └── workflows/
│       └── flutter-ci.yml        # Automated CI workflow
├── assets/
│   └── sample_data/
│       └── sample_posts.csv      # Standard sample dataset
├── docs/
│   └── architecture/
│       └── architecture.md       # Full architecture specification
├── lib/
│   ├── main.dart                 # Application entry point
│   ├── app.dart                  # Material app and theme configuration
│   ├── core/
│   │   ├── theme/app_theme.dart  # Clean white design system & shadows
│   │   ├── utils/formatters.dart # Compact numbers and date formatting
│   │   └── errors/app_exception.dart
│   ├── models/
│   │   ├── social_post.dart      # Post entity & calculations
│   │   ├── content_plan.dart     # Weekly schedule entity
│   │   └── creator_profile.dart  # User profile model
│   ├── repositories/
│   │   ├── post_repository.dart  # Abstract contract & implementation
│   │   └── content_plan_repository.dart
│   ├── services/
│   │   ├── analytics_service.dart# Median engagement & AI insights
│   │   └── sample_data_service.dart # CSV parsing & validation report
│   ├── viewmodels/
│   │   ├── dashboard_viewmodel.dart
│   │   ├── analytics_viewmodel.dart
│   │   ├── import_viewmodel.dart
│   │   └── content_planner_viewmodel.dart
│   ├── views/
│   │   ├── main_navigation_view.dart
│   │   ├── dashboard/dashboard_view.dart
│   │   ├── data_import/import_view.dart
│   │   ├── analytics/analytics_view.dart
│   │   └── content_planner/content_planner_view.dart
│   └── widgets/
│       ├── animated_metric_card.dart
│       ├── custom_chart_widget.dart
│       ├── post_card.dart
│       ├── insight_card.dart
│       ├── modern_button.dart
│       └── platform_badge.dart
├── test/
│   └── analytics_service_test.dart # Unit tests for models & calculations
└── pubspec.yaml
```

---

## 🚀 How to Run the App

1. Ensure the Flutter SDK is installed and added to your `PATH`.
2. Open terminal in this folder:
   ```powershell
   flutter pub get
   ```
3. Run automated tests:
   ```powershell
   flutter test
   ```
4. Run the app on an Android emulator or device:
   ```powershell
   flutter run
   ```

