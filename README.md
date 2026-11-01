# Creator-iq

A Flutter application for social media performance analytics and data-driven content planning.

**CreateIQ** helps creators track performance across Instagram, TikTok, YouTube, Facebook and X, understand their audience, and generate AI content ideas.

## Features

- Splash, onboarding and login / sign-up (mock auth; Google sign-in button)
- Connect social accounts (mock OAuth) or enter data manually
- Home dashboard: KPIs with % change, 7-day engagement chart, top post, AI tip, quick actions
- Analytics: platform and date-range filters, line/bar/pie charts, best-time heatmap, posts ranked by engagement
- Add Data: manual post entry with steppers, image preview, edit/delete history
- Guided questionnaire to personalise AI suggestions
- AI Studio: post ideas, captions, hashtags and a weekly content calendar
- AI chat assistant and an AI insights report with a 0–100 growth score
- Profile and settings: dark mode, notifications, language

Engagement rate = (likes + comments + shares + saves) / followers × 100.

## Tech stack

Flutter 3.x · Riverpod · go_router · fl_chart · google_fonts (Inter) · lucide_icons · flutter_animate · shared_preferences

## Project structure

```
lib/
  core/        theme, constants, routes, utils
  models/      User, SocialAccount, Post, AnalyticsSummary, ContentIdea, ChatMessage, QuestionnaireAnswers
  services/    ApiService (mock, placeholder endpoints), AnalyticsService, StorageService, MockData
  providers/   Riverpod state
  screens/     one folder per screen
  widgets/     reusable widgets (StatCard, GradientButton, ChartCard, PostTile, ...)
packages/
  lucide_icons/  locally patched icon package (see below)
```

## Running locally

```bash
flutter pub get
flutter run -d chrome            # web (debug, hot reload)
flutter run -d chrome --release  # web (release)
flutter run                      # connected Android/iOS device or emulator
```

Windows desktop builds require Developer Mode (`start ms-settings:developers`).

Login is mocked: any valid email and a password of 6+ characters works (e.g. `alex@createiq.app` / `123456`). Tap **Connect** on a platform to load sample data.

## Backend

All network calls go through `lib/services/api_service.dart`, which currently returns mock data after a short delay. Placeholder REST endpoints are listed in `ApiEndpoints`; replace each method body with an HTTP call to connect a real backend.

## Note on `packages/lucide_icons`

`lucide_icons` 0.257.0 doesn't compile on Flutter 3.44+ because `IconData` is now a final class. A patched copy lives in `packages/lucide_icons` and is used via `dependency_overrides` in `pubspec.yaml`.

## Tests

```bash
flutter test
```
