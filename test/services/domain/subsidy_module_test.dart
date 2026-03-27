import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/services/domain/subsidy_module.dart';

void main() {
  const subsidy = AVDepotSubsidy2027();

  group('Grundzulage', () {
    test('zero contribution returns zero', () {
      expect(subsidy.calcGrundzulage(0), 0);
    });

    test('negative contribution returns zero', () {
      expect(subsidy.calcGrundzulage(-100), 0);
    });

    test('minimum contribution (€120/yr) gets 50%', () {
      expect(subsidy.calcGrundzulage(120), closeTo(60, 0.01));
    });

    test('at first tier cap (€360) gets max first tier', () {
      expect(subsidy.calcGrundzulage(360), closeTo(180, 0.01));
    });

    test('above first tier (€600) adds second tier', () {
      // 360 × 50% + 240 × 25% = 180 + 60 = 240
      expect(subsidy.calcGrundzulage(600), closeTo(240, 0.01));
    });

    test('at €1,200 gets both tiers', () {
      // 360 × 50% + 840 × 25% = 180 + 210 = 390
      expect(subsidy.calcGrundzulage(1200), closeTo(390, 0.01));
    });

    test('at max contribution (€1,800) gets max subsidy (€540)', () {
      expect(subsidy.calcGrundzulage(1800), closeTo(540, 0.01));
    });

    test('above max (€2,400) is capped at €540', () {
      expect(subsidy.calcGrundzulage(2400), closeTo(540, 0.01));
    });

    test('above max (€36,000) is still capped at €540', () {
      expect(subsidy.calcGrundzulage(36000), closeTo(540, 0.01));
    });
  });

  group('Kinderzulage', () {
    test('zero children returns zero', () {
      expect(subsidy.calcKinderzulage(1800, 0), 0);
    });

    test('zero contribution returns zero', () {
      expect(subsidy.calcKinderzulage(0, 2), 0);
    });

    test('1 child, €300/yr contribution gets full €300', () {
      expect(subsidy.calcKinderzulage(300, 1), closeTo(300, 0.01));
    });

    test('1 child, €200/yr contribution gets €200 (1:1 match)', () {
      expect(subsidy.calcKinderzulage(200, 1), closeTo(200, 0.01));
    });

    test('2 children, €500/yr gets €600 (min(500,300) × 2)', () {
      expect(subsidy.calcKinderzulage(500, 2), closeTo(600, 0.01));
    });

    test('3 children, €1800/yr gets €900', () {
      expect(subsidy.calcKinderzulage(1800, 3), closeTo(900, 0.01));
    });

    test('1 child, €25/mo = €300/yr gets full grant', () {
      expect(subsidy.calcKinderzulage(25 * 12, 1), closeTo(300, 0.01));
    });
  });

  group('Berufseinsteigerbonus', () {
    test('age 23, year 0 gets €200', () {
      expect(subsidy.calcBonus(23, 0), 200);
    });

    test('age 24, year 0 gets €200', () {
      expect(subsidy.calcBonus(24, 0), 200);
    });

    test('age 25, year 0 gets zero (too old)', () {
      expect(subsidy.calcBonus(25, 0), 0);
    });

    test('age 23, year 1 gets zero (one-time only)', () {
      expect(subsidy.calcBonus(23, 1), 0);
    });

    test('age 23, year 2 gets zero (one-time only)', () {
      expect(subsidy.calcBonus(23, 2), 0);
    });

    test('age 30, year 0 gets zero (too old)', () {
      expect(subsidy.calcBonus(30, 0), 0);
    });
  });

  group('Geringverdienerbonus', () {
    test('eligible: brutto 22k, contribution 1200/yr', () {
      expect(subsidy.calcGeringverdienerbonus(22000, 1200), 175);
    });

    test('eligible: at threshold (€26,250) and min contribution (€120)', () {
      expect(subsidy.calcGeringverdienerbonus(26250, 120), 175);
    });

    test('ineligible: brutto above threshold', () {
      expect(subsidy.calcGeringverdienerbonus(26251, 1200), 0);
    });

    test('ineligible: contribution below minimum', () {
      expect(subsidy.calcGeringverdienerbonus(22000, 100), 0);
    });

    test('ineligible: contribution zero', () {
      expect(subsidy.calcGeringverdienerbonus(22000, 0), 0);
    });
  });

  group('Combined Zulage', () {
    test('career starter: age 23, 600/yr, 32k brutto, 0 kids', () {
      final z = subsidy.calcZulage(600, 0, 23, 0, 32000);
      expect(z.grund, closeTo(240, 0.01)); // 360×50% + 240×25%
      expect(z.kind, 0);
      expect(z.bonus, 200); // one-time, year 0
      expect(z.gering, 0); // 32k > 26,250
      expect(z.total, closeTo(440, 0.01));
    });

    test('family: age 32, 1200/yr, 45k brutto, 2 kids', () {
      final z = subsidy.calcZulage(1200, 2, 32, 0, 45000);
      expect(z.grund, closeTo(390, 0.01));
      expect(z.kind, closeTo(600, 0.01));
      expect(z.bonus, 0); // age 32 > 25
      expect(z.gering, 0); // 45k > 26,250
      expect(z.total, closeTo(990, 0.01));
    });

    test('low-income part-time: age 30, 600/yr, 22k brutto, 1 kid', () {
      final z = subsidy.calcZulage(600, 1, 30, 0, 22000);
      expect(z.grund, closeTo(240, 0.01));
      expect(z.kind, closeTo(300, 0.01)); // min(600, 300) × 1
      expect(z.bonus, 0);
      expect(z.gering, 175); // 22k ≤ 26,250 and 600 ≥ 120
      expect(z.total, closeTo(715, 0.01));
    });

    test('year 1 no longer gets Berufseinsteigerbonus', () {
      final z = subsidy.calcZulage(600, 0, 23, 1, 32000);
      expect(z.bonus, 0);
    });
  });
}
