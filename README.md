# Altersvorsorgedepot-Rechner 2027

A full-scale Flutter web application comparing the new German **Altersvorsorgedepot** (AV-Depot) with a standard private **ETF savings plan**.

Based on the **Altersvorsorgereformgesetz** as amended by the Finanzausschuss on 25.03.2026 and passed by the Bundestag on 27.03.2026 (Drucksache 21/4088). Start date for new AV-Depot products: **1 January 2027**.

---

## Table of Contents

1. [Quick Start](#quick-start)
2. [Prerequisites](#prerequisites)
3. [Project Setup](#project-setup)
4. [Configuration](#configuration)
5. [Architecture](#architecture)
6. [Calculation Methodology](#calculation-methodology)
7. [Data Sources & Research](#data-sources--research)
8. [Customization Guide](#customization-guide)
9. [Testing](#testing)
10. [Deployment](#deployment)
11. [Known Limitations](#known-limitations)
12. [License & Disclaimer](#license--disclaimer)

---

## Quick Start

```bash
flutter pub get
flutter run -d chrome
```

Production build:
```bash
flutter build web --release
# Output in build/web/ — deploy to any static host
```

---

## Prerequisites

| Requirement | Version | Notes |
|---|---|---|
| Flutter SDK | ≥ 3.2.0 | `flutter --version` to check |
| Dart SDK | ≥ 3.2.0 | Bundled with Flutter |
| Chrome | Latest | For `flutter run -d chrome` |
| Node.js | Optional | Only if using Firebase Hosting |

### Installing Flutter (if needed)

```bash
# macOS
brew install flutter

# Linux
sudo snap install flutter --classic

# Windows — download from https://docs.flutter.dev/get-started/install

# Verify
flutter doctor
```

Enable web support:
```bash
flutter config --enable-web
```

---

## Project Setup

### 1. Dependencies

All managed via `pubspec.yaml`:

| Package | Version | Purpose |
|---|---|---|
| `flutter_bloc` | ^9.1.1 | Reactive state management (Cubit/BLoC) |
| `go_router` | ^17.0.1 | Declarative routing |
| `equatable` | ^2.0.8 | Value equality for state classes |
| `fl_chart` | ^1.2.0 | Line charts with tooltips and touch interaction |
| `google_fonts` | ^8.0.2 | DM Sans (UI) + DM Mono (numbers) typography |
| `intl` | ^0.20.2 | German locale number/currency formatting |
| `uuid` | ^4.2.1 | Unique IDs for user-created scenarios |

### 2. Install & Run

```bash
flutter pub get          # Install dependencies
flutter run -d chrome    # Development with hot reload
flutter run -d chrome --web-renderer html   # Alternative renderer (smaller)
flutter run -d chrome --web-renderer canvaskit  # Better charts (default)
```

### 3. Environment Variables

None required. All configuration is in-code (see [Configuration](#configuration)).

### 4. IDE Setup

**VS Code** (recommended):
- Install Flutter & Dart extensions
- `F5` to run with debugging
- `.vscode/launch.json` auto-generated

**Android Studio / IntelliJ**:
- Install Flutter plugin
- Open `de_altersvorsorge_depot/` as project root
- Select Chrome as device

---

## Configuration

### Tax Parameters (`lib/services/domain/calculator_service.dart`)

All tax brackets and rates are defined as static methods. Key values to review annually:

```dart
// German income tax brackets (§32a EStG)
// Update these when brackets change
static double getGrenzsteuersatz(double brutto) {
  if (brutto <= 11784) return 0;        // Grundfreibetrag 2024
  if (brutto <= 17005) return 0.14;     // Eingangssteuersatz
  if (brutto <= 66760) return 0.2397...; // Progressive zone
  if (brutto <= 277825) return 0.42;    // Spitzensteuersatz
  return 0.45;                           // Reichensteuersatz
}
```

### Förderung Parameters (`lib/services/domain/calculator_service.dart`)

```dart
// Grundzulage — Koalitionseinigung März 2026
Stufe 1: 50% on first €360/yr   → max €180
Stufe 2: 25% on €361–€1,800/yr  → max €360
Maximum Grundzulage: €540/yr

// Kinderzulage
€1 per €1 match up to €300/child/yr (full at €25/mo)

// Berufseinsteigerbonus
€200/yr for first 3 years (age < 25 at contract start)

// Payout taxation
Retirement tax rate: grenzsteuersatz × 0.7 (simplified)
Payout period: 20 years (age 65–85)
```

### ETF Tax Parameters

```dart
// Abgeltungssteuer (default, without Kirchensteuer)
Rate: 26.375% (25% + 5.5% Soli)
With 8% Kirchensteuer (Bayern/BaWü): ~27.82%
With 9% Kirchensteuer (other states):  ~27.99%
Teilfreistellung: 30% for Aktien-ETFs (≥51% equity)
Vorabpauschale drag: ~0.2% p.a. (simplified)
// Kirchensteuer is configurable via Advanced Settings toggle
```

### Default Scenarios (`lib/models/scenario.dart`)

Personal and macro scenario defaults are defined in static factory methods:

```dart
PersonalScenario.defaults()  // 5 presets
MacroScenario.defaults()     // 6 presets
```

Modify these to change what users see on first load.

### Theme & Branding (`lib/config/theme.dart`)

All colors, fonts, and component styles in one file:

```dart
class AppColors {
  static const accent = Color(0xFF0066FF);  // Primary blue
  static const etf = Color(0xFFFF6B35);     // ETF orange
  // ... full palette
}
```

---

## Architecture

```
lib/
├── main.dart                          # App entry, BlocProvider setup, MaterialApp.router
├── config/
│   ├── build_config.dart              # Build mode flags, app name/version constants
│   └── theme.dart                     # Design tokens (spacing, colors, radii, typography)
│       ├── AppSpacing, AppRadius      # Layout constants
│       ├── AppColors                  # Full color palette (accent, etf, surfaces, semantic)
│       ├── AppTheme                   # ThemeData, SliderTheme, text style helpers
│       └── AppPadding, AppDimensions  # Padding presets, chart/bar dimensions
├── core/
│   ├── l10n/
│   │   └── app_strings.dart           # Bilingual strings (EN/DE) via AppStrings abstract class
│   │       ├── StringsEn              # English translations
│   │       └── StringsDe              # German translations
│   ├── routes/
│   │   └── router.dart                # GoRouter configuration (single route: /)
│   └── state/
│       ├── app_settings.dart          # Coordinates LocaleCubit + CalculatorCubit
│       ├── app_settings_scope.dart    # MultiBlocProvider wrapper for widget tree
│       └── locale_cubit.dart          # Language switching (EN ↔ DE)
├── models/
│   └── scenario.dart                  # Pure data classes (no logic)
│       ├── PersonalScenario           # sparrate, brutto, kinder, alterStart, spardauer
│       ├── MacroScenario              # rendite, inflation, color, description
│       ├── CostSettings               # kostenAV, kostenETF
│       ├── SubsidyBreakdown           # Grundzulage, Kinderzulage, Bonus, Förderquote
│       ├── YearlyDataPoint            # Per-year simulation output
│       ├── AVResult / ETFResult       # Full simulation results
│       └── CombinedResult             # AV + ETF paired for comparison (+ delta getters)
├── services/
│   └── domain/
│       └── calculator_service.dart    # Pure static calculation engine
│           ├── calcGrundzulage()      # 50%/25% two-tier subsidy
│           ├── calcKinderzulage()     # Up to €300/child 1:1 match
│           ├── calcBonus()            # €200/yr for 3 years (under 25)
│           ├── calcZulage()           # Combined yearly subsidy (record return type)
│           ├── getGrenzsteuersatz()   # German marginal tax rate approximation
│           ├── calcGuenstigerpruefung()
│           ├── calcSubsidyBreakdown() # Full year-1 breakdown
│           ├── simulateAV()           # Year-by-year AV-Depot simulation
│           ├── simulateETF()          # Year-by-year ETF-Depot simulation
│           ├── simulateCombined()     # AV + ETF paired
│           └── simulateAllMacros()    # Cross-product: person × all macros
├── features/
│   └── calculator/
│       ├── cubit/
│       │   ├── calculator_cubit.dart  # State management (flutter_bloc Cubit)
│       │   │   ├── Input setters      # setSparrate, setBrutto, setKinder, ...
│       │   │   ├── Scenario CRUD      # add/update/remove personal & macro
│       │   │   └── resetToDefaults()
│       │   └── calculator_state.dart  # Immutable state + computed getters
│       │       ├── effectiveRendite/Inflation
│       │       ├── subsidyBreakdown   # Calls CalculatorService
│       │       ├── avResult / etfResult / currentResult
│       │       └── allMacroResults    # All macros sorted by real return
│       ├── pages/
│       │   └── calculator_page.dart   # Main UI layout with tabs
│       └── widgets/
│           ├── input_panel.dart       # Sliders, PersonalScenarioBar, dialogs
│           ├── macro_section.dart     # MacroScenarioGrid, MacroCard, dialogs
│           ├── charts.dart            # MacroOverlayChart, ComparisonChart (fl_chart)
│           └── compound_table.dart    # DataTable: macro × key figures breakdown
└── shared/
    ├── utils/
    │   └── fmt.dart                   # Formatting: eur(), pct(), eurK(), signed()
    └── widgets/
        └── common.dart                # StatCard, MiniBar, ComparisonBar,
                                       # SectionDivider, ResultBanner
```

### Data Flow

```
User Input (Slider/Tap)
    ↓
CalculatorCubit (flutter_bloc Cubit)
    ↓  setter methods → emit(state.copyWith(...))
    ↓
CalculatorState (immutable, with computed getters)
    ↓  getters call CalculatorService static methods
    ↓
Widget rebuild via context.watch<CalculatorCubit>()
    ↓
Charts, Tables, Cards re-render with new data
```

All calculations are **pull-based** (computed in `CalculatorState` getters, not pushed/cached), ensuring results are always consistent with the latest state. The `AppSettingsScope` wraps the widget tree with `MultiBlocProvider`, exposing both the `CalculatorCubit` and `LocaleCubit` for language switching.

---

## Calculation Methodology

See [docs/RESEARCH.md](docs/RESEARCH.md) for full legislative sources and formula derivations.

### AV-Depot Simulation (per year)

```
For each year j = 0 ... spardauer-1:
  1. zulage = Grundzulage(jahresbeitrag) + Kinderzulage(jahresbeitrag, kinder) + Bonus(alter, j)
  2. günstigerprüfung = (jahresbeitrag + zulage) × grenzsteuersatz
     → if > zulage: additional refund on Girokonto (not reinvested)
  3. depot = (depot + jahresbeitrag + zulage) × (1 + rendite - kosten_av)
  4. No taxes on gains during accumulation (no Abgeltungssteuer, no Vorabpauschale)

Payout phase (20 years, age 65–85):
  monthly_brutto = depot / 240
  monthly_netto = monthly_brutto × (1 - grenzsteuersatz × 0.7)
```

### ETF-Depot Simulation (per year)

```
For each year j = 0 ... spardauer-1:
  1. depot = (depot + jahresbeitrag) × (1 + rendite - kosten_etf - 0.002)
     → 0.002 = simplified Vorabpauschale drag

Payout phase:
  gewinn = depot - eigenbeitraege
  steuerpflichtiger_gewinn = gewinn × (1 - 0.30)   // 30% Teilfreistellung
  steuer = steuerpflichtiger_gewinn × abgeltungssteuersatz  // 26.375% default, higher with Kirchensteuer
  netto = depot - steuer
  monthly = netto / 240
```

### Key Simplifications

| Aspect | Simplification | Reality |
|---|---|---|
| Returns | Constant annual rate | Volatile, sequence-of-returns risk |
| Inflation | Constant annual rate | Variable |
| Tax brackets | Static (2024 values) | Adjusted ~annually |
| Kirchensteuer | Optional toggle (0%/8%/9%) | Affects both AV payout tax and Abgeltungssteuer |
| Soli | Included in base rate | May change |
| Vorabpauschale | Fixed 0.2% drag | Depends on Basiszins |
| Retirement tax rate | Based on estimated combined retirement income | Actual rate depends on total taxable income |
| Günstigerprüfung refund | Not reinvested | Could be reinvested manually |
| Quellensteuer on fund level | Not modeled | ~0.3% p.a. already in fund returns |
| Wohnwirtschaftliche Verwendung | Not modeled | Tax-free withdrawal for property |

---

## Data Sources & Research

### Legislative Sources

| Document | Reference | Content |
|---|---|---|
| Gesetzentwurf | Bundestag Drucksache 21/4088 | Original Altersvorsorgereformgesetz |
| Finanzausschuss-Änderungen | 25.03.2026 session | Raised Grundzulage to 50%, lowered Kostendeckel to 1%, added Selbstständige |
| Bundestag Plenarprotokoll | 27.03.2026, 2.+3. Lesung | Final passage |
| BMF FAQ | bundesfinanzministerium.de | Official Q&A on the reform |
| Bundestag Textarchiv | bundestag.de/kw12-pa-finanzen | Committee hearing summary |

### Key URLs

- **BMF FAQ**: https://www.bundesfinanzministerium.de/Content/DE/FAQ/reform-der-privaten-altersvorsorge.html
- **Bundestag vote**: https://www.bundestag.de/presse/hib/kurzmeldungen-1157838
- **Bundestag hearing**: https://www.bundestag.de/dokumente/textarchiv/2026/kw12-pa-finanzen-1152002
- **Finanztip Ratgeber**: https://www.finanztip.de/altersvorsorge/altersvorsorgedepot/
- **Finanztip Rechner**: https://www.finanztip.de/altersvorsorge/altersvorsorgedepot-rechner/
- **justETF Overview**: https://www.justetf.com/de/academy/altersvorsorgedepot-entwurf-2027.html

### Förderung Structure (Post-Koalitionseinigung)

Source: Finanzausschuss amendment to Drucksache 21/4088, §89 EStG-E

| Parameter | First Draft (Dec 2025) | Final (Mar 2026) |
|---|---|---|
| Grundzulage Stufe 1 | 30 Ct/€ on first €1,200 | **50%** on first €360 |
| Grundzulage Stufe 2 | 20 Ct/€ on €1,201–€1,800 | **25%** on €361–€1,800 |
| Max. Grundzulage | €480/yr | **€540/yr** |
| Kinderzulage full at | €100/mo own contribution | **€25/mo** own contribution |
| Kostendeckel Standard | 1.5% Effektivkosten | **1.0%** Effektivkosten |
| Selbstständige | Excluded | **Included** |
| Öffentlicher Träger | Not planned | **Mandated** (Standarddepot) |
| Berufseinsteigerbonus | €200/yr, 3 years | **Unchanged** |
| Geringverdienerbonus | €175/yr under €26,250 | **Unchanged** |

### Macro Scenario Assumptions

| Scenario | Return p.a. | Inflation p.a. | Historical Basis |
|---|---|---|---|
| Boom | 10.0% | 1.5% | US/EU equity 2010–2021 |
| Basis | 7.0% | 2.0% | MSCI World 1970–2024 avg |
| Moderat | 5.0% | 2.5% | Below-average growth phases |
| Stagflation | 4.0% | 4.5% | 1970s oil crisis era |
| Japan | 2.0% | 0.5% | Nikkei 1990–2020 |
| Verl. Jahrzehnt | 3.0% | 2.0% | S&P 500 2000–2012 |

Sources for historical returns:
- MSCI World Net Return Index (1970–2024): ~7% p.a. nominal
- S&P 500 2000–2012: ~1.7% p.a. nominal (incl. Dotcom + GFC)
- Nikkei 225 1990–2020: ~0.5% p.a. nominal
- German CPI historical average: ~2.0% p.a.

---

## Customization Guide

### Adding a New Tax Regime

1. Create a new static method in `lib/services/domain/calculator_service.dart`:
```dart
static double getGrenzsteuersatzV2(double brutto) {
  // New brackets for 2027 or beyond
}
```

2. Update `simulateAV()` and `simulateETF()` to use the new method.

### Adding a New Subsidy Type

1. Add field to `SubsidyBreakdown` in `lib/models/scenario.dart`
2. Add calculation in `lib/services/domain/calculator_service.dart` → `calcSubsidyBreakdown()`
3. Add display in `lib/features/calculator/pages/calculator_page.dart`

### Adding a New Chart Type

1. Create widget in `lib/features/calculator/widgets/charts.dart`
2. Add to `lib/features/calculator/pages/calculator_page.dart` layout
3. Use `context.watch<CalculatorCubit>()` to get data reactively

### Persisting Custom Scenarios

Currently, custom scenarios are in-memory only. To persist:

1. Add `shared_preferences` or `hive` to `pubspec.yaml`
2. Serialize scenarios to JSON in `CalculatorCubit`
3. Load in `AppSettings.initialize()`, save on every CRUD operation

### Exporting Results

To add PDF/CSV export:
1. Add `pdf` or `csv` package
2. Create export service reading from `CalculatorState` getters
3. Add export button to UI

---

## Testing

### Unit Tests (Calculator)

```bash
flutter test test/calculator_test.dart
```

Example test structure:
```dart
test('Grundzulage at max contribution', () {
  expect(CalculatorService.calcGrundzulage(1800), 540.0);
});

test('Grundzulage at 360 boundary', () {
  expect(CalculatorService.calcGrundzulage(360), 180.0);
});

test('Kinderzulage caps at 300 per child', () {
  expect(CalculatorService.calcKinderzulage(500, 2), 600.0);
});
```

### Widget Tests

```bash
flutter test test/widget_test.dart
```

### Integration Tests

```bash
flutter test integration_test/
```

---

## Deployment

### Build

```bash
flutter build web --release
```

This produces a fully static site in `build/web/` (~25 MB). No backend required.

### Test Locally

```bash
cd build/web
python -m http.server 8080
# Open http://localhost:8080
```

### Deploy to Hosting Provider

Upload the contents of `build/web/` to your hosting provider's public directory:

- **Hostinger / shared hosting**: Upload via File Manager or FTP to `public_html/`
- **Vercel**: `vercel --prod`
- **Netlify**: Drag & drop `build/web/`
- **GitHub Pages**: Push to `gh-pages` branch

No server-side configuration needed — any static file host works.

### Security

This application is safe to host. It is a purely client-side static site:

- **No backend**: No server-side code, no database, no API endpoints to secure
- **No data collection**: No cookies, no tracking, no analytics, no user accounts
- **No external requests**: All calculations run locally in the browser
- **No user input transmitted**: Nothing leaves the visitor's device
- **Minimal attack surface**: Only static HTML, JS, and WASM files served by the web host

Recommended: Serve over **HTTPS** (enabled by default on most hosting providers) to prevent file tampering in transit.

---

## Known Limitations

1. **Constant returns**: Real markets are volatile; sequence-of-returns risk is not modeled
2. **Simplified Vorabpauschale**: Uses fixed 0.2% drag instead of actual Basiszins calculation
3. **No partial-year contributions**: Assumes full-year contributions from year 1
4. **Retirement tax rate**: Based on estimated combined income (state pension + AV payout + other); actual rate depends on total taxable income in retirement
5. **Günstigerprüfung refund not reinvested**: In practice, you could invest the tax refund in a separate ETF
6. **No Wohnriester/wohnwirtschaftliche Verwendung**: Tax-free withdrawal for property not modeled
7. **No Riester comparison**: Only compares AV-Depot vs. free ETF; old Riester not included
8. **No mortality tables**: Leibrente option would require actuarial calculations
10. **2024 tax brackets**: Should be updated when 2027 brackets are published

---

## License & Disclaimer

**This tool is for educational and illustrative purposes only.** It does not constitute financial, tax, or legal advice. The calculations are based on simplified assumptions and may differ significantly from actual outcomes depending on market conditions, provider costs, individual tax situations, and legislative changes.

Based on the Altersvorsorgereformgesetz as passed by the German Bundestag. The law may be subject to further amendments before or after the 1 January 2027 start date.

No warranty is provided. Use at your own risk. Consult a qualified financial advisor (Steuerberater, Finanzberater) for personal decisions.

---

*Built with Flutter • Last updated: March 2026*
