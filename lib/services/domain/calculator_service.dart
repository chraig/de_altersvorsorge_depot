import 'dart:math';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';
import 'package:avdepot_rechner/services/domain/subsidy_module.dart';
import 'package:avdepot_rechner/services/domain/pension_module.dart';

/// All legislative and tax parameters in one place.
/// Update these when tax brackets change or legislation is amended.
///
/// Sources:
/// - Subsidy parameters: §89 EStG-E (Altersvorsorgereformgesetz, Finanzausschuss 25.03.2026)
/// - Tax brackets: §32a EStG 2026 values (Steuerfortentwicklungsgesetz)
/// - ETF taxation: §20 InvStG (Teilfreistellung), §43a EStG + §4 SolZG (Abgeltungssteuer)
/// - Pension estimation: Deutsche Rentenversicherung (Rentenwert July 2024, West)
class CalcConstants {
  const CalcConstants._();

  // ─── GRUNDZULAGE (§89 Abs. 1 EStG-E) ──────────────────────────
  /// 50% match on contributions up to this cap (first tier)
  static const double grundzulageStufe1Rate = 0.50;
  /// First tier cap: max €360/yr eligible for 50% match
  static const double grundzulageStufe1Cap = 360.0;
  /// 25% match on contributions above first tier (second tier)
  static const double grundzulageStufe2Rate = 0.25;
  /// Maximum subsidized contribution: €1,800/yr. Above this, no subsidy.
  static const double grundzulageMaxBeitrag = 1800.0;
  /// Maximum total contribution per contract: €6,840/yr (BMF FAQ).
  /// Contributions above this are not allowed in the AV-Depot.
  static const double maxBeitragProVertrag = 6840.0;

  // ─── KINDERZULAGE (§89 Abs. 2 EStG-E) ─────────────────────────
  /// Max €300 per child per year, 1:1 match on own contributions
  static const double kinderzulageMax = 300.0;
  /// Child must be kindergeldberechtigt. Kindergeld ends at age 25 (in education)
  /// or 18 (default). Actual max age is user-selectable via PersonalScenario.kinderStudieren.
  static const int kinderzulageMaxAlter = 25;

  // ─── BERUFSEINSTEIGERBONUS (§89 Abs. 3 EStG-E) ────────────────
  /// One-time bonus for career starters (first year of contract only).
  /// Source: BMF FAQ — "einmalig 200 Euro"
  static const double bonusBetrag = 200.0;
  /// Must be under this age at contract start to qualify
  static const int bonusMaxAlter = 25;

  // ─── INCOME TAX BRACKETS (§32a EStG, 2026 values) ─────────────
  // Source: Steuerfortentwicklungsgesetz, applicable from Veranlagungszeitraum 2026.
  // Authoritative: https://www.gesetze-im-internet.de/estg/__32a.html
  // All values below — thresholds AND polynomial coefficients — are written verbatim
  // into §32a Abs. 1 Satz 2 EStG. Update this entire block when a new tax year applies.

  // ── Zone thresholds ──
  /// Grundfreibetrag: no tax at or below this (tax-free allowance)
  static const double grundfreibetrag = 12348;
  /// End of zone 2 (entry zone): marginal rate rises from 14% to 24% across this zone
  static const double zone2Ende = 17799;
  /// End of zone 3 (progressive zone): marginal rate rises from 24% to 42% across this zone
  static const double zone3Ende = 69878;
  /// End of zone 4 / start of zone 5 (Reichensteuersatz threshold)
  static const double zone4Ende = 277825;

  // ── Marginal rates (used by getGrenzsteuersatz for Günstigerprüfung comparison) ──
  /// Eingangssteuersatz: marginal rate at start of zone 2
  static const double zone2Satz = 0.14;
  /// Marginal rate at start of zone 3 (continuity with zone 2 end)
  static const double zone3StartSatz = 0.2397;
  /// Spitzensteuersatz: flat 42% across zone 4
  static const double spitzensteuersatz = 0.42;
  /// Reichensteuersatz: flat 45% above zone4Ende
  static const double reichensteuersatz = 0.45;

  // ── §32a polynomial coefficients (used by calcEinkommensteuer) ──
  // Zone 2 formula:  tax = (zone2A × y + zone2B) × y    where y = (zvE − grundfreibetrag) / 10,000
  // Zone 3 formula:  tax = (zone3A × z + zone3B) × z + zone3C    where z = (zvE − zone2Ende) / 10,000
  // Zone 4 formula:  tax = spitzensteuersatz × zvE − zone4Offset
  // Zone 5 formula:  tax = reichensteuersatz × zvE − zone5Offset
  /// Zone 2 quadratic coefficient (curvature)
  static const double zone2A = 914.51;
  /// Zone 2 linear coefficient (encodes 14% Eingangssteuersatz × 10,000)
  static const double zone2B = 1400;
  /// Zone 3 quadratic coefficient (curvature)
  static const double zone3A = 173.10;
  /// Zone 3 linear coefficient (encodes 23.97% start-of-zone-3 marginal rate × 10,000)
  static const double zone3B = 2397;
  /// Zone 3 continuity constant (tax amount at the start of zone 3)
  static const double zone3C = 1034.87;
  /// Zone 4 continuity offset (so zone 4 connects smoothly to end of zone 3)
  static const double zone4Offset = 11135.63;
  /// Zone 5 continuity offset (so zone 5 connects smoothly to end of zone 4)
  static const double zone5Offset = 19470.38;

  // ─── ETF TAXATION (§20 InvStG, §43a EStG) ─────────────────────
  /// Teilfreistellung rate. The calculator assumes the user holds an **Aktienfonds**
  /// (an equity fund / equity ETF). Per §20 Abs. 1 InvStG: 30% of distributions and
  /// realized gains are tax-exempt for private investors.
  ///
  /// IMPORTANT: this rate ONLY applies if the fund qualifies as an Aktienfonds under
  /// §2 Abs. 6 InvStG — i.e., the fund's investment terms (Anlagebedingungen)
  /// continuously commit to investing more than 50% of its Aktivvermögen in
  /// Kapitalbeteiligungen (typically listed equities). Other fund types receive
  /// different (or no) Teilfreistellung:
  ///   • Mischfonds (≥25% equity per §2 Abs. 7 InvStG): 15% (§20 Abs. 2 InvStG)
  ///   • Immobilienfonds, domestic focus (§2 Abs. 9 InvStG): 60% (§20 Abs. 3 InvStG)
  ///   • Immobilienfonds, foreign focus: 80% (§20 Abs. 3 InvStG)
  ///   • Sonstige Fonds (bond ETFs, money-market funds, mixed <25%): 0%
  ///
  /// If the user actually holds a non-Aktienfonds product, the calculator's ETF
  /// comparison overstates the tax advantage — most strikingly for bond ETFs which
  /// receive no Teilfreistellung at all.
  static const double teilfreistellung = 0.30;
  /// Simplified annual Vorabpauschale drag on ETF returns.
  /// Formula: Basiszins × 0.7 × 0.70 (Teilfreistellung) × 0.26375 (AbgSt+Soli).
  /// At Basiszins 2.29% (2024): effective ~0.30%. At 3.20% (2026): ~0.41%.
  /// Using 0.30% as a reasonable mid-range approximation.
  static const double vorabpauschaleDrag = 0.003;
  /// Kirchensteuersatz applied when the user is kirchensteuerpflichtig.
  /// 9% applies in 14 of 16 federal states (~71% of the population) — Bayern
  /// and Baden-Württemberg use 8%, but for simplicity the calculator uses the
  /// dominant rate. Bay/BaWü residents who are church members will see a
  /// slightly overstated tax burden (the 18-bp difference on the Abgeltungs­
  /// steuersatz translates to roughly €100–200 over a 30-year ETF accumulation).
  static const double kirchensteuersatz = 0.09;

  /// Average partial-year factor for new contributions in the Vorabpauschale
  /// computation (§18 InvStG: VP is reduced by 1/12 for each full month
  /// preceding the acquisition month). For monthly contributions distributed
  /// evenly across the year, the average factor is `(1/12) × Σ_{k=0..11} (1 − k/12)
  /// = 6.5 / 12 ≈ 0.5417`. Pre-existing depot value (held the full year) gets
  /// the full factor 1.0.
  static const double vorabpauschaleNeuerBeitragFaktor = 6.5 / 12;

  // ─── PAYOUT PHASE ─────────────────────────────────────────────
  /// Auszahlplan must run until this age (§89 Abs. 8 EStG-E)
  static const int payoutEndAge = 85;
  /// Ertragsanteil for Auszahlplan at payout start age 67 (§22 Nr. 1 Satz 3a EStG).
  /// Used for ungeförderte AV-Depot payouts: 17% of payout taxed at income rate.
  /// Calculator simplification: always assumes age-67 entry (17%) regardless of
  /// actual retirement age. Age-dependent table (60→22%, 65→18%, 68→16% etc.) not modeled.
  static const double ertragsanteil67 = 0.17;

  // ─── PENSION ESTIMATION (Deutsche Rentenversicherung) ──────────
  /// EUR per Entgeltpunkt per month (West Germany, July 2024).
  /// Updated annually. East Germany uses a different (converging) value.
  static const double rentenwert = 39.32;
  /// Average gross income used to calculate Entgeltpunkte (2024).
  /// 1.0 EP = earning exactly the average. Updated annually by BMF.
  static const double durchschnittsentgelt = 45358.0;
  /// Beitragsbemessungsgrenze (2024, West): no pension points above this income.
  /// Updated annually. Separate (lower) value exists for East Germany.
  static const double bbg = 90600.0;
  /// Assumed start of working life for contribution year estimation.
  /// Conservative default (25) reflects university graduates.
  /// Apprenticeship starters might use 16-18 in practice.
  static const int arbeitsbeginn = 25;
}

// ═══════════════════════════════════════════════════════════════════
// PAYOUT-PHASE ANNUITY HELPER
// ═══════════════════════════════════════════════════════════════════

/// Constant per-period annuity payment that exactly depletes `presentValue` to
/// zero over `periods` periods, while the remaining balance continues to
/// compound at `periodRate` per period.
///
/// Formula (ordinary-annuity, end-of-period payments):
///   PMT = PV × r / (1 − (1 + r)⁻ⁿ)
///
/// The caller chooses the period: pass yearly rate + years for an annual
/// annuity, monthly rate + months for a monthly annuity. The payout phase of
/// this calculator uses monthly periods so the displayed monthly figure is
/// realistic (a real Auszahlplan pays monthly, with monthly compounding on
/// the remaining balance).
///
/// Edge cases:
/// - `periodRate ≈ 0`: limit is PV/periods (no growth → equal split each period).
/// - `periods ≤ 0` or `presentValue ≤ 0`: returns 0.
double annuityPayment(double presentValue, double periodRate, int periods) {
  if (periods <= 0 || presentValue <= 0) return 0;
  if (periodRate.abs() < 1e-9) return presentValue / periods;
  return presentValue * periodRate / (1 - pow(1 + periodRate, -periods));
}

/// Number of kindergeldberechtigt children for [person] at savings year [j],
/// applying [incomeDev] for any dynamic child arrivals plus the existing-
/// child age-out logic. Centralizes the parameter unpacking that all simulation
/// loops would otherwise repeat.
int _kinderAt(PersonalScenario person, IncomeDevSettings incomeDev, int j) =>
    incomeDev.kinderAtYear(person.kinder, j,
        kinderAlter: person.kinderAlter, maxAge: person.maxKindergeldAlter);

// ═══════════════════════════════════════════════════════════════════
// SIMULATION ENGINE
// ═══════════════════════════════════════════════════════════════════

/// Simulation engine with injectable modules.
///
/// Each module (tax, subsidy, pension) can be replaced independently:
/// ```dart
/// final engine = SimulationEngine(
///   tax: GermanTax2026(),          // or a custom/updated implementation
///   subsidy: AVDepotSubsidy2027(), // or a different subsidy regime
///   pension: EntgeltpunkteEstimator(), // or a different pension system
/// );
/// ```
///
/// Default constructor uses the standard 2024/2027 implementations.
class SimulationEngine {
  final TaxModule tax;
  final SubsidyModule subsidy;
  final PensionModule pension;

  const SimulationEngine({
    this.tax = const GermanTax2026(),
    this.subsidy = const AVDepotSubsidy2027(),
    this.pension = const EntgeltpunkteEstimator(),
  });

  /// Default engine with standard modules.
  static const standard = SimulationEngine();

  // ─── SUBSIDY BREAKDOWN (for UI display) ────────────────────────

  /// Full subsidy breakdown for year 1.
  SubsidyBreakdown calcSubsidyBreakdown(PersonalScenario person) {
    final jb = person.jahresbeitrag;
    // Year 0: use kinderAtYear for consistency (accounts for children already near age-out).
    final kinderY0 = _kinderAt(person, const IncomeDevSettings(), 0);
    final z = subsidy.calcZulage(jb, kinderY0, person.alterStart, 0, person.brutto);
    final gst = tax.getGrenzsteuersatz(person.brutto);
    final gp = tax.calcGuenstigerpruefung(jb, z.total, gst);
    final fq = jb > 0 ? z.total / jb : 0.0;
    return SubsidyBreakdown(
      grundzulage: z.grund,
      kinderzulage: z.kind,
      bonus: z.bonus,
      total: z.total,
      foerderquote: fq,
      steuererstattung: gp.zusaetzlich,
      grenzsteuersatz: gst,
    );
  }

  /// Compute subsidy phases: groups of consecutive years with identical subsidies.
  /// Accounts for child age-out and Berufseinsteigerbonus (year 1 only).
  List<SubsidyPhase> calcSubsidyPhases(PersonalScenario person, {IncomeDevSettings incomeDev = const IncomeDevSettings()}) {
    final jbGef = person.jahresbeitragGefoerdert;
    final phases = <SubsidyPhase>[];

    int phaseStart = 0;
    double prevGrund = -1, prevKind = -1, prevBonus = -1, prevRefund = -1;
    int prevKinder = -1;

    for (int j = 0; j < person.spardauer; j++) {
      final alter = person.alterStart + j;
      final bruttoJ = incomeDev.bruttoForYear(person.brutto, j);
      final kinderJ = _kinderAt(person, incomeDev, j);
      final z = subsidy.calcZulage(jbGef, kinderJ, alter, j, bruttoJ);
      final gstJ = tax.getGrenzsteuersatz(bruttoJ);
      final gp = tax.calcGuenstigerpruefung(jbGef, z.total, gstJ);

      // Check if this year's values differ from previous
      if (z.grund != prevGrund || z.kind != prevKind || z.bonus != prevBonus ||
          kinderJ != prevKinder ||
          (gp.zusaetzlich - prevRefund).abs() > 0.01) {
        // Close previous phase
        if (j > 0) {
          phases.add(SubsidyPhase(
            yearFrom: phaseStart + 1, yearTo: j,
            kinder: prevKinder, grundzulage: prevGrund, kinderzulage: prevKind,
            bonus: prevBonus,
            total: prevGrund + prevKind + prevBonus,
            steuererstattung: prevRefund,
          ));
        }
        phaseStart = j;
        prevGrund = z.grund; prevKind = z.kind; prevBonus = z.bonus;
        prevKinder = kinderJ; prevRefund = gp.zusaetzlich;
      }
    }

    // Close final phase
    if (person.spardauer > 0) {
      phases.add(SubsidyPhase(
        yearFrom: phaseStart + 1, yearTo: person.spardauer,
        kinder: prevKinder, grundzulage: prevGrund, kinderzulage: prevKind,
        bonus: prevBonus,
        total: prevGrund + prevKind + prevBonus,
        steuererstattung: prevRefund,
      ));
    }

    return phases;
  }

  // ─── AV-DEPOT SIMULATION ──────────────────────────────────────

  AVResult simulateAV({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    final jbCapped = person.jahresbeitragCapped;
    final jbGefoerdert = person.jahresbeitragGefoerdert;
    final jbUngefoerdert = person.jahresbeitragUngefoerdert;
    final nettoRendite = macro.rendite - costs.kostenAV;

    // ── Accumulation phase ──────────────────────────────────────
    // Two buckets grow in the same depot but tracked separately for payout tax.
    double depotGefoerdert = 0; // subsidized bucket: full nachgelagerte Besteuerung
    double depotUngefoerdert = 0; // unsubsidized bucket: Ertragsanteilbesteuerung
    double eigenBeitraege = 0;
    double zulagenGesamt = 0;
    double steuererstattungGesamt = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      final alter = person.alterStart + j;
      final bruttoJ = incomeDev.bruttoForYear(person.brutto, j);
      final kinderJ = _kinderAt(person, incomeDev, j);
      final gstJ = tax.getGrenzsteuersatz(bruttoJ);
      final z = subsidy.calcZulage(jbGefoerdert, kinderJ, alter, j, bruttoJ);
      final gp = tax.calcGuenstigerpruefung(jbGefoerdert, z.total, gstJ);

      // Gefördert bucket: contribution + subsidies
      depotGefoerdert = (depotGefoerdert + jbGefoerdert + z.total) * (1 + nettoRendite);
      // Ungefördert bucket: excess contribution only
      if (jbUngefoerdert > 0) {
        depotUngefoerdert = (depotUngefoerdert + jbUngefoerdert) * (1 + nettoRendite);
      }

      eigenBeitraege += jbCapped;
      zulagenGesamt += z.total;
      steuererstattungGesamt += gp.zusaetzlich;

      final depot = depotGefoerdert + depotUngefoerdert;
      jahresWerte.add(YearlyDataPoint(
        year: j + 1,
        alter: alter + 1,
        depot: depot,
        depotReal: depot / pow(1 + macro.inflation, j + 1),
        eigenBeitraege: eigenBeitraege,
        zulagen: zulagenGesamt,
        zulageJahr: z.total,
      ));
    }

    // ── Payout phase ────────────────────────────────────────────
    final depot = depotGefoerdert + depotUngefoerdert;
    final auszahlungsDauer = person.auszahlungsDauer;

    // Compute the incremental tax that the AV payout adds on top of pension + other.
    // The AV payout has two taxable components:
    //   • gefördert: 100% of payout is taxable income (nachgelagerte Besteuerung)
    //   • ungefördert: 17% of payout is taxable income (Ertragsanteil at age 67)
    // Both sit on top of pension + sonstige in the §32a progression, so the marginal
    // rate must be computed against the FULL AV taxable amount (gefördert +
    // 17% × ungefördert), not against the gefördert portion alone.
    //
    // Each bucket continues to compound at `nettoRendite` during the payout phase
    // (no new contributions, no new Zulagen, but the depot stays invested). The
    // gross monthly payout per bucket is the constant annuity payment that depletes
    // the bucket exactly at the end of `auszahlungsDauer` years. Monthly periods
    // are used so the displayed monthly figure reflects real-world monthly
    // compounding during retirement.
    final effectiveRente = pension.estimateMonthlyPension(person, incomeDev);
    final monthlyRate = pow(1 + nettoRendite, 1.0 / 12).toDouble() - 1;
    final months = auszahlungsDauer * 12;
    final monatlichGefoerdert   = annuityPayment(depotGefoerdert,   monthlyRate, months);
    final monatlichUngefoerdert = annuityPayment(depotUngefoerdert, monthlyRate, months);
    final jahresGefoerdert   = monatlichGefoerdert   * 12;
    final jahresUngefoerdert = monatlichUngefoerdert * 12;
    final baseIncome = effectiveRente * 12 + person.sonstigeEinkuenfte; // pension + other
    final avTaxableTotal = jahresGefoerdert + jahresUngefoerdert * CalcConstants.ertragsanteil67;
    final combinedIncome = baseIncome + avTaxableTotal;
    final kirchensteuerFaktor = 1 + costs.kirchensteuerRate;
    // Incremental income tax attributable to the AV-derived taxable income.
    final taxOnBase = tax.calcEinkommensteuer(baseIncome);
    final taxOnCombined = tax.calcEinkommensteuer(combinedIncome);
    final taxOnAvPayout = taxOnCombined - taxOnBase;
    // avPayoutTaxRate = "rate per euro of AV taxable income" (gefördert + 17%×ungefördert).
    final avPayoutTaxRate = avTaxableTotal > 0 ? taxOnAvPayout / avTaxableTotal : 0.0;

    // Apply the rate to each bucket's taxable share:
    //   • gefördert: 100% of payout is taxable → rate applies to full payout
    //   • ungefördert: 17% of payout is taxable → rate applies to 17% of payout
    // Kirchensteuer is added on top of the income tax in both cases.
    final nettoGefoerdert = monatlichGefoerdert * (1 - avPayoutTaxRate * kirchensteuerFaktor);
    final nettoUngefoerdert = depotUngefoerdert > 0
        ? monatlichUngefoerdert * (1 - CalcConstants.ertragsanteil67 * avPayoutTaxRate * kirchensteuerFaktor)
        : 0.0;

    final monatlich = monatlichGefoerdert + monatlichUngefoerdert;
    final netto = nettoGefoerdert + nettoUngefoerdert;

    return AVResult(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      zulagenGesamt: zulagenGesamt,
      steuererstattungGesamt: steuererstattungGesamt,
      monatlicheAuszahlung: monatlich,
      nettoMonatlich: netto,
      grenzsteuersatz: tax.getGrenzsteuersatz(person.brutto),
      grenzsteuersatzRente: avPayoutTaxRate,
      wertzuwachs: depot - eigenBeitraege - zulagenGesamt,
      jahresWerte: jahresWerte,
    );
  }

  // ─── ETF-DEPOT SIMULATION ────────────────────────────────────

  ETFResult simulateETF({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    final jb = person.jahresbeitrag;
    final nettoRendite = macro.rendite - costs.kostenETF;

    // ── Accumulation phase ──────────────────────────────────────
    // Vorabpauschale model (§18 InvStG):
    //   • The VP base is the value at the START of the year (held the full
    //     year), not the year-end value. The new contribution made during the
    //     year gets the §18 partial-year reduction — averaged across monthly
    //     contributions, the new-contribution factor is 6.5/12 ≈ 0.5417.
    //   • The VP tax is paid out of the depot, modeled as `vp_base × drag`.
    //   • The cumulative VP paid is credited against the Abgeltungssteuer at
    //     sale (§19 Abs. 1 InvStG), so the same tax is not collected twice.
    double depot = 0;
    double eigenBeitraege = 0;
    double vorabpauschaleGesamt = 0; // cumulative VP-tax already paid
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      final depotStartOfYear = depot;                                     // held the full year (factor 1.0)
      depot = (depot + jb) * (1 + nettoRendite);                          // grow at full rate
      // VP base: start-of-year depot (full year) + jb × partial-year factor (~0.5417).
      final vpBase = depotStartOfYear
          + jb * CalcConstants.vorabpauschaleNeuerBeitragFaktor;
      final vpJahr = vpBase * CalcConstants.vorabpauschaleDrag;
      depot -= vpJahr;
      vorabpauschaleGesamt += vpJahr;
      eigenBeitraege += jb;

      jahresWerte.add(YearlyDataPoint(
        year: j + 1,
        alter: person.alterStart + j + 1,
        depot: depot,
        depotReal: depot / pow(1 + macro.inflation, j + 1),
        eigenBeitraege: eigenBeitraege,
        zulagen: 0,
        zulageJahr: 0,
      ));
    }

    // ── Payout phase ─────────────────────────────────────────────
    // The depot continues to compound at `nettoRendite` during retirement (no
    // new contributions). Monthly compounding is used so the displayed monthly
    // payout matches a real Auszahlplan.
    //
    // Gross monthly payout = constant annuity payment that depletes the depot
    // exactly at the end of `auszahlungsDauer` years.
    //
    // Tax is applied per month via an effective tax rate `etfTaxRatePayout`
    // (analogous to AV's `avPayoutTaxRate`). Each month the user pays
    //   tax_per_month = monatlichBrutto × etfTaxRatePayout
    // and receives
    //   monatlich = monatlichBrutto × (1 − etfTaxRatePayout)
    //
    // The rate is calibrated so the cumulative tax across all payout months
    // matches the legally-correct lifetime sale tax (Abgeltungssteuer on the
    // total taxable gain extracted, with Vorabpauschale credit per §19 Abs. 1
    // InvStG). Because Abgeltungssteuer is FLAT (not progressive) and total
    // gain extracted = total gross − cost basis (conservation of money), the
    // per-month rate equals the lifetime-average rate exactly:
    //
    //   etfTaxRatePayout = lifetimeSaleTax / lifetimeGross
    //
    // i.e. computing month-by-month or via the lifetime totals produces the
    // same monthly tax. We use the closed-form path because it's simpler and
    // gives the user a constant monthly net (UX-friendly).
    //
    // This replaces the earlier "lump-sum tax at retirement" model, which
    // implicitly assumed the user sold everything at retirement and parked
    // the post-tax amount tax-free — unrealistic for an 18-year payout.
    final auszahlungsDauer = person.auszahlungsDauer;
    final monthlyRate = pow(1 + nettoRendite, 1.0 / 12).toDouble() - 1;
    final months = auszahlungsDauer * 12;
    final monatlichBrutto = annuityPayment(depot, monthlyRate, months);
    final lifetimeGross = monatlichBrutto * months;
    final lifetimeGain = lifetimeGross - eigenBeitraege;
    final gewinn = depot - eigenBeitraege; // gain at retirement (display field)
    final lifetimeSaleTaxVorAnrechnung =
        lifetimeGain * (1 - CalcConstants.teilfreistellung) * costs.abgeltungssteuersatz;
    final lifetimeSaleTaxNachAnrechnung = lifetimeSaleTaxVorAnrechnung > vorabpauschaleGesamt
        ? lifetimeSaleTaxVorAnrechnung - vorabpauschaleGesamt
        : 0.0;
    // Effective per-month tax rate on the gross monthly payout. Constant by
    // construction because Abgeltungssteuer is flat. Parallel to AV's
    // `avPayoutTaxRate × kirchensteuerFaktor` for the gef bucket.
    final etfTaxRatePayout = lifetimeGross > 0
        ? lifetimeSaleTaxNachAnrechnung / lifetimeGross
        : 0.0;
    final monatlich = monatlichBrutto * (1 - etfTaxRatePayout);
    // Reported lifetime tax burden: VP paid during accumulation + sale tax during payout.
    final steuer = vorabpauschaleGesamt + lifetimeSaleTaxNachAnrechnung;
    // nachSteuer = lifetime cash-in-hand to the user (= net monthly × n_months).
    final nachSteuer = monatlich * months;

    return ETFResult(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      gewinn: gewinn,
      vorabpauschaleGesamt: vorabpauschaleGesamt,
      steuerAufGewinn: steuer,
      nachSteuer: nachSteuer,
      bruttoMonatlich: monatlichBrutto,
      monatlicheAuszahlung: monatlich,
      effectiveTaxRatePayout: etfTaxRatePayout,
      jahresWerte: jahresWerte,
    );
  }

  // ─── COMPOSITION ─────────────────────────────────────────────

  CombinedResult simulateCombined({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    return CombinedResult(
      macro: macro,
      av: simulateAV(person: person, macro: macro, costs: costs, incomeDev: incomeDev),
      etf: simulateETF(person: person, macro: macro, costs: costs),
    );
  }

  List<CombinedResult> simulateAllMacros({
    required PersonalScenario person,
    required List<MacroScenario> macros,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    return macros.map((m) => simulateCombined(person: person, macro: m, costs: costs, incomeDev: incomeDev)).toList();
  }
}
