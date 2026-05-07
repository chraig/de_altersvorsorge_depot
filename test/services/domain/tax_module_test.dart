import 'package:flutter_test/flutter_test.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';

void main() {
  const tax = GermanTax2026();

  group('Grenzsteuersatz', () {
    test('below Grundfreibetrag (€12,348) is 0%', () {
      expect(tax.getGrenzsteuersatz(0), 0);
      expect(tax.getGrenzsteuersatz(10000), 0);
      expect(tax.getGrenzsteuersatz(12348), 0);
    });

    test('entry zone (€12,349–€17,799) is 14%', () {
      expect(tax.getGrenzsteuersatz(15000), 0.14);
      expect(tax.getGrenzsteuersatz(17799), 0.14);
    });

    test('progressive zone interpolates linearly', () {
      final rate = tax.getGrenzsteuersatz(45000);
      // 0.2397 + (45000-17799)/(69878-17799) * (0.42-0.2397)
      final expected = 0.2397 + (45000 - 17799) / (69878 - 17799) * (0.42 - 0.2397);
      expect(rate, closeTo(expected, 0.0001));
    });

    test('at zone 3 end (€69,878) reaches Spitzensteuersatz', () {
      expect(tax.getGrenzsteuersatz(69878), closeTo(0.42, 0.001));
    });

    test('Spitzensteuersatz zone (€69,879–€277,825) is 42%', () {
      expect(tax.getGrenzsteuersatz(85000), 0.42);
      expect(tax.getGrenzsteuersatz(200000), 0.42);
      expect(tax.getGrenzsteuersatz(277825), 0.42);
    });

    test('Reichensteuersatz above €277,825 is 45%', () {
      expect(tax.getGrenzsteuersatz(277826), 0.45);
      expect(tax.getGrenzsteuersatz(500000), 0.45);
    });
  });

  group('Progressive Einkommensteuer (§32a)', () {
    test('zero income → zero tax', () {
      expect(tax.calcEinkommensteuer(0), 0);
    });

    test('below Grundfreibetrag → zero tax', () {
      expect(tax.calcEinkommensteuer(12348), 0);
    });

    test('zone 2: €15,000 → positive tax', () {
      final steuer = tax.calcEinkommensteuer(15000);
      expect(steuer, greaterThan(0));
      expect(steuer, lessThan(15000 * 0.14)); // less than marginal × full
    });

    test('zone 3: €45,000', () {
      final steuer = tax.calcEinkommensteuer(45000);
      // 2026 zone 3: z = (45000-17799)/10000 = 2.7201
      // (173.10 × 2.7201 + 2397) × 2.7201 + 1034.87 ≈ 8835.74
      expect(steuer, greaterThan(7000));
      expect(steuer, lessThan(12000));
    });

    test('zone 4: €85,000', () {
      final steuer = tax.calcEinkommensteuer(85000);
      // 0.42 × 85000 - 11135.63 = 24564.37
      expect(steuer, closeTo(24564.37, 1));
    });

    test('zone 5: €300,000', () {
      final steuer = tax.calcEinkommensteuer(300000);
      // 0.45 × 300000 - 19470.38 = 115529.62
      expect(steuer, closeTo(115529.62, 1));
    });

    test('average rate < marginal rate', () {
      for (final brutto in [30000.0, 50000.0, 80000.0, 150000.0]) {
        final avg = tax.getDurchschnittssteuersatz(brutto);
        final marginal = tax.getGrenzsteuersatz(brutto);
        expect(avg, lessThan(marginal),
          reason: 'At €${brutto.toInt()}: avg $avg should be < marginal $marginal');
      }
    });

    test('average rate is 0 at Grundfreibetrag', () {
      expect(tax.getDurchschnittssteuersatz(12348), 0);
      expect(tax.getDurchschnittssteuersatz(0), 0);
    });
  });

  group('Soli (§3 Abs. 3 + §4 SolzG)', () {
    test('ESt at or below Freigrenze (€19,950) → Soli is 0', () {
      expect(tax.calcSoli(0), 0);
      expect(tax.calcSoli(10000), 0);
      expect(tax.calcSoli(19950), 0);
    });

    test('Just above Freigrenze → Milderungszone caps Soli well below 5.5 %', () {
      // ESt = €20,000 → Δ = 50; cap = 0.119 × 50 = €5.95
      // Voll Soli = 0.055 × 20,000 = €1,100. So actual Soli = €5.95.
      expect(tax.calcSoli(20000), closeTo(5.95, 0.01));
      // ESt = €25,000 → Δ = 5,050; cap = 0.119 × 5,050 = €600.95
      // Voll Soli = 0.055 × 25,000 = €1,375. So actual Soli = €600.95.
      expect(tax.calcSoli(25000), closeTo(600.95, 0.01));
    });

    test('Milderungszone ends at ESt ≈ 1.859 × Freigrenze (€37,087)', () {
      // At the transition point: Voll = Milderung.
      // Voll = 0.055 × 37,086.9 = 2,039.78
      // Milderung = 0.119 × (37,086.9 − 19,950) = 0.119 × 17,136.9 = 2,039.29
      // → returns the smaller (≈ 2,039.29 from Milderung clause)
      final transition = tax.calcSoli(37086.9);
      expect(transition, closeTo(2039.29, 1));
    });

    test('Above Milderungszone → full 5.5 % Soli', () {
      expect(tax.calcSoli(50000), closeTo(2750, 0.01));   // 0.055 × 50,000
      expect(tax.calcSoli(100000), closeTo(5500, 0.01));  // 0.055 × 100,000
      expect(tax.calcSoli(200000), closeTo(11000, 0.01));
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
      // €600 contribution + €540 subsidy (Grundzulage + Kinderzulage), 0% rate
      final gp = tax.calcGuenstigerpruefung(600, 540, 0);
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
