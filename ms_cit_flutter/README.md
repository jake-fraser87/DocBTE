# MS-CIT Certificate Verification — Flutter (MVVM)

## Run it
```bash
flutter pub get
flutter run
```

## Login (hardcoded, for now)
- **Username:** `admin`
- **Password:** `admin123`

Credentials live in exactly one place: `lib/services/auth_service.dart`.
Swap that method body for a real API call later and nothing else in the
app needs to change.

## Architecture — MVVM

```
lib/
  models/          Model        Plain data classes, no logic, no Flutter imports
    user_model.dart
    request_model.dart
    dashboard_stats_model.dart
    report_model.dart

  services/        Data layer   Talks to "the backend" (mocked for now)
    auth_service.dart           Hardcoded login
    data_service.dart           Mock dashboard/requests/reports data

  viewmodels/       ViewModel   ChangeNotifier classes: UI state + intents
    login_viewmodel.dart
    dashboard_viewmodel.dart
    requests_viewmodel.dart
    reports_viewmodel.dart
    settings_viewmodel.dart
    main_shell_viewmodel.dart   Owns bottom-nav tab index

  views/            View        Widgets only. Read state via context.watch(),
    login/                      call ViewModel methods on user interaction.
    shell/          MainShellScreen — hosts bottom nav + IndexedStack
    dashboard/
    requests/
    reports/
    settings/
    widgets/                    Shared presentational widgets (StatCard, RequestCard)

  core/theme/        App-wide colors & ThemeData
  main.dart           App entry point, wires LoginViewModel at the root
```

**Data flow:** View calls a ViewModel method → ViewModel calls a Service →
Service returns a Model → ViewModel updates its state and calls
`notifyListeners()` → View rebuilds via `Provider`/`context.watch()`.

Views never call a Service directly, and ViewModels never import
`package:flutter/material.dart` widget classes — that boundary is what
keeps this testable and swappable.

## Screens
- **Login** — hardcoded auth, loading state, inline error banner
- **Dashboard** — stat cards (Total / Pending / Approved / Rejected / Partially Approved) with Desk-I / Desk-II split
- **Requests** — searchable list of certificate requests with status badges
- **Reports** — requests-by-corporation bars, turnaround stats, export actions
- **Settings** — profile, toggles, change password (stub), logout → back to Login

## Next steps (not wired yet)
- Replace `DataService`/`AuthService` mock bodies with real HTTP calls
- Add a request detail screen (tap a `RequestCard`)
- Wire the Filter button on Requests and the date-range picker on Dashboard
- Add `flutter_secure_storage` for a real session/token instead of hardcoded creds
