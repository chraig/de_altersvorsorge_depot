# Income Development Over Savings Period

Income development is **opt-in** via a toggle in the "Income Scenarios" tab of the input panel.
When disabled (default), gross income stays static across all savings years. When enabled, the
configured curve, part-time phases, and child arrival timing all flow through to year-by-year
brutto, subsidies, tax rates, and pension Entgeltpunkte accumulation.

---

## Current Implementation (v1.1.0+)

### 1. Growth Curves

Three selectable curve types, all implemented in `IncomeDevSettings.bruttoForYear()`:

- **Linear** (default): compound annual growth
  ```
  brutto(j) = brutto × (1 + growthRate)^j
  ```
  Range: 0–8% p.a. (slider step 0.5%)

- **Step-wise**: flat salary with periodic promotions
  ```
  brutto(j) = brutto × (1 + promotionIncrease)^floor(j / promotionInterval)
  ```
  Range: interval 1–15 yr, increase 5–50% per step

- **Logarithmic**: fast early growth, plateaus at salary cap
  ```
  brutto(j) = brutto + (salaryCap - brutto) × (1 - 1 / (1 + 0.1 × j))
  ```
  Range: salaryCap €40k–€200k

### 2. Part-Time Phases

Models reduced-income periods (parental leave, sabbatical):

- Toggle: "Part-Time Phase"
- Start year (0–spardauer-1), duration (1–10 yr), percentage (20–80% of full-time brutto)
- During phase, `bruttoForYear()` multiplies the curve output by `partTimePercent`

### 3. Child Arrival Timing

Dynamic children list — adds children mid-savings-period in addition to the static `kinder` count:

- List of arrival years (e.g., `[3, 6]` = first child year 3, second child year 6)
- Each dynamic child counts toward Kinderzulage from arrival year onward
- Ages out at 25 (or 18 if `kinderStudieren=false`) — same logic as base children
- Implemented in `IncomeDevSettings.kinderAtYear()`

### 4. Year-by-Year Impact

When income development is enabled, every year's brutto flows into:

- **Marginal tax rate** (`getGrenzsteuersatz(bruttoJ)`) — changes Günstigerprüfung refund per year
- **Geringverdienerbonus eligibility** — drops off when brutto crosses €26,250 threshold
- **Pension Entgeltpunkte accumulation** — `Σ min(bruttoJ, BBG) / Durchschnittsentgelt` per savings year, plus pre-savings years at base brutto. Affects retirement tax base.
- **Subsidy phase boundaries** — `calcSubsidyPhases()` creates a new phase whenever any subsidy component changes, including Geringverdienerbonus toggling on/off.

---

## Data Model

```dart
class IncomeDevSettings {
  final bool enabled;                  // default: false
  final GrowthCurve curve;             // default: linear
  final double growthRate;             // linear: 0–8% p.a.
  final int promotionInterval;         // step-wise: 1–15 yr
  final double promotionIncrease;      // step-wise: 5–50% per step
  final double salaryCap;              // logarithmic: €40k–€200k
  final int? partTimeStartYear;        // null = no part-time
  final int partTimeDuration;
  final double partTimePercent;        // 20–80%
  final List<int> childArrivalYears;   // dynamic children

  double bruttoForYear(double brutto, int j);
  int kinderAtYear(int baseKinder, int j, {List<int> kinderAlter, int maxAge});

  bool get hasPartTime;
  bool get hasChildTiming;
}

enum GrowthCurve { linear, stepwise, logarithmic }
```

---

## Code Locations

- **Model**: `lib/models/income_dev_settings.dart` → `IncomeDevSettings`, `GrowthCurve`
- **State**: `lib/features/calculator/cubit/calculator_state.dart` → `incomeDev` field
- **Cubit setters**: `lib/features/calculator/cubit/calculator_cubit.dart` →
  `toggleIncomeDev()`, `setGrowthCurve()`, `setIncomeGrowthRate()`,
  `setPromotionInterval()`, `setPromotionIncrease()`, `setSalaryCap()`,
  `setPartTimeStartYear()`, `setPartTimeDuration()`, `setPartTimePercent()`,
  `addChildArrivalYear()`, `updateChildArrivalYear()`, `removeChildArrivalYear()`
- **Simulation**: `lib/services/domain/calculator_service.dart` → `simulateAV()` and
  `calcSubsidyPhases()` accept `incomeDev`; pension EP via `EntgeltpunkteEstimator`
- **UI**: `lib/features/calculator/widgets/input_panel.dart` → `_IncomeScenarioPanel`
  (third tab in input panel)

---

## Tests

- **Unit tests**: `test/services/domain/income_scenarios_test.dart` covers all three curves,
  part-time phases, child arrival timing, age-out at maxAge 18 vs 25
- **Integration tests**: `test/services/domain/simulation_test.dart` verifies that income
  development flows through to AV results (subsidies, endkapital, pension estimate)

---

## Planned Extensions

Not yet implemented. Listed in priority order.

### 1. Salary Trajectory Mini-Chart

A small chart in the input panel showing projected income year-by-year, including
part-time phases and growth curve. Helps the user visualize what they've configured
before scrolling to see the impact on results.

### 2. Negative Growth (Career Break)

Currently growth rate slider is 0–8%. A negative range (-3% to 0%) would let users
model career setbacks or industry downturns.

### 3. Multiple Part-Time Phases

Currently a single part-time phase is supported. Real careers may have several
(e.g., parental leave for two children, then a later sabbatical).

### 4. Per-Child Education Toggle

`kinderStudieren` is currently a single boolean affecting all children. A per-child
toggle would let users model "child 1 went to university (until 25), child 2 went
straight to work (until 18)".
