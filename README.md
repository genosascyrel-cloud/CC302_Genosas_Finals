# Bohol Explorer (CC 302 Final Project)

A Flutter/Dart tourist guide for Bohol, Philippines.

## Run
```bash
flutter create . --project-name bohol_explorer --platforms=android,ios
flutter pub get
flutter run
```
Android release builds need `<uses-permission android:name="android.permission.INTERNET"/>` in
`android/app/src/main/AndroidManifest.xml` (above `<application>`).

## Requirement checklist
| Requirement | Where |
|---|---|
| AppBar & titles | every screen (`lib/screens/*`) |
| Text, colors, styling | `buildTheme()` in `lib/main.dart` (Material 3, teal seed) |
| Fonts & assets | Poppins via `google_fonts`; `assets/images/logo.png`; icons |
| Stateless / Stateful | `PlaceCard`, `AboutScreen` (stateless); `ExploreScreen`, `HomeShell`, `AddPlaceScreen` (stateful) |
| Custom widgets | `PlaceCard`, `PlaceImage`, `StateMessage`, `LoadingView`, `WeatherCard` |
| ListView.builder | Explore list, My Trip list |
| API integration | Wikipedia REST + Open-Meteo (`lib/services/api.dart`) |
| Delete | My Trip: swipe or trash icon, confirm dialog, Undo snackbar |
| Navigation | NavigationBar tabs + `Navigator.push` to Detail / Add Place |
| State management | `ChangeNotifier` (`SavedStore`) + `ListenableBuilder`, saved in `shared_preferences` |
| Error / loading / empty | `FutureBuilder` states, retry button, `StateMessage` |
| Additional features | search, category filter, pull-to-refresh, add/edit place with form validation, notes, live weather, undo |
| HCI | consistency, feedback (snackbars), user control (confirm/undo), error prevention (validation), accessibility (tooltips, 48dp targets), responsive (max-width + Row/Column switch) |

## Demo tips
Test with internet on before presenting. Fallback if offline: the My Trip tab, Add Place form and delete still work.
