# ⚽ Marcadores Mundial App

Live scores, standings, teams, and predictions for the FIFA World Cup 2026 — built with Flutter + Supabase.

## Features

- **Live Scores** — real-time match updates during the World Cup
- **Standings** — group tables and knockout brackets
- **Teams** — squad lists and team profiles
- **Predictions & Trivia** — guess results, earn points
- **Watch TV** — IPTV channels with embedded player
- **Push Notifications** — FCM via Supabase Edge Function
- **Multi-language** — English / Spanish
- **Dark Mode** — theme toggle with system default support

## Tech Stack

| Layer | Stack |
|-------|-------|
| Frontend | Flutter 3.x + Dart 3.x |
| Backend | Supabase (PostgreSQL, Auth, Storage, Edge Functions) |
| Push | Firebase Cloud Messaging + Supabase Edge Function |
| Local DB | Sembast (predictions, favorites) |
| State | Bloc / Cubit |
| Video | Chewie + video_player + webview_flutter |

## Supabase

Full documentation in [`SUPABASE.md`](SUPABASE.md).

### Project

- **URL:** `https://gdqfcrwhfceodrnzcdxk.supabase.co`
- **Tables:** `profiles`, `device_tokens`, `banners`, `channels`
- **Auth:** email/password with email confirmation
- **Storage:** `banners` bucket (5 MB, public read, auth write)
- **Edge Function:** `send-notification` — push notifications via FCM

## Getting Started

### Prerequisites

- Flutter SDK 3.x
- Supabase CLI (optional, for Edge Functions)

### Setup

```bash
# Clone
git clone https://github.com/tu-usuario/marcadores-mundial-app.git
cd marcadores-mundial-app

# Install deps
flutter pub get

# Run
flutter run
```

### Firebase (push notifications)

1. Create a Firebase project
2. Download `google-services.json` → `android/app/`
3. Download `GoogleService-Info.plist` → `ios/Runner/`
4. Run `flutterfire configure` to generate `lib/firebase_options.dart`
5. Set `FIREBASE_SERVICE_ACCOUNT` secret in Supabase

See [`SUPABASE.md`](SUPABASE.md) for Edge Function deployment.

### Environment

The Supabase URL and anon key are hardcoded in `lib/main.dart` for now. Keys have restricted permissions (RLS enforced).

## Project Structure

```
lib/
├── core/
│   ├── permissions/      # Permission enum + role checker
│   ├── theme/            # Light/dark themes
│   └── i18n/             # Translations (EN/ES)
├── data/
│   ├── datasources/      # World Cup remote API
│   ├── models/           # Data models (JSON serialization)
│   ├── repositories/     # Repository implementations
│   ├── database/         # Sembast local DB
│   └── services/         # Supabase, FCM
├── domain/
│   ├── entities/         # Business entities
│   ├── repositories/     # Abstract repositories
│   └── usecases/         # Business logic
└── presentation/
    ├── cubits/           # State management
    ├── pages/            # Screens
    └── widgets/          # Reusable widgets
```

## SQL Migrations

| File | What |
|------|------|
| `supabase_auth_profiles.sql` | Profiles, RLS, is_admin(), banners/channels RLS, storage |
| `supabase_device_tokens.sql` | Device tokens for push notifications |
| `supabase_banners.sql` | Banners table |
| `supabase_storage_banners.sql` | Storage bucket |

## License

MIT
