<p align="center">
  <img src="asset/img/marcador_logo_ap.png" alt="Marcadores Mundial App" width="120" height="120" style="border-radius: 24px;">
</p>

<h1 align="center">⚽ Marcadores Mundial 2026</h1>

<p align="center">
  <strong>FIFA World Cup 2026 — Live Scores, Predictions, Standings & TV</strong>
  <br>
  A cross-platform Flutter app for the biggest tournament on Earth.
  <br><br>
  <a href="https://github.com/dilmer23/marcadores_mundial_app">
    <img src="https://img.shields.io/badge/flutter-3.24-02569B?logo=flutter&logoColor=white" alt="Flutter 3.24">
  </a>
  <a href="https://github.com/dilmer23/marcadores_mundial_app">
    <img src="https://img.shields.io/badge/platform-Android%20%7C%20iOS%20%7C%20Web%20%7C%20Desktop-blue" alt="Platforms">
  </a>
  <a href="https://supabase.com">
    <img src="https://img.shields.io/badge/supabase-storage%20%7C%20auth%20%7C%20db-3ECF8E?logo=supabase&logoColor=white" alt="Supabase">
  </a>
  <a href="https://github.com/dilmer23/marcadores_mundial_app/blob/main/LICENSE">
    <img src="https://img.shields.io/badge/license-MIT-green" alt="License">
  </a>
</p>

---

## ✨ Features

<table>
  <tr>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/26bd.png" width="48"><br>
      <b>Live Scores</b><br>
      <small>Real-time match results, timers & scorers</small>
    </td>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3c6.png" width="48"><br>
      <b>Standings</b><br>
      <small>Group tables with stats & qualifiers</small>
    </td>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3af.png" width="48"><br>
      <b>Predictions</b><br>
      <small>Score predictor with accuracy tracking</small>
    </td>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4fa.png" width="48"><br>
      <b>Live TV</b><br>
      <small>Built-in channel player & IPTV</small>
    </td>
  </tr>
  <tr>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f3f0.png" width="48"><br>
      <b>Stadiums</b><br>
      <small>16 venues with capacity & region</small>
    </td>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/2753.png" width="48"><br>
      <b>Trivia</b><br>
      <small>27 World Cup questions with grades</small>
    </td>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f4f0.png" width="48"><br>
      <b>Banners</b><br>
      <small>Promotional ads with Supabase storage</small>
    </td>
    <td align="center" width="25%">
      <img src="https://cdn.jsdelivr.net/gh/twitter/twemoji@14.0.2/assets/72x72/1f30d.png" width="48"><br>
      <b>i18n</b><br>
      <small>English & Spanish bilingual UI</small>
    </td>
  </tr>
</table>

---

## 🏗 Architecture

Clean Architecture with feature-first organization, BLoC state management, and dependency inversion.

```
┌─────────────────────────────────────────────────────┐
│                    PRESENTATION                      │
│   Pages  ──►  Cubits  ──►  Widgets                  │
│   (UI / BLoC)                                       │
├─────────────────────────────────────────────────────┤
│                      DOMAIN                          │
│   Entities  ──►  Repositories  ──►  Use Cases       │
│   (Business Logic / Contracts)                      │
├─────────────────────────────────────────────────────┤
│                       DATA                           │
│   Models  ──►  Repository Impl  ──►  Data Sources   │
│   (Supabase / HTTP / Local DB)                      │
└─────────────────────────────────────────────────────┘
```

| Layer | Responsibility |
|---|---|
| **Presentation** | Flutter widgets, pages, and BLoC cubits. Handles UI state, animations, and user input. |
| **Domain** | Pure Dart — no framework dependencies. Entities, repository interfaces, and use cases define the business logic. |
| **Data** | Implements repositories. Talks to Supabase (Postgres + Storage), worldcup26.ir API, M3U playlists, and local Sembast database. |

---

## 📁 Project Structure

```
lib/
├── main.dart                         # App entry, DI wiring
├── core/
│   ├── constants/api_constants.dart  # World Cup API endpoints
│   ├── errors/exceptions.dart        # Server / Network / Cache errors
│   ├── i18n/translations.dart        # EN/ES translation system
│   ├── theme/app_theme.dart          # Material 3 themes (light/dark)
│   └── utils/                        # Image compressor, timezone utils
├── data/
│   ├── database/                     # Sembast local storage (IO + Web)
│   ├── datasources/                  # World Cup HTTP remote data source
│   ├── models/                       # Channel, Banner, Game, Team, etc.
│   ├── repositories/                 # Repository implementations
│   ├── services/supabase_service.dart # Supabase client wrapper
│   └── utils/m3u_parser.dart         # M3U playlist parser
├── domain/
│   ├── entities/                     # Channel, BannerAd, Game, Team, etc.
│   ├── repositories/                 # Abstract repository interfaces
│   └── usecases/                     # 15 use cases (CRUD + queries)
└── presentation/
    ├── cubits/                       # 10 cubits (WorldCup, Prediction, etc.)
    ├── pages/                        # 10 pages (Home, Watch TV, Admin, etc.)
    └── widgets/                      # 14 reusable widgets
```

---

## 🗄 Supabase Setup

The app uses Supabase for TV channels, banners, and image storage. Run these SQL files in your Supabase SQL Editor:

<details>
<summary><b>1. Channels table — <code>supabase_banners.sql</code></b></summary>

```sql
-- Creates banners table with RLS for public read
-- Run first to set up the banners table
```
</details>

<details>
<summary><b>2. Profiles + CRUD policies — <code>supabase_banners_crud.sql</code></b></summary>

```sql
-- Creates profiles table (admin/editor/viewer roles)
-- Adds created_by to banners
-- Granular RLS: admins full CRUD, editors insert/update
```
</details>

<details>
<summary><b>3. Storage bucket — <code>supabase_storage_banners.sql</code></b></summary>

```sql
-- Creates public 'banners' storage bucket (5 MB limit)
-- Allows image uploads (PNG, JPEG, WebP, GIF)
```
</details>

**Channels table schema:**

```sql
CREATE TABLE public.channels (
  id BIGINT GENERATED ALWAYS AS IDENTITY PRIMARY KEY,
  name TEXT NOT NULL,
  channel_url TEXT NOT NULL,
  logo_url TEXT,
  is_active BOOLEAN DEFAULT true,
  created_at TIMESTAMPTZ DEFAULT now()
);
```

> **Note:** Enable **Anonymous Sign-In** in Supabase Dashboard → Authentication → Settings for banner uploads to work.

---

## 🚀 Getting Started

### Prerequisites

- Flutter SDK **3.24+** ([install guide](https://docs.flutter.dev/get-started/install))
- Android Studio / Xcode for native builds
- Supabase project ([free tier](https://supabase.com))

### Installation

```bash
# Clone the repository
git clone https://github.com/dilmer23/marcadores_mundial_app.git
cd marcadores_mundial_app

# Install dependencies
flutter pub get

# Run the app
flutter run
```

> The app connects to a public Supabase instance out of the box. To use your own, update `main.dart`:
> ```dart
> final supabaseClient = SupabaseClient(
>   'https://your-project.supabase.co',
>   'your-anon-key',
> );
> ```

### Build APK / IPA

```bash
flutter build apk        # Android
flutter build ios         # iOS
flutter build web         # Web
flutter build windows     # Windows
flutter build macos       # macOS
flutter build linux       # Linux
```

---

## 📦 Dependencies

| Package | Purpose |
|---|---|
| `flutter_bloc` | State management |
| `supabase` | Backend: DB, Auth, Storage |
| `cached_network_image` | Image caching & loading |
| `shimmer` | Loading skeletons |
| `video_player` / `chewie` | IPTV video playback |
| `webview_flutter` | Channel streaming (mobile) |
| `sembast` / `sembast_web` | Local offline database |
| `image_picker` | Gallery image selection |
| `image` | Image compression & resizing |
| `intl` | Date/time localization |
| `url_launcher` | External links |
| `http` | HTTP client (API & M3U) |

---

## 🧩 Key Features Detail

### 📺 TV Channels
Channels managed via Supabase CRUD admin panel. Supports HLS streams via WebView (mobile) or IFrame (web). Searchable list with live indicators.

### 🏆 Predictions
Users predict match scores before kickoff. Scoring system:
- **3 points** — exact score prediction
- **1 point** — correct outcome (win/loss/draw)
- **0 points** — missed

Stats dashboard shows total predictions, points, correct count, and accuracy percentage.

### 📊 Standings
Group tables with full stats: MP, W, D, L, GF, GA, GD, Pts. Top 2 qualified teams highlighted. Color-coded goal difference.

### 🎯 Trivia
27 World Cup questions with shuffled options, progress bar, score tracking, and final grade:
- 🏆 **World Cup Winner** — 100%
- ⭐ **Semifinalist** — 80%+
- ⚽ **Group Stage** — 50%+
- 📚 **Need more practice** — <50%

### 🖼 Banner Advertising
Full CRUD admin interface for promotional banners. Images are:
1. Picked from gallery via `image_picker`
2. Compressed (1200×1200 max, JPEG quality 80)
3. Uploaded to Supabase Storage bucket
4. Displayed in drawer carousel with auto-scroll & deep linking

---

## 🔧 Configuration

### Android
- `minSdk`: 21
- `targetSdk` / `compileSdk`: 35
- Java 11 compatibility

### iOS
- Bundle: `com.example.marcadores_mundial_app`
- Display name: "Marcadores Mundial App"

### Web
- PWA enabled with maskable icons
- IFrame-based video player for channels

---

## 📄 License

Distributed under the **MIT License**. See `LICENSE` for more information.

---

<p align="center">
  Made with ❤️ for football fans around the world<br>
  <sub>© 2026 World Cup 2026 App — Data by <a href="https://worldcup26.ir">worldcup26.ir</a></sub>
</p>
