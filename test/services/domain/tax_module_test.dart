import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';

void main() {
  const tax = GermanTax2024();

  group('Grenzsteuersatz', () {
    test('below Grundfreibetrag (€11,784) is 0%', () {
      expect(tax.getGrenzsteuersatz(0), 0);
      expect(tax.getGrenzsteuersatz(10000), 0);
      expect(tax.getGrenzsteuersatz(11784), 0);
    });

    test('entry zone (€11,785–€17,005) is 14%', () {
      expect(tax.getGrenzsteuersatz(15000), 0.14);
      expect(tax.getGrenzsteuersatz(17005), 0.14);
    });

    test('progressive zone interpolates linearly', () {
      final rate = tax.getGrenzsteuersatz(45000);
      // 0.2397 + (45000-17005)/(66760-17005) * (0.42-0.2397)
      final expected = 0.2397 + (45000 - 17005) / (66760 - 17005) * (0.42 - 0.2397);
      expect(rate, closeTo(expected, 0.0001));
    });

    test('at zone 3 end (€66,760) reaches Spitzensteuersatz', () {
      expect(tax.getGrenzsteuersatz(66760), closeTo(0.42, 0.001));
    });

    test('Spitzensteuersatz zone (€66,761–€277,825) is 42%', () {
      expect(tax.getGrenzsteuersatz(85000), 0.42);
      expect(tax.getGrenzsteuersatz(200000), 0.42);
      expect(tax.getGrenzsteuersatz(277825), 0.42);
    });

    test('Reichensteuersatz above €277,825 is 45%', () {
      expect(tax.getGrenzsteuersatz(277826), 0.45);
      expect(tax.getGrenzsteuersatz(500000), 0.45);
    });
  });

  group('Günstigerprüfung', () {
    test('high income benefits from Sonderausgabenabzug', () {
      // €1800 contribution + €540 subsidy, 42% rate
      final gp = tax.calcGuenstigerpruefung(1800, 540, 0.42);
      // (1800 + 540) × 0.42 = 982.80
      expect(gp.steuerersparnis, closeTo(982.80, 0.01));
      // 982.80 - 540 = 442.80 additional refund
      expect(gp.zusaetzlich, closeTo(442.80, 0.01));
      expect(gp.vorteil, true);
    });

    test('low income: Zulagen are better than Sonderausgabenabzug', () {
      // €600 contribution + €715 subsidy (with Geringverdiener+Kind), 0% rate
      final gp = tax.calcGuenstigerpruefung(600, 715, 0);
      expect(gp.steuerersparnis, 0);
      expect(gp.zusaetzlich, 0);
      expect(gp.vorteil, false);
    });

    test('mid income: moderate refund', () {
      // €1800 contribution + €540 subsidy, 24% rate
      final gp = tax.calcGuenstigerpruefung(1800, 540, 0.24);
      // (1800 + 540) × 0.24 = 561.60
      expect(gp.steuerersparnis, closeTo(561.60, 0.01));
      // 561.60 - 540 = 21.60
      expect(gp.zusaetzlich, closeTo(21.60, 0.01));
      expect(gp.vorteil, true);
    });

    test('borderline: Sonderausgabenabzug equals Zulagen', () {
      // Exactly equal → no additional refund
      final gp = tax.calcGuenstigerpruefung(1000, 200, 0.20);
      // (1000 + 200) × 0.20 = 240
      expect(gp.zusaetzlich, closeTo(40, 0.01));
      expect(gp.vorteil, true);
    });
  });
}
