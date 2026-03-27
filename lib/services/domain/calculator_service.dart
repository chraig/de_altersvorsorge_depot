import 'dart:math';
import 'package:avdepot_rechner/models/scenario.dart';

/// All legislative and tax parameters in one place.
/// Update these when tax brackets change or legislation is amended.
class CalcConstants {
  const CalcConstants._();

  // ─── GRUNDZULAGE ─────────────────────────────────────────────
  static const double grundzulageStufe1Rate = 0.50;
  static const double grundzulageStufe1Cap = 360.0;
  static const double grundzulageStufe2Rate = 0.25;
  static const double grundzulageMaxBeitrag = 1800.0;

  // ─── KINDERZULAGE ────────────────────────────────────────────
  static const double kinderzulageMax = 300.0;

  // ─── BERUFSEINSTEIGERBONUS ───────────────────────────────────
  static const double bonusBetrag = 200.0;
  static const int bonusMaxJahre = 3;
  static const int bonusMaxAlter = 25;

  // ─── GERINGVERDIENERBONUS ───────────────────────────────────
  static const double geringverdienerBetrag = 175.0;
  static const double geringverdienerGrenze = 26250.0;
  static const double mindestbeitrag = 120.0;

  // ─── TAX BRACKETS (2024, §32a EStG) ─────────────────────────
  static const double grundfreibetrag = 11784;
  static const double zone2Ende = 17005;
  static const double zone2Satz = 0.14;
  static const double zone3Ende = 66760;
  static const double zone3StartSatz = 0.2397;
  static const double spitzensteuersatz = 0.42;
  static const double zone4Ende = 277825;
  static const double reichensteuersatz = 0.45;

  // ─── ETF TAXATION ───────────────────────────────────────────
  static const double teilfreistellung = 0.30;
  static const double vorabpauschaleDrag = 0.002;

  // ─── PAYOUT ─────────────────────────────────────────────────
  static const int payoutEndAge = 85;

  // ─── PENSION ESTIMATION ─────────────────────────────────────
  static const double rentenwert = 39.32;
  static const double durchschnittsentgelt = 45358.0;
  static const double bbg = 90600.0;
  static const int arbeitsbeginn = 25;
}

/// Core calculation engine for AV-Depot and ETF-Depot simulations.
/// All methods are static and pure -- no side effects.
class CalculatorService {

  // ─── FOERDERUNG (SUBSIDY) CALCULATIONS ────────────────────────────

  /// Grundzulage: 50% on first 360 EUR, 25% on 361-1800 EUR
  static double calcGrundzulage(double jahresbeitrag) {
    final capped = min(jahresbeitrag, CalcConstants.grundzulageMaxBeitrag);
    if (capped <= 0) return 0;
    return min(capped, CalcConstants.grundzulageStufe1Cap) * CalcConstants.grundzulageStufe1Rate
        + max(0.0, capped - CalcConstants.grundzulageStufe1Cap) * CalcConstants.grundzulageStufe2Rate;
  }

  /// Kinderzulage: up to 300 EUR per child per year (1:1 match)
  static double calcKinderzulage(double jahresbeitrag, int kinder) {
    if (kinder <= 0 || jahresbeitrag <= 0) return 0;
    return min(jahresbeitrag, CalcConstants.kinderzulageMax) * kinder;
  }

  /// Berufseinsteigerbonus: 200 EUR/year for first 3 years if under 25
  static double calcBonus(int alter, int bonusJahre) {
    return (alter < CalcConstants.bonusMaxAlter && bonusJahre < CalcConstants.bonusMaxJahre)
        ? CalcConstants.bonusBetrag : 0.0;
  }

  /// Geringverdienerbonus: 175 EUR/year if brutto <= 26,250 and eigenbeitrag >= 120
  static double calcGeringverdienerbonus(double brutto, double jahresbeitrag) {
    return (brutto <= CalcConstants.geringverdienerGrenze && jahresbeitrag >= CalcConstants.mindestbeitrag)
        ? CalcConstants.geringverdienerBetrag : 0.0;
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
    if (brutto <= CalcConstants.grundfreibetrag) return 0;
    if (brutto <= CalcConstants.zone2Ende) return CalcConstants.zone2Satz;
    if (brutto <= CalcConstants.zone3Ende) {
      return CalcConstants.zone3StartSatz
          + (brutto - CalcConstants.zone2Ende) / (CalcConstants.zone3Ende - CalcConstants.zone2Ende)
          * (CalcConstants.spitzensteuersatz - CalcConstants.zone3StartSatz);
    }
    if (brutto <= CalcConstants.zone4Ende) return CalcConstants.spitzensteuersatz;
    return CalcConstants.reichensteuersatz;
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
      totalEP += preSavingsYears * min(person.brutto, CalcConstants.bbg) / CalcConstants.durchschnittsentgelt;
      // Savings period with income growth
      for (int j = 0; j < person.spardauer; j++) {
        final bruttoJ = incomeDev.bruttoForYear(person.brutto, j);
        totalEP += min(bruttoJ, CalcConstants.bbg) / CalcConstants.durchschnittsentgelt;
      }
      effectiveRente = totalEP * CalcConstants.rentenwert;
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
    final nettoRendite = macro.rendite - costs.kostenETF - CalcConstants.vorabpauschaleDrag;

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
    const teilfreistellung = CalcConstants.teilfreistellung;
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
