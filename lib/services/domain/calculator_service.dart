import 'dart:math';
import 'package:avdepot_rechner/models/scenario.dart';

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

  /// Geringverdienerbonus: 175 EUR/year if brutto <= 26250 and eigenbeitrag >= 120
  static double calcGeringverdienerbonus(double brutto, double jahresbeitrag) {
    return (brutto <= 26250 && jahresbeitrag >= 120) ? 175.0 : 0.0;
  }

  /// Combined yearly subsidy
  static ({double grund, double kind, double bonus, double gering, double total})
  calcZulage(double jahresbeitrag, int kinder, int alter, int bonusJahre, double brutto) {
    final grund = calcGrundzulage(jahresbeitrag);
    final kind = calcKinderzulage(jahresbeitrag, kinder);
    final bonus = calcBonus(alter, bonusJahre);
    final gering = calcGeringverdienerbonus(brutto, jahresbeitrag);
    return (grund: grund, kind: kind, bonus: bonus, gering: gering, total: grund + kind + bonus + gering);
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
    final z = calcZulage(jb, person.kinder, person.alterStart, 0, person.brutto);
    final gst = getGrenzsteuersatz(person.brutto);
    final gp = calcGuenstigerpruefung(jb, z.total, gst);
    final fq = jb > 0 ? z.total / jb : 0.0;
    return SubsidyBreakdown(
      grundzulage: z.grund,
      kinderzulage: z.kind,
      bonus: z.bonus,
      geringverdienerbonus: z.gering,
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
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    final jb = person.jahresbeitrag;
    final nettoRendite = macro.rendite - costs.kostenAV;

    double depot = 0;
    double eigenBeitraege = 0;
    double zulagenGesamt = 0;
    double steuererstattungGesamt = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      final alter = person.alterStart + j;
      final bruttoJ = incomeDev.bruttoForYear(person.brutto, j);
      final gstJ = getGrenzsteuersatz(bruttoJ);
      final z = calcZulage(jb, person.kinder, alter, j, bruttoJ);
      final gp = calcGuenstigerpruefung(jb, z.total, gstJ);

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

    // Payout phase: until age 85, deferred taxation
    final auszahlungsDauer = person.auszahlungsDauer;
    final monatlich = depot / (auszahlungsDauer * 12);

    // Compute effective state pension
    double effectiveRente;
    if (person.gesetzlicheRenteOverride != null) {
      effectiveRente = person.gesetzlicheRenteOverride!;
    } else if (incomeDev.enabled) {
      // Accumulate Entgeltpunkte year by year with growing income
      double totalEP = 0;
      // Pre-savings contribution years (from age 25 to alterStart)
      final preSavingsYears = (person.alterStart - 25).clamp(0, 45);
      totalEP += preSavingsYears * min(person.brutto, 90600.0) / 45358.0;
      // Savings period with income growth
      for (int j = 0; j < person.spardauer; j++) {
        final bruttoJ = incomeDev.bruttoForYear(person.brutto, j);
        totalEP += min(bruttoJ, 90600.0) / 45358.0;
      }
      effectiveRente = totalEP * 39.32;
    } else {
      effectiveRente = person.gesetzlicheRente;
    }

    // Retirement tax based on combined retirement income
    final avJahresAuszahlung = depot / auszahlungsDauer;
    final rentenEinkommen = avJahresAuszahlung
        + effectiveRente * 12
        + person.sonstigeEinkuenfte;
    final gstRente = getGrenzsteuersatz(rentenEinkommen);
    final kirchensteuerFaktor = 1 + costs.kirchensteuer;
    final netto = monatlich * (1 - gstRente * kirchensteuerFaktor);

    return AVResult(
      endkapital: depot,
      endkapitalReal: depot / pow(1 + macro.inflation, person.spardauer),
      eigenBeitraege: eigenBeitraege,
      zulagenGesamt: zulagenGesamt,
      steuererstattungGesamt: steuererstattungGesamt,
      monatlicheAuszahlung: monatlich,
      nettoMonatlich: netto,
      grenzsteuersatz: getGrenzsteuersatz(person.brutto),
      grenzsteuersatzRente: gstRente,
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
    final steuer = steuerpflichtigerGewinn * costs.abgeltungssteuersatz;
    final nachSteuer = depot - steuer;

    final auszahlungsDauer = person.auszahlungsDauer;
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
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    return CombinedResult(
      macro: macro,
      av: simulateAV(person: person, macro: macro, costs: costs, incomeDev: incomeDev),
      etf: simulateETF(person: person, macro: macro, costs: costs),
    );
  }

  /// Run all macro scenarios for a given person
  static List<CombinedResult> simulateAllMacros({
    required PersonalScenario person,
    required List<MacroScenario> macros,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    return macros.map((m) => simulateCombined(person: person, macro: m, costs: costs, incomeDev: incomeDev)).toList();
  }
}
