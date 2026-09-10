# MS-CIT Certificate Verification — Flutter (MVVM, screen-wise)

## Run it
```bash
flutter pub get
flutter run
```

## Login (hardcoded, for now)
- **Username:** `admin`
- **Password:** `admin123`

Credentials live in exactly one place: `lib/screens/login_screen.dart`
(the `LoginService` class in that file). Swap that method body for a
real API call later and nothing else in the app needs to change.

## Architecture — MVVM, organized screen-wise

Each screen's View + ViewModel + Service live together in **one file**.
Only Models (plain data, no Flutter imports) and a couple of small
shared presentational widgets are split out.

```
lib/
  models/                       Model — plain data classes, no logic, no Flutter imports
    user_model.dart
    request_model.dart
    dashboard_stats_model.dart
    dashboard_filter_model.dart Date-range preset + selection value object (Home screen)
    report_model.dart

  screens/
    login_screen.dart           LoginService + LoginViewModel + LoginScreen
    shell_screen.dart           MainShellViewModel + MainShellScreen (bottom nav host)
    home_screen.dart            HomeService + HomeViewModel + HomeScreen (dashboard)
    requests_screen.dart        RequestsService + RequestsViewModel + RequestsScreen
    reports_screen.dart         ReportsService + ReportsViewModel + ReportsScreen
    settings_screen.dart        SettingsService + SettingsViewModel + SettingsScreen

  widgets/                      Small reusable *presentational* widgets only
    stat_card.dart               (no state, no ViewModel/Service access —
    request_card.dart            same idea as sharing a Button/Card component)

  core/theme/
    app_colors.dart             Color tokens
    app_theme.dart              ThemeData
    app_decorations.dart        Shared card/shadow/gradient decoration helpers

  main.dart                     App entry point — just wires MaterialApp + AppTheme.
                                 LoginScreen creates its own ViewModel/Service.
```

**Data flow (per screen):** View calls a ViewModel method → ViewModel
calls that screen's own Service → Service returns a Model → ViewModel
updates its state and calls `notifyListeners()` → View rebuilds via
`Provider`/`context.watch()`.

Each screen creates its own `ChangeNotifierProvider` inside its own
`build()` (see the `XScreen extends StatelessWidget` wrapper at the
bottom of each file), so no screen depends on another screen's
ViewModel except `MainShellViewModel`, which is intentionally shared
(it just tracks the logged-in user + active tab) and is read via
`context.read<MainShellViewModel>()` by Home/Requests/Settings.

Views never call a Service directly, and ViewModels never import
`package:flutter/material.dart` widget classes — that boundary is what
keeps this testable and swappable.

## Screens
- **Login** — hardcoded auth, loading state, inline error banner
- **Home (Dashboard)** — real date-range dropdown + two real date pickers
  (no longer hardcoded), stat cards (Total / Pending / Approved / Rejected /
  Partially Approved) with Desk-I / Desk-II split. Cards reload whenever the
  selection changes. Responsive 1–3 column card grid.
- **Requests** — searchable list of certificate requests with status badges
- **Reports** — requests-by-corporation bars, turnaround stats, export actions
- **Settings** — profile, toggles, change password (stub), logout → back to Login

## What was fixed
- **Blank "TOTAL REQUESTS" card:** the mock dashboard data hardcoded
  `totalRequests: 0` regardless of the other counts. `HomeService` now
  derives it from the actual pending/approved/rejected/partially-approved
  totals (`lib/screens/home_screen.dart`).
- **Hardcoded Home selection/date:** the old UI rendered non-interactive
  placeholder boxes. `HomeScreen` now uses a real `DropdownButtonFormField`
  for the date-range preset and real `showDatePicker()` fields for
  from/to, all wired through `HomeViewModel.filter` into the mock
  `HomeService.fetchDashboardStats()` call.
- **Silently blank dashboard on error:** the old View only checked the
  loading state; an error left the screen with no cards and no message.
  Home/Requests/Reports now show a proper error state with a Retry button.

## Next steps (not wired yet)
- Replace each screen's Service mock bodies with real HTTP calls
- Add a request detail screen (tap a `RequestCard`)
- Wire the Filter button on Requests
- Add `flutter_secure_storage` for a real session/token instead of hardcoded creds
