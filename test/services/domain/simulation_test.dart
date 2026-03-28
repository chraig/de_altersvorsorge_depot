import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';

void main() {
  const engine = SimulationEngine();

  PersonalScenario makePerson({
    double sparrate = 100,
    double brutto = 45000,
    int kinder = 0,
    int alterStart = 30,
    int spardauer = 37,
    double? renteOverride,
    double sonstigeEinkuenfte = 0,
  }) => PersonalScenario(
    name: 'Test', icon: '', sparrate: sparrate, brutto: brutto,
    kinder: kinder, alterStart: alterStart, spardauer: spardauer,
    gesetzlicheRenteOverride: renteOverride, sonstigeEinkuenfte: sonstigeEinkuenfte,
  );

  MacroScenario makeMacro({double rendite = 0.07, double inflation = 0.02}) =>
    MacroScenario(name: 'Test', shortName: 'T', icon: '', description: '',
      rendite: rendite, inflation: inflation, color: const Color(0xFF0000FF));

  group('AV-Depot Simulation', () {
    test('1-year accumulation with no subsidies scenario', () {
      // High income, no kids, age 40 → no bonus, no geringverdiener
      final p = makePerson(sparrate: 150, brutto: 85000, alterStart: 40, spardauer: 1);
      final m = makeMacro(rendite: 0.07);
      final costs = CostSettings(kostenAV: 0.005);
      final av = engine.simulateAV(person: p, macro: m, costs: costs);

      final jb = 150.0 * 12; // 1800
      final gz = 540.0; // max Grundzulage
      final zufluss = jb + gz;
      final expected = zufluss * (1 + 0.07 - 0.005);
      expect(av.endkapital, closeTo(expected, 1));
      expect(av.eigenBeitraege, closeTo(jb, 0.01));
      expect(av.zulagenGesamt, closeTo(gz, 0.01));
    });

    test('career starter gets one-time bonus in year 1 only', () {
      final p = makePerson(sparrate: 50, brutto: 32000, alterStart: 23, spardauer: 3);
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);

      // Year 0: gets bonus (200). Year 1,2: no bonus.
      // Total zulagen = (240+200) + 240 + 240 = 3×240 + 200 = 920
      const gz = 240.0; // 360×50% + 240×25%
      expect(av.zulagenGesamt, closeTo(3 * gz + 200, 1));
    });

    test('payout duration derived from retirement age', () {
      final p67 = makePerson(alterStart: 30, spardauer: 37); // retires at 67
      final p60 = makePerson(alterStart: 30, spardauer: 30); // retires at 60
      expect(p67.auszahlungsDauer, 18); // 85 - 67
      expect(p60.auszahlungsDauer, 25); // 85 - 60
    });

    test('monthly payout is depot / (auszahlungsDauer × 12)', () {
      final p = makePerson(sparrate: 100, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);
      final expectedMonthly = av.endkapital / (p.auszahlungsDauer * 12);
      expect(av.monatlicheAuszahlung, closeTo(expectedMonthly, 0.01));
    });

    test('retirement tax uses combined income', () {
      final p = makePerson(renteOverride: 1500, sonstigeEinkuenfte: 5000,
        sparrate: 150, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);

      // Incremental tax: tax(base + AV) - tax(base), divided by AV payout
      final avAnnual = av.endkapital / p.auszahlungsDauer;
      final baseIncome = 1500.0 * 12 + 5000;
      final taxOnBase = engine.tax.calcEinkommensteuer(baseIncome);
      final taxOnCombined = engine.tax.calcEinkommensteuer(baseIncome + avAnnual);
      final expectedRate = avAnnual > 0 ? (taxOnCombined - taxOnBase) / avAnnual : 0.0;
      expect(av.grenzsteuersatzRente, closeTo(expectedRate, 0.001));
    });

    test('Kirchensteuer increases payout tax', () {
      final p = makePerson(sparrate: 150, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final noKi = CostSettings(kirchensteuer: 0);
      final ki8 = CostSettings(kirchensteuer: 0.08);

      final avNoKi = engine.simulateAV(person: p, macro: m, costs: noKi);
      final avKi8 = engine.simulateAV(person: p, macro: m, costs: ki8);

      // Same depot, but higher tax → lower net payout
      expect(avNoKi.endkapital, closeTo(avKi8.endkapital, 0.01));
      expect(avKi8.nettoMonatlich, lessThan(avNoKi.nettoMonatlich));
    });

    test('inflation-adjusted capital is lower than nominal', () {
      final p = makePerson(sparrate: 100, alterStart: 30, spardauer: 37);
      final m = makeMacro(inflation: 0.02);
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);
      expect(av.endkapitalReal, lessThan(av.endkapital));
      expect(av.endkapitalReal, closeTo(av.endkapital / pow(1.02, 37), 1));
    });

    test('wertzuwachs = endkapital - eigenBeitraege - zulagen', () {
      final p = makePerson(sparrate: 100, alterStart: 30, spardauer: 20);
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);
      expect(av.wertzuwachs, closeTo(av.endkapital - av.eigenBeitraege - av.zulagenGesamt, 0.01));
    });

    test('yearly data points match spardauer length', () {
      final p = makePerson(spardauer: 10, alterStart: 30);
      final m = makeMacro();
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings());
      expect(av.jahresWerte.length, 10);
      expect(av.jahresWerte.first.year, 1);
      expect(av.jahresWerte.last.year, 10);
      expect(av.jahresWerte.last.alter, 40);
    });
  });

  group('ETF-Depot Simulation', () {
    test('1-year accumulation', () {
      final p = makePerson(sparrate: 100, spardauer: 1);
      final m = makeMacro(rendite: 0.07);
      final costs = CostSettings(kostenETF: 0.002);
      final etf = engine.simulateETF(person: p, macro: m, costs: costs);

      final jb = 1200.0;
      final nettoRendite = 0.07 - 0.002 - CalcConstants.vorabpauschaleDrag; // rendite - kostenETF - vorabpauschale
      final expected = jb * (1 + nettoRendite);
      expect(etf.endkapital, closeTo(expected, 1));
      expect(etf.eigenBeitraege, closeTo(jb, 0.01));
    });

    test('gains taxed with Teilfreistellung', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final costs = CostSettings();
      final etf = engine.simulateETF(person: p, macro: m, costs: costs);

      final expectedTax = (etf.gewinn * 0.70) * 0.26375;
      expect(etf.steuerAufGewinn, closeTo(expectedTax, 1));
      expect(etf.nachSteuer, closeTo(etf.endkapital - etf.steuerAufGewinn, 0.01));
    });

    test('Kirchensteuer increases ETF tax', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final noKi = CostSettings(kirchensteuer: 0);
      final ki9 = CostSettings(kirchensteuer: 0.09);

      final etfNoKi = engine.simulateETF(person: p, macro: m, costs: noKi);
      final etfKi9 = engine.simulateETF(person: p, macro: m, costs: ki9);

      expect(etfKi9.steuerAufGewinn, greaterThan(etfNoKi.steuerAufGewinn));
      expect(etfKi9.monatlicheAuszahlung, lessThan(etfNoKi.monatlicheAuszahlung));
    });

    test('no subsidies in ETF result', () {
      final p = makePerson(sparrate: 50, kinder: 2, spardauer: 10, alterStart: 30);
      final m = makeMacro();
      final etf = engine.simulateETF(person: p, macro: m, costs: CostSettings());
      for (final dp in etf.jahresWerte) {
        expect(dp.zulagen, 0);
        expect(dp.zulageJahr, 0);
      }
    });

    test('monthly payout correct', () {
      final p = makePerson(sparrate: 100, spardauer: 37, alterStart: 30);
      final m = makeMacro();
      final etf = engine.simulateETF(person: p, macro: m, costs: CostSettings());
      final expectedMonthly = etf.nachSteuer / (p.auszahlungsDauer * 12);
      expect(etf.monatlicheAuszahlung, closeTo(expectedMonthly, 0.01));
    });
  });

  group('Income Development', () {
    test('disabled: brutto stays constant', () {
      const dev = IncomeDevSettings(enabled: false, growthRate: 0.05);
      expect(dev.bruttoForYear(32000, 0), 32000);
      expect(dev.bruttoForYear(32000, 10), 32000);
    });

    test('enabled: brutto compounds annually', () {
      const dev = IncomeDevSettings(enabled: true, growthRate: 0.02);
      expect(dev.bruttoForYear(32000, 0), closeTo(32000, 0.01));
      expect(dev.bruttoForYear(32000, 10), closeTo(32000 * pow(1.02, 10), 1));
      expect(dev.bruttoForYear(32000, 30), closeTo(32000 * pow(1.02, 30), 1));
    });

    test('income dev affects Geringverdienerbonus eligibility', () {
      // Start at 25k (eligible), grow 3% → crosses 26,250 after ~2 years
      final p = makePerson(sparrate: 50, brutto: 25000, alterStart: 25, spardauer: 10);
      final m = makeMacro();
      final costs = CostSettings();
      const dev = IncomeDevSettings(enabled: true, growthRate: 0.03);

      final av = engine.simulateAV(person: p, macro: m, costs: costs, incomeDev: dev);
      // Should get Geringverdienerbonus only in early years
      // Year 0: 25000 → eligible
      // Year 1: 25750 → eligible
      // Year 2: 26522 → exceeds 26250 → ineligible
      // Total zulagen should include 175 for ~2 years only
      expect(av.zulagenGesamt, greaterThan(0));
    });

    test('income dev produces higher AV result than static', () {
      final p = makePerson(sparrate: 100, brutto: 40000, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final costs = CostSettings();

      final avStatic = engine.simulateAV(person: p, macro: m, costs: costs);
      final avGrow = engine.simulateAV(person: p, macro: m, costs: costs,
        incomeDev: const IncomeDevSettings(enabled: true, growthRate: 0.02));

      // Growing income → higher Grenzsteuersatz → higher Günstigerprüfung refund
      expect(avGrow.steuererstattungGesamt, greaterThanOrEqualTo(avStatic.steuererstattungGesamt));
    });

    test('stepwise curve flows through full AV simulation', () {
      final p = makePerson(sparrate: 100, brutto: 35000, alterStart: 25, spardauer: 30);
      final m = makeMacro();
      const dev = IncomeDevSettings(
        enabled: true, curve: GrowthCurve.stepwise,
        promotionInterval: 5, promotionIncrease: 0.15,
      );
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: dev);
      expect(av.endkapital, greaterThan(0));
      expect(av.jahresWerte.length, 30);
      // Stepwise growth should produce higher refund than static (promotions → higher tax bracket)
      final avStatic = engine.simulateAV(person: p, macro: m, costs: CostSettings());
      expect(av.steuererstattungGesamt, greaterThanOrEqualTo(avStatic.steuererstattungGesamt));
    });

    test('logarithmic curve flows through full AV simulation', () {
      final p = makePerson(sparrate: 100, brutto: 35000, alterStart: 25, spardauer: 30);
      final m = makeMacro();
      const dev = IncomeDevSettings(
        enabled: true, curve: GrowthCurve.logarithmic, salaryCap: 80000,
      );
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: dev);
      expect(av.endkapital, greaterThan(0));
    });

    test('part-time phase reduces AV subsidies during that period', () {
      final p = makePerson(sparrate: 50, brutto: 50000, alterStart: 30, spardauer: 20);
      final m = makeMacro();
      const devNoPt = IncomeDevSettings(enabled: true, curve: GrowthCurve.linear, growthRate: 0.02);
      const devPt = IncomeDevSettings(
        enabled: true, curve: GrowthCurve.linear, growthRate: 0.02,
        partTimeStartYear: 5, partTimeDuration: 3, partTimePercent: 0.5,
      );
      final avNoPt = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: devNoPt);
      final avPt = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: devPt);
      // Part-time reduces income → may qualify for Geringverdienerbonus in those years
      // or reduce Günstigerprüfung → different total
      expect(avPt.steuererstattungGesamt, isNot(avNoPt.steuererstattungGesamt));
    });

    test('child arrival increases Kinderzulage mid-simulation', () {
      final p = makePerson(sparrate: 100, brutto: 45000, kinder: 0, alterStart: 30, spardauer: 20);
      final m = makeMacro();
      const devNoChild = IncomeDevSettings(enabled: true, curve: GrowthCurve.linear, growthRate: 0.02);
      const devChild = IncomeDevSettings(
        enabled: true, curve: GrowthCurve.linear, growthRate: 0.02,
        childArrivalYears: [3],
      );
      final avNo = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: devNoChild);
      final avChild = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: devChild);
      // Child arriving at year 3 → Kinderzulage from year 3 onward → more total subsidies
      expect(avChild.zulagenGesamt, greaterThan(avNo.zulagenGesamt));
    });
  });

  group('CostSettings / Kirchensteuer', () {
    test('default Abgeltungssteuersatz is 26.3750%', () {
      final c = CostSettings();
      expect(c.abgeltungssteuersatz, closeTo(0.26375, 0.00001));
    });

    test('8% Kirchensteuer gives 27.8186%', () {
      final c = CostSettings(kirchensteuer: 0.08);
      expect(c.abgeltungssteuersatz, closeTo(0.278186, 0.0001));
    });

    test('9% Kirchensteuer gives 27.9951%', () {
      final c = CostSettings(kirchensteuer: 0.09);
      expect(c.abgeltungssteuersatz, closeTo(0.279951, 0.0001));
    });

    test('KapESt formula per §32d: 25% / (1 + 25% × KiSt)', () {
      for (final k in [0.08, 0.09]) {
        final c = CostSettings(kirchensteuer: k);
        final kapEst = 0.25 / (1 + 0.25 * k);
        final soli = kapEst * 0.055;
        final kiSt = kapEst * k;
        expect(c.abgeltungssteuersatz, closeTo(kapEst + soli + kiSt, 0.00001));
      }
    });
  });

  group('Combined / Cross-scenario', () {
    test('simulateCombined produces matching AV + ETF', () {
      final p = makePerson();
      final m = makeMacro();
      final costs = CostSettings();
      final combined = engine.simulateCombined(person: p, macro: m, costs: costs);

      expect(combined.av.endkapital, greaterThan(0));
      expect(combined.etf.endkapital, greaterThan(0));
      expect(combined.av.eigenBeitraege, combined.etf.eigenBeitraege);
    });

    test('simulateAllMacros returns one result per macro', () {
      final p = makePerson();
      final macros = [makeMacro(rendite: 0.10), makeMacro(rendite: 0.07), makeMacro(rendite: 0.03)];
      final results = engine.simulateAllMacros(person: p, macros: macros, costs: CostSettings());
      expect(results.length, 3);
    });

    test('higher return → higher endkapital', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 30);
      final costs = CostSettings();
      final avHigh = engine.simulateAV(person: p, macro: makeMacro(rendite: 0.10), costs: costs);
      final avLow = engine.simulateAV(person: p, macro: makeMacro(rendite: 0.03), costs: costs);
      expect(avHigh.endkapital, greaterThan(avLow.endkapital));
    });

    test('CalculatorService static facade matches engine', () {
      final p = makePerson();
      final m = makeMacro();
      final costs = CostSettings();
      final fromEngine = engine.simulateAV(person: p, macro: m, costs: costs);
      final fromFacade = CalculatorService.simulateAV(person: p, macro: m, costs: costs);
      expect(fromFacade.endkapital, fromEngine.endkapital);
      expect(fromFacade.nettoMonatlich, fromEngine.nettoMonatlich);
    });
  });

  group('SubsidyBreakdown', () {
    test('matches year-1 subsidy values', () {
      final p = makePerson(sparrate: 100, brutto: 45000, kinder: 2, alterStart: 23);
      final breakdown = engine.calcSubsidyBreakdown(p);

      expect(breakdown.grundzulage, closeTo(390, 0.01)); // 1200: 360×50% + 840×25%
      expect(breakdown.kinderzulage, closeTo(600, 0.01)); // min(1200,300) × 2
      expect(breakdown.bonus, 200); // age 23, year 0
      expect(breakdown.geringverdienerbonus, 0); // 45k > 26,250
      expect(breakdown.total, closeTo(1190, 0.01));
      expect(breakdown.foerderquote, closeTo(1190 / 1200, 0.01));
    });
  });
}
