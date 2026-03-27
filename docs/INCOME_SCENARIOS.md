# Income Development Over Savings Period

## Current Implementation (v1.1.0)

Basic linear income growth, **opt-in** via Advanced Settings toggle.

### What's Built

- Toggle: "Model Income Growth" (off by default)
- Annual growth rate slider (0–8%, default 2%)
- When enabled, gross income compounds annually: `brutto(j) = brutto × (1 + growthRate)^j`
- Year-by-year impact on:
  - Grenzsteuersatz (marginal tax rate changes as income grows)
  - Geringverdienerbonus eligibility (drops off when income exceeds €26,250)
  - Günstigerprüfung refund (changes with marginal rate)
  - Pension estimate (Entgeltpunkte accumulated per year with growing income, capped at BBG)
- Payout phase: retirement tax uses income-development-adjusted pension estimate

### Data Model

```dart
class IncomeDevSettings {
  final bool enabled;      // default: false
  final double growthRate;  // default: 0.02 (2% p.a.)

  double bruttoForYear(double brutto, int j) =>
    enabled ? brutto * pow(1 + growthRate, j) : brutto;
}
```

### Code Locations

- Model: `lib/models/scenario.dart` → `IncomeDevSettings`
- State: `lib/features/calculator/cubit/calculator_state.dart` → `incomeDev` field
- Cubit: `lib/features/calculator/cubit/calculator_cubit.dart` → `toggleIncomeDev()`, `setIncomeGrowthRate()`
- Simulation: `lib/services/domain/calculator_service.dart` → `simulateAV(incomeDev:)`, `_computeEffectiveRente()`
- UI: `lib/features/calculator/widgets/input_panel.dart` → `_IncomeDevToggle`

---

## Planned Extensions

Not yet implemented. Listed in priority order.

### 1. Growth Curves

Replace simple compound growth with selectable curve types:

- **Step-wise**: Flat salary with periodic promotions every N years
  - `salary(j) = brutto × (1 + promotion_pct)^floor(j / promotion_interval)`
- **Logarithmic**: Fast early growth, plateaus at salary cap
  - `salary(j) = brutto + (salary_cap - brutto) × (1 - 1/(1 + 0.1×j))`

### 2. Part-Time Phases

Model reduced income periods (e.g., parental leave):

- Part-time start year, duration, percentage (e.g., 50% for 3 years)
- `brutto(j) *= partTimePercentage` during the phase

### 3. Child Arrival Timing

Dynamic children count instead of static:

- List of years when each child arrives
- Kinderzulage starts at arrival year, stops when child turns 25
- Could trigger part-time phase automatically

### 4. Salary Cap

Beitragsbemessungsgrenze already caps pension points. Could also
cap income growth (e.g., logarithmic approach to a user-defined max).

### 5. Salary Trajectory Chart

Mini-chart in input panel showing projected income over savings period.
