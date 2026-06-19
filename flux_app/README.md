# Flux — Screen Recorder (UI)

Flutter interface for the Flux mobile screen recorder. **Interface only** — no
recording, storage, or playback logic yet. Theme is **Crimson & Clarity** (the
design system the Stitch screens render with).

## Screens

| Tab / Route        | File                                      |
|--------------------|-------------------------------------------|
| Record (home)      | `lib/screens/record_home_screen.dart`     |
| Gallery            | `lib/screens/video_gallery_screen.dart`   |
| Settings           | `lib/screens/app_settings_screen.dart`    |
| Active Recording*  | `lib/screens/active_recording_screen.dart`|

\* Pushed full-screen when the record button is tapped (not a bottom-nav tab).

## Structure

```
lib/
├── main.dart                 # App entry, MaterialApp
├── theme/                    # Colors, typography, spacing, ThemeData
├── models/                   # VideoItem (UI model)
├── data/mock_data.dart       # Static placeholder content
├── screens/                  # 4 screens + HomeShell (nav scaffold)
└── widgets/                  # Reusable UI pieces
```

## Run

This package ships `lib/` + `pubspec.yaml` only. Generate the platform folders
first, then fetch deps:

```bash
cd flux_app
flutter create .          # generates android/ ios/ etc. (keeps lib/)
flutter pub get
flutter run
```

## Notes

- Requires Flutter 3.27+ (uses `Color.withValues`).
- Inter font is loaded at runtime via `google_fonts`.
- Gallery thumbnails point at the original Stitch placeholder URLs and fall back
  to a neutral box if they expire.
- All toggles, chips, quality selector, and tab switching are visual state only.
