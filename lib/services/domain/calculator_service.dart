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
/// - Tax brackets: §32a EStG (2024 values — update when 2027 brackets published by BMF)
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

  // ─── KINDERZULAGE (§89 Abs. 2 EStG-E) ─────────────────────────
  /// Max €300 per child per year, 1:1 match on own contributions
  static const double kinderzulageMax = 300.0;

  // ─── BERUFSEINSTEIGERBONUS (§89 Abs. 3 EStG-E) ────────────────
  /// One-time bonus for career starters (first year of contract only).
  /// Source: BMF FAQ — "einmalig 200 Euro"
  static const double bonusBetrag = 200.0;
  /// Must be under this age at contract start to qualify
  static const int bonusMaxAlter = 25;

  // ─── GERINGVERDIENERBONUS (§89 Abs. 4 EStG-E) ─────────────────
  /// Extra yearly subsidy for low-income earners
  static const double geringverdienerBetrag = 175.0;
  /// Gross income threshold: only eligible at or below this
  static const double geringverdienerGrenze = 26250.0;
  /// Minimum annual contribution required for any subsidy
  static const double mindestbeitrag = 120.0;

  // ─── INCOME TAX BRACKETS (§32a EStG, 2024 values) ─────────────
  /// Grundfreibetrag: no tax below this (tax-free allowance)
  static const double grundfreibetrag = 11784;
  /// End of entry zone: 14% flat rate up to this threshold
  static const double zone2Ende = 17005;
  /// Entry tax rate (Eingangssteuersatz)
  static const double zone2Satz = 0.14;
  /// End of progressive zone: rate rises linearly from zone2Satz to Spitzensteuersatz
  static const double zone3Ende = 66760;
  /// Start rate of progressive zone (interpolated from §32a formula)
  static const double zone3StartSatz = 0.2397;
  /// Top rate for income up to zone4Ende
  static const double spitzensteuersatz = 0.42;
  /// Threshold for Reichensteuersatz (super-rich rate)
  static const double zone4Ende = 277825;
  /// Top marginal rate above zone4Ende
  static const double reichensteuersatz = 0.45;

  // ─── ETF TAXATION (§20 InvStG, §43a EStG) ─────────────────────
  /// Partial exemption for equity funds (≥51% equity): 30% of gains tax-free
  static const double teilfreistellung = 0.30;
  /// Simplified annual Vorabpauschale drag on ETF returns.
  /// Reality: depends on Basiszins (ECB reference rate × 0.7). This is an approximation.
  static const double vorabpauschaleDrag = 0.002;

  // ─── PAYOUT PHASE ─────────────────────────────────────────────
  /// Auszahlplan must run until this age (§89 Abs. 8 EStG-E)
  static const int payoutEndAge = 85;

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
// SIMULATION ENGINE
// ═══════════════════════════════════════════════════════════════════

/// Simulation engine with injectable modules.
///
/// Each module (tax, subsidy, pension) can be replaced independently:
/// ```dart
/// final engine = SimulationEngine(
///   tax: GermanTax2024(),          // or a custom/updated implementation
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
    this.tax = const GermanTax2024(),
    this.subsidy = const AVDepotSubsidy2027(),
    this.pension = const EntgeltpunkteEstimator(),
  });

  /// Default engine with standard modules.
  static const standard = SimulationEngine();

  // ─── SUBSIDY BREAKDOWN (for UI display) ────────────────────────

  /// Full subsidy breakdown for year 1.
  SubsidyBreakdown calcSubsidyBreakdown(PersonalScenario person) {
    final jb = person.jahresbeitrag;
    final z = subsidy.calcZulage(jb, person.kinder, person.alterStart, 0, person.brutto);
    final gst = tax.getGrenzsteuersatz(person.brutto);
    final gp = tax.calcGuenstigerpruefung(jb, z.total, gst);
    final fq = jb > 0 ? z.total / jb : 0.0;
    return SubsidyBreakdown(
      grundzulage: z.grund,
      kinderzulage: z.kind,
      bonus: z.bonus,
      geringverdienerbonus: z.gering,
      total: z.total,
      foerderquote: fq,
      steuererstattung: gp.zusaetzlich,
      grenzsteuersatz: gst,
    );
  }

  // ─── AV-DEPOT SIMULATION ──────────────────────────────────────

  AVResult simulateAV({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    final jb = person.jahresbeitrag;
    final nettoRendite = macro.rendite - costs.kostenAV;

    // ── Accumulation phase ──────────────────────────────────────
    double depot = 0;
    double eigenBeitraege = 0;
    double zulagenGesamt = 0;
    double steuererstattungGesamt = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      final alter = person.alterStart + j;
      final bruttoJ = incomeDev.bruttoForYear(person.brutto, j);
      final gstJ = tax.getGrenzsteuersatz(bruttoJ);
      final z = subsidy.calcZulage(jb, person.kinder, alter, j, bruttoJ);
      final gp = tax.calcGuenstigerpruefung(jb, z.total, gstJ);

      final zufluss = jb + z.total;
      depot = (depot + zufluss) * (1 + nettoRendite);

      eigenBeitraege += jb;
      zulagenGesamt += z.total;
      steuererstattungGesamt += gp.zusaetzlich;

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
    final auszahlungsDauer = person.auszahlungsDauer;
    final monatlich = depot / (auszahlungsDauer * 12);

    // ── Retirement tax on combined income ───────────────────────
    final effectiveRente = pension.estimateMonthlyPension(person, incomeDev);
    final avJahresAuszahlung = depot / auszahlungsDauer;
    final rentenEinkommen = avJahresAuszahlung
        + effectiveRente * 12
        + person.sonstigeEinkuenfte;
    final gstRente = tax.getGrenzsteuersatz(rentenEinkommen);
    final kirchensteuerFaktor = 1 + costs.kirchensteuer;
    final netto = monatlich * (1 - gstRente * kirchensteuerFaktor);

    return AVResult(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      zulagenGesamt: zulagenGesamt,
      steuererstattungGesamt: steuererstattungGesamt,
      monatlicheAuszahlung: monatlich,
      nettoMonatlich: netto,
      grenzsteuersatz: tax.getGrenzsteuersatz(person.brutto),
      grenzsteuersatzRente: gstRente,
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
    final nettoRendite = macro.rendite - costs.kostenETF - CalcConstants.vorabpauschaleDrag;

    // ── Accumulation phase ──────────────────────────────────────
    double depot = 0;
    double eigenBeitraege = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      depot = (depot + jb) * (1 + nettoRendite);
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

    // ── Payout phase: tax on gains only ─────────────────────────
    final gewinn = depot - eigenBeitraege;
    final steuerpflichtigerGewinn = gewinn * (1 - CalcConstants.teilfreistellung);
    final steuer = steuerpflichtigerGewinn * costs.abgeltungssteuersatz;
    final nachSteuer = depot - steuer;

    final auszahlungsDauer = person.auszahlungsDauer;
    final monatlich = nachSteuer / (auszahlungsDauer * 12);

    return ETFResult(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      gewinn: gewinn,
      steuerAufGewinn: steuer,
      nachSteuer: nachSteuer,
      monatlicheAuszahlung: monatlich,
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

// ═══════════════════════════════════════════════════════════════════
// BACKWARD COMPATIBILITY — static access via CalculatorService
// ═══════════════════════════════════════════════════════════════════

/// Static facade over [SimulationEngine.standard] for backward compatibility.
/// Existing code using `CalculatorService.simulateAV(...)` continues to work.
class CalculatorService {
  CalculatorService._();

  static final _engine = SimulationEngine.standard;

  static SubsidyBreakdown calcSubsidyBreakdown(PersonalScenario person) =>
      _engine.calcSubsidyBreakdown(person);

  static AVResult simulateAV({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) => _engine.simulateAV(person: person, macro: macro, costs: costs, incomeDev: incomeDev);

  static ETFResult simulateETF({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) => _engine.simulateETF(person: person, macro: macro, costs: costs);

  static CombinedResult simulateCombined({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) => _engine.simulateCombined(person: person, macro: macro, costs: costs, incomeDev: incomeDev);

  static List<CombinedResult> simulateAllMacros({
    required PersonalScenario person,
    required List<MacroScenario> macros,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) => _engine.simulateAllMacros(person: person, macros: macros, costs: costs, incomeDev: incomeDev);

  /// Direct access to the tax module (for UI display of Grenzsteuersatz).
  static double getGrenzsteuersatz(double brutto) => _engine.tax.getGrenzsteuersatz(brutto);
}
