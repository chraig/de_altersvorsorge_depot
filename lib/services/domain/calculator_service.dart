import 'dart:math';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';
import 'package:avdepot_rechner/services/domain/subsidy_module.dart';
import 'package:avdepot_rechner/services/domain/pension_module.dart';
import 'package:avdepot_rechner/services/domain/payout_module.dart';

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
  /// Pre-tax Vorabpauschale rate per §18 Abs. 1 InvStG: 0.7 × Basiszins.
  /// Multiply by `(1 − Teilfreistellung) × Abgeltungssteuersatz` to get the
  /// after-tax drag on the depot — KiSt-aware via `CostSettings.abgeltungssteuersatz`.
  ///
  /// Basiszins is set yearly by BMF (§203 Abs. 2 BGB) and varies significantly
  /// (2018: 0.87 %, 2022: 0 %, 2024: 2.29 %, 2026 preliminary: 3.20 %). The
  /// calculator uses ≈ 2.29 % (2024) → 0.7 × 2.29 % = 1.603 %; combined with
  /// 30 % Teilfreistellung the effective drag is ≈ 0.296 % (no KiSt) or
  /// ≈ 0.314 % (9 % KiSt). Constant Basiszins is a simplification — real-world
  /// VP varies substantially year-to-year as Basiszins moves.
  static const double vorabpauschaleBasisertragsRate = 0.01603;
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
/// The simulation is split into two phases that web integrators can adopt
/// independently:
///
///   1. **Accumulation** — `simulateAVAccumulation` / `simulateETFAccumulation`
///      run the savings phase only and return everything needed to display the
///      gross capital at retirement (and the bucket split / VP credit needed
///      to feed the payout phase later).
///   2. **Payout** — `avPayout` / `etfPayout` modules consume the accumulation
///      result plus person/macro/costs and produce monthly payout figures.
///
/// `simulateAV` / `simulateETF` chain the two phases and return the combined
/// `AVResult` / `ETFResult` used by the UI.
///
/// Each module can be replaced independently — useful for modeling alternative
/// regimes (Lebenslange Rente, strict Riester reading, updated tax brackets,
/// different subsidy designs):
/// ```dart
/// final engine = SimulationEngine(
///   tax:       GermanTax2026(),
///   subsidy:   AVDepotSubsidy2027(),
///   pension:   EntgeltpunkteEstimator(),
///   avPayout:  AnnuityAVPayout(),
///   etfPayout: AnnuityETFPayout(),
/// );
/// ```
class SimulationEngine {
  final TaxModule tax;
  final SubsidyModule subsidy;
  final PensionModule pension;
  final AVPayoutModule avPayout;
  final ETFPayoutModule etfPayout;

  const SimulationEngine({
    this.tax = const GermanTax2026(),
    this.subsidy = const AVDepotSubsidy2027(),
    this.pension = const EntgeltpunkteEstimator(),
    this.avPayout = const AnnuityAVPayout(),
    this.etfPayout = const AnnuityETFPayout(),
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

  // ─── AV-DEPOT ACCUMULATION (savings phase only) ──────────────
  //
  // Web integrators can call this directly to drive the savings-phase UI
  // (year-by-year curve, gross capital at age 67) without yet wiring up
  // the payout module. Pass the result into [avPayout.compute] later to
  // obtain the monthly payout figures.

  /// Run the AV-Depot savings phase only.
  /// Returns the bucket-aware accumulation state at retirement plus the
  /// year-by-year curve. Does NOT compute payout figures.
  AVAccumulation simulateAVAccumulation({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    final jbCapped = person.jahresbeitragCapped;
    final jbGefoerdert = person.jahresbeitragGefoerdert;
    final jbUngefoerdert = person.jahresbeitragUngefoerdert;
    final nettoRendite = macro.rendite - costs.kostenAV;

    // Two buckets grow in the same depot but tracked separately for payout tax.
    double depotGefoerdert = 0;   // subsidized: full nachgelagerte Besteuerung
    double depotUngefoerdert = 0; // unsubsidized: Ertragsanteilbesteuerung
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

    final depot = depotGefoerdert + depotUngefoerdert;
    return AVAccumulation(
      depotGefoerdert: depotGefoerdert,
      depotUngefoerdert: depotUngefoerdert,
      eigenBeitraege: eigenBeitraege,
      zulagenGesamt: zulagenGesamt,
      steuererstattungGesamt: steuererstattungGesamt,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      grenzsteuersatz: tax.getGrenzsteuersatz(person.brutto),
      jahresWerte: jahresWerte,
    );
  }

  // ─── ETF-DEPOT ACCUMULATION (savings phase only) ─────────────

  /// Run the ETF-Depot savings phase only.
  /// Vorabpauschale model (§18 InvStG):
  ///   • VP base = start-of-year depot (full year) + jb × NeuerBeitragFaktor
  ///     (6.5/12, the §18 partial-year average).
  ///   • VP cash is paid out of the depot as `vp_base × drag`.
  ///   • Cumulative VP is returned in `vorabpauschaleGesamt` for the payout
  ///     phase to credit against the sale tax (§19 Abs. 1 InvStG).
  ETFAccumulation simulateETFAccumulation({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    final jb = person.jahresbeitrag;
    final nettoRendite = macro.rendite - costs.kostenETF;
    // After-tax VP drag rate per §18 InvStG: pre-tax Basisertrag rate × taxable
    // share (Teilfreistellung) × Abgeltungssteuersatz. Pulled from CostSettings
    // so the rate is KiSt-aware (church-tax members pay slightly more).
    final vpRate = CalcConstants.vorabpauschaleBasisertragsRate
        * (1 - CalcConstants.teilfreistellung)
        * costs.abgeltungssteuersatz;

    double depot = 0;
    double eigenBeitraege = 0;
    double vorabpauschaleGesamt = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      final depotStartOfYear = depot;                            // held the full year (factor 1.0)
      depot = (depot + jb) * (1 + nettoRendite);                 // grow at full rate
      final vpBase = depotStartOfYear
          + jb * CalcConstants.vorabpauschaleNeuerBeitragFaktor;
      final vpJahr = vpBase * vpRate;
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

    return ETFAccumulation(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      vorabpauschaleGesamt: vorabpauschaleGesamt,
      jahresWerte: jahresWerte,
    );
  }

  // ─── COMBINED (accumulation + payout) ────────────────────────

  /// Full AV-Depot simulation: accumulation phase + payout phase.
  /// The payout module is `avPayout` (default: [AnnuityAVPayout]).
  AVResult simulateAV({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    final acc = simulateAVAccumulation(
        person: person, macro: macro, costs: costs, incomeDev: incomeDev);
    final pay = avPayout.compute(
      accumulation: acc,
      person: person,
      macro: macro,
      costs: costs,
      tax: tax,
      pension: pension,
      incomeDev: incomeDev,
    );
    return AVResult(
      endkapital: acc.endkapital,
      endkapitalReal: acc.endkapitalReal,
      eigenBeitraege: acc.eigenBeitraege,
      zulagenGesamt: acc.zulagenGesamt,
      steuererstattungGesamt: acc.steuererstattungGesamt,
      monatlicheAuszahlung: pay.monatlicheAuszahlung,
      nettoMonatlich: pay.nettoMonatlich,
      grenzsteuersatz: acc.grenzsteuersatz,
      grenzsteuersatzRente: pay.grenzsteuersatzRente,
      wertzuwachs: acc.wertzuwachs,
      jahresWerte: acc.jahresWerte,
    );
  }

  /// Full ETF-Depot simulation: accumulation phase + payout phase.
  /// The payout module is `etfPayout` (default: [AnnuityETFPayout]).
  ETFResult simulateETF({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    final acc = simulateETFAccumulation(person: person, macro: macro, costs: costs);
    final pay = etfPayout.compute(
        accumulation: acc, person: person, macro: macro, costs: costs);
    return ETFResult(
      endkapital: acc.endkapital,
      endkapitalReal: acc.endkapitalReal,
      eigenBeitraege: acc.eigenBeitraege,
      gewinn: acc.gewinn,
      vorabpauschaleGesamt: acc.vorabpauschaleGesamt,
      // Total lifetime tax = VP paid during accumulation + sale tax during payout.
      steuerAufGewinn: acc.vorabpauschaleGesamt + pay.lifetimeSaleTax,
      nachSteuer: pay.nachSteuer,
      bruttoMonatlich: pay.bruttoMonatlich,
      monatlicheAuszahlung: pay.monatlicheAuszahlung,
      effectiveTaxRatePayout: pay.effectiveTaxRatePayout,
      jahresWerte: acc.jahresWerte,
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
