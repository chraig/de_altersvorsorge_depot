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
- Child must be kindergeldberechtigt (receiving Kindergeld)
- Kindergeld ends at age 18 (default) or 25 (if in education/training)
- Calculator uses age 25 as upper bound (`CalcConstants.kinderzulageMaxAlter`)
- Each child's age is tracked; Kinderzulage stops when `childAge + savingsYear ≥ 25`

**Change from first draft**: Originally required €100/mo for full Kinderzulage;
Koalitionseinigung lowered threshold to €25/mo.

### 2.3 Berufseinsteigerbonus

**Legal basis**: §89 Abs. 3 EStG-E

```
Bonus = €200 if (alter_bei_abschluss < 25) AND (vertragsjahr == 1)
```

- One-time €200 bonus in the first year of contract (BMF FAQ: "einmalig 200 Euro")
- Not proportional to contributions
- Must be under 25 at contract start

### 2.4 Günstigerprüfung (Tax Optimization Check)

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

### 3.2 AV-Depot — Payout Phase

**Legal basis**: §22 Nr. 5 EStG-E. The taxation depends on whether the underlying
contributions were subsidized (gefördert) or not (ungefördert).

#### Geförderte Beiträge — full nachgelagerte Besteuerung

- **100% of the payout is taxed** at the recipient's personal Einkommensteuersatz
  in retirement. This applies to the contributions, the Zulagen credited to the
  contract, and all gains earned on the gefördert bucket — there is no carve-out
  for the gain portion.
- Auszahlplan runs until age 85 (§89 Abs. 8 EStG-E).
- Up to 30% Einmalentnahme is allowed at the start of the payout phase (§89 Abs. 9
  EStG-E) — not currently modeled by the calculator.
- Optional: conversion to Leibrente via a Versicherungsunternehmen (provider
  switch permitted) — not currently modeled.

#### Ungeförderte Beiträge — Ertragsanteilbesteuerung (calculator simplification)

The Riester rules in §22 Nr. 5 EStG (which serve as precedent for AV-Depot) split
the ungefördert payout treatment by payout form:

1. **Lebenslange Rente** (lifelong annuity, requires Versicherer): Ertragsanteil­
   besteuerung — only the age-dependent Ertragsanteil percentage of each payout
   is taxed at the personal income rate (17% at age 67, 18% at age 65, etc.).
2. **Einmalkapitalauszahlung**: taxed like a Lebensversicherung payout.
3. **Auszahlplan / "alle anderen Fälle"**: Unterschiedsbetrag — the full
   difference between cumulative payouts and cumulative contributions (i.e.,
   essentially the gains) is taxed at the personal income rate.

Source for the split: NRW Finanzamt — Besteuerung der späteren Auszahlungen aus
Riester-Verträgen, citing §22 Nr. 5 Sätze 1 und 2 EStG and §22 Nr. 5 Satz 7 EStG.
<https://www.finanzamt.nrw.de/steuerinfos/privatpersonen/riester/besteuerung-der-spaeteren-auszahlungen>

**The AV-Depot is structurally an Auszahlplan** (it pays out over a fixed period
ending at age 85, not lifelong), so the strict Riester reading would put the
ungefördert bucket into category 3 (Unterschiedsbetrag).

**Calculator simplification**: Despite the Auszahlplan structure, the calculator
applies the **Ertragsanteilbesteuerung at 17% (age-67 entry)** — the rule that
strictly belongs to category 1 (Lebenslange Rente) — to the ungefördert bucket.
This is a deliberate simplification:

- It treats the 18-year Auszahlplan analogously to a lifelong annuity for tax
  purposes, even though the payouts terminate at age 85.
- It is **more favorable** to the user than the Unterschiedsbetrag rule: only
  17% of the payout enters the tax base, vs. essentially all gains (which can
  be 70–85% of the depot after a long savings period).
- Unterschiedsbetrag-Besteuerung — the strict Auszahlplan rule per the Riester
  precedent — is **not modeled**.
- The age-dependent Ertragsanteil table (60→22%, 65→18%, 68→16% etc.) is also
  not modeled — the calculator uses the age-67 rate (17%) regardless of the
  user's actual retirement age.

This is a known difference from the strict Riester reading and should be kept in
mind when interpreting results: the ungefördert bucket's net payout in the
calculator is an upper bound; a Finanzamt applying the Auszahlplan / Unterschieds­
betrag rule would yield a lower net payout.

#### Combined retirement tax rate

The AV payout is added on top of the user's other retirement income (state pension
+ other) for the marginal-rate calculation. Implementation:

```
incrementalTaxOnAV = einkommensteuer(pension + sonstige + AV) − einkommensteuer(pension + sonstige)
avPayoutTaxRate    = incrementalTaxOnAV / AV_annualPayout
```

This is the incremental rate at which the AV payout itself is taxed, used in both
the gefördert (100% of payout) and ungefördert (17% of payout) tax-base
calculations.

### 3.3 ETF-Depot (Private, Unfördert)

**Legal basis**: Investmentsteuergesetz (InvStG) governs the taxation of
investment-fund income for private investors:

- §2 InvStG — fund-type definitions (Aktienfonds, Mischfonds, Immobilienfonds, …)
- §16 InvStG — what counts as Investmenterträge: Ausschüttungen, Vorabpauschale,
  Veräußerungsgewinne
- §18 InvStG — Vorabpauschale (annual tax on unrealized gains)
- §19 InvStG — Veräußerungsgewinne (gains on sale)
- §20 InvStG — Teilfreistellung (partial exemption by fund type)

The applicable **rate** for these Investmenterträge is the Abgeltungssteuer
fixed by §32d Abs. 1 EStG (25% + 5.5% Soli + optional Kirchensteuer);
collection at source is governed by §43a EStG. There is no §20 Abs. 1 Nr. 7
EStG involvement — that paragraph covers interest from non-fund Kapital­
forderungen and does not apply to Investmentfonds.

**During accumulation** (§18 InvStG):
- Vorabpauschale: annual tax on the year's deemed minimum gain — formally
  `Basiszins × 0.7 × ETF_value × (1 − Teilfreistellung) × Abgeltungssteuersatz`,
  where `ETF_value` is the value at the **start** of the calendar year.
- For fund units acquired during the year, §18 InvStG reduces the VP by
  `1/12 for each full month preceding the acquisition month`. For monthly
  contributions distributed evenly across the year, the **average partial-year
  factor** is `(1/12) × Σ_{k=0..11} (1 − k/12) = 6.5/12 ≈ 0.5417`. Pre-existing
  depot value (held the full year) gets factor 1.0.
- Calculator simplifies the rate as a fixed `vorabpauschaleDrag = 0.3%`
  (≈ Basiszins 2.3–3.2% × 0.7 × 0.70 × 0.26375) and applies the partial-year
  factor to new contributions: `vp_year = (depotStart + jb × 0.5417) × 0.003`,
  paid out of the depot.
- Crucially, the cumulative Vorabpauschale paid is **credited against the
  Abgeltungssteuer at sale** (§19 Abs. 1 InvStG, Anrechnung) — the same tax
  is not collected twice.

**At payout/sale**:
```
Gewinn = Endkapital - Eigenbeiträge      // Endkapital is post-VP-deductions
Steuerpflichtiger_Gewinn = Gewinn × (1 - Teilfreistellung)
Steuer_vor_Anrechnung = Steuerpflichtiger_Gewinn × Abgeltungssteuersatz
Steuer_nach_Anrechnung = max(0, Steuer_vor_Anrechnung − VorabpauschaleGesamt)
NachSteuer = Endkapital − Steuer_nach_Anrechnung    // VP was already debited from the depot

Where:
  Teilfreistellung = 30%   // calculator assumes Aktienfonds — see table below
  Abgeltungssteuersatz = 26.3750% without Kirchensteuer (25.0000% + 1.3750% Soli)
  With Kirchensteuer: KapESt = 1 / (4 + k)  // §32d Abs. 1 Satz 4 EStG with q=0, plus Soli + KiSt
    → calculator uses k = 0.09 (dominant rate, see §3.4): 27.9951%
```

#### Teilfreistellung by fund type (§20 InvStG)

Authoritative source: <https://www.gesetze-im-internet.de/invstg_2018/__20.html>
(definitions in <https://www.gesetze-im-internet.de/invstg_2018/__2.html>).

| Fund type | Continuous min. allocation (per Anlagebedingungen) | Teilfreistellung |
|---|---|---|
| **Aktienfonds** (§2 Abs. 6) | > 50% Kapitalbeteiligungen (typically listed equities) | **30%** |
| **Mischfonds** (§2 Abs. 7) | ≥ 25% Kapitalbeteiligungen | 15% |
| **Immobilienfonds**, domestic (§2 Abs. 9) | > 50% in real estate / property companies | 60% |
| **Immobilienfonds**, foreign focus | > 50% in foreign real estate / Auslands-Objektgesellschaften | 80% |
| **Sonstige Fonds** (bond ETFs, money-market, mixed < 25% equity) | — | **0%** |

The above are private-investor rates. Higher rates apply for assets held in business
property (60% / 30% / 80% Immobilien) and corporate taxpayers (80% / 40% Aktien) —
not relevant for this calculator's private-investor scope.

**The calculator assumes the user holds an Aktienfonds** (a typical broad equity ETF
such as MSCI World, FTSE All-World, S&P 500). For other fund types, the ETF side of
the comparison would be taxed differently:
- A bond-only ETF ("sonstiger Fonds") would receive **no Teilfreistellung at all**,
  meaning 100% of gains are taxable. The AV-Depot's relative advantage would grow
  significantly versus what this calculator shows.
- A Mischfonds (mixed fund 25–50% equity) would receive only 15%. Calculator output
  remains directional but the ETF side would be taxed somewhat higher.
- An Immobilienfonds (REIT / open real estate fund) would receive 60% or 80%, more
  favorable than equity. Calculator would understate the ETF side's tax efficiency.

If you want to model a non-Aktienfonds product, change `CalcConstants.teilfreistellung`
to the appropriate value from the table above.

**Key difference**: In the ETF depot, only the GAIN is taxed (and — for Aktienfonds —
with 30% exemption). In the AV-Depot, the gefördert portion's entire payout is taxed
(at a potentially lower retirement rate); the ungefördert portion uses Ertragsanteilbesteuerung.
This creates a crossover point depending on returns, duration, tax rates, and fund type.

---

## 3.4 Kirchensteuer (Church Tax)

Kirchensteuer applies to both AV-Depot (on income tax) and ETF-Depot (on Abgeltungssteuer).
The actual rate is **8%** in Bayern and Baden-Württemberg, **9%** in the other 14
federal states. About 71% of the population lives in 9%-states.

The calculator simplifies this to a **Yes/No toggle**, with the rate fixed at
**9%** when on (the dominant German rate, defined as `CalcConstants.kirchensteuersatz`).
Bayern/BaWü residents who pay Kirchensteuer will see a marginally overstated tax
burden — about 18 bp on the Abgeltungssteuersatz, translating to roughly €100–200
over a 30-year ETF accumulation. This was deemed acceptable for UI simplicity.

**ETF side — reduced KapESt formula:**

§32d Abs. 1 Sätze 4–5 EStG specifies the KapESt formula when Kirchensteuer
applies. The law writes it literally as:

```
                e − 4q
KapESt(e) = ──────────             // §32d Abs. 1 Satz 4 EStG
              4 + k
```

where `e` = Kapitalertrag (capital income), `q` = anrechenbare ausländische
Quellensteuer (creditable foreign withholding tax), `k` = Kirchensteuersatz.

Foreign withholding tax `q` is **not modeled** — we cannot meaningfully
estimate it without per-fund data — so we set `q = 0`, leaving:

```
KapESt(e)            = e × 1 / (4 + k)            // = e × 0.25 when k = 0
Soli                 = KapESt × 5.5%
KiSt                 = KapESt × k
Abgeltungssteuersatz = (KapESt + Soli + KiSt) / e = (1 + 0.055 + k) / (4 + k)

Results:
  k = 0.00 (toggle Off):              26.3750%
  k = 0.09 (toggle On, dominant rate): 27.9951%
  // The k = 0.08 case (Bayern/Baden-Württemberg) is not selectable; calculator
  // assumes 9% as a simplification. See note above.
```

The 1/(4+k) form is what tax advisors recognize from §32d directly.

**AV side — retirement payout taxation:**

```
BaseIncome      = Pension × 12 + SonstigeEinkünfte
AV_Taxable      = Jahres_Gefördert + Jahres_Ungefördert × 0.17    // 100% gef + 17% Ertragsanteil ungef
TaxOnAV         = calcEinkommensteuer(BaseIncome + AV_Taxable) − calcEinkommensteuer(BaseIncome)
AvPayoutTaxRate = TaxOnAV / AV_Taxable                             // rate per euro of AV taxable income

// Per-bucket net (Kirchensteuer added on top of the income tax in both cases):
Netto_Gefördert   = Monatlich_Gefördert   × (1 − AvPayoutTaxRate × (1 + KiSt_rate))
Netto_Ungefördert = Monatlich_Ungefördert × (1 − 0.17 × AvPayoutTaxRate × (1 + KiSt_rate))
```

The tax on the AV payout is computed via the exact §32a polynomial (not the
marginal rate on the last euro), and is incremental — only the additional tax
attributable to the AV-derived taxable income is allocated to the AV buckets.
The user's pension and other income retain their own implicit tax burden.

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
```

### Combined Yearly Subsidy

```
Zulage(j) = Grundzulage(Jahresbeitrag)
           + Kinderzulage(Jahresbeitrag, KinderAtYear(j))
           + Berufseinsteigerbonus(Alter, j)
```

Note: Subsidies are not constant over the savings period. `calcSubsidyPhases()` groups
consecutive years with identical subsidy components into phases (e.g., children aging
out of Kindergeld at 18 or 25, Berufseinsteigerbonus only in year 1).

### German Marginal Tax Rate (piecewise approximation, §32a EStG 2026)

```
Grenzsteuersatz(Brutto) =
  0%       if Brutto ≤ 12,348   (Grundfreibetrag)
  14%      if Brutto ≤ 17,799   (Eingangssteuersatz)
  23.97% + (Brutto - 17,799) / (69,878 - 17,799) × (42% - 23.97%)
           if Brutto ≤ 69,878   (Progressive zone, linear interpolation)
  42%      if Brutto ≤ 277,825  (Spitzensteuersatz)
  45%      if Brutto > 277,825  (Reichensteuersatz)
```

### Income Development (opt-in)

When the income-development toggle is off (default), `Brutto_j = Brutto` for all
years and `Kinder_j` depends only on the static `kinderAlter` ageing-out logic.

When enabled, the calculator supports three growth curves plus an optional
part-time phase. All produce a year-specific `Brutto_j` consumed downstream
by the marginal-rate calculation, the Geringverdiener eligibility check (note:
Geringverdienerbonus has been removed from the code, but eligibility-based
phase boundaries still apply for other components), and the pension EP
accumulation. Implementation: `IncomeDevSettings.bruttoForYear()`.

```
// ── Base growth curve ──
GrowthCurve.linear:        Brutto_j = Brutto × (1 + GrowthRate)^j         // 0–8% p.a.
GrowthCurve.stepwise:      Brutto_j = Brutto × (1 + PromotionIncrease)^floor(j / PromotionInterval)
GrowthCurve.logarithmic:   Brutto_j = Brutto + (SalaryCap − Brutto) × (1 − 1 / (1 + 0.1 × j))

// ── Optional part-time overlay ──
If PartTimeStart_j ≤ j < PartTimeStart_j + PartTimeDuration:
  Brutto_j ← Brutto_j × PartTimePercent                                    // typically 0.2–0.8

// ── Child arrival timing (independent of growth curve) ──
Kinder_j = (number of base children still under maxAge at year j)
         + (number of childArrivalYears ≤ j with arrival_age + (j − arrival_year) < maxAge)
   where maxAge = 25 if kinderStudieren else 18
```

### AV-Depot Year-by-Year Accumulation

```
// ── Constants (computed once; do not vary by year) ──
Jahresbeitrag    = Sparrate × 12                                    // [EUR/month → EUR/year]
JB_Capped        = min(Jahresbeitrag, 6840)                          // max €6,840/yr per contract
JB_Gefördert     = min(JB_Capped, 1800)                              // subsidized portion
JB_Ungefördert   = JB_Capped - JB_Gefördert                          // excess (no subsidy)

// Note: JB_Gefördert and JB_Ungefördert are NOT indexed by j — sparrate is a
// fixed user choice independent of income development. The split is determined
// once and applied identically each year.

For j = 0 to Spardauer - 1:
  Alter    = AlterStart + j
  Brutto_j = IncomeDev.bruttoForYear(Brutto, j)              // static or growing
  Grenzsteuersatz_j = Grenzsteuersatz(Brutto_j)
  Zulage_j = Zulage(j)                                       // year-specific: child age-out, bonus year 1 only
  // Sonderausgabenabzug capped at min(Jahresbeitrag, 1800) + Zulagen (§10a EStG-E)
  Günstigerprüfung:
    Steuerersparnis_j = (JB_Gefördert + Zulage_j) × Grenzsteuersatz_j
    Zusätzlich_j      = max(0, Steuerersparnis_j - Zulage_j)  // → Girokonto, NOT depot

  Depot_Gefördert   = (Depot_Gefördert   + JB_Gefördert   + Zulage_j) × (1 + Rendite - KostenAV)
  Depot_Ungefördert = (Depot_Ungefördert + JB_Ungefördert)            × (1 + Rendite - KostenAV)
  Depot = Depot_Gefördert + Depot_Ungefördert
```

**What about cumulative contributions per bucket?** The simulation already
implicitly tracks them: since `JB_Gefördert` and `JB_Ungefördert` are constants,
the cumulative contributions per bucket are simply `JB_Gefördert × Spardauer`
and `JB_Ungefördert × Spardauer`. The wealth accumulators `Depot_Gefördert` and
`Depot_Ungefördert` already separate the two buckets and include their
respective Zulagen + compounded gains.

The chosen payout taxation (100% of gefördert payout, 17% of ungefördert payout
— see §3.2) only needs the bucket-end values, so the cumulative-contributions
info is currently unused. If a future taxation rule were to require it — for
example **Unterschiedsbetrag** (strict Riester reading, gain = cumulative payout
− cumulative contributions) — it could be computed in one line inside the
payout phase:

```
Unterschiedsbetrag_Ungefördert = Depot_Ungefördert − JB_Ungefördert × Spardauer
```

No simulation restructuring would be needed. The Zulagen flow into the
gefördert bucket and are taxed in full at payout per §22 Nr. 5 EStG.

### AV-Depot Payout

Two tax regimes apply depending on whether contributions were subsidized:

```
Auszahlungsdauer = (85 - Rentenalter), clamped to 5–30 years
  // 85 = CalcConstants.payoutEndAge (§89 Abs. 8 EStG-E)

// ── Pension estimation for retirement tax calculation ──
If manual override set:
  EffectiveRente = gesetzlicheRenteOverride            // [EUR/month]
Else if income development enabled:
  TotalEP = Σ_j min(Brutto_j, BBG) / Durchschnittsentgelt
          + preSavingsYears × min(Brutto, BBG) / Durchschnittsentgelt
  EffectiveRente = TotalEP × Rentenwert                // [EUR/month]
Else:
  EffectiveRente = geschaetzteRente                    // static estimate

// ── Annual + monthly payouts per bucket ──
Jahres_Gefördert      = Depot_Gefördert   / Auszahlungsdauer        // [EUR/year]
Jahres_Ungefördert    = Depot_Ungefördert / Auszahlungsdauer        // [EUR/year]
Monatlich_Gefördert   = Jahres_Gefördert   / 12                     // [EUR/month]
Monatlich_Ungefördert = Jahres_Ungefördert / 12                     // [EUR/month]

// ── Incremental tax rate computed against the FULL AV taxable income ──
// Gefördert: 100% of payout is taxable.
// Ungefördert: 17% of payout is taxable (Ertragsanteil at age 67 — calculator
// simplification; the §22 EStG age table 60→22%, 65→18%, 68→16% etc. is not
// modeled, and the strict Riester reading would apply Unterschiedsbetrag for
// the Auszahlplan instead — see §3.2 for the deliberate simplification).
BaseIncome      = EffectiveRente × 12 + SonstigeEinkünfte
AV_Taxable      = Jahres_Gefördert + Jahres_Ungefördert × 0.17
CombinedIncome  = BaseIncome + AV_Taxable
TaxOnAV         = calcEinkommensteuer(CombinedIncome) − calcEinkommensteuer(BaseIncome)
AvPayoutTaxRate = TaxOnAV / AV_Taxable                              // rate per euro of taxable AV income

// ── Per-bucket net payouts (Kirchensteuer added on top of the income tax) ──
KiStFaktor          = 1 + Kirchensteuer
Netto_Gefördert     = Monatlich_Gefördert   × (1 − AvPayoutTaxRate × KiStFaktor)
Netto_Ungefördert   = Monatlich_Ungefördert × (1 − 0.17 × AvPayoutTaxRate × KiStFaktor)
Monatlich_Brutto    = Monatlich_Gefördert + Monatlich_Ungefördert
Monatlich_Netto     = Netto_Gefördert + Netto_Ungefördert
```

The tax is computed via the exact §32a polynomial; the resulting `AvPayoutTaxRate`
represents the rate at which each euro of AV-derived taxable income is taxed when
added on top of the user's pension + other income. The pension and other income
retain their own implicit tax burden — only the **incremental** tax attributable
to the AV is allocated to the AV buckets.

### ETF-Depot Year-by-Year Accumulation

```
VorabpauschaleDrag       = 0.003       // simplified per-year VP rate (CalcConstants)
  // Approximates Basiszins × 0.7 × (1 − Teilfreistellung) × Abgeltungssteuersatz
  // at Basiszins 2.3–3.2% with Teilfreistellung 30% and abgSt 26.375%.
NeuerBeitragFaktor       = 6.5 / 12    // §18 InvStG partial-year reduction
  // Average factor for new monthly contributions: VP is reduced by 1/12 for
  // each full month preceding the acquisition month, averaged across Jan–Dec.

VorabpauschaleGesamt = 0               // cumulative VP cash paid

For j = 0 to Spardauer - 1:
  Depot_StartOfYear = Depot                                                       // held the full year (factor 1.0)
  Depot             = (Depot + Jahresbeitrag) × (1 + Rendite − KostenETF)         // grow at full rate
  // VP base: full-year for prior holdings + partial-year for new contribution.
  VP_Base_j         = Depot_StartOfYear + Jahresbeitrag × NeuerBeitragFaktor
  VP_j              = VP_Base_j × VorabpauschaleDrag                              // tax paid out of depot
  Depot             = Depot − VP_j
  VorabpauschaleGesamt += VP_j
```

### ETF-Depot Payout

```
Gewinn                    = Depot − Eigenbeiträge       // Depot already net of VP debits
Teilfreistellung          = 30%                          // §20 InvStG, Aktienfonds (>50% equity per §2 Abs. 6)
Steuerpflichtiger_Gewinn  = Gewinn × (1 − Teilfreistellung)
Steuer_vor_Anrechnung     = Steuerpflichtiger_Gewinn × Abgeltungssteuersatz
  // Abgeltungssteuersatz: 26.3750% without KiSt, 27.8186% with 8%, 27.9951% with 9%
  // Formula: KapESt = 1 / (4 + k) per §32d Abs. 1 Satz 4 EStG (q=0); + Soli + KiSt (see §3.4)

// Vorabpauschale already paid is credited against the sale tax (§19 Abs. 1 InvStG):
Steuer_nach_Anrechnung    = max(0, Steuer_vor_Anrechnung − VorabpauschaleGesamt)
Netto                     = Depot − Steuer_nach_Anrechnung   // VP was already debited from Depot
Monatlich                 = Netto / (Auszahlungsdauer × 12)  // [EUR → EUR/month] output

// Lifetime tax burden (for reporting):
Steuer_Lifetime           = VorabpauschaleGesamt + Steuer_nach_Anrechnung
                          ≈ Steuer_vor_Anrechnung   (when VP is fully credited, i.e. typical)
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

**Progressive §32a tax for retirement payout — incremental, not average**: The
calculator uses the exact §32a polynomial (`calcEinkommensteuer`) twice — once on
the user's base retirement income (pension + other) and once on that income plus
the AV taxable amount. The difference is the incremental tax that the AV payout
adds, divided by the AV taxable amount to obtain `AvPayoutTaxRate`. This rate is
the correct one to apply: it captures exactly how the AV's taxable income is taxed
when stacked on top of pension + other in the §32a progression, without double-
counting the tax already implicitly borne by the pension.

This differs from a simple average-rate (`tax / income`) approach, which would
dilute the AV's marginal tax burden with the lower-bracket portion of the pension
income. It also differs from a marginal-rate-on-the-last-euro approach, which
would overstate the tax when the AV taxable amount spans multiple brackets.

The remaining simplification is using **Brutto as a proxy for zvE** (zu
versteuerndes Einkommen). In reality, zvE = Brutto − Werbungskosten −
Sonderausgaben − etc. This slightly overstates `AvPayoutTaxRate` for most users.

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

### 2026 Brackets (used in calculator)

**Legal basis**: §32a Abs. 1 Satz 2 EStG, applicable from Veranlagungszeitraum 2026,
as amended by the **Steuerfortentwicklungsgesetz** (passed by the Bundestag in
December 2024).

**Source of values**: The bracket thresholds and polynomial coefficients are written
**verbatim into the statute itself**. The values below were taken from the official
consolidated text published by the Federal Ministry of Justice at
<https://www.gesetze-im-internet.de/estg/__32a.html> (which mirrors the Bundesgesetzblatt).

| zvE (zu versteuerndes Einkommen) | Grenzsteuersatz | Tax formula |
|---|---|---|
| ≤ €12,348 | 0% | Grundfreibetrag (no tax) |
| €12,349 – €17,799 | 14–24% | (914.51 × y + 1,400) × y, y = (zvE − 12,348) / 10,000 |
| €17,800 – €69,878 | 24–42% | (173.10 × z + 2,397) × z + 1,034.87, z = (zvE − 17,799) / 10,000 |
| €69,879 – €277,825 | 42% | 0.42 × zvE − 11,135.63 (Spitzensteuersatz) |
| > €277,825 | 45% | 0.45 × zvE − 19,470.38 (Reichensteuersatz) |

**What the coefficients mean** (these are not free parameters — they are calibrated by the
legislator so that the tax function is continuous at every zone boundary and so that the
marginal rate hits the legally specified targets):

- `1400 / 10,000 = 14%` → Eingangssteuersatz, the marginal rate at the start of zone 2.
- `2397 / 10,000 = 23.97%` → marginal rate at the start of zone 3 (must equal the marginal
  rate at the end of zone 2, ensuring smooth transition).
- `914.51` and `173.10` → curvature coefficients. They control how steeply the marginal
  rate climbs through each progressive zone, calibrated so the marginal rate reaches
  exactly 24% at the end of zone 2 and exactly 42% at the end of zone 3.
- `1034.87`, `11135.63`, `19470.38` → continuity offsets. Tax computed at a zone boundary
  using the lower zone's formula must equal the tax computed using the upper zone's
  formula; these constants enforce that.

These are **not** interpretations or approximations on the calculator's part — they are
the literal coefficients in the statute. Any changes here in future tax years should come
from updates to §32a EStG, not from re-derivation.

**Calculator implementation**: Exact §32a polynomial formulas in `GermanTax2026.calcEinkommensteuer()` ([lib/services/domain/tax_module.dart](../lib/services/domain/tax_module.dart)). Marginal rate (`getGrenzsteuersatz`) uses a linear interpolation across the progressive zone — used only for Günstigerprüfung where the marginal rate is the correct comparison.

**Note**: The calculator uses Bruttojahreseinkommen as a proxy for zvE. In reality, zvE =
Brutto − Werbungskosten − Sonderausgaben − etc. This simplification slightly overstates the
tax for most users.

### Planned Updates

Tax brackets are adjusted annually for inflation (kalte Progression).
The 2027 brackets should be substituted once published by the BMF (typically late 2026).
When a new year is added, prefer renaming the class (e.g., `GermanTax2027`) and adding it
as a new module rather than mutating the existing one — this preserves historical
comparability and supports the modular tax-engine design.

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
