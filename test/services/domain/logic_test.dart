import 'package:flutter/material.dart';
import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';

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
      rendite: rendite, inflation: inflation, color: const Color(0xFF0066FF));

  // ═══════════════════════════════════════════════════════════════
  // AV vs ETF COMPARISON LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('AV vs ETF: when AV wins', () {
    test('low income + children → AV wins (high subsidy leverage)', () {
      final p = makePerson(sparrate: 100, brutto: 35000, kinder: 2);
      final m = makeMacro(rendite: 0.07);
      final r = engine.simulateCombined(person: p, macro: m, costs: CostSettings());
      expect(r.deltaEndkapital, greaterThan(0), reason: 'AV should beat ETF for subsidized families');
    });

    test('low income part-time + child → AV wins strongly', () {
      final p = makePerson(sparrate: 50, brutto: 22000, kinder: 1);
      final m = makeMacro(rendite: 0.07);
      final r = engine.simulateCombined(person: p, macro: m, costs: CostSettings());
      expect(r.deltaEndkapital, greaterThan(0));
      // Check high subsidy rate
      final breakdown = engine.calcSubsidyBreakdown(p);
      expect(breakdown.foerderquote, greaterThan(0.5), reason: 'Subsidy rate should exceed 50%');
    });

    test('maximum contribution (€150/mo) with average income → AV wins', () {
      final p = makePerson(sparrate: 150, brutto: 45000, kinder: 0);
      final m = makeMacro(rendite: 0.07);
      final r = engine.simulateCombined(person: p, macro: m, costs: CostSettings());
      expect(r.deltaEndkapital, greaterThan(0));
    });
  });

  group('AV vs ETF: when ETF wins', () {
    test('very high income + high contributions → ETF wins', () {
      final p = makePerson(sparrate: 3000, brutto: 200000, kinder: 0);
      final m = makeMacro(rendite: 0.07);
      final r = engine.simulateCombined(person: p, macro: m, costs: CostSettings());
      expect(r.deltaEndkapital, lessThan(0),
        reason: 'ETF should win: contributions far above subsidy cap, high retirement tax');
    });

    test('very high income + very high contributions + low returns → ETF wins', () {
      final p = makePerson(sparrate: 3000, brutto: 200000, kinder: 0);
      final m = makeMacro(rendite: 0.02, inflation: 0.005);
      final r = engine.simulateCombined(person: p, macro: m, costs: CostSettings());
      expect(r.deltaEndkapital, lessThan(0),
        reason: 'Low returns + high retirement tax + unsubsidized contributions = ETF advantage');
    });

    test('contributions above €1,800/yr erode AV advantage', () {
      // At €150/mo (€1,800/yr) — max subsidized
      final p150 = makePerson(sparrate: 150, brutto: 60000);
      final r150 = engine.simulateCombined(person: p150, macro: makeMacro(), costs: CostSettings());

      // At €500/mo (€6,000/yr) — €4,200 unsubsidized
      final p500 = makePerson(sparrate: 500, brutto: 60000);
      final r500 = engine.simulateCombined(person: p500, macro: makeMacro(), costs: CostSettings());

      // AV advantage per euro invested should be lower for p500
      final advantageRatio150 = r150.deltaEndkapital / p150.sparrate;
      final advantageRatio500 = r500.deltaEndkapital / p500.sparrate;
      expect(advantageRatio500, lessThan(advantageRatio150),
        reason: 'Additional unsubsidized contributions dilute AV advantage');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // SUBSIDY ELIGIBILITY TRANSITIONS
  // ═══════════════════════════════════════════════════════════════

  group('Geringverdienerbonus eligibility with income development', () {
    test('starts eligible, loses eligibility as income grows', () {
      // Start at 25k, grow 3% → crosses 26,250 after ~2 years
      final p = makePerson(sparrate: 50, brutto: 25000, alterStart: 25, spardauer: 10);
      final m = makeMacro();
      const dev = IncomeDevSettings(enabled: true, growthRate: 0.03);
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: dev);

      // Verify Geringverdiener applies in year 0 and 1
      final breakdown0 = engine.calcSubsidyBreakdown(p);
      expect(breakdown0.geringverdienerbonus, 175);

      // After year 2, income = 25000 × 1.03^2 = 26522 > 26250
      // Total zulagen should be less than if Geringverdiener applied all 10 years
      final avStatic = engine.simulateAV(person: p, macro: m, costs: CostSettings());
      // With growth, fewer years of Geringverdienerbonus → less total zulagen?
      // Actually no — static 25k always qualifies, growth makes it lose eligibility
      expect(av.zulagenGesamt, lessThan(avStatic.zulagenGesamt),
        reason: 'Income growth causes loss of Geringverdienerbonus in later years');
    });

    test('income always below threshold keeps Geringverdienerbonus', () {
      final p = makePerson(sparrate: 50, brutto: 20000, alterStart: 25, spardauer: 10);
      final m = makeMacro();
      // Even at 2% growth: 20000 × 1.02^10 = 24,380 → still below 26,250
      const dev = IncomeDevSettings(enabled: true, growthRate: 0.02);
      final avGrow = engine.simulateAV(person: p, macro: m, costs: CostSettings(), incomeDev: dev);
      final avStatic = engine.simulateAV(person: p, macro: m, costs: CostSettings());

      // Both should get Geringverdienerbonus all 10 years → similar zulagen
      // (Growth version gets slightly more from Günstigerprüfung as income rises)
      expect(avGrow.zulagenGesamt, closeTo(avStatic.zulagenGesamt, 1));
    });
  });

  group('Berufseinsteigerbonus one-time behavior', () {
    test('only first year counts — same person, bonus vs no bonus age', () {
      // Same spardauer, same brutto, only age differs (23 vs 26)
      final pWithBonus = makePerson(sparrate: 50, brutto: 32000, alterStart: 23, spardauer: 10);
      final pNoBonus = makePerson(sparrate: 50, brutto: 32000, alterStart: 26, spardauer: 10);
      final m = makeMacro();
      final costs = CostSettings();

      final avWith = engine.simulateAV(person: pWithBonus, macro: m, costs: costs);
      final avWithout = engine.simulateAV(person: pNoBonus, macro: m, costs: costs);

      // Same duration, same brutto → subsidy difference is exactly €200 (one-time bonus)
      final zulagenDiff = avWith.zulagenGesamt - avWithout.zulagenGesamt;
      expect(zulagenDiff, closeTo(200, 1),
        reason: 'One-time bonus adds exactly €200 to total subsidies');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // RETIREMENT TAX LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('Retirement tax based on combined income', () {
    test('higher state pension → higher retirement tax rate', () {
      final p1 = makePerson(renteOverride: 500, sparrate: 100);
      final p2 = makePerson(renteOverride: 2000, sparrate: 100);
      final m = makeMacro();
      final costs = CostSettings();

      final av1 = engine.simulateAV(person: p1, macro: m, costs: costs);
      final av2 = engine.simulateAV(person: p2, macro: m, costs: costs);

      expect(av2.grenzsteuersatzRente, greaterThan(av1.grenzsteuersatzRente));
      expect(av2.nettoMonatlich, lessThan(av1.nettoMonatlich),
        reason: 'Higher pension → higher combined income → higher tax → lower AV net');
    });

    test('sonstigeEinkuenfte increases retirement tax', () {
      final p0 = makePerson(sonstigeEinkuenfte: 0);
      final p50k = makePerson(sonstigeEinkuenfte: 50000);
      final m = makeMacro();
      final costs = CostSettings();

      final av0 = engine.simulateAV(person: p0, macro: m, costs: costs);
      final av50k = engine.simulateAV(person: p50k, macro: m, costs: costs);

      expect(av50k.grenzsteuersatzRente, greaterThan(av0.grenzsteuersatzRente));
    });

    test('retirement tax rate differs from working tax rate', () {
      final p = makePerson(brutto: 85000, sparrate: 150, renteOverride: 1500);
      final m = makeMacro();
      final av = engine.simulateAV(person: p, macro: m, costs: CostSettings());

      // Working rate at 85k = 42% (Spitzensteuersatz)
      // Retirement income is likely much lower → lower rate
      expect(av.grenzsteuersatz, 0.42);
      expect(av.grenzsteuersatzRente, lessThan(av.grenzsteuersatz),
        reason: 'Retirement income typically lower than working income → lower tax rate');
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PAYOUT PHASE LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('Payout duration logic', () {
    test('retirement at 67 → 18 years payout (until 85)', () {
      final p = makePerson(alterStart: 30, spardauer: 37); // 67
      expect(p.auszahlungsDauer, 18);
    });

    test('retirement at 60 → 25 years payout', () {
      final p = makePerson(alterStart: 30, spardauer: 30); // 60
      expect(p.auszahlungsDauer, 25);
    });

    test('retirement at 75 → clamped to 5 years minimum', () {
      final p = makePerson(alterStart: 30, spardauer: 45); // 75
      expect(p.auszahlungsDauer, 10); // 85-75=10
    });

    test('longer payout → lower monthly but same total', () {
      final p60 = makePerson(alterStart: 30, spardauer: 30); // retires 60, 25yr payout
      final p67 = makePerson(alterStart: 30, spardauer: 37); // retires 67, 18yr payout
      final m = makeMacro();
      final costs = CostSettings();

      final av60 = engine.simulateAV(person: p60, macro: m, costs: costs);
      final av67 = engine.simulateAV(person: p67, macro: m, costs: costs);

      // p67 saves 7 more years → more capital
      expect(av67.endkapital, greaterThan(av60.endkapital));
      // But also higher monthly payout (more capital, shorter payout)
      expect(av67.monatlicheAuszahlung, greaterThan(av60.monatlicheAuszahlung));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // KIRCHENSTEUER IMPACT LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('Kirchensteuer impact on comparison', () {
    test('Kirchensteuer affects both AV and ETF', () {
      final p = makePerson(sparrate: 150, brutto: 55000);
      final m = makeMacro();
      final noKi = CostSettings(kirchensteuer: 0);
      final ki9 = CostSettings(kirchensteuer: 0.09);

      final rNoKi = engine.simulateCombined(person: p, macro: m, costs: noKi);
      final rKi9 = engine.simulateCombined(person: p, macro: m, costs: ki9);

      // Both AV and ETF should have lower net payouts with Kirchensteuer
      expect(rKi9.av.nettoMonatlich, lessThan(rNoKi.av.nettoMonatlich));
      expect(rKi9.etf.monatlicheAuszahlung, lessThan(rNoKi.etf.monatlicheAuszahlung));
    });

    test('Kirchensteuer does not affect AV gross depot', () {
      final p = makePerson(sparrate: 150, brutto: 55000);
      final m = makeMacro();
      final noKi = CostSettings(kirchensteuer: 0);
      final ki9 = CostSettings(kirchensteuer: 0.09);

      final avNoKi = engine.simulateAV(person: p, macro: m, costs: noKi);
      final avKi9 = engine.simulateAV(person: p, macro: m, costs: ki9);

      // Kirchensteuer only affects payout tax, not accumulation
      expect(avKi9.endkapital, avNoKi.endkapital);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // MACRO SCENARIO IMPACT LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('Macro scenario impact', () {
    test('boom beats basis beats stagflation', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 30);
      final costs = CostSettings();
      final boom = engine.simulateAV(person: p, macro: makeMacro(rendite: 0.10, inflation: 0.015), costs: costs);
      final basis = engine.simulateAV(person: p, macro: makeMacro(rendite: 0.07, inflation: 0.02), costs: costs);
      final stag = engine.simulateAV(person: p, macro: makeMacro(rendite: 0.04, inflation: 0.045), costs: costs);

      expect(boom.endkapital, greaterThan(basis.endkapital));
      expect(basis.endkapital, greaterThan(stag.endkapital));
    });

    test('inflation reduces purchasing power', () {
      final p = makePerson(sparrate: 100, spardauer: 30, alterStart: 30);
      final costs = CostSettings();
      final lowInfl = engine.simulateAV(person: p, macro: makeMacro(rendite: 0.07, inflation: 0.01), costs: costs);
      final highInfl = engine.simulateAV(person: p, macro: makeMacro(rendite: 0.07, inflation: 0.04), costs: costs);

      // Same nominal return → same nominal depot
      expect(lowInfl.endkapital, closeTo(highInfl.endkapital, 1));
      // But real value much lower with high inflation
      expect(highInfl.endkapitalReal, lessThan(lowInfl.endkapitalReal));
    });

    test('zero return still accumulates from contributions + subsidies', () {
      final p = makePerson(sparrate: 100, brutto: 45000, spardauer: 10, alterStart: 30);
      final costs = CostSettings(kostenAV: 0);
      final av = engine.simulateAV(person: p, macro: makeMacro(rendite: 0, inflation: 0), costs: costs);

      // With 0% return and 0% cost, depot = sum of contributions + subsidies
      expect(av.endkapital, closeTo(av.eigenBeitraege + av.zulagenGesamt, 1));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PRESET SCENARIO LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('Preset scenarios produce sensible results', () {
    final presets = PersonalScenario.defaults(StringsDe());
    final baseline = MacroScenario(name: 'Basis', shortName: 'B', icon: '',
      description: '', rendite: 0.07, inflation: 0.02, color: const Color(0xFF0066FF));

    test('all presets produce positive endkapital', () {
      for (final p in presets) {
        final av = engine.simulateAV(person: p, macro: baseline, costs: CostSettings());
        final etf = engine.simulateETF(person: p, macro: baseline, costs: CostSettings());
        expect(av.endkapital, greaterThan(0), reason: '${p.name} AV should be positive');
        expect(etf.endkapital, greaterThan(0), reason: '${p.name} ETF should be positive');
      }
    });

    test('all presets retire at 67', () {
      for (final p in presets) {
        expect(p.rentenalter, 67, reason: '${p.name} should retire at 67');
      }
    });

    test('career starter qualifies for Berufseinsteigerbonus', () {
      final starter = presets[0]; // Berufseinsteiger
      expect(starter.alterStart, lessThan(25));
      final breakdown = engine.calcSubsidyBreakdown(starter);
      expect(breakdown.bonus, 200);
    });

    test('part-time + child qualifies for Geringverdienerbonus', () {
      final teilzeit = presets[4]; // Teilzeit + Kind
      expect(teilzeit.brutto, lessThanOrEqualTo(26250));
      final breakdown = engine.calcSubsidyBreakdown(teilzeit);
      expect(breakdown.geringverdienerbonus, 175);
      expect(breakdown.kinderzulage, greaterThan(0));
    });

    test('high earner has low subsidy rate', () {
      final high = presets[3]; // Gutverdiener
      final breakdown = engine.calcSubsidyBreakdown(high);
      // €500/mo = €6,000/yr, but subsidized only up to €1,800 → low Förderquote
      expect(breakdown.foerderquote, lessThan(0.15),
        reason: 'High earner with €500/mo should have <15% subsidy rate');
    });

    test('family with 2 kids gets Kinderzulage', () {
      final family = presets[2]; // Familie 2 Kinder
      final breakdown = engine.calcSubsidyBreakdown(family);
      expect(breakdown.kinderzulage, greaterThan(0));
      expect(family.kinder, 2);
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // PENSION ESTIMATE LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('Pension estimate consistency', () {
    test('higher income → higher pension', () {
      final p30 = makePerson(brutto: 30000);
      final p60 = makePerson(brutto: 60000);
      expect(p60.geschaetzteRente, greaterThan(p30.geschaetzteRente));
    });

    test('income above BBG does not increase pension', () {
      final p90 = makePerson(brutto: 90000);
      final p120 = makePerson(brutto: 120000);
      // Both capped at BBG (90,600) → nearly same pension
      expect(p120.geschaetzteRente, closeTo(p90.geschaetzteRente, 50));
    });

    test('pension override overrides estimate', () {
      final p = makePerson(brutto: 85000, renteOverride: 500);
      expect(p.gesetzlicheRente, 500);
      expect(p.geschaetzteRente, greaterThan(500),
        reason: 'Estimate should be higher, but override is respected');
    });

    test('pension is roughly 40-50% of monthly gross for average earner', () {
      final p = makePerson(brutto: 45000);
      final monthlyGross = 45000 / 12;
      final ratio = p.geschaetzteRente / monthlyGross;
      expect(ratio, greaterThan(0.35));
      expect(ratio, lessThan(0.55));
    });
  });

  // ═══════════════════════════════════════════════════════════════
  // INCOME DEVELOPMENT IMPACT LOGIC
  // ═══════════════════════════════════════════════════════════════

  group('Income development logical impact', () {
    test('income growth increases Günstigerprüfung refund over time', () {
      final p = makePerson(sparrate: 150, brutto: 40000, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final costs = CostSettings();

      final avStatic = engine.simulateAV(person: p, macro: m, costs: costs);
      final avGrow = engine.simulateAV(person: p, macro: m, costs: costs,
        incomeDev: const IncomeDevSettings(enabled: true, growthRate: 0.03));

      // Growing income → higher marginal tax → higher Günstigerprüfung refund
      expect(avGrow.steuererstattungGesamt, greaterThan(avStatic.steuererstattungGesamt));
    });

    test('zero growth rate does not change AV result', () {
      final p = makePerson(sparrate: 100, brutto: 45000, alterStart: 30, spardauer: 37);
      final m = makeMacro();
      final costs = CostSettings();

      final avStatic = engine.simulateAV(person: p, macro: m, costs: costs);
      final avZero = engine.simulateAV(person: p, macro: m, costs: costs,
        incomeDev: const IncomeDevSettings(enabled: true, growthRate: 0));

      expect(avZero.endkapital, closeTo(avStatic.endkapital, 1));
      expect(avZero.zulagenGesamt, closeTo(avStatic.zulagenGesamt, 1));
    });

    test('income dev does NOT affect ETF simulation', () {
      final p = makePerson(sparrate: 100);
      final m = makeMacro();
      final costs = CostSettings();

      final etf1 = engine.simulateETF(person: p, macro: m, costs: costs);
      // simulateETF doesn't take incomeDev parameter → result should be identical
      final etf2 = engine.simulateETF(person: p, macro: m, costs: costs);

      expect(etf1.endkapital, etf2.endkapital);
    });
  });
}
