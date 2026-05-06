import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';

export 'package:avdepot_rechner/models/income_dev_settings.dart';

const _uuid = Uuid();

// ═══════════════════════════════════════════════════════════════════
// PERSONAL SCENARIO
// ═══════════════════════════════════════════════════════════════════

class PersonalScenario {
  final String id;
  String name;
  String icon;
  double sparrate;           // [EUR/month] monthly savings contribution
  double brutto;             // [EUR/year] yearly gross income
  int kinder;                // [count] number of existing children at savings start
  List<int> kinderAlter;     // [years] age of each existing child at savings start (empty = assume age 0)
  bool kinderStudieren;      // true = Kindergeld until 25 (education), false = until 18
  int alterStart;            // [years] age at start of savings
  int spardauer;             // [years] savings duration (derived: retirementAge - startAge)
  double? gesetzlicheRenteOverride; // [EUR/month] manual override, null = auto-derive
  double sonstigeEinkuenfte;  // [EUR/year] other retirement income (rental, private pension etc.)
  int arbeitsbeginn;          // [years] age when started paying into Rentenversicherung
  bool isCustom;

  PersonalScenario({
    String? id,
    required this.name,
    required this.icon,
    required this.sparrate,
    required this.brutto,
    required this.kinder,
    this.kinderAlter = const [],
    this.kinderStudieren = true,
    required this.alterStart,
    required this.spardauer,
    this.gesetzlicheRenteOverride,
    this.sonstigeEinkuenfte = 0,
    this.arbeitsbeginn = 25,
    this.isCustom = false,
  }) : id = id ?? _uuid.v4();

  PersonalScenario copyWith({
    String? name, String? icon, double? sparrate, double? brutto,
    int? kinder, List<int>? kinderAlter, bool? kinderStudieren, int? alterStart, int? spardauer,
    double? gesetzlicheRenteOverride, bool clearRenteOverride = false,
    double? sonstigeEinkuenfte, int? arbeitsbeginn, bool? isCustom,
  }) => PersonalScenario(
    id: id, name: name ?? this.name, icon: icon ?? this.icon,
    sparrate: sparrate ?? this.sparrate, brutto: brutto ?? this.brutto,
    kinder: kinder ?? this.kinder, kinderAlter: kinderAlter ?? this.kinderAlter,
    kinderStudieren: kinderStudieren ?? this.kinderStudieren,
    alterStart: alterStart ?? this.alterStart,
    spardauer: spardauer ?? this.spardauer,
    gesetzlicheRenteOverride: clearRenteOverride ? null : (gesetzlicheRenteOverride ?? this.gesetzlicheRenteOverride),
    sonstigeEinkuenfte: sonstigeEinkuenfte ?? this.sonstigeEinkuenfte,
    arbeitsbeginn: arbeitsbeginn ?? this.arbeitsbeginn,
    isCustom: isCustom ?? this.isCustom,
  );

  int get rentenalter => alterStart + spardauer;           // [years] retirement age
  double get jahresbeitrag => sparrate * 12;                // [EUR/year] annual contribution (input→core conversion)
  int get auszahlungsDauer => (CalcConstants.payoutEndAge - rentenalter).clamp(5, 30); // [years] payout phase
  /// Kindergeld eligibility ends at age 18 normally, or 25 if the child is
  /// in education / vocational training (§32 Abs. 4 EStG).
  int get maxKindergeldAlter => kinderStudieren ? 25 : 18;

  /// Annual contribution capped at the per-contract maximum (€6,840/yr).
  /// Contributions above this aren't allowed in the AV-Depot.
  double get jahresbeitragCapped => min(jahresbeitrag, CalcConstants.maxBeitragProVertrag);

  /// Subsidized portion of the annual contribution (≤ €1,800/yr).
  double get jahresbeitragGefoerdert =>
      min(jahresbeitragCapped, CalcConstants.grundzulageMaxBeitrag);

  /// Unsubsidized portion: the slice between €1,800 and the per-contract cap.
  double get jahresbeitragUngefoerdert =>
      jahresbeitragCapped - jahresbeitragGefoerdert;

  /// Estimated monthly state pension derived from gross income.
  /// Formula: min(Brutto, BBG) / Durchschnittsentgelt × Beitragsjahre × Rentenwert
  /// BBG caps pensionable income.
  double get geschaetzteRente {
    final beitragsjahre = (rentenalter - arbeitsbeginn).clamp(0, 45);
    final cappedBrutto = min(brutto, CalcConstants.bbg);
    final entgeltpunkteProJahr = cappedBrutto / CalcConstants.durchschnittsentgelt;
    return entgeltpunkteProJahr * beitragsjahre * CalcConstants.rentenwert;
  }

  /// Effective monthly state pension: override if set, otherwise derived.
  double get gesetzlicheRente => gesetzlicheRenteOverride ?? geschaetzteRente;

  static List<PersonalScenario> defaults(AppStrings s) => [
    PersonalScenario(name: s.presetCareerStarter, icon: '\uD83C\uDF93', sparrate: 50, brutto: 32000, kinder: 0, alterStart: 23, spardauer: 44),
    PersonalScenario(name: s.presetSingleMid30, icon: '\uD83D\uDCBC', sparrate: 150, brutto: 55000, kinder: 0, alterStart: 35, spardauer: 32),
    PersonalScenario(name: s.presetFamily2Kids, icon: '\uD83D\uDC68\u200D\uD83D\uDC69\u200D\uD83D\uDC67\u200D\uD83D\uDC66', sparrate: 100, brutto: 45000, kinder: 2, kinderAlter: [3, 5], alterStart: 32, spardauer: 35),
    PersonalScenario(name: s.presetHighEarner, icon: '\uD83D\uDCC8', sparrate: 500, brutto: 85000, kinder: 0, alterStart: 40, spardauer: 27),
    PersonalScenario(name: s.presetPartTimeChild, icon: '\uD83D\uDC76', sparrate: 50, brutto: 22000, kinder: 1, kinderAlter: [1], alterStart: 30, spardauer: 37),
  ];
}

// ═══════════════════════════════════════════════════════════════════
// MACRO SCENARIO
// ═══════════════════════════════════════════════════════════════════

class MacroScenario {
  final String id;
  String name;
  String shortName;
  String icon;
  String description;
  double rendite;    // annual return
  double inflation;  // annual inflation
  Color color;
  bool isCustom;

  MacroScenario({
    String? id,
    required this.name,
    required this.shortName,
    required this.icon,
    required this.description,
    required this.rendite,
    required this.inflation,
    required this.color,
    this.isCustom = false,
  }) : id = id ?? _uuid.v4();

  MacroScenario copyWith({
    String? name, String? shortName, String? icon, String? description,
    double? rendite, double? inflation, Color? color, bool? isCustom,
  }) => MacroScenario(
    id: id, name: name ?? this.name, shortName: shortName ?? this.shortName,
    icon: icon ?? this.icon, description: description ?? this.description,
    rendite: rendite ?? this.rendite, inflation: inflation ?? this.inflation,
    color: color ?? this.color, isCustom: isCustom ?? this.isCustom,
  );

  double get realRendite => rendite - inflation;

  static List<MacroScenario> defaults(AppStrings s) => [
    MacroScenario(name: s.macroBoomName, shortName: s.macroBoomShort, icon: '\uD83D\uDE80',
      description: s.macroBoomDesc,
      rendite: 0.10, inflation: 0.015, color: const Color(0xFF10B981)),
    MacroScenario(name: s.macroBaselineName, shortName: s.macroBaselineShort, icon: '\uD83D\uDCCA',
      description: s.macroBaselineDesc,
      rendite: 0.07, inflation: 0.02, color: const Color(0xFF0066FF)),
    MacroScenario(name: s.macroModerateName, shortName: s.macroModerateShort, icon: '\u2696\uFE0F',
      description: s.macroModerateDesc,
      rendite: 0.05, inflation: 0.025, color: const Color(0xFFF59E0B)),
    MacroScenario(name: s.macroStagflationName, shortName: s.macroStagflationShort, icon: '\uD83D\uDD25',
      description: s.macroStagflationDesc,
      rendite: 0.04, inflation: 0.045, color: const Color(0xFFEF4444)),
    MacroScenario(name: s.macroJapanName, shortName: s.macroJapanShort, icon: '\uD83C\uDDEF\uD83C\uDDF5',
      description: s.macroJapanDesc,
      rendite: 0.02, inflation: 0.005, color: const Color(0xFF8B5CF6)),
    MacroScenario(name: s.macroLostDecadeName, shortName: s.macroLostDecadeShort, icon: '\uD83D\uDCA5',
      description: s.macroLostDecadeDesc,
      rendite: 0.03, inflation: 0.02, color: const Color(0xFF6B7280)),
  ];
}

// ═══════════════════════════════════════════════════════════════════
// UNGEFÖRDERT TAX TREATMENT
// ═══════════════════════════════════════════════════════════════════

// ═══════════════════════════════════════════════════════════════════
// COST SETTINGS
// ═══════════════════════════════════════════════════════════════════

class CostSettings {
  double kostenAV;
  double kostenETF;
  /// Whether the user is liable for Kirchensteuer. The rate is fixed at
  /// `CalcConstants.kirchensteuersatz` (9%, the dominant rate in Germany).
  bool kirchensteuerpflichtig;

  CostSettings({
    this.kostenAV = 0.005,
    this.kostenETF = 0.002,
    this.kirchensteuerpflichtig = false,
  });

  /// Effective Kirchensteuersatz: 9% if liable, 0 otherwise.
  double get kirchensteuerRate =>
      kirchensteuerpflichtig ? CalcConstants.kirchensteuersatz : 0.0;

  /// Abgeltungssteuer + Soli + optional Kirchensteuer.
  ///
  /// Formula per §32d Abs. 1 Sätze 4–5 EStG: when Kirchensteuer applies, the
  /// KapESt itself is reduced because the KiSt paid on the Kapitalertrag is
  /// deductible from the KapESt base. The law states:
  ///
  ///     Steuer = (e − 4q) / (4 + k)        // §32d Abs. 1 Satz 4 EStG
  ///
  /// where e = Einnahmen (capital income), q = anrechenbare ausländische
  /// Quellensteuer, k = Kirchensteuersatz. Foreign withholding tax (q) is
  /// not modeled by this calculator — we cannot meaningfully estimate it
  /// without per-fund detail — so the formula reduces to KapESt = e × 1/(4+k).
  /// Soli (5.5% of KapESt) and KiSt (k × KapESt) are then added on top.
  ///
  /// Total Abgeltungssteuersatz = 1/(4+k) × (1 + 0.055 + k)
  ///   k = 0.00:  0.25      × 1.055 = 26.3750%
  ///   k = 0.09:  0.244499… × 1.145 = 27.9951%
  double get abgeltungssteuersatz {
    if (!kirchensteuerpflichtig) return 0.26375;
    final k = CalcConstants.kirchensteuersatz;
    final kapEst = 1 / (4 + k);                    // §32d Abs. 1 Satz 4 EStG (q=0)
    final soli = kapEst * 0.055;
    final kiSt = kapEst * k;
    return kapEst + soli + kiSt;
  }

  CostSettings copyWith({double? kostenAV, double? kostenETF, bool? kirchensteuerpflichtig}) =>
    CostSettings(
      kostenAV: kostenAV ?? this.kostenAV,
      kostenETF: kostenETF ?? this.kostenETF,
      kirchensteuerpflichtig: kirchensteuerpflichtig ?? this.kirchensteuerpflichtig,
    );
}

// ═══════════════════════════════════════════════════════════════════
// SUBSIDY (ZULAGE) BREAKDOWN
// ═══════════════════════════════════════════════════════════════════

/// A phase of consecutive years with identical subsidy components.
class SubsidyPhase {
  final int yearFrom;   // [1-based] first year of this phase
  final int yearTo;     // [1-based] last year of this phase
  final int kinder;     // eligible children in this phase
  final double grundzulage;
  final double kinderzulage;
  final double bonus;
  final double total;
  final double steuererstattung;

  const SubsidyPhase({
    required this.yearFrom, required this.yearTo,
    required this.kinder, required this.grundzulage, required this.kinderzulage,
    required this.bonus, required this.total,
    required this.steuererstattung,
  });

  int get years => yearTo - yearFrom + 1;
}

/// All values are per year (matching German subsidy law).
class SubsidyBreakdown {
  final double grundzulage;        // [EUR/year]
  final double kinderzulage;       // [EUR/year]
  final double bonus;              // [EUR/year] (one-time, only in year 1)
  final double total;              // [EUR/year] sum of all subsidies
  final double foerderquote;       // [ratio] total / jahresbeitrag
  final double steuererstattung;   // [EUR/year] Günstigerprüfung refund (NOT in depot)
  final double grenzsteuersatz;    // [ratio] marginal tax rate

  const SubsidyBreakdown({
    required this.grundzulage,
    required this.kinderzulage,
    required this.bonus,
    required this.total,
    required this.foerderquote,
    required this.steuererstattung,
    required this.grenzsteuersatz,
  });
}

// ═══════════════════════════════════════════════════════════════════
// YEARLY DATA POINT
// ═══════════════════════════════════════════════════════════════════

/// Snapshot of depot state at end of each savings year.
class YearlyDataPoint {
  final int year;              // [count] savings year (1-based)
  final int alter;             // [years] age at end of this year
  final double depot;          // [EUR] nominal depot value
  final double depotReal;      // [EUR] inflation-adjusted depot value
  final double eigenBeitraege; // [EUR] cumulative own contributions
  final double zulagen;        // [EUR] cumulative subsidies
  final double zulageJahr;     // [EUR/year] subsidy received this year

  const YearlyDataPoint({
    required this.year,
    required this.alter,
    required this.depot,
    required this.depotReal,
    required this.eigenBeitraege,
    required this.zulagen,
    required this.zulageJahr,
  });
}

// ═══════════════════════════════════════════════════════════════════
// SIMULATION RESULTS
// ═══════════════════════════════════════════════════════════════════

/// AV-Depot simulation result.
/// Accumulation in yearly steps; payout converted to monthly at output boundary.
class AVResult {
  final double endkapital;            // [EUR] gross depot value at retirement
  final double endkapitalReal;        // [EUR] inflation-adjusted depot value
  final double eigenBeitraege;        // [EUR] cumulative own contributions
  final double zulagenGesamt;         // [EUR] cumulative subsidies (in depot)
  final double steuererstattungGesamt; // [EUR] cumulative Günstigerprüfung refunds (NOT in depot)
  final double monatlicheAuszahlung;  // [EUR/month] gross monthly payout (core→output conversion)
  final double nettoMonatlich;        // [EUR/month] net monthly payout after retirement tax
  final double grenzsteuersatz;       // [ratio] marginal tax rate during working life
  final double grenzsteuersatzRente;  // [ratio] marginal tax rate on combined retirement income
  final double wertzuwachs;           // [EUR] capital gains (endkapital - eigen - zulagen)
  final List<YearlyDataPoint> jahresWerte;

  const AVResult({
    required this.endkapital,
    required this.endkapitalReal,
    required this.eigenBeitraege,
    required this.zulagenGesamt,
    required this.steuererstattungGesamt,
    required this.monatlicheAuszahlung,
    required this.nettoMonatlich,
    required this.grenzsteuersatz,
    required this.grenzsteuersatzRente,
    required this.wertzuwachs,
    required this.jahresWerte,
  });
}

/// ETF-Depot simulation result.
/// Accumulation in yearly steps; payout uses monthly annuity compounding.
class ETFResult {
  final double endkapital;            // [EUR] depot value at retirement (after Vorabpauschale debits during accumulation)
  final double endkapitalReal;        // [EUR] inflation-adjusted depot value
  final double eigenBeitraege;        // [EUR] cumulative own contributions
  final double gewinn;                // [EUR] gain accumulated up to retirement (endkapital - eigenBeitraege)
  final double vorabpauschaleGesamt;  // [EUR] cumulative Vorabpauschale paid during accumulation
  final double steuerAufGewinn;       // [EUR] total lifetime tax burden = vorabpauschaleGesamt + sale tax during payout
  final double nachSteuer;            // [EUR] lifetime cash-in-hand to user (= monatlicheAuszahlung × n_months)
  final double bruttoMonatlich;       // [EUR/month] gross monthly payout from annuity formula (before lifetime sale tax)
  final double monatlicheAuszahlung;  // [EUR/month] net monthly payout (after lifetime sale tax spread evenly)
  final double effectiveTaxRatePayout; // [ratio] per-month tax rate on gross payout (= lifetimeSaleTax / lifetimeGross). Constant under flat Abgeltungssteuer.
  final List<YearlyDataPoint> jahresWerte;

  const ETFResult({
    required this.endkapital,
    required this.endkapitalReal,
    required this.eigenBeitraege,
    required this.gewinn,
    required this.vorabpauschaleGesamt,
    required this.steuerAufGewinn,
    required this.nachSteuer,
    required this.bruttoMonatlich,
    required this.monatlicheAuszahlung,
    required this.effectiveTaxRatePayout,
    required this.jahresWerte,
  });
}

// ═══════════════════════════════════════════════════════════════════
// COMBINED RESULT (for compound table)
// ═══════════════════════════════════════════════════════════════════

class CombinedResult {
  final MacroScenario macro;
  final AVResult av;
  final ETFResult etf;

  const CombinedResult({required this.macro, required this.av, required this.etf});

  double get deltaEndkapital => av.endkapital - etf.endkapital;
  double get deltaMonatlich => av.nettoMonatlich - etf.monatlicheAuszahlung;
}
