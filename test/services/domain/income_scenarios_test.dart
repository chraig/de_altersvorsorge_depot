import 'dart:math';
import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/models/scenario.dart';

void main() {
  group('GrowthCurve: linear', () {
    const dev = IncomeDevSettings(enabled: true, curve: GrowthCurve.linear, growthRate: 0.03);

    test('year 0 is base brutto', () {
      expect(dev.bruttoForYear(40000, 0), closeTo(40000, 0.01));
    });

    test('compounds annually', () {
      expect(dev.bruttoForYear(40000, 10), closeTo(40000 * pow(1.03, 10), 1));
    });

    test('zero growth rate stays flat', () {
      const flat = IncomeDevSettings(enabled: true, curve: GrowthCurve.linear, growthRate: 0);
      expect(flat.bruttoForYear(50000, 20), closeTo(50000, 0.01));
    });
  });

  group('GrowthCurve: stepwise', () {
    const dev = IncomeDevSettings(
      enabled: true, curve: GrowthCurve.stepwise,
      promotionInterval: 5, promotionIncrease: 0.15,
    );

    test('year 0–4: no promotion yet', () {
      expect(dev.bruttoForYear(40000, 0), closeTo(40000, 1));
      expect(dev.bruttoForYear(40000, 4), closeTo(40000, 1));
    });

    test('year 5: first promotion (15% raise)', () {
      expect(dev.bruttoForYear(40000, 5), closeTo(46000, 1));
    });

    test('year 10: second promotion', () {
      expect(dev.bruttoForYear(40000, 10), closeTo(40000 * pow(1.15, 2), 1));
    });

    test('year 15: third promotion', () {
      expect(dev.bruttoForYear(40000, 15), closeTo(40000 * pow(1.15, 3), 1));
    });
  });

  group('GrowthCurve: logarithmic', () {
    const dev = IncomeDevSettings(
      enabled: true, curve: GrowthCurve.logarithmic,
      salaryCap: 90000,
    );

    test('year 0 is base brutto', () {
      expect(dev.bruttoForYear(40000, 0), closeTo(40000, 1));
    });

    test('approaches salary cap over time', () {
      final yr30 = dev.bruttoForYear(40000, 30);
      expect(yr30, greaterThan(70000));
      expect(yr30, lessThan(90000));
    });

    test('never exceeds salary cap', () {
      final yr100 = dev.bruttoForYear(40000, 100);
      expect(yr100, lessThan(90000));
    });

    test('starts fast, slows down', () {
      final yr5 = dev.bruttoForYear(40000, 5);
      final yr10 = dev.bruttoForYear(40000, 10);
      final yr15 = dev.bruttoForYear(40000, 15);
      final gain5to10 = yr10 - yr5;
      final gain10to15 = yr15 - yr10;
      expect(gain10to15, lessThan(gain5to10), reason: 'Growth should decelerate');
    });
  });

  group('Part-time phase', () {
    const dev = IncomeDevSettings(
      enabled: true, curve: GrowthCurve.linear, growthRate: 0.02,
      partTimeStartYear: 5, partTimeDuration: 3, partTimePercent: 0.5,
    );

    test('before part-time: full income', () {
      expect(dev.bruttoForYear(40000, 4), closeTo(40000 * pow(1.02, 4), 1));
    });

    test('during part-time: halved income', () {
      final fullIncome = 40000 * pow(1.02, 5);
      expect(dev.bruttoForYear(40000, 5), closeTo(fullIncome * 0.5, 1));
      expect(dev.bruttoForYear(40000, 7), closeTo(40000 * pow(1.02, 7) * 0.5, 1));
    });

    test('after part-time: full income again', () {
      final fullIncome = 40000 * pow(1.02, 8);
      expect(dev.bruttoForYear(40000, 8), closeTo(fullIncome, 1));
    });

    test('no part-time when not set', () {
      const noPt = IncomeDevSettings(enabled: true, curve: GrowthCurve.linear, growthRate: 0.02);
      expect(noPt.hasPartTime, false);
      expect(noPt.bruttoForYear(40000, 5), closeTo(40000 * pow(1.02, 5), 1));
    });
  });

  group('Child arrival timing', () {
    const dev = IncomeDevSettings(
      enabled: true,
      childArrivalYears: [3, 6],
    );

    test('before first child: base kinder', () {
      expect(dev.kinderAtYear(0, 0), 0);
      expect(dev.kinderAtYear(0, 2), 0);
    });

    test('after first child: +1', () {
      expect(dev.kinderAtYear(0, 3), 1);
      expect(dev.kinderAtYear(0, 5), 1);
    });

    test('after second child: +2', () {
      expect(dev.kinderAtYear(0, 6), 2);
      expect(dev.kinderAtYear(0, 10), 2);
    });

    test('stacks on base kinder', () {
      expect(dev.kinderAtYear(1, 0), 1);
      expect(dev.kinderAtYear(1, 3), 2);
      expect(dev.kinderAtYear(1, 6), 3);
    });

    test('disabled: always returns base', () {
      const disabled = IncomeDevSettings(enabled: false, childArrivalYears: [3, 6]);
      expect(disabled.kinderAtYear(0, 10), 0);
    });

    test('empty list: always returns base', () {
      const empty = IncomeDevSettings(enabled: true, childArrivalYears: []);
      expect(empty.kinderAtYear(2, 10), 2);
    });
  });

  group('Child age-out (Kindergeld ends at 25)', () {
    test('base child ages out after 25 years', () {
      const dev = IncomeDevSettings(); // disabled, but kinderAtYear still works
      // Child age 0 at start → eligible for 25 years (0..24), not at year 25
      expect(dev.kinderAtYear(1, 0, kinderAlter: [0], maxAge: 25), 1);
      expect(dev.kinderAtYear(1, 24, kinderAlter: [0], maxAge: 25), 1);
      expect(dev.kinderAtYear(1, 25, kinderAlter: [0], maxAge: 25), 0);
    });

    test('older child ages out sooner', () {
      const dev = IncomeDevSettings();
      // Child age 20 at start → eligible for 5 years (20..24), out at year 5
      expect(dev.kinderAtYear(1, 0, kinderAlter: [20], maxAge: 25), 1);
      expect(dev.kinderAtYear(1, 4, kinderAlter: [20], maxAge: 25), 1);
      expect(dev.kinderAtYear(1, 5, kinderAlter: [20], maxAge: 25), 0);
    });

    test('two children age out at different times', () {
      const dev = IncomeDevSettings();
      // Child 1: age 5, Child 2: age 15
      // At year 0: both eligible
      expect(dev.kinderAtYear(2, 0, kinderAlter: [5, 15], maxAge: 25), 2);
      // At year 10: child 2 is 25 → out, child 1 is 15 → still in
      expect(dev.kinderAtYear(2, 10, kinderAlter: [5, 15], maxAge: 25), 1);
      // At year 20: child 1 is 25 → out too
      expect(dev.kinderAtYear(2, 20, kinderAlter: [5, 15], maxAge: 25), 0);
    });

    test('dynamic child ages out after 25 years from arrival', () {
      const dev = IncomeDevSettings(enabled: true, childArrivalYears: [5]);
      // Dynamic child born at year 5, ages out at year 30 (age 25)
      expect(dev.kinderAtYear(0, 4), 0);  // not yet arrived
      expect(dev.kinderAtYear(0, 5), 1);  // just arrived (age 0)
      expect(dev.kinderAtYear(0, 29), 1); // age 24, still eligible
      expect(dev.kinderAtYear(0, 30), 0); // age 25, aged out
    });

    test('empty kinderAlter assumes age 0 for all base children', () {
      const dev = IncomeDevSettings();
      // 2 base children, no ages given → both assumed age 0
      expect(dev.kinderAtYear(2, 0, maxAge: 25), 2);
      expect(dev.kinderAtYear(2, 24, maxAge: 25), 2);
      expect(dev.kinderAtYear(2, 25, maxAge: 25), 0);
    });

    test('family preset: children age 3 and 5, savings 35 years', () {
      const dev = IncomeDevSettings();
      // Child 1 (age 3): eligible until year 22 (age 25)
      // Child 2 (age 5): eligible until year 20 (age 25)
      expect(dev.kinderAtYear(2, 0, kinderAlter: [3, 5], maxAge: 25), 2);
      expect(dev.kinderAtYear(2, 19, kinderAlter: [3, 5], maxAge: 25), 2);
      expect(dev.kinderAtYear(2, 20, kinderAlter: [3, 5], maxAge: 25), 1); // child 2 out
      expect(dev.kinderAtYear(2, 22, kinderAlter: [3, 5], maxAge: 25), 0); // both out
      expect(dev.kinderAtYear(2, 34, kinderAlter: [3, 5], maxAge: 25), 0); // end of savings
    });
  });

  group('hasPartTime / hasChildTiming', () {
    test('hasPartTime requires both start year and duration', () {
      expect(const IncomeDevSettings(partTimeStartYear: 5, partTimeDuration: 3).hasPartTime, true);
      expect(const IncomeDevSettings(partTimeStartYear: null, partTimeDuration: 3).hasPartTime, false);
      expect(const IncomeDevSettings(partTimeStartYear: 5, partTimeDuration: 0).hasPartTime, false);
    });

    test('hasChildTiming requires non-empty list', () {
      expect(const IncomeDevSettings(childArrivalYears: [3]).hasChildTiming, true);
      expect(const IncomeDevSettings(childArrivalYears: []).hasChildTiming, false);
    });
  });

  group('Combined scenarios', () {
    test('stepwise + part-time', () {
      const dev = IncomeDevSettings(
        enabled: true, curve: GrowthCurve.stepwise,
        promotionInterval: 5, promotionIncrease: 0.20,
        partTimeStartYear: 3, partTimeDuration: 2, partTimePercent: 0.5,
      );
      // Year 3: no promotion yet, but part-time → 40000 × 0.5 = 20000
      expect(dev.bruttoForYear(40000, 3), closeTo(20000, 1));
      // Year 5: promotion + no part-time → 40000 × 1.20 = 48000
      expect(dev.bruttoForYear(40000, 5), closeTo(48000, 1));
    });

    test('logarithmic + part-time + children', () {
      const dev = IncomeDevSettings(
        enabled: true, curve: GrowthCurve.logarithmic,
        salaryCap: 80000,
        partTimeStartYear: 8, partTimeDuration: 3, partTimePercent: 0.6,
        childArrivalYears: [8],
      );
      // Year 8: income near cap, part-time at 60%, 1 child arrives
      final yr8 = dev.bruttoForYear(40000, 8);
      expect(yr8, lessThan(80000 * 0.6)); // capped + part-time
      expect(dev.kinderAtYear(0, 8), 1);
      // Year 11: full income again, still 1 child
      final yr11 = dev.bruttoForYear(40000, 11);
      expect(yr11, greaterThan(yr8));
      expect(dev.kinderAtYear(0, 11), 1);
    });
  });
}
