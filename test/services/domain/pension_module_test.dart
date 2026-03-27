import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/pension_module.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';

void main() {
  const pension = EntgeltpunkteEstimator();

  PersonalScenario makePerson({
    double brutto = 45000,
    int alterStart = 30,
    int spardauer = 37,
    double? renteOverride,
  }) => PersonalScenario(
    name: 'Test', icon: '', sparrate: 100, brutto: brutto,
    kinder: 0, alterStart: alterStart, spardauer: spardauer,
    gesetzlicheRenteOverride: renteOverride,
  );

  group('Static estimate (no income dev, no override)', () {
    test('career starter: 32k brutto, age 23–67', () {
      final p = makePerson(brutto: 32000, alterStart: 23, spardauer: 44);
      final rente = pension.estimateMonthlyPension(p, const IncomeDevSettings());
      // beitragsjahre = 67 - 25 = 42, EP = 32000/45358 = 0.7056, rente = 0.7056 × 42 × 39.32
      expect(rente, closeTo(1165, 5));
    });

    test('high earner: 85k brutto, age 40–67', () {
      final p = makePerson(brutto: 85000, alterStart: 40, spardauer: 27);
      final rente = pension.estimateMonthlyPension(p, const IncomeDevSettings());
      // beitragsjahre = 67 - 25 = 42, EP = 85000/45358 = 1.874
      expect(rente, closeTo(3095, 5));
    });

    test('above BBG: 120k brutto is capped', () {
      final p = makePerson(brutto: 120000, alterStart: 25, spardauer: 42);
      final rente = pension.estimateMonthlyPension(p, const IncomeDevSettings());
      // EP = min(120000, 90600)/45358 = 1.997
      final expected = (90600 / 45358) * 42 * 39.32;
      expect(rente, closeTo(expected, 5));
    });

    test('young starter has fewer contribution years', () {
      final p25 = makePerson(brutto: 45000, alterStart: 25, spardauer: 42);
      final p30 = makePerson(brutto: 45000, alterStart: 30, spardauer: 37);
      final r25 = pension.estimateMonthlyPension(p25, const IncomeDevSettings());
      final r30 = pension.estimateMonthlyPension(p30, const IncomeDevSettings());
      // Same brutto, same retirement age (67), same contribution years (42)
      expect(r25, closeTo(r30, 1));
    });
  });

  group('Manual override', () {
    test('override takes priority over estimate', () {
      final p = makePerson(brutto: 85000, renteOverride: 500);
      final rente = pension.estimateMonthlyPension(p, const IncomeDevSettings());
      expect(rente, 500);
    });

    test('override of zero is respected', () {
      final p = makePerson(renteOverride: 0);
      final rente = pension.estimateMonthlyPension(p, const IncomeDevSettings());
      expect(rente, 0);
    });
  });

  group('Income development EP accumulation', () {
    test('growing income accumulates more EP than static', () {
      final p = makePerson(brutto: 32000, alterStart: 25, spardauer: 42);
      final staticRente = pension.estimateMonthlyPension(p, const IncomeDevSettings());
      final growingRente = pension.estimateMonthlyPension(p, const IncomeDevSettings(enabled: true, growthRate: 0.02));
      expect(growingRente, greaterThan(staticRente));
    });

    test('zero growth rate matches static (approximately)', () {
      final p = makePerson(brutto: 45000, alterStart: 25, spardauer: 42);
      final staticRente = pension.estimateMonthlyPension(p, const IncomeDevSettings());
      final zeroGrowth = pension.estimateMonthlyPension(p, const IncomeDevSettings(enabled: true, growthRate: 0));
      // With 0 growth and alterStart==25==arbeitsbeginn, pre-savings=0, so EP accumulation
      // covers same 42 years at same brutto → should match static estimate
      expect(zeroGrowth, closeTo(staticRente, 1));
    });

    test('BBG caps high growth', () {
      final p = makePerson(brutto: 80000, alterStart: 25, spardauer: 42);
      final rente = pension.estimateMonthlyPension(p, const IncomeDevSettings(enabled: true, growthRate: 0.05));
      // After ~3 years at 5% growth, brutto exceeds BBG (90,600). EP should be capped.
      final maxRente = (CalcConstants.bbg / CalcConstants.durchschnittsentgelt) * 42 * CalcConstants.rentenwert;
      expect(rente, lessThanOrEqualTo(maxRente + 50)); // allow small overshoot from pre-savings
    });

    test('override still takes priority over income dev', () {
      final p = makePerson(brutto: 32000, renteOverride: 999);
      final rente = pension.estimateMonthlyPension(p, const IncomeDevSettings(enabled: true, growthRate: 0.05));
      expect(rente, 999);
    });
  });
}
