# Changelog

All notable changes to this project will be documented in this file.

## [1.0.0] — 2026-03-27

### Added
- Initial release based on Altersvorsorgereformgesetz (Bundestag vote 27.03.2026)
- Full AV-Depot simulation engine with Grundzulage, Kinderzulage, Berufseinsteigerbonus
- ETF-Depot simulation with Vorabpauschale, Abgeltungssteuer, Teilfreistellung
- Günstigerprüfung (automatic tax optimization check)
- 5 personal scenario presets (Berufseinsteiger, Single, Familie, Gutverdiener, Teilzeit)
- 6 macro scenario presets (Boom, Basis, Moderat, Stagflation, Japan, Verlorenes Jahrzehnt)
- Add/edit/delete custom personal and macro scenarios via dialogs
- Macro overlay chart (all scenarios + selected ETF)
- AV vs ETF comparison chart with ghost lines for other macros
- Compound breakdown table (all macros × key figures)
- Förderung detail box with Grundzulage, Kinderzulage, Förderquote, Steuererstattung
- Composition mini-bars (Eigenbeiträge, Zulagen, Steuererstattung, Wertzuwachs)
- Comparison bars (Endkapital, Eigenbeiträge, Zulagen)
- Monthly payout comparison (netto after tax)
- Advanced settings (manual Rendite, Inflation, Kosten AV, Kosten ETF)
- Reset to defaults button
- Bilingual UI (English and German) with live language toggle via LocaleCubit
- State management via flutter_bloc (Cubit pattern) for calculator and locale
- Declarative routing with go_router
- Feature-based project structure (config, core, features, models, services, shared)
- Full research documentation (docs/RESEARCH.md)
- Configuration reference documentation (docs/CONFIGURATION.md)
- Comprehensive README with setup, configuration, and deployment guides

### Based On
- Koalitionseinigung CDU/CSU + SPD, 25.03.2026
- Grundzulage: 50% / 25% (up from 30 Ct / 20 Ct)
- Kostendeckel: 1.0% (down from 1.5%)
- Kinderzulage: full at €25/mo (down from €100/mo)
- Selbstständige: now included in eligibility

## [Unreleased]

### Planned
- Geringverdienerbonus (€175/yr for income ≤ €26,250) implementation
- Riester comparison mode (old vs. new Fördersystem)
- PDF/CSV export of results
- Persistent storage for custom scenarios (SharedPreferences/Hive)
- 2027 tax brackets update (when published by BMF)
- Kirchensteuer option (8% or 9%)
- Wohnwirtschaftliche Verwendung modeling
- Leibrente vs. Auszahlplan comparison
- Monte Carlo simulation (random return sequences)
- Responsive layout optimizations for mobile
- Dark mode
