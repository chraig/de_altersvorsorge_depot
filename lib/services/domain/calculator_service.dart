import 'dart:math';
import '../../models/scenario.dart';

/// Core calculation engine for AV-Depot and ETF-Depot simulations.
/// All methods are static and pure -- no side effects.
class CalculatorService {

  // ─── FOERDERUNG (SUBSIDY) CALCULATIONS ────────────────────────────

  /// Grundzulage: 50% on first 360 EUR, 25% on 361-1800 EUR
  static double calcGrundzulage(double jahresbeitrag) {
    final capped = min(jahresbeitrag, 1800.0);
    if (capped <= 0) return 0;
    return min(capped, 360.0) * 0.50 + max(0.0, capped - 360.0) * 0.25;
  }

  /// Kinderzulage: up to 300 EUR per child per year (1:1 match up to 300 EUR)
  static double calcKinderzulage(double jahresbeitrag, int kinder) {
    if (kinder <= 0 || jahresbeitrag <= 0) return 0;
    return min(jahresbeitrag, 300.0) * kinder;
  }

  /// Berufseinsteigerbonus: 200 EUR/year for first 3 years if under 25
  static double calcBonus(int alter, int bonusJahre) {
    return (alter < 25 && bonusJahre < 3) ? 200.0 : 0.0;
  }

  /// Combined yearly subsidy
  static ({double grund, double kind, double bonus, double total})
  calcZulage(double jahresbeitrag, int kinder, int alter, int bonusJahre) {
    final grund = calcGrundzulage(jahresbeitrag);
    final kind = calcKinderzulage(jahresbeitrag, kinder);
    final bonus = calcBonus(alter, bonusJahre);
    return (grund: grund, kind: kind, bonus: bonus, total: grund + kind + bonus);
  }

  /// German marginal tax rate approximation
  static double getGrenzsteuersatz(double brutto) {
    if (brutto <= 11784) return 0;
    if (brutto <= 17005) return 0.14;
    if (brutto <= 66760) return 0.2397 + (brutto - 17005) / (66760 - 17005) * (0.42 - 0.2397);
    if (brutto <= 277825) return 0.42;
    return 0.45;
  }

  /// Guenstigerpruefung: check if Sonderausgabenabzug beats Zulagen
  static ({double steuerersparnis, double zusaetzlich, bool vorteil})
  calcGuenstigerpruefung(double jahresbeitrag, double zulageTotal, double grenzsteuersatz) {
    final gesamtBeitrag = jahresbeitrag + zulageTotal;
    final steuerersparnis = gesamtBeitrag * grenzsteuersatz;
    final zusaetzlich = max(0.0, steuerersparnis - zulageTotal);
    return (steuerersparnis: steuerersparnis, zusaetzlich: zusaetzlich, vorteil: steuerersparnis > zulageTotal);
  }

  /// Full subsidy breakdown for year 1
  static SubsidyBreakdown calcSubsidyBreakdown(PersonalScenario person) {
    final jb = person.jahresbeitrag;
    final z = calcZulage(jb, person.kinder, person.alterStart, 0);
    final gst = getGrenzsteuersatz(person.brutto);
    final gp = calcGuenstigerpruefung(jb, z.total, gst);
    final fq = jb > 0 ? z.total / jb : 0.0;
    return SubsidyBreakdown(
      grundzulage: z.grund,
      kinderzulage: z.kind,
      bonus: z.bonus,
      total: z.total,
      foerderquote: fq,
      steuererstattung: gp.zusaetzlich,
      grenzsteuersatz: gst,
    );
  }

  // ─── AV-DEPOT SIMULATION ────────────────────────────────────────

  static AVResult simulateAV({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    final jb = person.jahresbeitrag;
    final gst = getGrenzsteuersatz(person.brutto);
    final nettoRendite = macro.rendite - costs.kostenAV;

    double depot = 0;
    double eigenBeitraege = 0;
    double zulagenGesamt = 0;
    double steuererstattungGesamt = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      final alter = person.alterStart + j;
      final z = calcZulage(jb, person.kinder, alter, j);
      final gp = calcGuenstigerpruefung(jb, z.total, gst);

      final zufluss = jb + z.total;
      depot = (depot + zufluss) * (1 + nettoRendite);

      eigenBeitraege += jb;
      zulagenGesamt += z.total;
      steuererstattungGesamt += gp.zusaetzlich;

      final inflationsbereinigt = depot / pow(1 + macro.inflation, j + 1);

      jahresWerte.add(YearlyDataPoint(
        year: j + 1,
        alter: alter + 1,
        depot: depot,
        depotReal: inflationsbereinigt,
        eigenBeitraege: eigenBeitraege,
        zulagen: zulagenGesamt,
        zulageJahr: z.total,
      ));
    }

    // Payout phase: 20 years, deferred taxation
    const auszahlungsDauer = 20;
    final monatlich = depot / (auszahlungsDauer * 12);
    final steuersatzRente = gst * 0.7; // typically lower in retirement
    final netto = monatlich * (1 - steuersatzRente);

    return AVResult(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      zulagenGesamt: zulagenGesamt,
      steuererstattungGesamt: steuererstattungGesamt,
      monatlicheAuszahlung: monatlich,
      nettoMonatlich: netto,
      grenzsteuersatz: gst,
      wertzuwachs: depot - eigenBeitraege - zulagenGesamt,
      jahresWerte: jahresWerte,
    );
  }

  // ─── ETF-DEPOT SIMULATION ──────────────────────────────────────

  static ETFResult simulateETF({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    final jb = person.jahresbeitrag;
    final nettoRendite = macro.rendite - costs.kostenETF - 0.002; // Vorabpauschale drag

    double depot = 0;
    double eigenBeitraege = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      depot = (depot + jb) * (1 + nettoRendite);
      eigenBeitraege += jb;

      final inflationsbereinigt = depot / pow(1 + macro.inflation, j + 1);

      jahresWerte.add(YearlyDataPoint(
        year: j + 1,
        alter: person.alterStart + j + 1,
        depot: depot,
        depotReal: inflationsbereinigt,
        eigenBeitraege: eigenBeitraege,
        zulagen: 0,
        zulageJahr: 0,
      ));
    }

    // Payout: Abgeltungssteuer on gains with Teilfreistellung
    final gewinn = depot - eigenBeitraege;
    const teilfreistellung = 0.30;
    final steuerpflichtigerGewinn = gewinn * (1 - teilfreistellung);
    final steuer = steuerpflichtigerGewinn * 0.26375; // Abgeltungssteuer + Soli
    final nachSteuer = depot - steuer;

    const auszahlungsDauer = 20;
    final monatlich = nachSteuer / (auszahlungsDauer * 12);

    return ETFResult(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      gewinn: gewinn,
      steuerAufGewinn: steuer,
      nachSteuer: nachSteuer,
      monatlicheAuszahlung: monatlich,
      jahresWerte: jahresWerte,
    );
  }

  // ─── COMBINED RESULTS ──────────────────────────────────────────

  static CombinedResult simulateCombined({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    return CombinedResult(
      macro: macro,
      av: simulateAV(person: person, macro: macro, costs: costs),
      etf: simulateETF(person: person, macro: macro, costs: costs),
    );
  }

  /// Run all macro scenarios for a given person
  static List<CombinedResult> simulateAllMacros({
    required PersonalScenario person,
    required List<MacroScenario> macros,
    required CostSettings costs,
  }) {
    return macros.map((m) => simulateCombined(person: person, macro: m, costs: costs)).toList();
  }
}
