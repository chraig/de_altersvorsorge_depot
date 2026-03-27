import 'dart:math';
import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';

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
  int kinder;                // [count] number of children eligible for Kindergeld
  int alterStart;            // [years] age at start of savings
  int spardauer;             // [years] savings duration (derived: retirementAge - startAge)
  double? gesetzlicheRenteOverride; // [EUR/month] manual override, null = auto-derive
  double sonstigeEinkuenfte;  // [EUR/year] other retirement income (rental, private pension etc.)
  bool isCustom;

  PersonalScenario({
    String? id,
    required this.name,
    required this.icon,
    required this.sparrate,
    required this.brutto,
    required this.kinder,
    required this.alterStart,
    required this.spardauer,
    this.gesetzlicheRenteOverride,
    this.sonstigeEinkuenfte = 0,
    this.isCustom = false,
  }) : id = id ?? _uuid.v4();

  PersonalScenario copyWith({
    String? name, String? icon, double? sparrate, double? brutto,
    int? kinder, int? alterStart, int? spardauer,
    double? gesetzlicheRenteOverride, bool clearRenteOverride = false,
    double? sonstigeEinkuenfte, bool? isCustom,
  }) => PersonalScenario(
    id: id, name: name ?? this.name, icon: icon ?? this.icon,
    sparrate: sparrate ?? this.sparrate, brutto: brutto ?? this.brutto,
    kinder: kinder ?? this.kinder, alterStart: alterStart ?? this.alterStart,
    spardauer: spardauer ?? this.spardauer,
    gesetzlicheRenteOverride: clearRenteOverride ? null : (gesetzlicheRenteOverride ?? this.gesetzlicheRenteOverride),
    sonstigeEinkuenfte: sonstigeEinkuenfte ?? this.sonstigeEinkuenfte,
    isCustom: isCustom ?? this.isCustom,
  );

  int get rentenalter => alterStart + spardauer;           // [years] retirement age
  double get jahresbeitrag => sparrate * 12;                // [EUR/year] annual contribution (input→core conversion)
  int get auszahlungsDauer => (CalcConstants.payoutEndAge - rentenalter).clamp(5, 30); // [years] payout phase

  /// Estimated monthly state pension derived from gross income.
  /// Formula: min(Brutto, BBG) / Durchschnittsentgelt × Beitragsjahre × Rentenwert
  /// BBG caps pensionable income; arbeitsbeginn assumed at 25 (conservative).
  double get geschaetzteRente {
    final beitragsjahre = (rentenalter - CalcConstants.arbeitsbeginn).clamp(0, 45);
    final cappedBrutto = brutto < CalcConstants.bbg ? brutto : CalcConstants.bbg;
    final entgeltpunkteProJahr = cappedBrutto / CalcConstants.durchschnittsentgelt;
    return entgeltpunkteProJahr * beitragsjahre * CalcConstants.rentenwert;
  }

  /// Effective monthly state pension: override if set, otherwise derived.
  double get gesetzlicheRente => gesetzlicheRenteOverride ?? geschaetzteRente;

  static List<PersonalScenario> defaults(AppStrings s) => [
    PersonalScenario(name: s.presetCareerStarter, icon: '\uD83C\uDF93', sparrate: 50, brutto: 32000, kinder: 0, alterStart: 23, spardauer: 44),
    PersonalScenario(name: s.presetSingleMid30, icon: '\uD83D\uDCBC', sparrate: 150, brutto: 55000, kinder: 0, alterStart: 35, spardauer: 32),
    PersonalScenario(name: s.presetFamily2Kids, icon: '\uD83D\uDC68\u200D\uD83D\uDC69\u200D\uD83D\uDC67\u200D\uD83D\uDC66', sparrate: 100, brutto: 45000, kinder: 2, alterStart: 32, spardauer: 35),
    PersonalScenario(name: s.presetHighEarner, icon: '\uD83D\uDCC8', sparrate: 500, brutto: 85000, kinder: 0, alterStart: 40, spardauer: 27),
    PersonalScenario(name: s.presetPartTimeChild, icon: '\uD83D\uDC76', sparrate: 50, brutto: 22000, kinder: 1, alterStart: 30, spardauer: 37),
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
// INCOME DEVELOPMENT
// ═══════════════════════════════════════════════════════════════════

class IncomeDevSettings {
  final bool enabled;
  final double growthRate; // annual growth, e.g. 0.02 = 2%

  const IncomeDevSettings({this.enabled = false, this.growthRate = 0.02});

  IncomeDevSettings copyWith({bool? enabled, double? growthRate}) =>
    IncomeDevSettings(
      enabled: enabled ?? this.enabled,
      growthRate: growthRate ?? this.growthRate,
    );

  /// Compute gross income for year j given a starting brutto.
  double bruttoForYear(double brutto, int j) {
    if (!enabled) return brutto;
    return brutto * pow(1 + growthRate, j);
  }
}

// ═══════════════════════════════════════════════════════════════════
// COST SETTINGS
// ═══════════════════════════════════════════════════════════════════

class CostSettings {
  double kostenAV;
  double kostenETF;
  double kirchensteuer; // 0.0 = none, 0.08 = Bayern/BaWü, 0.09 = other states

  CostSettings({this.kostenAV = 0.005, this.kostenETF = 0.002, this.kirchensteuer = 0.0});

  /// Abgeltungssteuer + Soli + optional Kirchensteuer.
  /// Formula per §32d Abs. 1 Satz 3 EStG: KapESt is reduced because
  /// Kirchensteuer is deductible from the tax base.
  /// KapESt = 25% / (1 + 25% × KiSt_rate)
  double get abgeltungssteuersatz {
    if (kirchensteuer == 0) return 0.26375;
    final kapEst = 0.25 / (1 + 0.25 * kirchensteuer);
    final soli = kapEst * 0.055;
    final kiSt = kapEst * kirchensteuer;
    return kapEst + soli + kiSt;
  }

  CostSettings copyWith({double? kostenAV, double? kostenETF, double? kirchensteuer}) =>
    CostSettings(
      kostenAV: kostenAV ?? this.kostenAV,
      kostenETF: kostenETF ?? this.kostenETF,
      kirchensteuer: kirchensteuer ?? this.kirchensteuer,
    );
}

// ═══════════════════════════════════════════════════════════════════
// SUBSIDY (ZULAGE) BREAKDOWN
// ═══════════════════════════════════════════════════════════════════

/// All values are per year (matching German subsidy law).
class SubsidyBreakdown {
  final double grundzulage;        // [EUR/year]
  final double kinderzulage;       // [EUR/year]
  final double bonus;              // [EUR/year] (one-time, only in year 1)
  final double geringverdienerbonus; // [EUR/year]
  final double total;              // [EUR/year] sum of all subsidies
  final double foerderquote;       // [ratio] total / jahresbeitrag
  final double steuererstattung;   // [EUR/year] Günstigerprüfung refund (NOT in depot)
  final double grenzsteuersatz;    // [ratio] marginal tax rate

  const SubsidyBreakdown({
    required this.grundzulage,
    required this.kinderzulage,
    required this.bonus,
    required this.geringverdienerbonus,
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
/// Accumulation in yearly steps; payout converted to monthly at output boundary.
class ETFResult {
  final double endkapital;            // [EUR] gross depot value at retirement
  final double endkapitalReal;        // [EUR] inflation-adjusted depot value
  final double eigenBeitraege;        // [EUR] cumulative own contributions
  final double gewinn;                // [EUR] total gains (endkapital - eigenBeitraege)
  final double steuerAufGewinn;       // [EUR] Abgeltungssteuer on gains (after Teilfreistellung)
  final double nachSteuer;            // [EUR] depot value after tax
  final double monatlicheAuszahlung;  // [EUR/month] net monthly payout (core→output conversion)
  final List<YearlyDataPoint> jahresWerte;

  const ETFResult({
    required this.endkapital,
    required this.endkapitalReal,
    required this.eigenBeitraege,
    required this.gewinn,
    required this.steuerAufGewinn,
    required this.nachSteuer,
    required this.monatlicheAuszahlung,
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
