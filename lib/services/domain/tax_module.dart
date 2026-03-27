import 'package:avdepot_rechner/services/domain/calculator_service.dart';

/// Interface for income tax calculation.
/// Replace this to support different tax systems or updated brackets.
abstract class TaxModule {
  /// Marginal tax rate for a given annual gross income.
  double getGrenzsteuersatz(double brutto);

  /// Günstigerprüfung: compare Sonderausgabenabzug vs. keeping Zulagen.
  /// Returns steuerersparnis, additional refund, and whether it's beneficial.
  ({double steuerersparnis, double zusaetzlich, bool vorteil})
  calcGuenstigerpruefung(double jahresbeitrag, double zulageTotal, double grenzsteuersatz);
}

/// German income tax brackets (§32a EStG, 2024 values).
/// Piecewise linear approximation of the progressive tax schedule.
///
/// Note: Uses Brutto as proxy for zvE (zu versteuerndes Einkommen).
/// In reality, zvE = Brutto - Werbungskosten - Sonderausgaben etc.
class GermanTax2024 implements TaxModule {
  const GermanTax2024();

  @override
  double getGrenzsteuersatz(double brutto) {
    if (brutto <= CalcConstants.grundfreibetrag) return 0;
    if (brutto <= CalcConstants.zone2Ende) return CalcConstants.zone2Satz;
    if (brutto <= CalcConstants.zone3Ende) {
      return CalcConstants.zone3StartSatz
          + (brutto - CalcConstants.zone2Ende) / (CalcConstants.zone3Ende - CalcConstants.zone2Ende)
          * (CalcConstants.spitzensteuersatz - CalcConstants.zone3StartSatz);
    }
    if (brutto <= CalcConstants.zone4Ende) return CalcConstants.spitzensteuersatz;
    return CalcConstants.reichensteuersatz;
  }

  @override
  ({double steuerersparnis, double zusaetzlich, bool vorteil})
  calcGuenstigerpruefung(double jahresbeitrag, double zulageTotal, double grenzsteuersatz) {
    final gesamtBeitrag = jahresbeitrag + zulageTotal;
    final steuerersparnis = gesamtBeitrag * grenzsteuersatz;
    final zusaetzlich = steuerersparnis > zulageTotal ? steuerersparnis - zulageTotal : 0.0;
    return (steuerersparnis: steuerersparnis, zusaetzlich: zusaetzlich, vorteil: steuerersparnis > zulageTotal);
  }
}
