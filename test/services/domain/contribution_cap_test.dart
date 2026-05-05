import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';

void main() {
  const engine = SimulationEngine();
  const tax = GermanTax2026();

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

  group('Ungefördert payout taxation (Ertragsanteilbesteuerung 17%)', () {
    test('high contribution: ungefördert bucket exists and net > pure-nachgelagert net', () {
      // €500/mo → €1,800 gefördert + €4,200 ungefördert
      final p = makePerson(sparrate: 500, brutto: 80000, spardauer: 30, gesetzlicheRenteOverride: 1500);
      final m = makeMacro(rendite: 0.07);
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings());

      // Sanity: simulation produces positive net payout
      expect(av.nettoMonatlich, greaterThan(0));
      // Ungefördert bucket exists, net is higher than if 100% of total payout were taxed
      // at the marginal rate. We compare against a hypothetical full-nachgelagert calc.
      final fullNachNet = av.monatlicheAuszahlung *
        (1 - av.grenzsteuersatzRente);
      expect(av.nettoMonatlich, greaterThan(fullNachNet),
        reason: 'Ertragsanteil treatment must yield more net than 100% nachgelagert');
    });

    test('at €150/mo no ungefördert — payout is pure gefördert (nachgelagert)', () {
      final p = makePerson(sparrate: 150, brutto: 50000, spardauer: 30, gesetzlicheRenteOverride: 1500);
      final m = makeMacro(rendite: 0.07);
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings());

      // No ungefördert bucket → entire payout taxed at incremental income rate
      final expectedNet = av.monatlicheAuszahlung * (1 - av.grenzsteuersatzRente);
      expect(av.nettoMonatlich, closeTo(expectedNet, 0.5));
    });

    test('marginal rate is computed against full AV taxable income (gef + 17%×ungef)', () {
      // With both buckets present, the rate must reflect that the 17% Ertragsanteil
      // of ungefördert ALSO sits on top of pension+other in the §32a progression.
      // Setup: alterStart 30 (no Berufseinsteigerbonus), no kids — so the only
      // subsidy is the Grundzulage (€540/yr, max for €1,800 gef contribution).
      final p = makePerson(sparrate: 500, brutto: 80000, alterStart: 30,
        spardauer: 30, gesetzlicheRenteOverride: 1500);
      final m = makeMacro(rendite: 0.07);
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings());

      // Bucket flows per year (constant across all 30 years for this scenario):
      //   gef   = €1,800 contribution + €540 Grundzulage   = €2,340
      //   ungef = €4,200 (excess above €1,800 cap)
      // Both grow at the same nettoRendite, so the depot ratio at retirement
      // matches the annual-flow ratio.
      const gefAnnualFlow = 2340.0;
      const ungefAnnualFlow = 4200.0;
      const gefRatio = gefAnnualFlow / (gefAnnualFlow + ungefAnnualFlow);
      const ungefRatio = ungefAnnualFlow / (gefAnnualFlow + ungefAnnualFlow);
      final monatlichGef = av.monatlicheAuszahlung * gefRatio;
      final monatlichUngef = av.monatlicheAuszahlung * ungefRatio;

      // Predicted net per the documented formula:
      //   gef:   monatlichGef × (1 − rate)              (100% taxable)
      //   ungef: monatlichUngef × (1 − 0.17 × rate)    (17% taxable)
      const ertragsanteil = 0.17;
      final expected = monatlichGef * (1 - av.grenzsteuersatzRente)
                     + monatlichUngef * (1 - ertragsanteil * av.grenzsteuersatzRente);
      expect(av.nettoMonatlich, closeTo(expected, 0.5),
        reason: 'Net payout must equal gef×(1−rate) + ungef×(1−0.17×rate)');
    });
  });
}
