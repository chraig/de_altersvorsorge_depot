# CLAUDE.md - Altersvorsorgedepot-Rechner Project Guide

## Project Overview

Altersvorsorgedepot-Rechner 2027 is a **Flutter/Dart web application** that compares the new German **Altersvorsorgedepot** (AV-Depot) with a standard private **ETF savings plan**. Based on the Altersvorsorgereformgesetz as passed by the Bundestag on 27.03.2026 (Drucksache 21/4088).

**Dart SDK:** >=3.2.0 <4.0.0 | **Flutter:** 3.x stable | **Platform:** Web (Chrome)

---

## Build & Run Commands

```bash
# Install dependencies
flutter pub get

# Run (development)
flutter run -d chrome

# Build (production)
flutter build web --release --web-renderer canvaskit
# Output in build/web/ — deploy to any static host

# Analyze
flutter analyze

# Run all tests
flutter test
```

---

## Architecture

### Layer Structure

```
UI (features/*/pages/, features/*/widgets/)
  -> State Management (features/*/cubit/)
    -> Services (services/domain/)
      -> Models (models/)
```

### Directory Layout

```
lib/
  main.dart                    # Entry point, BlocProvider setup, MaterialApp.router
  config/                      # Build config, theme (design tokens, colors, typography)
  core/                        # Routes (GoRouter), global state, locale management
    l10n/                      # Bilingual strings (EN/DE) via AppStrings abstract class
    routes/                    # GoRouter configuration
    state/                     # AppSettings coordinator, AppSettingsScope, LocaleCubit
  models/                      # Pure data classes (PersonalScenario, MacroScenario, results)
  services/
    domain/                    # Pure static calculation engine (CalculatorService)
  features/                    # Feature modules (vertical slices)
    calculator/                # Calculator feature (cubit + pages + widgets)
  shared/                      # Reusable utilities and widgets
    utils/                     # Formatters (Fmt)
    widgets/                   # StatCard, MiniBar, ComparisonBar, ResultBanner
```

---

## Key Conventions

### Imports

**All internal imports MUST use fully qualified `package:avdepot_rechner/` paths. Relative imports are NOT permitted.**

```dart
// CORRECT
import 'package:avdepot_rechner/features/calculator/cubit/calculator_cubit.dart';
import 'package:avdepot_rechner/core/state/app_settings.dart';

// WRONG - never use relative imports
import '../state/app_settings.dart';
import './locale_cubit.dart';
```

### State Management: Cubit Only

This project uses **Cubit** (not Bloc) for all state management — the data flows are straightforward enough that events/transformers are unnecessary.

- `CalculatorCubit` — all calculator inputs, scenario CRUD, advanced settings
- `LocaleCubit` — language switching (EN ↔ DE)

### Cubit Patterns

- States use **immutable classes** with `copyWith` for state changes
- All state changes go through `emit(state.copyWith(...))` — never mutate state directly
- Computed getters in `CalculatorState` call `CalculatorService` static methods (pull-based, never stale)
- `AppSettingsScope` wraps the widget tree with `MultiBlocProvider`

### File Naming

- Widgets: `{widget_type}.dart` (e.g., `input_panel.dart`, `charts.dart`)
- Services: `{domain}_service.dart` (e.g., `calculator_service.dart`)
- Cubits: `{feature}_cubit.dart`, `{feature}_state.dart`
- Strings: `app_strings.dart` (contains both EN and DE implementations)

### Feature-First Organization

- Each feature is self-contained in `features/{name}/` with its own pages, widgets, cubits
- Cross-feature dependencies flow through services, not directly between features
- `shared/widgets/` for components used by 2+ features
- `shared/utils/` for formatting and helpers

---

## Design Token System

All UI constants are centralized in `lib/config/theme.dart`:

- **AppSpacing** — spacing scale (xs=2, sm=4, md=8, lg=12, xl=16, xxl=20, xxxl=24, section=28, hero=36)
- **AppRadius** — border radii with semantic aliases (chip=8, card=12, panel=16)
- **AppOpacity** — opacity scale (subtle=0.04, tint=0.1, faded=0.12, muted=0.25, disabled=0.3, half=0.5)
- **AppBreakpoints** — responsive breakpoints (compact=480, medium=700, expanded=800)
- **AppDimensions** — dimension tokens (maxContentWidth=1200, chartHeight=220, barHeight=22)
- **AppColors** — full semantic color palette (accent, etf, surfaces, text, semantic, warning)
- **AppPadding** — padding presets (page, card, panel, section, chip, button)
- **AppTheme** — ThemeData, SliderTheme, text style helpers (mono, monoAccent, monoSmall)

---

## Localization

Bilingual support (English + German) via `lib/core/l10n/app_strings.dart`:

- `AppStrings` abstract class defines all UI strings
- `StringsEn` and `StringsDe` implement all translations
- `LocaleCubit` manages language state, toggled via `toggle()` method
- Scenario presets receive `AppStrings` to generate localized names/descriptions
- Access strings via `context.watch<LocaleCubit>().state.strings`

---

## Calculation Engine

All financial logic lives in `lib/services/domain/calculator_service.dart`.
Constants are centralized in `CalcConstants` — update this class when legislation changes.

**Subsidy module** (replaceable for different subsidy regimes):
- `calcGrundzulage()` — 50%/25% two-tier subsidy
- `calcKinderzulage()` — up to €300/child 1:1 match
- `calcBonus()` — one-time €200 (under 25, first year)
- `calcGeringverdienerbonus()` — €175/yr if gross ≤ €26,250
- `calcZulage()` — combined yearly subsidy (record return type)
- `calcSubsidyBreakdown()` — full year-1 breakdown for UI display

**Tax module** (replaceable for different tax brackets):
- `getGrenzsteuersatz()` — German marginal tax rate (2024 brackets, piecewise linear)
- `calcGuenstigerpruefung()` — automatic tax optimization check

**Simulation module**:
- `simulateAV()` — AV-Depot accumulation + payout with deferred taxation + Kirchensteuer
- `simulateETF()` — ETF-Depot accumulation + payout with Abgeltungssteuer + Kirchensteuer
- `simulateCombined()` / `simulateAllMacros()` — cross-product for comparison

**Pension module**:
- `_computeEffectiveRente()` — state pension estimation (override > income-dev EP > static)

**Income development** (`lib/models/income_dev_settings.dart` → `IncomeDevSettings`):
- Opt-in toggle, linear compound growth rate (0–8%)
- When enabled: year-by-year varying brutto affects subsidies, tax, and pension EP
- `bruttoForYear(brutto, j)` — computes income for savings year j
- `kinderAtYear(baseKinder, j)` — dynamic child count from arrival years
- 3 growth curves: linear, step-wise, logarithmic
- Part-time phases and child arrival timing

All methods are pure — no side effects, no state. Each module can be replaced independently.

---

## Companion Documents

| Document | Purpose |
|----------|---------|
| `docs/RESEARCH.md` | Legislative basis, formula derivations, data sources, tax brackets |
| `docs/CONFIGURATION.md` | All adjustable parameters, defaults, valid ranges, legal basis |
| `docs/INCOME_SCENARIOS.md` | Income scenarios: modeling choices, current implementation + planned extensions |
| `docs/CALCULATION_MAP.md` | End-to-end calculation pipeline, module dependencies, what-affects-what matrix |

---

## Rules for Code Changes

1. Never modify files outside `lib/` and `test/` without asking
2. Never remove existing tests unless explicitly instructed
3. **All tests must pass before committing** — run `flutter test` after every implementation change. Do not commit if tests fail. Add new tests for new functionality.
4. Follow existing code patterns in the project
5. Always use fully qualified `package:avdepot_rechner/` imports
6. Use German (de) locale as default for initial app state
7. Never mention AI involvement in commit messages, code comments, or documentation
8. **Evaluate new functionality for modularization** — if a new feature has distinct logic (e.g., a different tax system, subsidy regime, or estimation method), implement it as a separate module with an abstract interface, not inline in existing code
