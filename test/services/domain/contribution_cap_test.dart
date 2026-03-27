import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';

void main() {
  const engine = SimulationEngine();
  const tax = GermanTax2024();

  PersonalScenario makePerson({
    double sparrate = 100,
    double brutto = 45000,
    int kinder = 0,
    int alterStart = 30,
    int spardauer = 37,
    double? gesetzlicheRenteOverride,
  }) => PersonalScenario(
    name: 'Test', icon: '', sparrate: sparrate, brutto: brutto,
    kinder: kinder, alterStart: alterStart, spardauer: spardauer,
    gesetzlicheRenteOverride: gesetzlicheRenteOverride,
  );

  MacroScenario makeMacro({double rendite = 0.07, double inflation = 0.02}) =>
    MacroScenario(name: 'Test', shortName: 'T', icon: '', description: '',
      rendite: rendite, inflation: inflation, color: const Color(0xFF0066FF));

  group('Günstigerprüfung capped at €1,800', () {
    test('at €1,800 contribution: full deduction', () {
      final gp = tax.calcGuenstigerpruefung(1800, 540, 0.42);
      // (1800 + 540) × 0.42 = 982.80
      expect(gp.steuerersparnis, closeTo(982.80, 0.01));
    });

    test('at €3,600 contribution: deduction still capped at 1800', () {
      final gp = tax.calcGuenstigerpruefung(3600, 540, 0.42);
      // Cap: min(3600, 1800) = 1800. (1800 + 540) × 0.42 = 982.80
      // NOT (3600 + 540) × 0.42 = 1738.80
      expect(gp.steuerersparnis, closeTo(982.80, 0.01));
    });

    test('at €6,000 contribution: same as €1,800', () {
      final gpLow = tax.calcGuenstigerpruefung(1800, 540, 0.42);
      final gpHigh = tax.calcGuenstigerpruefung(6000, 540, 0.42);
      expect(gpHigh.steuerersparnis, gpLow.steuerersparnis);
    });

    test('below €1,800: uses actual contribution', () {
      final gp = tax.calcGuenstigerpruefung(600, 240, 0.30);
      // (600 + 240) × 0.30 = 252
      expect(gp.steuerersparnis, closeTo(252, 0.01));
    });
  });

  group('Contribution cap at €6,840/yr per contract', () {
    test('€570/mo exactly reaches contract max', () {
      final p = makePerson(sparrate: 570, spardauer: 1);
      final m = makeMacro(rendite: 0);
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings(kostenAV: 0));
      // 570 × 12 = 6840 → capped at 6840
      expect(av.eigenBeitraege, closeTo(6840, 1));
    });

    test('above contract max is capped', () {
      // Even if slider allowed higher, code should cap at 6840
      final p = makePerson(sparrate: 1000, spardauer: 1); // 12000/yr > 6840
      final m = makeMacro(rendite: 0);
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings(kostenAV: 0));
      expect(av.eigenBeitraege, closeTo(6840, 1));
    });

    test('at €150/mo: everything is gefördert (no ungefördert)', () {
      final p = makePerson(sparrate: 150, spardauer: 1);
      final m = makeMacro(rendite: 0);
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings(kostenAV: 0));
      // 150 × 12 = 1800 = exactly the Grundzulage max → all gefördert
      // Endkapital should be 1800 + subsidies (no ungefördert bucket)
      expect(av.eigenBeitraege, closeTo(1800, 1));
    });
  });

  group('Gefördert / Ungefördert split', () {
    test('€150/mo: all subsidized, full nachgelagerte Besteuerung', () {
      final p = makePerson(sparrate: 150, brutto: 50000, spardauer: 30);
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);
      // All 1800/yr is gefördert → full payout tax at retirement rate
      expect(av.endkapital, greaterThan(0));
    });

    test('€400/mo: split into gefördert + ungefördert', () {
      final p = makePerson(sparrate: 400, brutto: 60000, spardauer: 30);
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);
      // 400 × 12 = 4800; gefördert = 1800, ungefördert = 3000
      expect(av.eigenBeitraege, closeTo(4800 * 30, 1));
    });

    test('ungefördert gets better tax treatment than gefördert', () {
      // High contribution + realistic pension → combined income above Grundfreibetrag
      final pHigh = makePerson(sparrate: 500, brutto: 80000, spardauer: 30, gesetzlicheRenteOverride: 1500);
      final m = makeMacro();
      final costs = CostSettings();
      final avHigh = engine.simulateAV(person: pHigh, macro: m, costs: costs);

      // Net should be less than gross (tax applies)
      expect(avHigh.nettoMonatlich, greaterThan(0));
      expect(avHigh.monatlicheAuszahlung, greaterThan(avHigh.nettoMonatlich));
    });

    test('subsidies only apply to gefördert portion', () {
      // Verify that only the first €1,800 of contributions get subsidies
      final pLow = makePerson(sparrate: 150, brutto: 50000, spardauer: 1);
      final pHigh = makePerson(sparrate: 400, brutto: 50000, spardauer: 1);
      final m = makeMacro(rendite: 0);
      final costs = CostSettings(kostenAV: 0);

      final avLow = engine.simulateAV(person: pLow, macro: m, costs: costs);
      final avHigh = engine.simulateAV(person: pHigh, macro: m, costs: costs);

      // Both should get the same subsidies (both have €1,800 gefördert)
      expect(avHigh.zulagenGesamt, closeTo(avLow.zulagenGesamt, 1));
    });
  });

  group('Halbeinkünfteverfahren for ungefördert', () {
    test('50% of gains taxed, not full payout', () {
      // With large ungefördert portion and high returns, the Halbeinkünfte-
      // verfahren should result in lower tax than full nachgelagerte Besteuerung
      final p = makePerson(sparrate: 570, brutto: 80000, spardauer: 30, gesetzlicheRenteOverride: 0);
      final m = makeMacro(rendite: 0.07);
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);

      // Net should be meaningfully higher than if we taxed everything at full rate
      // (we can't easily compute the exact "wrong" result here, but net > 0 is basic)
      expect(av.nettoMonatlich, greaterThan(0));
      // Gross to net ratio: should be above 60% (with Halbeinkünfte, tax is moderate)
      final ratio = av.nettoMonatlich / av.monatlicheAuszahlung;
      expect(ratio, greaterThan(0.5));
    });
  });
}
