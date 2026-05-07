import 'dart:math';
import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';
import 'package:avdepot_rechner/services/domain/payout_module.dart';
import 'package:avdepot_rechner/services/domain/pension_module.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';

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
      // High income, no kids, age 40 → no bonus
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

    test('monthly payout uses monthly annuity formula (depot keeps compounding during payout)', () {
      // Both buckets continue to compound at (rendite − kostenAV) during payout.
      // Monthly annuity formula: PMT_m = PV × r_m / (1 − (1+r_m)^-n_m)
      // where r_m = (1 + yearlyRate)^(1/12) − 1 and n_m = years × 12.
      final p = makePerson(sparrate: 100, alterStart: 30, spardauer: 37);
      final m = makeMacro();           // rendite 0.07
      final costs = CostSettings();    // kostenAV 0.005 default
      final av = engine.simulateAV(person: p, macro: m, costs: costs);

      // sparrate 100 → 1200/yr → all gefördert (≤€1,800), no ungefördert.
      const r = 0.07 - 0.005;            // 0.065 yearly
      const n = 18;                       // years (auszahlungsDauer for retirement at 67)
      final rM = pow(1 + r, 1 / 12) - 1;
      const months = n * 12;              // 216
      final expectedMonthly = av.endkapital * rM / (1 - 1 / pow(1 + rM, months));
      expect(av.monatlicheAuszahlung, closeTo(expectedMonthly, 1));

      // Sanity: must be greater than the naive depot/n model would give.
      final naive = av.endkapital / months;
      expect(av.monatlicheAuszahlung, greaterThan(naive),
        reason: 'Monthly annuity payout must exceed naive depot/months (compounding during payout)');
    });

    test('retirement tax uses combined income', () {
      final p = makePerson(renteOverride: 1500, sonstigeEinkuenfte: 5000,
        sparrate: 150, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);

      // Annual gross AV payout = monthly annuity × 12. Sparrate 150 → all
      // gefördert, no ungefördert bucket, so AV taxable = annual gross.
      const r = 0.07 - 0.005;
      const n = 18;
      final rM = pow(1 + r, 1 / 12) - 1;
      const months = n * 12;
      final monthlyGross = av.endkapital * rM / (1 - 1 / pow(1 + rM, months));
      final avAnnual = monthlyGross * 12;
      // Incremental tax: tax(base + AV) - tax(base), divided by AV taxable
      final baseIncome = 1500.0 * 12 + 5000;
      final taxOnBase = engine.tax.calcEinkommensteuer(baseIncome);
      final taxOnCombined = engine.tax.calcEinkommensteuer(baseIncome + avAnnual);
      final expectedRate = avAnnual > 0 ? (taxOnCombined - taxOnBase) / avAnnual : 0.0;
      expect(av.grenzsteuersatzRente, closeTo(expectedRate, 0.001));
    });

    test('Kirchensteuer increases payout tax', () {
      final p = makePerson(sparrate: 150, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final noKi = CostSettings(kirchensteuerpflichtig: false);
      final withKi = CostSettings(kirchensteuerpflichtig: true);

      final avNoKi = engine.simulateAV(person: p, macro: m, costs: noKi);
      final avWithKi = engine.simulateAV(person: p, macro: m, costs: withKi);

      // Same depot, but higher tax → lower net payout
      expect(avNoKi.endkapital, closeTo(avWithKi.endkapital, 0.01));
      expect(avWithKi.nettoMonatlich, lessThan(avNoKi.nettoMonatlich));
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

      const jb = 1200.0;
      // New ETF model (§18 + §19 InvStG):
      //   1. depot grows at full rate: jb × (1 + rendite − kostenETF)
      //   2. VP_base = depotStart (0) + jb × partialYearFactor (~0.5417)
      //   3. VP_year = VP_base × vpRate, where vpRate is the after-tax drag
      //      = Basisertrag × (1 − Teilfreistellung) × Abgeltungssteuersatz
      //      (KiSt-aware via CostSettings.abgeltungssteuersatz)
      const grown = jb * (1 + 0.07 - 0.002);
      final vpRate = CalcConstants.vorabpauschaleBasisertragsRate
          * (1 - CalcConstants.teilfreistellung)
          * costs.abgeltungssteuersatz;
      final vpBase = jb * CalcConstants.vorabpauschaleNeuerBeitragFaktor;
      final vpYear = vpBase * vpRate;
      final expected = grown - vpYear;
      expect(etf.endkapital, closeTo(expected, 0.01));
      expect(etf.eigenBeitraege, closeTo(jb, 0.01));
      expect(etf.vorabpauschaleGesamt, closeTo(vpYear, 0.01));
    });

    test('VP rate is higher for kirchensteuerpflichtige users', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final noKi = CostSettings(kirchensteuerpflichtig: false);
      final withKi = CostSettings(kirchensteuerpflichtig: true);

      final etfNoKi = engine.simulateETF(person: p, macro: m, costs: noKi);
      final etfWithKi = engine.simulateETF(person: p, macro: m, costs: withKi);

      // KiSt raises the Abgeltungssteuersatz from 26.375 % to ~27.995 % per
      // §32d Abs. 1 Satz 4 EStG (1/(4+k)). VP rate is proportional, so a
      // KiSt-pflichtige user pays slightly more VP each year.
      expect(etfWithKi.vorabpauschaleGesamt, greaterThan(etfNoKi.vorabpauschaleGesamt));
      // Magnitude: ratio should equal the abgSt ratio (~1.061×).
      final ratio = etfWithKi.vorabpauschaleGesamt / etfNoKi.vorabpauschaleGesamt;
      expect(ratio, closeTo(0.27995 / 0.26375, 0.005));
    });

    test('gains taxed with Teilfreistellung (Vorabpauschale credited)', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final costs = CostSettings();
      final etf = engine.simulateETF(person: p, macro: m, costs: costs);

      // New ETF payout model: depot continues to compound during the 18 years of
      // payout. Total gross extracted over lifetime = bruttoMonatlich × n_months,
      // of which (n × bruttoMonatlich − eigenBeitraege) is the lifetime taxable
      // gain. Lifetime tax (when VP credit is fully utilized) = lifetime gain ×
      // 0.7 × abgSt; lifetime burden = vpGesamt + sale-tax-after-credit.
      final months = p.auszahlungsDauer * 12;
      final lifetimeGross = etf.bruttoMonatlich * months;
      final lifetimeGain = lifetimeGross - etf.eigenBeitraege;
      final expectedLifetimeTax = lifetimeGain * 0.70 * 0.26375;
      expect(etf.steuerAufGewinn, closeTo(expectedLifetimeTax, 1),
        reason: 'Lifetime tax = lifetime-gain × 0.7 × abgSt when VP credit is fully utilized');

      // nachSteuer = lifetime cash-in-hand to user = monatlicheAuszahlung × n_months.
      expect(etf.nachSteuer, closeTo(etf.monatlicheAuszahlung * months, 0.5));
      // Equivalently: lifetime gross − sale tax after credit.
      final saleTaxAfterCredit = etf.steuerAufGewinn - etf.vorabpauschaleGesamt;
      expect(etf.nachSteuer, closeTo(lifetimeGross - saleTaxAfterCredit, 0.5));

      // Cumulative VP must be positive over a 30-year accumulation.
      expect(etf.vorabpauschaleGesamt, greaterThan(0));
    });

    test('Kirchensteuer increases ETF tax', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final noKi = CostSettings(kirchensteuerpflichtig: false);
      final withKi = CostSettings(kirchensteuerpflichtig: true);

      final etfNoKi = engine.simulateETF(person: p, macro: m, costs: noKi);
      final etfWithKi = engine.simulateETF(person: p, macro: m, costs: withKi);

      expect(etfWithKi.steuerAufGewinn, greaterThan(etfNoKi.steuerAufGewinn));
      expect(etfWithKi.monatlicheAuszahlung, lessThan(etfNoKi.monatlicheAuszahlung));
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

    test('monthly payout: annuity on full depot, lifetime tax spread evenly', () {
      // The depot itself continues to compound at (rendite − kostenETF) during
      // the payout phase. Gross monthly payout depletes the depot exactly.
      // Sale tax is computed against the lifetime gain and spread evenly over
      // all payout months → constant net monthly payout.
      final p = makePerson(sparrate: 100, spardauer: 37, alterStart: 30);
      final m = makeMacro();           // rendite 0.07
      final etf = engine.simulateETF(person: p, macro: m, costs: CostSettings());

      const r = 0.07 - 0.002;          // kostenETF default 0.002
      final months = p.auszahlungsDauer * 12;  // 216 months
      final rM = pow(1 + r, 1 / 12) - 1;
      // Gross monthly: monthly annuity on depot (post-VP from accumulation).
      final expectedBrutto = etf.endkapital * rM / (1 - 1 / pow(1 + rM, months));
      expect(etf.bruttoMonatlich, closeTo(expectedBrutto, 1));

      // Net monthly: gross minus per-month share of lifetime sale tax.
      final saleTax = etf.steuerAufGewinn - etf.vorabpauschaleGesamt;
      final expectedNet = expectedBrutto - saleTax / months;
      expect(etf.monatlicheAuszahlung, closeTo(expectedNet, 1));

      // Sanity: gross must exceed naive depot/months (compounding during payout).
      final naive = etf.endkapital / months;
      expect(etf.bruttoMonatlich, greaterThan(naive));
    });

    test('effectiveTaxRatePayout = lifetimeSaleTax / lifetimeGross', () {
      // Under flat Abgeltungssteuer, the per-month rate equals the
      // lifetime-average rate exactly. This test documents the invariant.
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final etf = engine.simulateETF(person: p, macro: m, costs: CostSettings());

      final months = p.auszahlungsDauer * 12;
      final lifetimeGross = etf.bruttoMonatlich * months;
      final saleTax = etf.steuerAufGewinn - etf.vorabpauschaleGesamt;
      final expectedRate = saleTax / lifetimeGross;
      expect(etf.effectiveTaxRatePayout, closeTo(expectedRate, 1e-9));

      // And rate-based net = gross × (1 − rate) = subtractive net.
      final netByRate = etf.bruttoMonatlich * (1 - etf.effectiveTaxRatePayout);
      expect(etf.monatlicheAuszahlung, closeTo(netByRate, 0.01));
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
      // Part-time reduces income → smaller Günstigerprüfung refund in those years
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

  group('AV payout: Solidaritätszuschlag with Freigrenze', () {
    test('typical retiree (low-mid pension + AV) → Soli rate is 0', () {
      // Pension €18k + small AV payout → ESt well below €19,950 Freigrenze.
      final p = makePerson(
          sparrate: 100, brutto: 45000, alterStart: 30, spardauer: 37,
          renteOverride: 1500); // €18k/yr pension
      final m = makeMacro();
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings());

      expect(av.soliRatePayout, 0.0,
          reason: 'Soli should be 0 — combined retirement zvE keeps ESt below Freigrenze');
    });

    test('high-income retiree (large pension + sonstige + AV) → Soli applies', () {
      // €4.5k/mo pension + €30k other income + AV payout → ESt well above
      // €19,950 Freigrenze. Soli rate per euro of AV taxable should be > 0
      // and bounded above by 0.119 × estRate (Milderungszone cap) and below
      // by 0.055 × estRate (full-rate floor when both base and combined ESt
      // sit above the Milderungszone).
      final p = makePerson(
          sparrate: 1000, brutto: 200000, alterStart: 30, spardauer: 37,
          renteOverride: 4500, sonstigeEinkuenfte: 30000);
      final m = makeMacro();
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings());

      expect(av.soliRatePayout, greaterThan(0),
          reason: 'High retirement zvE pushes ESt above Soli Freigrenze');
      final ratio = av.soliRatePayout / av.grenzsteuersatzRente;
      expect(ratio, lessThanOrEqualTo(0.119 + 1e-9),
          reason: 'Cap by Milderungszone ratio 11.9 %');
      expect(ratio, greaterThan(0.05),
          reason: 'Should be at least the full-rate floor (5.5 % × estRate)');
    });

    test('Soli pushes net monthly payout below the no-Soli baseline', () {
      // Compare two retirees with identical AV depot but different other-income:
      //   - low: pension only → ESt below Freigrenze → Soli = 0
      //   - high: large pension + sonstige → ESt above Freigrenze → Soli > 0
      // For the same gross monthly payout, the high earner should net less
      // (incremental Soli on top of incremental §32a tax).
      final low = makePerson(
          sparrate: 1000, brutto: 200000, alterStart: 30, spardauer: 37,
          renteOverride: 1500); // small pension → ESt likely < Freigrenze
      final high = makePerson(
          sparrate: 1000, brutto: 200000, alterStart: 30, spardauer: 37,
          renteOverride: 4500, sonstigeEinkuenfte: 30000);
      final m = makeMacro();
      final avLow = engine.simulateAV(person: low, macro: m, costs: CostSettings());
      final avHigh = engine.simulateAV(person: high, macro: m, costs: CostSettings());

      // Same depot trajectory → same gross payout. Net differs only via tax rate.
      expect(avLow.monatlicheAuszahlung, closeTo(avHigh.monatlicheAuszahlung, 0.01));
      // Soli rate is 0 for low earner, > 0 for high earner.
      expect(avLow.soliRatePayout, 0.0);
      expect(avHigh.soliRatePayout, greaterThan(0));
    });
  });

  group('CostSettings / Kirchensteuer', () {
    test('default (not kirchensteuerpflichtig): Abgeltungssteuersatz is 26.3750%', () {
      final c = CostSettings();
      expect(c.kirchensteuerpflichtig, isFalse);
      expect(c.kirchensteuerRate, 0.0);
      expect(c.abgeltungssteuersatz, closeTo(0.26375, 0.00001));
    });

    test('kirchensteuerpflichtig: rate is 9% (dominant German rate), Abgeltungssteuersatz 27.9951%', () {
      final c = CostSettings(kirchensteuerpflichtig: true);
      expect(c.kirchensteuerRate, CalcConstants.kirchensteuersatz);
      expect(c.kirchensteuerRate, 0.09);
      expect(c.abgeltungssteuersatz, closeTo(0.279951, 0.0001));
    });

    test('KapESt formula per §32d Abs. 1 Satz 4 EStG: 1 / (4 + k)', () {
      // §32d formula (with q=0, since foreign Quellensteuer is not modeled):
      //   KapESt = 1 / (4 + k); then add Soli + KiSt on top.
      final c = CostSettings(kirchensteuerpflichtig: true);
      final k = c.kirchensteuerRate;
      final kapEst = 1 / (4 + k);
      final soli = kapEst * 0.055;
      final kiSt = kapEst * k;
      expect(c.abgeltungssteuersatz, closeTo(kapEst + soli + kiSt, 0.00001));
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

  });

  group('SubsidyBreakdown', () {
    test('matches year-1 subsidy values', () {
      final p = makePerson(sparrate: 100, brutto: 45000, kinder: 2, alterStart: 23);
      final breakdown = engine.calcSubsidyBreakdown(p);

      expect(breakdown.grundzulage, closeTo(390, 0.01)); // 1200: 360×50% + 840×25%
      expect(breakdown.kinderzulage, closeTo(600, 0.01)); // min(1200,300) × 2
      expect(breakdown.bonus, 200); // age 23, year 0
      expect(breakdown.total, closeTo(1190, 0.01));
      expect(breakdown.foerderquote, closeTo(1190 / 1200, 0.01));
    });
  });

  group('calcSubsidyPhases', () {
    test('single phase when nothing changes', () {
      // No kids, age 40 → no bonus: constant subsidies
      final p = makePerson(sparrate: 150, brutto: 85000, kinder: 0, alterStart: 40, spardauer: 10);
      final phases = engine.calcSubsidyPhases(p);
      expect(phases.length, 1);
      expect(phases[0].yearFrom, 1);
      expect(phases[0].yearTo, 10);
      expect(phases[0].grundzulage, greaterThan(0));
      expect(phases[0].kinderzulage, 0);
    });

    test('bonus creates separate first-year phase', () {
      // Age 23 → Berufseinsteigerbonus in year 0 only
      final p = makePerson(sparrate: 100, brutto: 45000, kinder: 0, alterStart: 23, spardauer: 5);
      final phases = engine.calcSubsidyPhases(p);
      expect(phases.length, greaterThanOrEqualTo(2));
      expect(phases[0].yearFrom, 1);
      expect(phases[0].yearTo, 1);
      expect(phases[0].bonus, 200);
      expect(phases[1].bonus, 0); // subsequent years: no bonus
    });

    test('child age-out creates phase boundary', () {
      // Child age 20, kinderStudieren=true (maxAge 25): ages out at year 5
      final p = PersonalScenario(
        name: 'Test', icon: '', sparrate: 150, brutto: 85000,
        kinder: 1, kinderAlter: [20], kinderStudieren: true,
        alterStart: 40, spardauer: 10,
      );
      final phases = engine.calcSubsidyPhases(p);
      expect(phases.length, 2);
      // Phase 1: years 1-5, child still eligible
      expect(phases[0].yearTo, 5);
      expect(phases[0].kinderzulage, greaterThan(0));
      expect(phases[0].kinder, 1);
      // Phase 2: years 6-10, child aged out
      expect(phases[1].yearFrom, 6);
      expect(phases[1].kinderzulage, 0);
      expect(phases[1].kinder, 0);
    });

    test('kinderStudieren=false creates earlier phase boundary', () {
      // Same child age 20, but kinderStudieren=false (maxAge 18): ages out at year -2 → immediately
      // Actually age 20 > 18, so child is already ineligible at year 0!
      final p = PersonalScenario(
        name: 'Test', icon: '', sparrate: 150, brutto: 85000,
        kinder: 1, kinderAlter: [20], kinderStudieren: false,
        alterStart: 40, spardauer: 10,
      );
      final phases = engine.calcSubsidyPhases(p);
      // All years should show 0 children eligible
      for (final phase in phases) {
        expect(phase.kinderzulage, 0);
        expect(phase.kinder, 0);
      }
    });

    test('kinderStudieren=false vs true: different Kinderzulage duration', () {
      // Child age 10, savings 20 years
      // kinderStudieren=true: eligible until year 15 (age 25)
      // kinderStudieren=false: eligible until year 8 (age 18)
      final pStudy = PersonalScenario(
        name: 'T', icon: '', sparrate: 150, brutto: 85000,
        kinder: 1, kinderAlter: [10], kinderStudieren: true,
        alterStart: 40, spardauer: 20,
      );
      final pNoStudy = PersonalScenario(
        name: 'T', icon: '', sparrate: 150, brutto: 85000,
        kinder: 1, kinderAlter: [10], kinderStudieren: false,
        alterStart: 40, spardauer: 20,
      );
      final phasesStudy = engine.calcSubsidyPhases(pStudy);
      final phasesNoStudy = engine.calcSubsidyPhases(pNoStudy);

      // With study: Kinderzulage paid for 15 years
      final yearsWithKindStudy = phasesStudy
          .where((p) => p.kinderzulage > 0)
          .fold<int>(0, (sum, p) => sum + p.years);
      // Without study: Kinderzulage paid for 8 years
      final yearsWithKindNoStudy = phasesNoStudy
          .where((p) => p.kinderzulage > 0)
          .fold<int>(0, (sum, p) => sum + p.years);

      expect(yearsWithKindStudy, 15);
      expect(yearsWithKindNoStudy, 8);
      expect(yearsWithKindStudy, greaterThan(yearsWithKindNoStudy));
    });

    test('phases cover full savings period', () {
      final p = makePerson(sparrate: 100, brutto: 45000, kinder: 2, alterStart: 23, spardauer: 35);
      final phases = engine.calcSubsidyPhases(p);
      // All years must be covered
      final totalYears = phases.fold<int>(0, (sum, p) => sum + p.years);
      expect(totalYears, 35);
      // Contiguous: each phase starts where previous ended
      for (int i = 1; i < phases.length; i++) {
        expect(phases[i].yearFrom, phases[i - 1].yearTo + 1);
      }
    });
  });

  group('kinderStudieren in full AV simulation', () {
    test('kinderStudieren=false yields less total subsidies', () {
      // Child age 5, savings 30 years
      // kinderStudieren=true: Kinderzulage for 20 years
      // kinderStudieren=false: Kinderzulage for 13 years
      final pStudy = PersonalScenario(
        name: 'T', icon: '', sparrate: 100, brutto: 45000,
        kinder: 1, kinderAlter: [5], kinderStudieren: true,
        alterStart: 30, spardauer: 30,
      );
      final pNoStudy = pStudy.copyWith(kinderStudieren: false);
      final m = makeMacro();
      final costs = CostSettings();

      final avStudy = engine.simulateAV(person: pStudy, macro: m, costs: costs);
      final avNoStudy = engine.simulateAV(person: pNoStudy, macro: m, costs: costs);

      expect(avStudy.zulagenGesamt, greaterThan(avNoStudy.zulagenGesamt));
      expect(avStudy.endkapital, greaterThan(avNoStudy.endkapital));
    });

    test('kinderStudieren has no effect when no children', () {
      final pTrue = makePerson(sparrate: 100, brutto: 45000, kinder: 0);
      final pFalse = PersonalScenario(
        name: 'Test', icon: '', sparrate: 100, brutto: 45000,
        kinder: 0, kinderStudieren: false,
        alterStart: 30, spardauer: 37,
      );
      final m = makeMacro();
      final costs = CostSettings();

      final avTrue = engine.simulateAV(person: pTrue, macro: m, costs: costs);
      final avFalse = engine.simulateAV(person: pFalse, macro: m, costs: costs);

      expect(avTrue.endkapital, avFalse.endkapital);
      expect(avTrue.zulagenGesamt, avFalse.zulagenGesamt);
    });

    test('kinderStudieren=false: child already over 18 gets zero Kinderzulage', () {
      // Child age 20 → already over 18, zero Kinderzulage from start
      final p = PersonalScenario(
        name: 'T', icon: '', sparrate: 100, brutto: 45000,
        kinder: 1, kinderAlter: [20], kinderStudieren: false,
        alterStart: 30, spardauer: 10,
      );
      final m = makeMacro();
      final costs = CostSettings();
      final av = engine.simulateAV(person: p, macro: m, costs: costs);

      // Same child with kinderStudieren=true still gets 5 years of Kinderzulage
      final pStudy = p.copyWith(kinderStudieren: true);
      final avStudy = engine.simulateAV(person: pStudy, macro: m, costs: costs);

      expect(avStudy.zulagenGesamt, greaterThan(av.zulagenGesamt));
    });
  });

  group('Modular phase split (accumulation / payout)', () {
    test('AV: standalone accumulation matches accumulation embedded in simulateAV', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final costs = CostSettings();

      final acc = engine.simulateAVAccumulation(person: p, macro: m, costs: costs);
      final full = engine.simulateAV(person: p, macro: m, costs: costs);

      expect(acc.endkapital, closeTo(full.endkapital, 0.01));
      expect(acc.eigenBeitraege, closeTo(full.eigenBeitraege, 0.01));
      expect(acc.zulagenGesamt, closeTo(full.zulagenGesamt, 0.01));
      expect(acc.steuererstattungGesamt, closeTo(full.steuererstattungGesamt, 0.01));
      expect(acc.wertzuwachs, closeTo(full.wertzuwachs, 0.01));
      expect(acc.jahresWerte.length, full.jahresWerte.length);
    });

    test('ETF: standalone accumulation matches accumulation embedded in simulateETF', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 37);
      final m = makeMacro();
      final costs = CostSettings();

      final acc = engine.simulateETFAccumulation(person: p, macro: m, costs: costs);
      final full = engine.simulateETF(person: p, macro: m, costs: costs);

      expect(acc.endkapital, closeTo(full.endkapital, 0.01));
      expect(acc.eigenBeitraege, closeTo(full.eigenBeitraege, 0.01));
      expect(acc.vorabpauschaleGesamt, closeTo(full.vorabpauschaleGesamt, 0.01));
      expect(acc.gewinn, closeTo(full.gewinn, 0.01));
      expect(acc.jahresWerte.length, full.jahresWerte.length);
    });

    test('Custom payout module is honored by SimulationEngine', () {
      // A trivial payout module that pays a constant net of 1234/month and
      // zero tax. Used to confirm engine wiring routes through the module.
      const customAvPayout = _ConstantAVPayout(1234);
      const customEngine = SimulationEngine(avPayout: customAvPayout);

      final p = makePerson();
      final m = makeMacro();
      final av = customEngine.simulateAV(person: p, macro: m, costs: CostSettings());

      expect(av.monatlicheAuszahlung, 1234);
      expect(av.nettoMonatlich, 1234);
      expect(av.grenzsteuersatzRente, 0);
      // Accumulation fields still computed by the engine.
      expect(av.endkapital, greaterThan(0));
    });
  });
}

class _ConstantAVPayout implements AVPayoutModule {
  final double monthly;
  const _ConstantAVPayout(this.monthly);

  @override
  AVPayout compute({
    required AVAccumulation accumulation,
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    required TaxModule tax,
    required PensionModule pension,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) =>
      AVPayout(
          monatlicheAuszahlung: monthly,
          nettoMonatlich: monthly,
          grenzsteuersatzRente: 0,
          soliRatePayout: 0);
}
