# Product Changelog

All notable user-facing changes to the Altersvorsorgedepot-Rechner.

## [1.1.0] — 2026-03-27

### Added
- Progressive §32a tax calculation (exact polynomial formulas replacing marginal rate approximation)
- Selectable ungefördert tax treatment (nachgelagert / Ertragsanteil / Halbeinkünfte) — pending BMF guidance
- Adjustable Arbeitsbeginn (14–35 years) for pension point estimation
- Facts-only principle: only verified legislation implemented, uncertainties documented
- Geringverdienerbonus (€175/yr for gross ≤ €26,250) with green banner when active
- Kirchensteuer toggle (None / 8% Bayern-BaWü / 9% other states) in Advanced Settings
- Dynamic pros/cons section in comparison results, adapting to the current scenario
- "Included in This Calculator" section in footer listing all implemented features
- Simplifications and "Not Yet Included" sections in footer
- ETF tax note explaining Teilfreistellung and how only gains are taxed
- Contextual explanation when ETF portfolio outperforms AV-Depot
- Retirement age slider replaces savings duration slider — duration derived automatically
- Responsive layout for mobile and tablet screens
- Personal scenario highlighting — selected preset is visually indicated
- Preset scenario names update when switching language
- Legislative basis section with Drucksache, Finanzausschuss amendments, Bundestag vote, and effective date
- Source references (BMF FAQ, Bundestag, Finanztip, justETF) in subsidy logic section
- Tax refund bar clearly labeled as paid to bank account, not into the depot

### Changed
- Default selection is now "Career Starter" preset (retirement at 67) instead of arbitrary values
- All presets now retire at 67 (career starter was 65)
- High earner preset savings rate raised from €150/mo to €500/mo
- Monthly savings slider max raised from €300 to €5,000
- Gross annual income slider max raised from €120,000 to €1,000,000
- Adjusting starting age automatically recalculates duration to keep retirement age constant
- Moved legislative description from header subtitle to detailed section at bottom
- Stat cards (Final Capital / Purchasing Power) now equal height
- Compound table summary bar: labels above values with vertical dividers, wraps on mobile
- "Lost Decade" / "Verlorenes Jahrzehnt" written out in full (was abbreviated)
- All hardcoded strings now bilingual (router error page, comparison bar labels)
- All imports converted to fully qualified package:avdepot_rechner/ paths
- Hardcoded colors extracted to AppColors constants
- Simplified deployment docs for static hosting

### Fixed
- Chart tooltip crash when hovering over ghost lines (tooltipItems size mismatch)
- Reset button now also resets tab selection to first tab

## [1.0.0] — 2026-03-27

### Added
- AV-Depot simulation with Grundzulage (50%/25%), Kinderzulage, Berufseinsteigerbonus
- ETF-Depot simulation with Vorabpauschale, Abgeltungssteuer, 30% Teilfreistellung
- Günstigerprüfung (automatic tax optimization check)
- 5 personal scenario presets (Berufseinsteiger, Single, Familie, Gutverdiener, Teilzeit)
- 6 macro scenario presets (Boom, Basis, Moderat, Stagflation, Japan, Verlorenes Jahrzehnt)
- Custom personal and macro scenarios (add, edit, delete)
- Macro overlay chart showing all scenarios with selected ETF comparison
- AV vs ETF comparison chart with ghost lines for other macros
- Compound breakdown table across all macros
- Subsidy detail box (Grundzulage, Kinderzulage, Förderquote, Steuererstattung)
- Composition breakdown (Eigenbeiträge, Zulagen, Wertzuwachs)
- Monthly payout comparison (netto after tax)
- Advanced settings (manual Rendite, Inflation, Kosten AV, Kosten ETF)
- Reset to defaults
- Bilingual UI (English / German) with live toggle
- Subsidy logic reference section

### Based On
- Altersvorsorgereformgesetz, Bundestag Drucksache 21/4088
- Koalitionseinigung CDU/CSU + SPD, 25.03.2026
- Bundestag vote 27.03.2026
- Grundzulage: 50% / 25% (up from 30 Ct / 20 Ct in original draft)
- Kostendeckel: 1.0% (down from 1.5%)
- Kinderzulage: full at €25/mo (down from €100/mo)
- Selbstständige: now included in eligibility

## Planned

- Income development: step-wise/logarithmic growth curves, part-time phases, child arrival timing
- Riester comparison mode (old vs. new Fördersystem)
- PDF/CSV export of results
- Persistent storage for custom scenarios
- 2027 tax brackets update (when published by BMF)
- Wohnwirtschaftliche Verwendung modeling
- Leibrente vs. Auszahlplan comparison
- Monte Carlo simulation (random return sequences)
- Dark mode
