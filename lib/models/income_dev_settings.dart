import 'dart:math';

/// Growth curve types for income development modeling.
enum GrowthCurve { linear, stepwise, logarithmic }

/// Income development settings — models how gross income changes over
/// the savings period. Opt-in: when [enabled] is false, all methods
/// return static values (no growth, no part-time, no child timing).
///
/// This is a modeling module — it makes no assumptions about legislation.
/// The simulation engine uses [bruttoForYear] and [kinderAtYear] as its
/// only interface to this module.
class IncomeDevSettings {
  final bool enabled;
  final GrowthCurve curve;
  final double growthRate;        // [ratio] annual compound growth (linear/logarithmic)
  final int promotionInterval;    // [years] promotion every N years (stepwise)
  final double promotionIncrease; // [ratio] salary jump per promotion (stepwise)
  final double salaryCap;         // [EUR/year] income ceiling for logarithmic curve
  final int? partTimeStartYear;   // [year index] when part-time begins (null = none)
  final int partTimeDuration;     // [years] how long part-time lasts
  final double partTimePercent;   // [ratio] income factor during part-time (e.g. 0.5 = 50%)
  final List<int> childArrivalYears; // [year indices] when each child arrives

  const IncomeDevSettings({
    this.enabled = false,
    this.curve = GrowthCurve.linear,
    this.growthRate = 0.02,
    this.promotionInterval = 5,
    this.promotionIncrease = 0.15,
    this.salaryCap = 90000,
    this.partTimeStartYear,
    this.partTimeDuration = 0,
    this.partTimePercent = 0.5,
    this.childArrivalYears = const [],
  });

  IncomeDevSettings copyWith({
    bool? enabled, GrowthCurve? curve, double? growthRate,
    int? promotionInterval, double? promotionIncrease, double? salaryCap,
    int? partTimeStartYear, bool clearPartTime = false,
    int? partTimeDuration, double? partTimePercent,
    List<int>? childArrivalYears,
  }) => IncomeDevSettings(
    enabled: enabled ?? this.enabled,
    curve: curve ?? this.curve,
    growthRate: growthRate ?? this.growthRate,
    promotionInterval: promotionInterval ?? this.promotionInterval,
    promotionIncrease: promotionIncrease ?? this.promotionIncrease,
    salaryCap: salaryCap ?? this.salaryCap,
    partTimeStartYear: clearPartTime ? null : (partTimeStartYear ?? this.partTimeStartYear),
    partTimeDuration: partTimeDuration ?? this.partTimeDuration,
    partTimePercent: partTimePercent ?? this.partTimePercent,
    childArrivalYears: childArrivalYears ?? this.childArrivalYears,
  );

  /// Compute gross income for savings year [j] given starting [brutto].
  /// Applies growth curve first, then part-time reduction if active.
  double bruttoForYear(double brutto, int j) {
    if (!enabled) return brutto;

    double base;
    switch (curve) {
      case GrowthCurve.linear:
        base = brutto * pow(1 + growthRate, j);
      case GrowthCurve.stepwise:
        final promotions = promotionInterval > 0 ? j ~/ promotionInterval : 0;
        base = brutto * pow(1 + promotionIncrease, promotions);
      case GrowthCurve.logarithmic:
        base = brutto + (salaryCap - brutto) * (1 - 1 / (1 + 0.1 * j));
    }

    if (partTimeStartYear != null && partTimeDuration > 0) {
      if (j >= partTimeStartYear! && j < partTimeStartYear! + partTimeDuration) {
        base *= partTimePercent;
      }
    }

    return base;
  }

  /// Number of kindergeldberechtigt children at savings year [j].
  /// Accounts for:
  /// - Base children aging out (age at start + j >= maxAge → no longer eligible)
  /// - Dynamic children arriving and eventually aging out
  /// [baseKinder]: number of existing children
  /// [kinderAlter]: ages of existing children at savings start (empty = assume age 0)
  /// [maxAge]: Kindergeld ends at this age (default 25)
  int kinderAtYear(int baseKinder, int j, {List<int> kinderAlter = const [], int maxAge = 25}) {
    // Count base children still eligible
    int eligible = 0;
    if (baseKinder > 0) {
      for (int i = 0; i < baseKinder; i++) {
        final ageAtStart = i < kinderAlter.length ? kinderAlter[i] : 0;
        final ageAtYearJ = ageAtStart + j;
        if (ageAtYearJ < maxAge) eligible++;
      }
    }

    // Count dynamic children (from childArrivalYears) still eligible
    if (enabled) {
      for (final arrivalYear in childArrivalYears) {
        if (j >= arrivalYear) {
          final childAge = j - arrivalYear; // born at arrival year
          if (childAge < maxAge) eligible++;
        }
      }
    }

    return eligible;
  }

  bool get hasPartTime => partTimeStartYear != null && partTimeDuration > 0;
  bool get hasChildTiming => childArrivalYears.isNotEmpty;
}
