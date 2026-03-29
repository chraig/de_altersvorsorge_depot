# Configuration Reference

This document lists every adjustable parameter in the calculator, where it lives in the
codebase, its default value, valid range, and the legislative or empirical basis for
the default.

---

## 1. Förderung Parameters

Located in: `lib/services/domain/calculator_service.dart`

| Parameter | Default | Range | Legal Basis | Code Location |
|---|---|---|---|---|
| Grundzulage Stufe 1 rate | 50% | Fixed | §89 Abs. 1 EStG-E | `calcGrundzulage()` |
| Grundzulage Stufe 1 cap | €360/yr | Fixed | §89 Abs. 1 EStG-E | `calcGrundzulage()` |
| Grundzulage Stufe 2 rate | 25% | Fixed | §89 Abs. 1 EStG-E | `calcGrundzulage()` |
| Grundzulage Stufe 2 cap | €1,800/yr | Fixed | §89 Abs. 1 EStG-E | `calcGrundzulage()` |
| Max Grundzulage | €540/yr | Derived | — | Calculated |
| Kinderzulage per child | up to €300/yr | Fixed | §89 Abs. 2 EStG-E | `calcKinderzulage()` |
| Kinderzulage match rate | 1:1 | Fixed | §89 Abs. 2 EStG-E | `calcKinderzulage()` |
| Berufseinsteigerbonus | €200 (one-time) | Fixed | §89 Abs. 3 EStG-E | `calcBonus()` |
| Bonus max age | 24 (under 25) | Fixed | §89 Abs. 3 EStG-E | `calcBonus()` |
| Geringverdienerbonus | €175/yr | Fixed | §89 Abs. 4 EStG-E | `calcGeringverdienerbonus()` |
| Geringverdiener threshold | €26,250 brutto | Fixed | §89 Abs. 4 EStG-E | `calcGeringverdienerbonus()` |
| Mindestbeitrag | €120/yr | Not enforced | §89 Abs. 1 EStG-E | Slider min=€10/mo |
| Höchstbeitrag (gefördert) | €1,800/yr | Enforced in calc | §89 Abs. 1 EStG-E | `calcGrundzulage()` |

### To modify Förderung parameters:

Edit the constants directly in the `calcGrundzulage()`, `calcKinderzulage()`, and
`calcBonus()` methods. All are hardcoded for clarity; extract to a config class if
you need runtime configurability.

---

## 2. Tax Parameters

Located in: `lib/services/domain/calculator_service.dart`

| Parameter | Default | Basis | Code Location |
|---|---|---|---|
| Grundfreibetrag | €11,784 | §32a EStG 2024 | `getGrenzsteuersatz()` |
| Eingangssteuersatz | 14% | §32a EStG | `getGrenzsteuersatz()` |
| Progressive zone end | €66,760 | §32a EStG 2024 | `getGrenzsteuersatz()` |
| Spitzensteuersatz | 42% | §32a EStG | `getGrenzsteuersatz()` |
| Reichensteuersatz start | €277,826 | §32a EStG 2024 | `getGrenzsteuersatz()` |
| Reichensteuersatz | 45% | §32a EStG | `getGrenzsteuersatz()` |
| Abgeltungssteuersatz | 26.3750% (default) | §43a + §4 SolZG | `CostSettings.abgeltungssteuersatz` |
| Kirchensteuer | 0% / 8% / 9% | Toggle in Advanced Settings | `CostSettings.kirchensteuer` |
| Teilfreistellung Aktienfonds | 30% | §20 InvStG | `simulateETF()` |
| Vorabpauschale drag | 0.3% p.a. | Simplified (Basiszins ~2.3-3.2%) | `simulateETF()` |
| Retirement tax | Incremental §32a on combined income | Progressive formula | `simulateAV()` |

### To update tax brackets:

Replace the values in `getGrenzsteuersatz()`. The function uses a piecewise linear
approximation. For production use, consider implementing the exact §32a formulas:

```dart
// Zone 2 (2024): y = (1008.70 * z + 1400) * z
// where z = (zvE - 11784) / 10000
// This gives the tax amount, not the marginal rate
```

### Kirchensteuer

Kirchensteuer is implemented as a toggle in Advanced Settings (None / 8% / 9%):

- **ETF side**: Uses the reduced KapESt formula: `KapESt = 25% / (1 + 25% × KiSt_rate)` (§32d Abs. 1 Satz 3 EStG), then adds Soli and KiSt
  - None: 26.3750% | 8%: 27.8186% | 9%: 27.9951%
- **AV side**: Retirement payout tax multiplied by `(1 + KiSt_rate)`
- Code: `CostSettings.abgeltungssteuersatz` (computed getter) and `CostSettings.kirchensteuer`

---

## 3. Cost Parameters

Located in: `lib/models/scenario.dart` (defaults) and `lib/features/calculator/cubit/calculator_cubit.dart` (state)

| Parameter | Default | Range (UI) | Basis |
|---|---|---|---|
| AV-Depot Kosten | 0.5% p.a. | 0.1–1.5% | Kostendeckel: 1.0% Standardprodukt |
| ETF-Depot Kosten | 0.2% p.a. | 0.1–1.0% | Typical World-ETF TER |

### Cost decomposition (informational):

**AV-Depot total effective costs** may include:
- ETF TER: 0.1–0.2%
- Platform/custody fee: 0.0–0.3%
- Transaction costs: negligible for buy-and-hold
- Total: 0.2–0.5% for self-directed; up to 1.0% for managed Standardprodukt

**ETF-Depot total effective costs**:
- ETF TER: 0.1–0.2%
- Broker: €0 at Neobroker
- Spread: <0.05% for large ETFs
- Total: 0.1–0.2%

---

## 4. Payout Parameters

Located in: `lib/services/domain/calculator_service.dart`

| Parameter | Default | Basis | Code Location |
|---|---|---|---|
| Auszahlungsdauer | 20 years | §89 Abs. 8 (bis 85) | `simulateAV()`, `simulateETF()` |
| Payout start age | 65 | Implied (Rentenalter) | User-selected retirement age; spardauer derived as retirementAge - alterStart |
| Einmalentnahme | 0% (not modeled) | Up to 30% allowed | §89 Abs. 9 EStG-E |
| Leibrente option | Not modeled | Available via provider switch | — |

### To model Einmalentnahme:

```dart
final einmalquote = 0.30; // 30% upfront
final einmal = depot * einmalquote;
final einmalSteuer = einmal * steuersatzRente;
final einmalNetto = einmal - einmalSteuer;
final restDepot = depot * (1 - einmalquote);
final monatlich = restDepot / ((auszahlungsDauer * 12));
```

---

## 5. Personal Scenario Defaults

Located in: `lib/models/scenario.dart` → `PersonalScenario.defaults()`

| Preset | Sparrate | Brutto | Kinder | Alter | Dauer | Rationale |
|---|---|---|---|---|---|---|
| Berufseinsteiger 🎓 | €50/mo | €32,000 | 0 | 23 | 44 | Entry-level income, long horizon, retirement at 67 |
| Single Mitte 30 💼 | €150/mo | €55,000 | 0 | 35 | 32 | Median income, max. contribution |
| Familie 2 Kinder 👨‍👩‍👧‍👦 | €100/mo | €45,000 | 2 | 32 | 35 | Dual-earner household, one partner |
| Gutverdiener 📈 | €500/mo | €85,000 | 0 | 40 | 27 | High income, contributions above subsidy cap |
| Teilzeit + Kind 👶 | €50/mo | €22,000 | 1 | 30 | 37 | Part-time worker, high Förderquote |

### UI Ranges for Sliders

| Slider | Min | Max | Step | Unit |
|---|---|---|---|---|
| Sparrate | 10 | 570 | 5 | €/Monat (max €6,840/yr per contract) |
| Bruttojahreseinkommen | 12,000 | 250,000 | 1,000 | €/Jahr (covers 99%+ of population) |
| Kinder | 0 | 5 | 1 | — |
| Alter bei Start | 18 | 60 | 1 | Jahre |
| Rentenalter | 60 | 75 | 1 | Jahre |
| Gesetzliche Rente | 0 | 3,500 | 50 | €/Monat |
| Sonstige Einkünfte | 0 | 50,000 | 500 | €/Jahr |
| Beginn Erwerbstätigkeit | 14 | 35 | 1 | Jahre (affects pension EP) |
| Rendite p.a. | 1.0% | 14.0% | 0.5% | — |
| Kosten AV | 0.1% | 1.5% | 0.1% | — |
| Kosten ETF | 0.1% | 1.0% | 0.1% | — |
| Inflation p.a. | 0.5% | 6.0% | 0.5% | — |

---

## 6. Macro Scenario Defaults

Located in: `lib/models/scenario.dart` → `MacroScenario.defaults()`

| Preset | Rendite | Inflation | Real | Color | Hex |
|---|---|---|---|---|---|
| Boom 🚀 | 10.0% | 1.5% | 8.5% | Green | #10B981 |
| Basis 📊 | 7.0% | 2.0% | 5.0% | Blue | #0066FF |
| Moderat ⚖️ | 5.0% | 2.5% | 2.5% | Amber | #F59E0B |
| Stagflation 🔥 | 4.0% | 4.5% | -0.5% | Red | #EF4444 |
| Japan 🇯🇵 | 2.0% | 0.5% | 1.5% | Purple | #8B5CF6 |
| Verl. Jahrzehnt 💥 | 3.0% | 2.0% | 1.0% | Gray | #6B7280 |

### Available Colors for Custom Macros

Defined in `lib/features/calculator/widgets/macro_section.dart` → `_MacroScenarioDialogState._colors`:

```dart
#10B981, #0066FF, #F59E0B, #EF4444, #8B5CF6,
#6B7280, #EC4899, #06B6D4, #84CC16
```

---

## 7. Theme Configuration

Located in: `lib/config/theme.dart`

### Color Palette

| Token | Hex | Usage |
|---|---|---|
| accent | #0066FF | Primary actions, AV-Depot, links |
| accentLight | #E6F0FF | Backgrounds for accent elements |
| etf | #FF6B35 | ETF-Depot indicator |
| etfLight | #FFF3ED | ETF background tint |
| card | #F7F8FA | Card backgrounds |
| bg | #FFFFFF | Scaffold background |
| border | #E5E7EB | Borders, dividers |
| text | #1A1A2E | Primary text |
| label | #4A4A6A | Secondary text, labels |
| muted | #8B8BA7 | Tertiary text, hints |
| success | #10B981 | Positive values |
| successBg | #ECFDF5 | Positive value backgrounds |
| danger | #EF4444 | Negative values |
| dangerBg | #FEF2F2 | Negative value backgrounds |
| warnBg | #FFFBEB | Disclaimer background |
| warnBorder | #FDE68A | Disclaimer border |
| warnText | #92400E | Disclaimer text |

### Typography

| Style | Font | Weight | Usage |
|---|---|---|---|
| Display | DM Sans | 800 | Headings |
| Body | DM Sans | 400–600 | Labels, descriptions |
| Mono | DM Mono | 500–700 | Numbers, currency, percentages |

---

## 8. Feature Flags

### Already Implemented

- Kirchensteuer toggle (None / 8% Bayern-BaWü / 9% other states)
- Geringverdienerbonus (€175/yr for gross ≤ €26,250)
- Income development toggle (3 growth curves, part-time, child timing)
- Ungefördert tax treatment selector (nachgelagert / Ertragsanteil / Halbeinkünfte)
- Progressive §32a tax calculation (exact polynomial formulas, not marginal rate)
- Adjustable Arbeitsbeginn (14–35, affects pension EP calculation)

### Planned for Future Versions

```dart
class FeatureFlags {
  static const bool enableEinmalentnahme = false;
  static const bool enableRiesterComparison = false;
  static const bool enableMonteCarloSim = false;
  static const bool enablePDFExport = false;
  static const bool enableDarkMode = false;
  static const bool enableIncomeGrowthCurves = false; // step-wise, logarithmic
  static const bool enablePartTimePhases = false;
  static const bool enableChildArrivalTiming = false;
}
```

---

*Last updated: March 2026*
