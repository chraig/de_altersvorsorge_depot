import 'package:avdepot_rechner/services/domain/calculator_service.dart';

/// Interface for subsidy (Förderung) calculation.
/// Replace this to support different subsidy regimes or legislative changes.
abstract class SubsidyModule {
  /// Calculate all subsidies for one year.
  /// Returns individual amounts and total.
  ({double grund, double kind, double bonus, double gering, double total})
  calcZulage(double jahresbeitrag, int kinder, int alter, int bonusJahre, double brutto);
}

/// AV-Depot subsidies as defined by the Altersvorsorgereformgesetz (2027).
/// Implements Grundzulage, Kinderzulage, Berufseinsteigerbonus, Geringverdienerbonus.
class AVDepotSubsidy2027 implements SubsidyModule {
  const AVDepotSubsidy2027();

  /// Grundzulage: two-tier percentage match on own contributions.
  double calcGrundzulage(double jahresbeitrag) {
    final capped = jahresbeitrag < CalcConstants.grundzulageMaxBeitrag
        ? jahresbeitrag : CalcConstants.grundzulageMaxBeitrag;
    if (capped <= 0) return 0;
    final stufe1 = (capped < CalcConstants.grundzulageStufe1Cap ? capped : CalcConstants.grundzulageStufe1Cap)
        * CalcConstants.grundzulageStufe1Rate;
    final above = capped - CalcConstants.grundzulageStufe1Cap;
    final stufe2 = above > 0 ? above * CalcConstants.grundzulageStufe2Rate : 0.0;
    return stufe1 + stufe2;
  }

  /// Kinderzulage: 1:1 match on contributions up to max per child.
  double calcKinderzulage(double jahresbeitrag, int kinder) {
    if (kinder <= 0 || jahresbeitrag <= 0) return 0;
    final match = jahresbeitrag < CalcConstants.kinderzulageMax ? jahresbeitrag : CalcConstants.kinderzulageMax;
    return match * kinder;
  }

  /// Berufseinsteigerbonus: one-time bonus for young contract holders (year 1 only).
  double calcBonus(int alter, int bonusJahre) {
    return (alter < CalcConstants.bonusMaxAlter && bonusJahre == 0)
        ? CalcConstants.bonusBetrag : 0.0;
  }

  /// Geringverdienerbonus: extra subsidy for low-income earners.
  double calcGeringverdienerbonus(double brutto, double jahresbeitrag) {
    return (brutto <= CalcConstants.geringverdienerGrenze && jahresbeitrag >= CalcConstants.mindestbeitrag)
        ? CalcConstants.geringverdienerBetrag : 0.0;
  }

  @override
  ({double grund, double kind, double bonus, double gering, double total})
  calcZulage(double jahresbeitrag, int kinder, int alter, int bonusJahre, double brutto) {
    final grund = calcGrundzulage(jahresbeitrag);
    final kind = calcKinderzulage(jahresbeitrag, kinder);
    final bonus = calcBonus(alter, bonusJahre);
    final gering = calcGeringverdienerbonus(brutto, jahresbeitrag);
    return (grund: grund, kind: kind, bonus: bonus, gering: gering, total: grund + kind + bonus + gering);
  }
}
