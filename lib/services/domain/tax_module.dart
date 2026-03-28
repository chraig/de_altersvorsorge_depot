import 'package:avdepot_rechner/services/domain/calculator_service.dart';

/// Interface for income tax calculation.
/// Replace this to support different tax systems or updated brackets.
abstract class TaxModule {
  /// Marginal tax rate for a given annual gross income.
  /// Used for display purposes and Günstigerprüfung marginal comparison.
  double getGrenzsteuersatz(double brutto);

  /// Actual income tax amount for a given annual gross income.
  /// Uses the exact progressive §32a formula (not marginal × income).
  double calcEinkommensteuer(double brutto);

  /// Average tax rate = calcEinkommensteuer(brutto) / brutto.
  /// This is the effective rate on the total income.
  double getDurchschnittssteuersatz(double brutto);

  /// Günstigerprüfung: compare Sonderausgabenabzug vs. keeping Zulagen.
  /// Uses marginal rate for the comparison (correct per §10a).
  ({double steuerersparnis, double zusaetzlich, bool vorteil})
  calcGuenstigerpruefung(double jahresbeitrag, double zulageTotal, double grenzsteuersatz);
}

/// German income tax (§32a EStG, 2024 values).
/// Implements the exact piecewise polynomial formula from the law.
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
  double getDurchschnittssteuersatz(double brutto) {
    if (brutto <= 0) return 0;
    return calcEinkommensteuer(brutto) / brutto;
  }

  /// Exact §32a EStG 2024 formula.
  /// Source: §32a Abs. 1 Satz 2 EStG (2024 values per Inflationsausgleichsgesetz).
  @override
  double calcEinkommensteuer(double brutto) {
    if (brutto <= CalcConstants.grundfreibetrag) return 0;

    if (brutto <= CalcConstants.zone2Ende) {
      // Zone 2: y = (zvE - 11784) / 10000
      // Steuer = (922.98 × y + 1400) × y
      final y = (brutto - 11784) / 10000;
      return (922.98 * y + 1400) * y;
    }

    if (brutto <= CalcConstants.zone3Ende) {
      // Zone 3: z = (zvE - 17005) / 10000
      // Steuer = (181.19 × z + 2397) × z + 1025.38
      final z = (brutto - 17005) / 10000;
      return (181.19 * z + 2397) * z + 1025.38;
    }

    if (brutto <= CalcConstants.zone4Ende) {
      // Zone 4: Steuer = 0.42 × zvE - 10602.13
      return 0.42 * brutto - 10602.13;
    }

    // Zone 5: Steuer = 0.45 × zvE - 18936.88
    return 0.45 * brutto - 18936.88;
  }

  @override
  ({double steuerersparnis, double zusaetzlich, bool vorteil})
  calcGuenstigerpruefung(double jahresbeitrag, double zulageTotal, double grenzsteuersatz) {
    // Sonderausgabenabzug is capped at min(Jahresbeitrag, 1800) + Zulagen
    // per §10a EStG-E and BMF FAQ. Contributions above €1,800 are not deductible.
    final cappedBeitrag = jahresbeitrag < CalcConstants.grundzulageMaxBeitrag
        ? jahresbeitrag : CalcConstants.grundzulageMaxBeitrag;
    final gesamtBeitrag = cappedBeitrag + zulageTotal;
    // Günstigerprüfung uses the marginal rate for the comparison (correct per §10a)
    final steuerersparnis = gesamtBeitrag * grenzsteuersatz;
    final zusaetzlich = steuerersparnis > zulageTotal ? steuerersparnis - zulageTotal : 0.0;
    return (steuerersparnis: steuerersparnis, zusaetzlich: zusaetzlich, vorteil: steuerersparnis > zulageTotal);
  }
}
