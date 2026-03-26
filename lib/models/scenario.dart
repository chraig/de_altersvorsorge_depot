import 'package:flutter/material.dart';
import 'package:uuid/uuid.dart';
import '../core/l10n/app_strings.dart';

const _uuid = Uuid();

// ═══════════════════════════════════════════════════════════════════
// PERSONAL SCENARIO
// ═══════════════════════════════════════════════════════════════════

class PersonalScenario {
  final String id;
  String name;
  String icon;
  double sparrate;    // monthly
  double brutto;      // yearly gross
  int kinder;
  int alterStart;
  int spardauer;
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
    this.isCustom = false,
  }) : id = id ?? _uuid.v4();

  PersonalScenario copyWith({
    String? name, String? icon, double? sparrate, double? brutto,
    int? kinder, int? alterStart, int? spardauer, bool? isCustom,
  }) => PersonalScenario(
    id: id, name: name ?? this.name, icon: icon ?? this.icon,
    sparrate: sparrate ?? this.sparrate, brutto: brutto ?? this.brutto,
    kinder: kinder ?? this.kinder, alterStart: alterStart ?? this.alterStart,
    spardauer: spardauer ?? this.spardauer, isCustom: isCustom ?? this.isCustom,
  );

  int get rentenalter => alterStart + spardauer;
  double get jahresbeitrag => sparrate * 12;

  static List<PersonalScenario> defaults(AppStrings s) => [
    PersonalScenario(name: s.presetCareerStarter, icon: '\uD83C\uDF93', sparrate: 50, brutto: 32000, kinder: 0, alterStart: 23, spardauer: 42),
    PersonalScenario(name: s.presetSingleMid30, icon: '\uD83D\uDCBC', sparrate: 150, brutto: 55000, kinder: 0, alterStart: 35, spardauer: 32),
    PersonalScenario(name: s.presetFamily2Kids, icon: '\uD83D\uDC68\u200D\uD83D\uDC69\u200D\uD83D\uDC67\u200D\uD83D\uDC66', sparrate: 100, brutto: 45000, kinder: 2, alterStart: 32, spardauer: 35),
    PersonalScenario(name: s.presetHighEarner, icon: '\uD83D\uDCC8', sparrate: 150, brutto: 85000, kinder: 0, alterStart: 40, spardauer: 27),
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
// COST SETTINGS
// ═══════════════════════════════════════════════════════════════════

class CostSettings {
  double kostenAV;
  double kostenETF;

  CostSettings({this.kostenAV = 0.005, this.kostenETF = 0.002});

  CostSettings copyWith({double? kostenAV, double? kostenETF}) =>
    CostSettings(kostenAV: kostenAV ?? this.kostenAV, kostenETF: kostenETF ?? this.kostenETF);
}

// ═══════════════════════════════════════════════════════════════════
// SUBSIDY (ZULAGE) BREAKDOWN
// ═══════════════════════════════════════════════════════════════════

class SubsidyBreakdown {
  final double grundzulage;
  final double kinderzulage;
  final double bonus;
  final double total;
  final double foerderquote;
  final double steuererstattung;
  final double grenzsteuersatz;

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

class YearlyDataPoint {
  final int year;
  final int alter;
  final double depot;
  final double depotReal;
  final double eigenBeitraege;
  final double zulagen;
  final double zulageJahr;

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

class AVResult {
  final double endkapital;
  final double endkapitalReal;
  final double eigenBeitraege;
  final double zulagenGesamt;
  final double steuererstattungGesamt;
  final double monatlicheAuszahlung;
  final double nettoMonatlich;
  final double grenzsteuersatz;
  final double wertzuwachs;
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
    required this.wertzuwachs,
    required this.jahresWerte,
  });
}

class ETFResult {
  final double endkapital;
  final double endkapitalReal;
  final double eigenBeitraege;
  final double gewinn;
  final double steuerAufGewinn;
  final double nachSteuer;
  final double monatlicheAuszahlung;
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
