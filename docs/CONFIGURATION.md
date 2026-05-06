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
| Kinderzulage max age | 25 if education / 18 otherwise | User toggle | Kindergeld law | `PersonalScenario.kinderStudieren` (Assumptions panel) |
| Berufseinsteigerbonus | €200 (one-time) | Fixed | §89 Abs. 3 EStG-E | `calcBonus()` |
| Bonus max age | 24 (under 25) | Fixed | §89 Abs. 3 EStG-E | `calcBonus()` |
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
| Grundfreibetrag | €12,348 | §32a EStG 2026 | `getGrenzsteuersatz()` |
| Eingangssteuersatz | 14% | §32a EStG | `getGrenzsteuersatz()` |
| End of entry zone (zone 2) | €17,799 | §32a EStG 2026 | `getGrenzsteuersatz()` |
| End of progressive zone (zone 3) | €69,878 | §32a EStG 2026 | `getGrenzsteuersatz()` |
| Spitzensteuersatz | 42% | §32a EStG | `getGrenzsteuersatz()` |
| Reichensteuersatz start | €277,826 | §32a EStG | `getGrenzsteuersatz()` |
| Reichensteuersatz | 45% | §32a EStG | `getGrenzsteuersatz()` |
| Abgeltungssteuersatz | 26.3750% (default) | §43a + §4 SolZG | `CostSettings.abgeltungssteuersatz` |
| Kirchensteuer | Yes/No (rate fixed at 9% when on) | Yes/No toggle in Advanced Settings | `CostSettings.kirchensteuerpflichtig` + `CalcConstants.kirchensteuersatz` |
| Teilfreistellung (Aktienfonds, >50% equity) | 30% | §20 InvStG, §2 Abs. 6 InvStG | `CalcConstants.teilfreistellung` |
| Teilfreistellung — other fund types | 15% Mischfonds, 60–80% Immobilienfonds, 0% Anleihe-/Geldmarkt-ETFs | §20 InvStG | not modeled — calculator assumes Aktienfonds |
| Vorabpauschale drag | 0.3% p.a. | Simplified (Basiszins ~2.3-3.2%) | `simulateETF()` |
| Retirement tax | Incremental §32a on combined income | Progressive formula | `simulateAV()` |

### To update tax brackets:

Update the constants in `CalcConstants` (calculator_service.dart) and the polynomial
coefficients in `GermanTax2026.calcEinkommensteuer()` (tax_module.dart). The exact
§32a formulas are already implemented:

```dart
// Zone 2 (2026): tax = (914.51 × y + 1400) × y
//   where y = (zvE - 12348) / 10000
// Zone 3 (2026): tax = (173.10 × z + 2397) × z + 1034.87
//   where z = (zvE - 17799) / 10000
// Zone 4 (2026): tax = 0.42 × zvE - 11135.63
// Zone 5 (2026): tax = 0.45 × zvE - 19470.38
```

When new annual values are published, rename the class (e.g., `GermanTax2027`) so
prior versions remain available for historical comparison.

### Kirchensteuer

Kirchensteuer is a **Yes/No toggle**. The rate is fixed at 9% (= the rate
in 14 of 16 federal states, ~71% of the population). Bayern and Baden-
Württemberg residents technically pay 8%, which the calculator slightly
overstates as a deliberate simplification — the difference is ~18 bp on
the Abgeltungssteuersatz, translating to roughly €100–200 over a 30-year
ETF accumulation.

- **ETF side**: Uses the reduced KapESt formula from §32d Abs. 1 Sätze 4–5 EStG: `KapESt = (e − 4q) / (4 + k)`, where e = Kapitalertrag, q = creditable foreign withholding tax, k = Kirchensteuersatz. Foreign withholding tax is not modeled (q = 0), so the formula simplifies to `KapESt = e × 1/(4+k)`. Soli (5.5%) and KiSt (k) are then added on top of KapESt.
  - Off: 26.3750% | On: 27.9951%
- **AV side**: Retirement payout tax multiplied by `(1 + kirchensteuerRate)`
- Code: `CostSettings.kirchensteuerpflichtig` (bool), `CostSettings.kirchensteuerRate` (returns `CalcConstants.kirchensteuersatz` = 0.09 when on, 0 otherwise), `CostSettings.abgeltungssteuersatz` (computed getter).

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
| Alter pro Kind | 0 | 24 | 1 | Jahre (Kinderzulage endet mit 25) |
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

- Kirchensteuer Yes/No toggle, rate fixed at 9% (dominant German rate; Bayern/BaWü's 8% is a deliberate simplification)
- Income development toggle with 3 growth curves (linear, step-wise, logarithmic)
- Part-time phases (start year, duration, percentage)
- Child arrival timing (dynamic children added at specific savings years)
- Per-child age tracking with kinderStudieren toggle (Kindergeld until 18 or 25)
- Ungefördert payout taxed via Ertragsanteilbesteuerung (17%, age-67 entry, §22 Nr. 1 Satz 3a EStG)
- Progressive §32a tax calculation (exact polynomial formulas, incremental retirement tax rate)
- Adjustable Arbeitsbeginn (14–35, affects pension EP calculation)
- Stacked bar charts: per-year breakdown of contributions/subsidies (savings) and net/tax (payout)
- Phase-based subsidy breakdown (year ranges with identical components grouped)

### Planned for Future Versions

- Einmalentnahme (up to 30% lump-sum at retirement, §89 Abs. 9 EStG-E)
- Riester comparison (legacy product comparison alongside ETF)
- Monte Carlo simulation (volatile returns instead of constant)
- PDF / CSV export of results
- Dark mode
- Salary trajectory mini-chart in input panel
- Per-child education toggle (currently a single global flag)

---

*Last updated: March 2026*
