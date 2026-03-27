import 'dart:math';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';

/// Interface for state pension estimation.
/// Replace this to support different pension systems or estimation methods.
abstract class PensionModule {
  /// Estimate monthly state pension for the given person and income development.
  double estimateMonthlyPension(PersonalScenario person, IncomeDevSettings incomeDev);
}

/// German state pension estimation via Entgeltpunkte.
///
/// Formula: Σ(min(brutto_j, BBG) / Durchschnittsentgelt) × Rentenwert
///
/// Respects:
/// - Beitragsbemessungsgrenze (no pension points above BBG)
/// - Manual override via gesetzlicheRenteOverride
/// - Income development (year-by-year EP accumulation when enabled)
/// - Pre-savings contribution years (from arbeitsbeginn to alterStart)
class EntgeltpunkteEstimator implements PensionModule {
  const EntgeltpunkteEstimator();

  @override
  double estimateMonthlyPension(PersonalScenario person, IncomeDevSettings incomeDev) {
    // Priority 1: manual override
    if (person.gesetzlicheRenteOverride != null) {
      return person.gesetzlicheRenteOverride!;
    }

    // Priority 2: income-development-based year-by-year EP accumulation
    if (incomeDev.enabled) {
      double totalEP = 0;
      // Pre-savings years (from arbeitsbeginn to savings start)
      final preSavingsYears = (person.alterStart - CalcConstants.arbeitsbeginn).clamp(0, 45);
      totalEP += preSavingsYears * _epForBrutto(person.brutto);
      // Savings period with growing income
      for (int j = 0; j < person.spardauer; j++) {
        totalEP += _epForBrutto(incomeDev.bruttoForYear(person.brutto, j));
      }
      return totalEP * CalcConstants.rentenwert;
    }

    // Priority 3: static estimate from PersonalScenario
    return person.gesetzlicheRente;
  }

  /// Entgeltpunkte for one year at a given brutto, capped at BBG.
  double _epForBrutto(double brutto) {
    return min(brutto, CalcConstants.bbg) / CalcConstants.durchschnittsentgelt;
  }
}
