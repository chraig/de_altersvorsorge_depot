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

/// German income tax (§32a EStG, 2026 values per Steuerfortentwicklungsgesetz).
/// Implements the exact piecewise polynomial formula from the law.
///
/// Note: Uses Brutto as proxy for zvE (zu versteuerndes Einkommen).
/// In reality, zvE = Brutto - Werbungskosten - Sonderausgaben etc.
class GermanTax2026 implements TaxModule {
  const GermanTax2026();

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

  /// Exact §32a EStG 2026 formula.
  ///
  /// Source: §32a Abs. 1 Satz 2 EStG, applicable from Veranlagungszeitraum 2026 per
  /// the Steuerfortentwicklungsgesetz (Bundestag, December 2024). All thresholds
  /// AND polynomial coefficients are written verbatim into the statute — they are
  /// not derived or approximated here. Authoritative consolidated text:
  /// https://www.gesetze-im-internet.de/estg/__32a.html
  ///
  /// All literals live in `CalcConstants` (calculator_service.dart). To update for a
  /// new tax year, change them there in one place.
  @override
  double calcEinkommensteuer(double brutto) {
    if (brutto <= CalcConstants.grundfreibetrag) return 0;

    if (brutto <= CalcConstants.zone2Ende) {
      // Zone 2: tax = (zone2A × y + zone2B) × y, y = (zvE - grundfreibetrag) / 10,000
      final y = (brutto - CalcConstants.grundfreibetrag) / 10000;
      return (CalcConstants.zone2A * y + CalcConstants.zone2B) * y;
    }

    if (brutto <= CalcConstants.zone3Ende) {
      // Zone 3: tax = (zone3A × z + zone3B) × z + zone3C, z = (zvE - zone2Ende) / 10,000
      final z = (brutto - CalcConstants.zone2Ende) / 10000;
      return (CalcConstants.zone3A * z + CalcConstants.zone3B) * z + CalcConstants.zone3C;
    }

    if (brutto <= CalcConstants.zone4Ende) {
      // Zone 4: tax = spitzensteuersatz × zvE - zone4Offset
      return CalcConstants.spitzensteuersatz * brutto - CalcConstants.zone4Offset;
    }

    // Zone 5: tax = reichensteuersatz × zvE - zone5Offset
    return CalcConstants.reichensteuersatz * brutto - CalcConstants.zone5Offset;
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
