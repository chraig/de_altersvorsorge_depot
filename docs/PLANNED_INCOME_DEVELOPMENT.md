# Planned Feature: Income Development Over Savings Period

## Overview

Model how gross salary changes over the savings period, replacing the current
static salary assumption. This feature is **opt-in** — disabled by default, the
calculator uses a constant salary. When activated, year-by-year salary changes
affect subsidies, tax rates, and pension point accumulation.

## Activation

- Toggle in Advanced Settings: "Model income development" (off by default)
- When off: current behavior (static gross salary for all years)
- When on: salary varies year-by-year based on configured parameters

## Parameters

### Core Inputs

| Parameter | Default | Range | Description |
|---|---|---|---|
| Annual salary growth rate | 2% | 0–8% | Compound annual salary increase |
| Growth curve | Linear | Linear / Step / Logarithmic | How growth is distributed over time |
| Salary cap | €90,000 | Fixed | Beitragsbemessungsgrenze (no additional pension points above this) |

### Growth Curves

1. **Linear**: Constant percentage increase each year
   - `salary(j) = brutto × (1 + growth_rate)^j`

2. **Step-wise**: Flat salary with periodic promotions
   - Promotion every N years (configurable, default 5)
   - Promotion increase (configurable, default 15%)
   - `salary(j) = brutto × (1 + promotion_pct)^floor(j / promotion_interval)`

3. **Logarithmic**: Fast early growth, plateaus
   - `salary(j) = brutto + (salary_cap - brutto) × (1 - 1/(1 + 0.1×j))`
   - Approaches salary cap asymptotically

### Life Event Parameters

| Parameter | Default | Range | Description |
|---|---|---|---|
| Part-time start year | — | 0–spardauer | Year when part-time begins (relative to savings start) |
| Part-time duration | 0 | 0–10 years | How long part-time lasts |
| Part-time percentage | 50% | 20–80% | Salary reduction during part-time |
| Child arrival years | — | List of years | When each child arrives (overrides static `kinder` count) |

## Impact on Calculations

### What Changes Year-by-Year

With income development active, the simulation loop changes from using a static
`brutto` to `brutto(j)` for each year `j`:

1. **Grenzsteuersatz(j)**: Tax bracket changes as salary grows
   - Higher salary → higher marginal rate → larger Günstigerprüfung refund

2. **Geringverdienerbonus(j)**: May apply only in early years
   - Eligible when `brutto(j) ≤ 26,250` — drops off as salary grows

3. **Kinderzulage(j)**: Varies if children arrive at different years
   - Child arrives at year Y → Kinderzulage starts at year Y
   - Kindergeld typically ends at age 25 → Kinderzulage stops

4. **Entgeltpunkte(j)**: Pension points accumulate per year
   - `EP(j) = min(brutto(j), Beitragsbemessungsgrenze) / Durchschnittsentgelt`
   - Total EP = sum over all years → more accurate pension estimate

5. **Günstigerprüfung refund(j)**: Changes with marginal rate
   - Early career (low rate) → small refund
   - Later career (high rate) → large refund

### What Stays the Same

- Savings rate (monthly contribution): constant
- Macro scenario (return, inflation): constant per scenario
- Costs (AV, ETF): constant
- Kirchensteuer: constant

## Data Model Changes

```dart
class IncomeDevSettings {
  bool enabled;                    // default: false
  double growthRate;               // default: 0.02
  GrowthCurve curve;               // default: linear
  double? partTimeStart;           // year index, null = no part-time
  int partTimeDuration;            // years, default: 0
  double partTimePercentage;       // default: 0.5
  List<int> childArrivalYears;     // year indices when children arrive
}

enum GrowthCurve { linear, stepwise, logarithmic }
```

Add to `CalculatorState`:
```dart
final IncomeDevSettings incomeDev;
```

## Simulation Changes

```
For j = 0 to spardauer - 1:
  // Determine salary for this year
  if incomeDev.enabled:
    brutto_j = applyCurve(brutto, j, incomeDev)
    if isPartTime(j, incomeDev):
      brutto_j *= incomeDev.partTimePercentage
    kinder_j = countActiveChildren(j, incomeDev.childArrivalYears)
  else:
    brutto_j = brutto  // static (current behavior)
    kinder_j = kinder

  // Rest of simulation uses brutto_j and kinder_j instead of static values
  gst_j = getGrenzsteuersatz(brutto_j)
  zulage_j = calcZulage(jahresbeitrag, kinder_j, alter, j, brutto_j)
  gp_j = calcGuenstigerpruefung(jahresbeitrag, zulage_j.total, gst_j)
  ...
```

## UI Changes

### Advanced Settings (when toggle is on)

- Salary growth rate slider (0–8%)
- Growth curve selector (3 chips: Linear / Step / Logarithmic)
- Part-time toggle with start year, duration, percentage sliders
- Child timing: add/remove child arrival years

### Visualization

- Optional salary trajectory mini-chart in the input panel
- Year-by-year subsidy breakdown table showing how subsidies change

## State Pension Impact

With income development, the pension estimate becomes more accurate:
```
Total EP = Σ min(brutto(j), BBG) / Durchschnittsentgelt
Monthly pension = Total EP × Rentenwert
```

This replaces the current simplified formula that assumes constant salary.

## Implementation Priority

1. Basic salary growth rate (linear) — simplest, most impactful
2. Geringverdienerbonus year-by-year check
3. Children timing
4. Part-time phases
5. Step/logarithmic curves
6. Salary trajectory chart
