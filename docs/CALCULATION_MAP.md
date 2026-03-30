# Calculation Map

End-to-end trace of how user inputs flow through the calculation engine to produce results.

## Pipeline Overview

```mermaid
flowchart TD
    A[User Input<br/>Sliders & Toggles] --> B[PersonalScenario<br/>MacroScenario<br/>CostSettings<br/>IncomeDevSettings]
    B --> C[CalculatorState<br/>computed getters]
    C --> D[SimulationEngine]
    D --> E[SubsidyModule<br/>calcZulage]
    D --> F[TaxModule<br/>getGrenzsteuersatz<br/>calcEinkommensteuer<br/>getDurchschnittssteuersatz<br/>calcGuenstigerpruefung]
    D --> G[IncomeDevSettings<br/>bruttoForYear<br/>kinderAtYear]
    D --> H[PensionModule<br/>estimateMonthlyPension]
    E --> I[simulateAV]
    F --> I
    G --> I
    H --> I
    D --> J[simulateETF]
    I --> K[CombinedResult<br/>delta comparison]
    J --> K
    K --> L[UI: Charts, Tables<br/>Comparison Bars<br/>Pros/Cons<br/>Calculation Basis]
```

---

## Input Model Mapping

| UI Input | Model Field | Unit | Used By |
|----------|------------|------|---------|
| Monthly Savings | `PersonalScenario.sparrate` | EUR/month | `jahresbeitrag` x12, subsidy calc, depot accumulation |
| Gross Annual Income | `PersonalScenario.brutto` | EUR/year | tax rate, Geringverdienerbonus, pension EP, income dev base |
| Number of Children | `PersonalScenario.kinder` | count | Kinderzulage (may change with child timing) |
| Starting Age | `PersonalScenario.alterStart` | years | Berufseinsteigerbonus eligibility, savings duration |
| Retirement Age | derived as `spardauer` | years | payout duration (85 - retirement age) |
| State Pension | `PersonalScenario.gesetzlicheRente` | EUR/month | retirement tax calculation |
| Other Income | `PersonalScenario.sonstigeEinkuenfte` | EUR/year | retirement tax calculation |
| Return p.a. | `MacroScenario.rendite` | ratio/year | depot growth |
| Inflation p.a. | `MacroScenario.inflation` | ratio/year | real value calculation |
| AV Cost | `CostSettings.kostenAV` | ratio/year | deducted from return |
| ETF Cost | `CostSettings.kostenETF` | ratio/year | deducted from return |
| Kirchensteuer | `CostSettings.kirchensteuer` | ratio (0/0.08/0.09) | `abgeltungssteuersatz` getter, AV payout tax |
| Income Growth | `IncomeDevSettings.*` | various | year-by-year brutto, dynamic kinder |

---

## AV-Depot Simulation Flow

```mermaid
flowchart TD
    subgraph LOOP["For each savings year j = 0 ... spardauer-1"]
        direction TB
        INC["Income for year j<br/>bruttoJ = bruttoForYear brutto, j<br/>kinderJ = kinderAtYear kinder, j"]
        SUB["Subsidies - SubsidyModule<br/>Grundzulage: 50% x min jbGef, 360 + 25% x rest<br/>Kinderzulage: min jbGef, 300 x kinderJ, age-out at 25<br/>Bonus: 200 EUR if age lt 25 AND j == 0<br/>Geringverdiener: 175 EUR if bruttoJ le 26250"]
        TAX["Tax Optimization - TaxModule<br/>gstJ = getGrenzsteuersatz bruttoJ<br/>Sonderausgaben = min jb, 1800 + zulagen x gstJ<br/>Refund = difference, to bank account"]
        SPLIT["Contribution Split<br/>jbCapped = min jahresbeitrag, 6840<br/>jbGefoerdert = min jbCapped, 1800<br/>jbUngefoerdert = jbCapped - jbGefoerdert"]
        GROW["Depot Growth - tax-free<br/>depotGef = depotGef + jbGef + zulagen x 1 + r - kostenAV<br/>depotUngef = depotUngef + jbUngef x 1 + r - kostenAV"]
        INC --> SUB --> TAX --> SPLIT --> GROW
    end
    GROW --> PAY
    subgraph PAY["Payout Phase"]
        direction TB
        PENS["Pension Estimation<br/>Priority: override, income-dev EP, static<br/>EP = Sum min bruttoJ, BBG / Durchschnittsentgelt x Rentenwert"]
        RTAX["Retirement Tax - progressive 32a<br/>combinedIncome = avAnnualPayout + pension x 12 + sonstige<br/>avgRate = calcEinkommensteuer combinedIncome / combinedIncome"]
        GEF["Gefoerdert: 100% taxed<br/>netto = brutto x 1 - gst x kirchenFaktor"]
        UNGEF["Ungefoerdert: tax pending BMF guidance<br/>Default: nachgelagerte Besteuerung"]
        PENS --> RTAX --> GEF
        RTAX --> UNGEF
    end
    GEF --> RES[AVResult<br/>endkapital, nettoMonatlich<br/>zulagenGesamt, wertzuwachs]
    UNGEF --> RES
```

---

## ETF-Depot Simulation Flow

```mermaid
flowchart TD
    subgraph LOOP["For each savings year j = 0 ... spardauer-1"]
        GROW["Depot Growth<br/>depot = depot + jahresbeitrag x 1 + r - kostenETF - 0.003<br/>0.003 = simplified Vorabpauschale drag<br/>No subsidies, no tax optimization"]
    end
    GROW --> PTAX
    subgraph PTAX["Payout Tax at sale"]
        GAINS["gains = depot - totalContributions"]
        TEIL["taxableGains = gains x 1 - 30%<br/>Teilfreistellung"]
        ABGST["tax = taxableGains x abgeltungssteuersatz<br/>26.3750% or higher with KiSt"]
        NET["netto = depot - tax<br/>monthly = netto / auszahlungsDauer x 12"]
        GAINS --> TEIL --> ABGST --> NET
    end
    NET --> RES[ETFResult<br/>endkapital, nachSteuer<br/>monatlicheAuszahlung]
```

---

## Module Dependency Map

```mermaid
flowchart TD
    SE[SimulationEngine] --> TM[TaxModule<br/>interface]
    SE --> SM[SubsidyModule<br/>interface]
    SE --> PM[PensionModule<br/>interface]

    TM --> GT[GermanTax2024]
    SM --> AVS[AVDepotSubsidy2027]
    PM --> EPE[EntgeltpunkteEstimator]

    GT --> CC[CalcConstants<br/>tax brackets]
    AVS --> CC
    EPE --> CC

    IDS[IncomeDevSettings<br/>standalone] --> BFY[bruttoForYear<br/>GrowthCurve, part-time]
    IDS --> KAY[kinderAtYear<br/>childArrivalYears]

    CS[CostSettings<br/>standalone] --> ABS[abgeltungssteuersatz<br/>kirchensteuer, 32d formula]

    FACADE[CalculatorService<br/>static facade] --> SE

    style SE fill:#0066FF,color:#fff
    style CC fill:#F59E0B,color:#fff
    style IDS fill:#10B981,color:#fff
    style CS fill:#10B981,color:#fff
    style FACADE fill:#8B5CF6,color:#fff
```

---

## What Affects What

| Changed Input | Affects Depot Capital | Affects Net Payout | Affects Subsidies |
|---------------|----------------------|-------------------|-------------------|
| Savings Rate | yes, directly | yes | yes, via contribution |
| Gross Income | no | yes, retirement tax | Only Geringverdienerbonus |
| Children | no | no | yes, Kinderzulage |
| Starting Age | yes, longer compounding | yes | yes, Berufseinsteigerbonus |
| Retirement Age | yes, duration | yes, payout years | no |
| State Pension | no | yes, retirement tax | no |
| Other Income | no | yes, retirement tax | no |
| Return p.a. | yes, directly | yes | no |
| AV/ETF Cost | yes, reduces return | yes | no |
| Kirchensteuer | no | yes, both AV + ETF | no |
| Income Growth | no | yes, pension + tax | Only Geringverdienerbonus timing |
| Macro Scenario | yes, return + inflation | yes | no |

---

## File Locations

| Component | File |
|-----------|------|
| SimulationEngine + CalcConstants | `lib/services/domain/calculator_service.dart` |
| TaxModule + GermanTax2024 | `lib/services/domain/tax_module.dart` |
| SubsidyModule + AVDepotSubsidy2027 | `lib/services/domain/subsidy_module.dart` |
| PensionModule + EntgeltpunkteEstimator | `lib/services/domain/pension_module.dart` |
| IncomeDevSettings + GrowthCurve | `lib/models/income_dev_settings.dart` |
| PersonalScenario, MacroScenario, CostSettings, Results | `lib/models/scenario.dart` |
| CalculatorCubit (state management) | `lib/features/calculator/cubit/calculator_cubit.dart` |
| CalculatorState (computed getters) | `lib/features/calculator/cubit/calculator_state.dart` |
