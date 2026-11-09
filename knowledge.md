# PCG Dagbani Hymn Book — Project Guide

This guide explains the app in everyday language first, then follows the code paths that connect its screens, data, and services. It is intended for both developers and people who simply need to understand and explain what the app does.

> **In one sentence:** This is an offline-first Flutter hymn book. The hymn and chorus text ships inside the app, while reading preferences, favorites, and user-added audio are saved on the device.

## Contents

- [What the app does](#what-the-app-does)
- [How to run it](#how-to-run-it)
- [How the project is organized](#how-the-project-is-organized)
- [How a hymn gets from the data file to the screen](#how-a-hymn-gets-from-the-data-file-to-the-screen)
- [Features and how they connect](#features-and-how-they-connect)
- [Where the information is stored](#where-the-information-is-stored)
- [Features that are incomplete or not in the main flow](#features-that-are-incomplete-or-not-in-the-main-flow)
- [Tests and useful places to start changing things](#tests-and-useful-places-to-start-changing-things)

## What the app does

The app is called **PCG Dagbani Hymn Book** (Presbyterian Church of Ghana — Northern Presbytery). A person opens it, reads Dagbani hymns and choruses, moves between entries, searches by words or numbers, marks favorites, and can share or copy lyrics. It also includes reading display settings, an offline synthesized polyphonic SATB tune/pitch guide, contributor profile management, and a way to attach an audio recording to a specific hymn.

The main reading experience does not require an account or an internet connection. The hymn text is bundled with the application. Device storage is used for preferences and locally added audio. There is no remote API or server-backed account flow in the current app code.

## How to run it

This is a Flutter/Dart project. With Flutter installed and the project dependencies available:

```sh
flutter pub get
flutter run
```

To build a production release APK for Android:

```sh
flutter build apk --release
```

The declared Dart SDK requirement and package list are in [pubspec.yaml](pubspec.yaml). The app entry point is [lib/main.dart](lib/main.dart). Platform-specific launch/build configuration lives in the `android/`, `ios/`, `web/`, `windows/`, `linux/`, and `macos/` directories.

## How the project is organized

The main Dart code is under [lib/](lib/):

| Location | Responsibility |
|---|---|
| [lib/main.dart](lib/main.dart) | Initializes Flutter and, on desktop, SQLite FFI; installs the shared settings provider and light/dark themes; starts the splash screen. |
| [lib/home/](lib/home) | The home reading experience (`HomeScreen`) opening immediately to Hymn 1 with swipe navigation, search, and drawer, plus a standalone table-of-contents screen. |
| [lib/hymns/](lib/hymns) | A hymn detail route and a reusable hymn-list widget. |
| [lib/screens/](lib/screens) | Settings, hymn library (Contents & Favorites tabs), audio uploads, contributor profile, Northern Presbytery history, and about screens, plus future placeholder screens. |
| [lib/models/](lib/models) | Data objects for a hymn, uploaded hymn audio metadata, and app-wide reading settings. |
| [lib/db/](lib/db) | Loading bundled hymn JSON and persisting favorites/audio metadata in SQLite where supported. |
| [lib/services/](lib/services) | Loading bundled content, synthesizing multi-harmonic tune audio (Church Organ / Piano), and managing user-uploaded audio. |
| [lib/widgets/](lib/widgets) | Reusable hymn display (`HymnView`), search delegate (`HymnSearchDelegate`), audio controls, sharing sheet, and UI elements. |
| [assets/](assets) | Bundled hymn and chorus data, other content JSON, high-resolution cover image, and Dagbani font file. |
| [test/](test) | Widget and unit tests for settings, audio services, hymn display, search, and SQLite platform support. |

## How a hymn gets from the data file to the screen

This is the central data path:

1. The source text is stored in [assets/hymn.json](assets/hymn.json) and [assets/choruses.json](assets/choruses.json). Each entry has fields such as an ID, number, title, page, lyrics/content, and optionally category, translation, or reference.
2. Both files are declared as Flutter assets in [pubspec.yaml](pubspec.yaml), so Flutter packages them with the app.
3. [HymnLoader.loadHymnsFromAssets](lib/db/hymn_loader.dart) reads and decodes both files, combines their entries, and converts each one into a [Hymn](lib/models/hymn.dart) object.
4. `Hymn.fromMap` normalizes the source data. For example, it accepts lyrics under either `content` or the database-style field names, handles a list of verses or newline-separated text, and maps the page, translation, category, and reference to consistent model properties.
5. [HomeScreen](lib/home/home_screen.dart) keeps the loaded collection in memory. It opens immediately to Hymn 1 (*PAƔMIYA NAAWUNI*) and displays it in a swipeable `PageView`.
6. [HymnView](lib/widgets/hymn_view.dart) renders the title, category/number, page, reference, translation, stanzas, and the PCG watermark emblem. The same viewer is used when browsing a single hymn through other routes.

The bundled JSON is the source of the hymn words. SQLite is used for favorite state and audio metadata on native platforms.

## Features and how they connect

### 1. Launch, Splash Screen, and App Icons

The startup chain is:

`main()` → `HymnBookApp` → `SplashScreen` → `HomeScreen`

- **Android 12+ Native Splash API**: Configured in `android/app/src/main/res/values-v31/styles.xml` using `windowSplashScreenAnimatedIcon` and `windowSplashScreenBackground` (`#FFFFFF`). Centered 160dp splash drawable in `drawable/splash_icon.xml` bounded within the 192dp circle prevents automatic OS cropping or bilinear blurring.
- **Pre-Android 12 Splash**: Centered, filtered bitmap in `drawable/launch_background.xml` and `drawable-v21/launch_background.xml`.
- **Exported High-DPI Density Buckets**: High-resolution splash assets (`splash_logo.png`) provided across `mdpi`, `hdpi`, `xhdpi`, `xxhdpi`, and `xxxhdpi` (from 160px up to 640px).
- **Flutter Splash Screen**: [lib/splash/splash_screen.dart](lib/splash/splash_screen.dart) displays the high-clarity circular church crest, "PRESBYTERIAN CHURCH OF GHANA", "PCG DAGBANI HYMN BOOK", "Northern Presbytery", and "Vol 1" subtitle without opacity fade delay, transitioning smoothly into `HomeScreen`.
- **Adaptive Launcher Icons**: Android 8.0+ adaptive icons defined in `android/app/src/main/res/mipmap-anydpi-v26/ic_launcher.xml` and `ic_launcher_round.xml` with safe-zone foreground padding and pure white background (`@color/ic_launcher_background`), plus multi-density mipmaps across all legacy densities.
- **Cross-Platform Icons**: Web favicons/PWA icons, Windows `.ico`, macOS icons, and iOS app icons/launch images all display the official PCG church crest.

### 2. Main Reading Experience

- [HomeScreen](lib/home/home_screen.dart) opens directly to Hymn 1.
- Readers swipe left/right between hymns or use the bottom navigation bar (Previous, Jump to Hymn #, Next).
- The top app bar features quick access to search, font size adjustment, favorite toggle, tune accompaniment player, and hymn sharing/copying.
- [lib/widgets/hymn_view.dart](lib/widgets/hymn_view.dart) renders the official Presbyterian Church of Ghana watermark emblem centered behind verses with subtle opacity (`0.05` dark / `0.07` light) wrapped in an `IgnorePointer` with `FilterQuality.high`.
- Each stanza has a dedicated card and one-tap copy button.

### 3. Table of Contents, Search, and Favorites

- The active library is [lib/screens/hymn_library_screen.dart](lib/screens/hymn_library_screen.dart), accessible from the home drawer:
  - **Contents**: Categorized hymn lists with in-line search and category groups.
  - **Favorites**: List of bookmarked hymns with one-tap removal.
- App-wide search is implemented by [HymnSearchDelegate](lib/widgets/hymn_search_delegate.dart). It supports:
  - Hymn number, title, page, translation, category, and stanza search.
  - Comma-separated pairs (e.g. `1, 1` or `1, 48`) matching both number/page and page/number combinations.
  - **Reactive Category Filter Chips**: Dynamically filters results in real time:
    - **All**: Shows all matching hymns and choruses.
    - **Hymns**: Shows strictly non-chorus hymns.
    - **Dagbani Choruses**: Shows strictly choruses.
    - Real-time count badges update as queries are typed.

### 4. Contributor Profile & Upload Gate

- [lib/screens/profile_screen.dart](lib/screens/profile_screen.dart) is a complete profile management form:
  - **Full Name / Contributor Name** (`user_name`): Placeholder `Aminu Amos`.
  - **Congregation / Local Church** (`user_congregation`): Placeholder `PCG: Van Den Broek Memorial Congregation`.
  - **Presbytery / District** (`user_district`): Placeholder `Northern Presbytery`.
  - **Ministry / Role** (`user_role`): Choice chips (*Organist / Keyboardist*, *Chorister / Choir Director*, *Pastor / Catechist*, *Presbyter / Elder*, *Church Member*).
  - **Phone / Contact** (`user_contact`, optional).
  - Presbyterian Blue header card with official emblem, contributor name, and role badge.
  - Persists directly to `shared_preferences`.
- **Upload Gate**: When a user selects **Uploads** from the drawer, [ProfileCheckUtility](lib/widgets/profile_check_utility.dart) checks whether name and congregation are set. If incomplete, it prompts the user and directs them to `ProfileScreen(redirectToUpload: true)`. Upon saving, the user is automatically transitioned into `UploadScreen`.

### 5. Tune, Pitch, and Uploaded Hymn Recordings

#### Offline Synthesized Tune & Pitch Guide
- Opened via the music-note icon in [lib/widgets/tune_player_sheet.dart](lib/widgets/tune_player_sheet.dart).
- Backed by [TuneAudioService](lib/services/tune_audio_service.dart), generating 16-bit 44.1kHz PCM WAV audio in memory.
- Multi-harmonic polyphonic SATB choral voicing:
  - **Church Pipe Organ**: 8′ foundation, 4′ octave, and 16′ sub-bass stops with subtle organ vibrato.
  - **Acoustic Piano**: Percussive attack with exponential natural acoustic decay.
  - **Solo Lead**: Vocal pitch lead.
- Specific chord progressions for Hymn 1 (*Lobe den Herren*), Hymn 2 (*Old 100th*), Hymn 3 (*PHB 3*), and Ghanaian tunes.
- Tempo slider (60–140 BPM) and vocal Pitch Pipe (`C4` to `C5`).

#### User-Uploaded Hymn Audio
- Form and management screen in [lib/screens/upload_screen.dart](lib/screens/upload_screen.dart), backed by [UploadedAudioService](lib/services/uploaded_audio_service.dart) and [UploadedHymnAudio](lib/models/uploaded_hymn_audio.dart).
- Pre-fills performer name and congregation from the saved contributor profile.
- Allows users to record or pick an audio file (`.mp3`, `.m4a`, `.wav`, `.aac`, etc.) and link it to an existing hymn number.
- Copies the audio into the device app storage directory (`hymn_audios/`) and persists metadata in SQLite and `shared_preferences`.
- In [lib/widgets/hymn_view.dart](lib/widgets/hymn_view.dart), an `UploadedHymnAudioPlayer` bar appears **only** on hymns that have an uploaded recording.

### 6. Settings and Display Customization

- Screen: [lib/screens/settings_screen.dart](lib/screens/settings_screen.dart), state in [lib/models/settings_model.dart](lib/models/settings_model.dart).
- Theme mode: Light, Dark, or System mode with Presbyterian Blue (`#1565C0`) and Teal (`#00897B`).
- Font Family: Choice of Merriweather, Playfair Display, Roboto, Open Sans, Lora, and Lato.
- Font Size: Stepper (A- / A+) and slider with live Dagbani verse preview.
- Keep Screen Awake: Backed by `wakelock_plus` to prevent display sleep during church services.

### 7. Church History & About Screens

- **Church History**: [lib/screens/history_screen.dart](lib/screens/history_screen.dart)
  - Dedicated **Northern Presbytery History** narrative with church icon (`Icons.church_rounded`).
  - Highlights missionary beginnings (1828), growth, and modern development.
  - **Languages & Vision** notice explaining that the hymn book comprises many languages, with the team focusing on Dagbani for this release and introducing additional Ghanaian languages (Twi, Ga, Ewe, English) in future updates.
- **About App**: [lib/screens/about_screen.dart](lib/screens/about_screen.dart)
  - Clear developer attribution: *"This app was developed and is managed by Great Light Group."*
  - Official website: **`greatlightgroup.com`** with one-tap copy.
  - Official approval details by Northern Presbytery Chairman and Presbyterian leadership.
  - Contact details (`greatlightgroup247@gmail.com`, WhatsApp `0594273358`).
  - Notice on upcoming Dagbani Bible (text and audio).

## Where the information is stored

| Information | Current source or storage |
|---|---|
| Hymn lyrics, numbers, titles, pages, translations, categories | Bundled JSON: [assets/hymn.json](assets/hymn.json) and [assets/choruses.json](assets/choruses.json). |
| Reading preferences (theme, font, size, awake) | Device `shared_preferences`, managed by `SettingsModel`. |
| Contributor profile (name, congregation, role, district, contact) | Device `shared_preferences` (`user_name`, `user_congregation`, etc.). |
| Favorite status | SQLite `hymns.isFavorite` on native platforms; in-memory for web. |
| Uploaded audio metadata | SQLite table `uploaded_hymn_audios` on native platforms plus `shared_preferences` JSON cache. |
| Uploaded audio files | Saved in device local app storage (`hymn_audios/`). |
| Generated tune sequences | Synthesized algorithmically in [lib/services/tune_audio_service.dart](lib/services/tune_audio_service.dart). |

## Tests

Tests in [test/](test):

- [test/home_and_settings_test.dart](test/home_and_settings_test.dart): Tests settings updates, tune service configuration, uploaded-audio lookup, and hymn display text/stanza formatting.
- [test/hymn_database_web_guard_test.dart](test/hymn_database_web_guard_test.dart): Verifies SQLite platform guarding for web runtimes.
- [test/widget_test.dart](test/widget_test.dart): Smoke test for `HymnBookApp` and splash screen loading.
