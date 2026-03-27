# Research Documentation — Altersvorsorgedepot-Rechner

This document records the legislative basis, data sources, formula derivations, and
design decisions behind the calculator's financial logic.

**Code reference:** All numeric constants described here are implemented in
`lib/services/domain/calculator_service.dart` as the `CalcConstants` class.
Update that class when legislation changes; this document serves as the authoritative reference.

---

## 1. Legislative Timeline

| Date | Event | Source |
|---|---|---|
| Sep 2024 | BMF publishes first concept paper for AV-Depot reform | BMF Eckpunktepapier |
| Oct 2024 | Finanztip publishes initial analysis of the reform proposal | finanztip.de/altersvorsorge/altersvorsorgedepot |
| Dec 2025 | Bundeskabinett approves Gesetzentwurf (Drucksache 21/4088) | bundesfinanzministerium.de |
| 16 Mar 2026 | Finanzausschuss public hearing (Sachverständigenanhörung) | bundestag.de/kw12-pa-finanzen-1152002 |
| 25 Mar 2026 | Finanzausschuss amends the bill (Koalitionseinigung CDU/CSU + SPD) | Finanzausschuss Beschlussempfehlung |
| 27 Mar 2026 | Bundestag passes Altersvorsorgereformgesetz in 2. und 3. Lesung | bundestag.de/presse/hib/kurzmeldungen-1157838 |
| 01 Jan 2027 | Planned start: Anbieter may offer AV-Depot products | §89 EStG-E |

### Key Legislative Documents

1. **Gesetzentwurf der Bundesregierung**
   - Drucksache 21/4088
   - "Entwurf eines Gesetzes zur Reform der steuerlich geförderten privaten Altersvorsorge (Altersvorsorgereformgesetz)"
   - Contains: new §89–§99 EStG-E, Positivliste, Standardprodukt rules

2. **Finanzausschuss Änderungsantrag (25.03.2026)**
   - Raised Grundzulage from proportional cents to percentage-based: 50%/25%
   - Lowered Kostendeckel from 1.5% to 1.0% for Standardprodukt
   - Extended eligibility to all Selbstständige (previously excluded)
   - Mandated öffentlicher Träger for Standarddepot
   - Full Kinderzulage achievable at €25/mo (previously €100/mo)

3. **BMF FAQ**
   - URL: bundesfinanzministerium.de/Content/DE/FAQ/reform-der-privaten-altersvorsorge.html
   - Covers: eligibility, Bestandsschutz for Riester, inheritance, wohnwirtschaftliche Verwendung

---

## 2. Förderung (Subsidy) Structure

### 2.1 Grundzulage

**Legal basis**: §89 Abs. 1 EStG-E (as amended 25.03.2026)

```
Zulage = 50% × min(Eigenbeitrag, 360)
       + 25% × max(0, min(Eigenbeitrag, 1800) - 360)
```

| Eigenbeitrag/Jahr | Grundzulage | Förderquote |
|---|---|---|
| €120 (Minimum) | €60 | 50.0% |
| €300 | €150 | 50.0% |
| €360 | €180 | 50.0% |
| €600 | €240 | 40.0% |
| €1,200 | €390 | 32.5% |
| €1,800 (Maximum) | €540 | 30.0% |

**Design note**: The two-tiered structure incentivizes participation even at low
contribution levels (50% match on first €360). Above €360, the marginal incentive
drops to 25%, but total subsidy continues to grow.

**Source for final 50%/25% split**: Bundestag Drucksache 21/4088 (Beschlussempfehlung
des Finanzausschusses), Artikel 1 Nr. 23.

### 2.2 Kinderzulage

**Legal basis**: §89 Abs. 2 EStG-E

```
Kinderzulage = min(Eigenbeitrag, 300) × Anzahl_Kinder
```

- Maximum: €300 per child per year
- Full amount reached at €300/yr own contribution (= €25/mo)
- This is a 1:1 match up to the cap
- Child must be kindergeldberechtigt

**Change from first draft**: Originally required €100/mo for full Kinderzulage;
Koalitionseinigung lowered threshold to €25/mo.

### 2.3 Berufseinsteigerbonus

**Legal basis**: §89 Abs. 3 EStG-E

```
Bonus = €200 if (alter_bei_abschluss < 25) AND (vertragsjahr == 1)
```

- One-time €200 bonus in the first year of contract (BMF FAQ: "einmalig 200 Euro")
- Not proportional to contributions
- Requires active contributions (Mindestbeitrag €120/yr)
- Must be under 25 at contract start

### 2.4 Geringverdienerbonus

**Legal basis**: §89 Abs. 4 EStG-E

```
Geringverdienerbonus = €175 if (brutto ≤ 26,250) AND (Eigenbeitrag ≥ 120)
```

- Implemented: €175/yr added to total subsidy when conditions are met
- Stacks on top of Grundzulage

### 2.5 Günstigerprüfung (Tax Optimization Check)

**Legal basis**: §10a EStG-E (modified)

The Finanzamt automatically checks whether the taxpayer benefits more from:
- (A) Keeping the Zulagen, or
- (B) Deducting Eigenbeitrag + Zulagen as Sonderausgaben

```
Sonderausgabenabzug = (Eigenbeitrag + Zulagen) × Grenzsteuersatz

If Sonderausgabenabzug > Zulagen:
  → Additional refund = Sonderausgabenabzug - Zulagen
  → Refund goes to Girokonto (NOT into AV-Depot)
  → Zulagen stay in the depot regardless
```

**Example** (from justETF, verified against BMF FAQ):
- Eigenbeitrag: €1,800/yr
- Grundzulage: €540
- Grenzsteuersatz: 42%
- Sonderausgabenabzug: (€1,800 + €540) × 0.42 = €982.80
- Additional refund: €982.80 - €540 = €442.80

**Calculator implementation**: The refund is tracked but NOT reinvested into the
AV-Depot (conservative approach). In practice, a user could manually invest this
into a separate ETF depot.

---

## 3. Tax Treatment

### 3.1 AV-Depot — Accumulation Phase

**Legal basis**: §20 Abs. 1 EStG-E (exemption for AV-Depot)

- **No Abgeltungssteuer** on dividends or capital gains within the depot
- **No Vorabpauschale** (the annual tax on unrealized ETF gains)
- **Tax-free rebalancing**: switching between funds inside the AV-Depot triggers no tax
- Fund-level Quellensteuer (~0.3% p.a.) still applies but is internal to the fund NAV

### 3.2 AV-Depot — Payout Phase

**Legal basis**: §22 Nr. 5 EStG-E

- **Nachgelagerte Besteuerung**: 100% of payouts are taxed as income
- Taxed at personal Einkommensteuersatz in retirement (typically lower than working life)
- Auszahlplan runs until age 85 (§89 Abs. 8 EStG-E)
- Up to 30% Einmalentnahme at start of payout phase (§89 Abs. 9 EStG-E)
- Optional: Leibrente via Versicherungsunternehmen (provider switch permitted)

**Calculator implementation**: Retirement tax rate is calculated on the combined
annual retirement income (AV-Depot payout + estimated state pension × 12 +
other retirement income), using the same marginal tax bracket function.
This replaces the earlier simplification of `Grenzsteuersatz × 0.7`.

### 3.3 ETF-Depot (Private, Unfördert)

**Legal basis**: §20 Abs. 1 Nr. 7 EStG (existing law)

**During accumulation**:
- Vorabpauschale: annual tax on unrealized gains (Basiszins × 0.7 × ETF value × 0.7 Teilfreistellung × 26.3750%)
- Simplified in calculator as 0.2% annual drag on returns

**At payout/sale**:
```
Gewinn = Verkaufserlös - Anschaffungskosten
Steuerpflichtiger_Gewinn = Gewinn × (1 - Teilfreistellung)
Steuer = Steuerpflichtiger_Gewinn × Abgeltungssteuersatz

Where:
  Teilfreistellung = 30% for Aktienfonds (≥51% equity, §20 InvStG)
  Abgeltungssteuersatz = 26.3750% without Kirchensteuer (25.0000% + 1.3750% Soli)
  With Kirchensteuer: KapESt = 25% / (1 + 25% × KiSt_rate)  // §32d Abs. 1 Satz 3 EStG, plus Soli + KiSt
    → 8% KiSt (Bayern/BaWü): 27.8186%  |  9% KiSt (other): 27.9951%
```

**Key difference**: In the ETF depot, only the GAIN is taxed (and with 30% exemption).
In the AV-Depot, the ENTIRE payout is taxed (but at a potentially lower rate).
This creates a crossover point depending on returns, duration, and tax rates.

---

## 3.4 Kirchensteuer (Church Tax)

Kirchensteuer applies to both AV-Depot (on income tax) and ETF-Depot (on Abgeltungssteuer).
Configurable in the calculator as None / 8% (Bayern/BaWü) / 9% (other states).

**ETF side — reduced KapESt formula:**

```
KapESt = 25% / (1 + 25% × KiSt_rate)  // §32d Abs. 1 Satz 3 EStG
Soli = KapESt × 5.5%
KiSt = KapESt × KiSt_rate
Abgeltungssteuersatz = KapESt + Soli + KiSt

Results:
  None:  26.3750%
  8%:    27.8186%
  9%:    27.9951%
```

**AV side — retirement payout taxation:**

```
Steuersatz_Rente = Grenzsteuersatz(Renteneinkommen) × (1 + KiSt_rate)

Where Renteneinkommen = AV_Jahresauszahlung + GesetzlicheRente × 12 + SonstigeEinkünfte
```

Note: Uses marginal rate (Grenzsteuersatz), which slightly overstates tax compared
to the actual average rate (Durchschnittssteuersatz). See Design Decisions below.

---

## 3.5 Simulation Formulas (as implemented in code)

All constants below reference `CalcConstants` in `calculator_service.dart`.

### Individual Subsidy Formulas

```
Grundzulage(jb) = min(jb, 360) × 50% + max(0, min(jb, 1800) - 360) × 25%
  // jb = Jahresbeitrag [EUR/year]. Max: €540/year.

Kinderzulage(jb, kinder) = min(jb, 300) × kinder
  // Max: €300/child/year. Full grant from €25/month contribution.

Berufseinsteigerbonus(alter, j) = €200 if (alter < 25) AND (j == 0), else 0
  // One-time bonus in first savings year only. Source: BMF FAQ "einmalig".

Geringverdienerbonus(brutto, jb) = €175 if (brutto ≤ 26,250) AND (jb ≥ 120), else 0
  // Mindestbeitrag: €120/year. Stacks on top of Grundzulage.
```

### Combined Yearly Subsidy

```
Zulage(j) = Grundzulage(Jahresbeitrag)
           + Kinderzulage(Jahresbeitrag, Kinder)
           + Berufseinsteigerbonus(Alter, j)
           + Geringverdienerbonus(Brutto_j, Jahresbeitrag)
```

### German Marginal Tax Rate (piecewise approximation, §32a EStG 2024)

```
Grenzsteuersatz(Brutto) =
  0%       if Brutto ≤ 11,784   (Grundfreibetrag)
  14%      if Brutto ≤ 17,005   (Eingangssteuersatz)
  23.97% + (Brutto - 17,005) / (66,760 - 17,005) × (42% - 23.97%)
           if Brutto ≤ 66,760   (Progressive zone, linear interpolation)
  42%      if Brutto ≤ 277,825  (Spitzensteuersatz)
  45%      if Brutto > 277,825  (Reichensteuersatz)
```

### Income Development (opt-in, linear growth)

```
If enabled:
  Brutto_j = Brutto × (1 + GrowthRate)^j    // compound annual growth
Else:
  Brutto_j = Brutto                          // static income (default)
```

### AV-Depot Year-by-Year Accumulation

```
Jahresbeitrag = Sparrate × 12               // [EUR/month → EUR/year] input conversion

For j = 0 to Spardauer - 1:
  Alter = AlterStart + j
  Brutto_j = IncomeDev.bruttoForYear(Brutto, j)  // static or growing
  Grenzsteuersatz_j = Grenzsteuersatz(Brutto_j)
  Zulage_j = Zulage(j)                           // uses Brutto_j for Geringverdienerbonus
  Günstigerprüfung:
    Steuerersparnis = (Jahresbeitrag + Zulage_j) × Grenzsteuersatz_j
    Zusätzlich = max(0, Steuerersparnis - Zulage_j)  // → Girokonto, NOT depot
  Zufluss = Jahresbeitrag + Zulage_j               // own contribution + subsidies → depot
  Depot = (Depot + Zufluss) × (1 + Rendite - KostenAV)
```

### AV-Depot Payout

```
Auszahlungsdauer = (85 - Rentenalter), clamped to 5–30 years
  // 85 = CalcConstants.payoutEndAge (§89 Abs. 8 EStG-E)
Monatlich_Brutto = Depot / (Auszahlungsdauer × 12)  // [EUR → EUR/month] output conversion

// Pension estimation for retirement tax calculation:
If manual override set:
  EffectiveRente = gesetzlicheRenteOverride         // [EUR/month]
Else if income development enabled:
  TotalEP = Σ min(Brutto_j, BBG) / Durchschnittsentgelt  // accumulated per year
    + preSavingsYears × min(Brutto, BBG) / Durchschnittsentgelt
  EffectiveRente = TotalEP × Rentenwert             // [EUR/month]
  // BBG = 90,600 | Durchschnittsentgelt = 45,358 | Rentenwert = 39.32 | Arbeitsbeginn = 25
Else:
  EffectiveRente = geschaetzteRente                 // static estimate from PersonalScenario

// Retirement tax based on combined retirement income:
AV_Jahresauszahlung = Depot / Auszahlungsdauer      // [EUR/year]
Renteneinkommen = AV_Jahresauszahlung + EffectiveRente × 12 + SonstigeEinkünfte  // all [EUR/year]
Steuersatz_Rente = Grenzsteuersatz(Renteneinkommen) × (1 + Kirchensteuer)
Monatlich_Netto = Monatlich_Brutto × (1 - Steuersatz_Rente)

Note: Uses marginal rate (overstates tax vs. actual average rate). See Design Decisions.
```

### ETF-Depot Year-by-Year Accumulation

```
VorabpauschaleDrag = 0.002                          // simplified annual drag (CalcConstants)

For j = 0 to Spardauer - 1:
  Depot = (Depot + Jahresbeitrag) × (1 + Rendite - KostenETF - VorabpauschaleDrag)
```

### ETF-Depot Payout

```
Gewinn = Depot - Eigenbeiträge
Teilfreistellung = 30%                               // §20 InvStG, Aktienfonds ≥51% equity
Steuerpflichtiger_Gewinn = Gewinn × (1 - Teilfreistellung)
Steuer = Steuerpflichtiger_Gewinn × Abgeltungssteuersatz
  // Abgeltungssteuersatz: 26.3750% without KiSt, 27.8186% with 8%, 27.9951% with 9%
  // Formula: KapESt = 25% / (1 + 25% × KiSt_rate), then + Soli + KiSt (see §3.4)
Netto = Depot - Steuer
Monatlich = Netto / (Auszahlungsdauer × 12)          // [EUR → EUR/month] output conversion
```

### Inflation Adjustment

```
Endkapital_Real = Depot / (1 + Inflation)^Spardauer
Depot_Real(j) = Depot(j) / (1 + Inflation)^(j+1)
```

### Design Decisions: Units and Simplifications

**Yearly-core calculation architecture**: All core simulation loops operate on yearly
steps. This is intentional — German subsidies (Grundzulage, Kinderzulage etc.) are
defined as annual amounts in legislation. Tax brackets are annual. Converting to monthly
would require artificially distributing annual subsidies across 12 months, introducing
rounding errors without improving accuracy.

**Unit boundaries**:
- Input boundary: `sparrate` (EUR/month) and `gesetzlicheRente` (EUR/month) are converted
  to yearly via `jahresbeitrag = sparrate × 12` and `rente × 12` at the simulation boundary.
- Core: All subsidy, tax, and accumulation calculations use yearly amounts.
- Output boundary: `monatlicheAuszahlung = depot / (auszahlungsDauer × 12)` converts back.

**Marginal vs. average tax rate for retirement payout**: The calculator uses the
Grenzsteuersatz (marginal rate) on combined retirement income. In reality, the
Durchschnittssteuersatz (average rate) would be more precise — the actual tax on
€30,000 retirement income is not 30,000 × marginalRate, but the sum of tax across
all brackets. Using the marginal rate **overstates** the tax on AV-Depot payouts,
making the comparison slightly conservative (favoring ETF). This is a documented
simplification.

---

## 4. Cost Parameters

### 4.1 AV-Depot Costs

**Legal basis**: §89 Abs. 6 EStG-E

- **Kostendeckel Standardprodukt**: 1.0% Effektivkosten p.a. (lowered from 1.5%)
- Applies only to the mandatory Standardprodukt each provider must offer
- Non-standard products may exceed 1.0% (no legal cap)
- Öffentlicher Träger (Staatsfonds) expected to offer <0.5%

**Calculator default**: 0.5% p.a. (assumes user selects a low-cost provider or Staatsfonds)

### 4.2 ETF-Depot Costs

- **TER**: 0.1–0.2% for typical World-ETFs (MSCI ACWI, FTSE All-World)
- **Broker fees**: €0 at Neobroker (Trade Republic, Scalable, etc.)
- **Spread**: negligible for large ETFs

**Calculator default**: 0.2% p.a.

### 4.3 Impact of Costs Over Time

| Duration | 0.2% costs | 0.5% costs | 1.0% costs | 1.5% costs |
|---|---|---|---|---|
| 20 years | -3.9% | -9.5% | -18.2% | -26.1% |
| 30 years | -5.8% | -13.9% | -26.0% | -36.4% |
| 40 years | -7.7% | -18.1% | -33.1% | -45.3% |

*(Percentage of final capital lost vs. zero-cost scenario, at 7% gross return)*

**Source**: Own calculation; consistent with Finanztip analysis showing ~€65,000
difference between 0.2% and 1.0% over 40 years at 7% gross return.

---

## 5. Macro Scenario Methodology

### Data Sources for Historical Returns

| Index | Period | Nominal CAGR | Real CAGR | Source |
|---|---|---|---|---|
| MSCI World Net | 1970–2024 | ~7.2% | ~4.8% | msci.com |
| S&P 500 | 2000–2012 | ~1.7% | ~-0.7% | multpl.com |
| Nikkei 225 | 1990–2020 | ~0.5% | ~0.2% | nikkei.com |
| German CPI | 1970–2024 | ~2.3% | — | destatis.de |
| US CPI 1970s | 1970–1982 | ~8.5% | — | bls.gov |

### Scenario Design Philosophy

Each macro scenario represents a **sustained regime**, not a single year. They are
intentionally stylized to bracket the range of plausible outcomes:

1. **Boom**: Best-case for equity investors. Low-rate, low-inflation, high-growth environment.
   Modeled after the post-GFC recovery (2010–2021).

2. **Basis**: Long-run average. Represents what a diversified global equity portfolio has
   historically delivered over 30+ year horizons.

3. **Moderat**: Below-trend growth with mildly elevated inflation. Common during economic
   uncertainty or transition periods.

4. **Stagflation**: Worst case for traditional 60/40 portfolios. High inflation erodes
   purchasing power while low growth limits nominal returns. Based on 1970s data.

5. **Japan**: Prolonged stagnation with near-zero returns and minimal inflation. Represents
   the tail risk of a "lost decades" scenario similar to Japan 1990–2020.

6. **Verlorenes Jahrzehnt**: Two major crashes (Dotcom + GFC) with slow recovery. Nominal
   returns barely positive, real returns negative.

### Custom Scenario Guidelines

When users create custom macros, recommended ranges:
- Rendite: 0–14% (below 0% not modeled; above 14% unrealistic for diversified equity)
- Inflation: 0–6% (below 0% = deflation; above 6% = severe monetary instability)
- Duration matters: extreme scenarios are more plausible over 5–10 years than 30+

---

## 6. German Income Tax Brackets

### 2024 Brackets (used in calculator)

**Legal basis**: §32a EStG (2024)

| zvE (zu versteuerndes Einkommen) | Grenzsteuersatz | Formula |
|---|---|---|
| ≤ €11,784 | 0% | Grundfreibetrag |
| €11,785 – €17,005 | 14–24% | Linear progression |
| €17,006 – €66,760 | 24–42% | Linear progression |
| €66,761 – €277,825 | 42% | Spitzensteuersatz |
| > €277,825 | 45% | Reichensteuersatz |

**Calculator implementation**: Piecewise linear approximation (see `CalculatorService.getGrenzsteuersatz()` in `lib/services/domain/calculator_service.dart`).
This gives the marginal rate, which is what matters for the Günstigerprüfung.

**Note**: The calculator uses Bruttojahreseinkommen as a proxy for zvE. In reality, zvE =
Brutto - Werbungskosten - Sonderausgaben - etc. This simplification overstates the
Grenzsteuersatz for most users by a few percentage points.

### Planned Updates

Tax brackets are typically adjusted annually for inflation (kalte Progression).
The 2027 brackets should be substituted once published by the BMF (expected late 2026).

---

## 7. Comparison Framework: AV-Depot vs. ETF-Depot

### When AV-Depot Wins

- **High subsidy leverage**: Low-to-medium income + children → Förderquote >40%
- **Long duration**: Zulagen compound over decades
- **High marginal tax rate during working life**: Günstigerprüfung refund is larger
- **Low retirement income**: Deferred taxation at lower rate

### When ETF-Depot Wins

- **Very high income, no children**: Marginal tax benefit small relative to constraints
- **Need for flexibility**: ETF-Depot has no lock-up period
- **Very short duration**: Not enough time for subsidy compounding
- **High retirement income**: Deferred taxation at high rate eats into advantage
- **Contributions above €1,800/yr**: No additional subsidy; Teilfreistellung is better

### Critical Insight

The AV-Depot taxes the **entire payout** (Eigenbeitrag + Zulagen + Gewinne) at income
tax rates. The ETF-Depot only taxes **gains** (and with 30% Teilfreistellung) at
Abgeltungssteuer. Over very long periods with high returns, the ETF-Depot's tax advantage
on the gain portion can partially offset the AV-Depot's subsidy advantage. The calculator
makes this tradeoff visible.

---

## 8. References

### Official Government Sources

1. Bundesfinanzministerium — FAQ zur Reform der privaten Altersvorsorge
   https://www.bundesfinanzministerium.de/Content/DE/FAQ/reform-der-privaten-altersvorsorge.html

2. Deutscher Bundestag — Kostenhöhe bei der Altersvorsorgereform umstritten (Anhörung)
   https://www.bundestag.de/dokumente/textarchiv/2026/kw12-pa-finanzen-1152002

3. Deutscher Bundestag — Reform der privaten Altersvorsorge zugestimmt (Abstimmung)
   https://www.bundestag.de/presse/hib/kurzmeldungen-1157838

### Independent Analysis

4. Finanztip — Altersvorsorgedepot Ratgeber
   https://www.finanztip.de/altersvorsorge/altersvorsorgedepot/

5. Finanztip — Altersvorsorgedepot-Rechner
   https://www.finanztip.de/altersvorsorge/altersvorsorgedepot-rechner/

6. justETF — Altersvorsorge-Depot ab 2027
   https://www.justetf.com/de/academy/altersvorsorgedepot-entwurf-2027.html

7. finanzen.net — Altersvorsorgedepot: Koalition einigt sich
   https://www.finanzen.net/ratgeber/vorsorge/altersvorsorgedepot/

8. Lazy Investors — Vollständigster Altersvorsorgedepot-Rechner
   https://lazyinvestors.de/altersvorsorgedepot-rechner/

9. fragfina — Zulagen-Rechner
   https://www.fragfina.de/finanzrechner/altersvorsorgedepot-zulagen-rechner/

### Market Data

10. MSCI World Index — Fact Sheet & Performance
    https://www.msci.com/world

11. Statistisches Bundesamt — Verbraucherpreisindex
    https://www.destatis.de/DE/Themen/Wirtschaft/Preise/Verbraucherpreisindex/

---

*Last updated: March 2026*
