import 'dart:math';
import 'package:avdepot_rechner/models/scenario.dart';

/// All legislative and tax parameters in one place.
/// Update these when tax brackets change or legislation is amended.
///
/// Sources:
/// - Subsidy parameters: §89 EStG-E (Altersvorsorgereformgesetz, Finanzausschuss 25.03.2026)
/// - Tax brackets: §32a EStG (2024 values — update when 2027 brackets published by BMF)
/// - ETF taxation: §20 InvStG (Teilfreistellung), §43a EStG + §4 SolZG (Abgeltungssteuer)
/// - Pension estimation: Deutsche Rentenversicherung (Rentenwert July 2024, West)
class CalcConstants {
  const CalcConstants._();

  // ─── GRUNDZULAGE (§89 Abs. 1 EStG-E) ──────────────────────────
  /// 50% match on contributions up to this cap (first tier)
  static const double grundzulageStufe1Rate = 0.50;
  /// First tier cap: max €360/yr eligible for 50% match
  static const double grundzulageStufe1Cap = 360.0;
  /// 25% match on contributions above first tier (second tier)
  static const double grundzulageStufe2Rate = 0.25;
  /// Maximum subsidized contribution: €1,800/yr. Above this, no subsidy.
  static const double grundzulageMaxBeitrag = 1800.0;

  // ─── KINDERZULAGE (§89 Abs. 2 EStG-E) ─────────────────────────
  /// Max €300 per child per year, 1:1 match on own contributions
  static const double kinderzulageMax = 300.0;

  // ─── BERUFSEINSTEIGERBONUS (§89 Abs. 3 EStG-E) ────────────────
  /// Flat bonus per year for career starters
  static const double bonusBetrag = 200.0;
  /// Number of years the bonus is paid
  static const int bonusMaxJahre = 3;
  /// Must be under this age at contract start to qualify
  static const int bonusMaxAlter = 25;

  // ─── GERINGVERDIENERBONUS (§89 Abs. 4 EStG-E) ─────────────────
  /// Extra yearly subsidy for low-income earners
  static const double geringverdienerBetrag = 175.0;
  /// Gross income threshold: only eligible at or below this
  static const double geringverdienerGrenze = 26250.0;
  /// Minimum annual contribution required for any subsidy
  static const double mindestbeitrag = 120.0;

  // ─── INCOME TAX BRACKETS (§32a EStG, 2024 values) ─────────────
  /// Grundfreibetrag: no tax below this (tax-free allowance)
  static const double grundfreibetrag = 11784;
  /// End of entry zone: 14% flat rate up to this threshold
  static const double zone2Ende = 17005;
  /// Entry tax rate (Eingangssteuersatz)
  static const double zone2Satz = 0.14;
  /// End of progressive zone: rate rises linearly from zone2Satz to Spitzensteuersatz
  static const double zone3Ende = 66760;
  /// Start rate of progressive zone (interpolated from §32a formula)
  static const double zone3StartSatz = 0.2397;
  /// Top rate for income up to zone4Ende
  static const double spitzensteuersatz = 0.42;
  /// Threshold for Reichensteuersatz (super-rich rate)
  static const double zone4Ende = 277825;
  /// Top marginal rate above zone4Ende
  static const double reichensteuersatz = 0.45;

  // ─── ETF TAXATION (§20 InvStG, §43a EStG) ─────────────────────
  /// Partial exemption for equity funds (≥51% equity): 30% of gains tax-free
  static const double teilfreistellung = 0.30;
  /// Simplified annual Vorabpauschale drag on ETF returns.
  /// Reality: depends on Basiszins (ECB reference rate × 0.7). This is an approximation.
  static const double vorabpauschaleDrag = 0.002;

  // ─── PAYOUT PHASE ─────────────────────────────────────────────
  /// Auszahlplan must run until this age (§89 Abs. 8 EStG-E)
  static const int payoutEndAge = 85;

  // ─── PENSION ESTIMATION (Deutsche Rentenversicherung) ──────────
  /// EUR per Entgeltpunkt per month (West Germany, July 2024).
  /// Updated annually. East Germany uses a different (converging) value.
  static const double rentenwert = 39.32;
  /// Average gross income used to calculate Entgeltpunkte (2024).
  /// 1.0 EP = earning exactly the average. Updated annually by BMF.
  static const double durchschnittsentgelt = 45358.0;
  /// Beitragsbemessungsgrenze (2024, West): no pension points above this income.
  /// Updated annually. Separate (lower) value exists for East Germany.
  static const double bbg = 90600.0;
  /// Assumed start of working life for contribution year estimation.
  /// Conservative default (25) reflects university graduates.
  /// Apprenticeship starters might use 16-18 in practice.
  static const int arbeitsbeginn = 25;
}

// ═══════════════════════════════════════════════════════════════════
// CALCULATION ENGINE
// ═══════════════════════════════════════════════════════════════════

/// Core calculation engine for AV-Depot and ETF-Depot simulations.
///
/// All methods are static and pure — no side effects, no state.
/// The engine is modularized into independent, replaceable components:
///
/// **Subsidy module** (can be replaced for different subsidy regimes):
///   [calcGrundzulage], [calcKinderzulage], [calcBonus],
///   [calcGeringverdienerbonus], [calcZulage], [calcSubsidyBreakdown]
///
/// **Tax module** (can be replaced for different tax systems):
///   [getGrenzsteuersatz], [calcGuenstigerpruefung]
///
/// **Simulation module** (orchestrates subsidy + tax per year):
///   [simulateAV] — AV-Depot accumulation + payout
///   [simulateETF] — ETF-Depot accumulation + payout
///
/// **Composition module** (combines AV + ETF for comparison):
///   [simulateCombined], [simulateAllMacros]
///
/// **Pension estimation** is embedded in [simulateAV] payout phase.
/// To replace it, modify the `effectiveRente` computation block.
class CalculatorService {

  // ═════════════════════════════════════════════════════════════════
  // SUBSIDY MODULE — Förderung calculations
  // Each method is independent and can be replaced individually.
  // ═════════════════════════════════════════════════════════════════

  /// Grundzulage: two-tier percentage match on own contributions.
  /// Returns the annual Grundzulage amount in EUR.
  static double calcGrundzulage(double jahresbeitrag) {
    final capped = min(jahresbeitrag, CalcConstants.grundzulageMaxBeitrag);
    if (capped <= 0) return 0;
    return min(capped, CalcConstants.grundzulageStufe1Cap) * CalcConstants.grundzulageStufe1Rate
        + max(0.0, capped - CalcConstants.grundzulageStufe1Cap) * CalcConstants.grundzulageStufe2Rate;
  }

  /// Kinderzulage: 1:1 match on contributions up to max per child.
  /// Returns the annual Kinderzulage amount in EUR.
  static double calcKinderzulage(double jahresbeitrag, int kinder) {
    if (kinder <= 0 || jahresbeitrag <= 0) return 0;
    return min(jahresbeitrag, CalcConstants.kinderzulageMax) * kinder;
  }

  /// Berufseinsteigerbonus: flat annual bonus for young contract holders.
  /// Returns EUR amount (200) or 0 if not eligible.
  static double calcBonus(int alter, int bonusJahre) {
    return (alter < CalcConstants.bonusMaxAlter && bonusJahre < CalcConstants.bonusMaxJahre)
        ? CalcConstants.bonusBetrag : 0.0;
  }

  /// Geringverdienerbonus: extra subsidy for low-income earners.
  /// Returns EUR amount (175) or 0 if not eligible.
  static double calcGeringverdienerbonus(double brutto, double jahresbeitrag) {
    return (brutto <= CalcConstants.geringverdienerGrenze && jahresbeitrag >= CalcConstants.mindestbeitrag)
        ? CalcConstants.geringverdienerBetrag : 0.0;
  }

  /// Combined yearly subsidy: aggregates all four subsidy components.
  /// Returns a record with individual amounts and total.
  static ({double grund, double kind, double bonus, double gering, double total})
  calcZulage(double jahresbeitrag, int kinder, int alter, int bonusJahre, double brutto) {
    final grund = calcGrundzulage(jahresbeitrag);
    final kind = calcKinderzulage(jahresbeitrag, kinder);
    final bonus = calcBonus(alter, bonusJahre);
    final gering = calcGeringverdienerbonus(brutto, jahresbeitrag);
    return (grund: grund, kind: kind, bonus: bonus, gering: gering, total: grund + kind + bonus + gering);
  }

  // ═════════════════════════════════════════════════════════════════
  // TAX MODULE — Income tax and tax optimization
  // Replace getGrenzsteuersatz when tax brackets change.
  // ═════════════════════════════════════════════════════════════════

  /// German marginal tax rate (Grenzsteuersatz).
  /// Piecewise linear approximation of §32a EStG.
  /// Input: annual gross income (zu versteuerndes Einkommen approximation).
  /// Output: marginal tax rate (0.0 – 0.45).
  ///
  /// Note: Uses Brutto as proxy for zvE. In reality, zvE = Brutto - Werbungskosten
  /// - Sonderausgaben etc., which would lower the rate by a few percentage points.
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

  /// Günstigerprüfung: automatic tax optimization check.
  /// Compares Sonderausgabenabzug vs. keeping Zulagen.
  /// Additional refund (if any) goes to Girokonto, NOT into the depot.
  static ({double steuerersparnis, double zusaetzlich, bool vorteil})
  calcGuenstigerpruefung(double jahresbeitrag, double zulageTotal, double grenzsteuersatz) {
    final gesamtBeitrag = jahresbeitrag + zulageTotal;
    final steuerersparnis = gesamtBeitrag * grenzsteuersatz;
    final zusaetzlich = max(0.0, steuerersparnis - zulageTotal);
    return (steuerersparnis: steuerersparnis, zusaetzlich: zusaetzlich, vorteil: steuerersparnis > zulageTotal);
  }

  /// Full subsidy breakdown for year 1 (used for the subsidy detail table).
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

  // ═════════════════════════════════════════════════════════════════
  // AV-DEPOT SIMULATION
  // Accumulation phase: year-by-year with subsidies + tax-free growth.
  // Payout phase: deferred taxation on combined retirement income.
  // ═════════════════════════════════════════════════════════════════

  static AVResult simulateAV({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    final jb = person.jahresbeitrag;
    final nettoRendite = macro.rendite - costs.kostenAV;

    // ── Accumulation phase ──────────────────────────────────────
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

      final zufluss = jb + z.total; // own contribution + subsidies → into depot
      depot = (depot + zufluss) * (1 + nettoRendite);

      eigenBeitraege += jb;
      zulagenGesamt += z.total;
      steuererstattungGesamt += gp.zusaetzlich; // tracked but NOT in depot

      jahresWerte.add(YearlyDataPoint(
        year: j + 1,
        alter: alter + 1,
        depot: depot,
        depotReal: depot / pow(1 + macro.inflation, j + 1),
        eigenBeitraege: eigenBeitraege,
        zulagen: zulagenGesamt,
        zulageJahr: z.total,
      ));
    }

    // ── Payout phase ────────────────────────────────────────────
    final auszahlungsDauer = person.auszahlungsDauer;
    final monatlich = depot / (auszahlungsDauer * 12);

    // ── Pension estimation (for retirement tax calculation) ─────
    final effectiveRente = _computeEffectiveRente(person, incomeDev);

    // ── Retirement tax on combined income ───────────────────────
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

  /// Compute effective monthly state pension.
  /// Priority: manual override > income-development-based EP accumulation > static estimate.
  static double _computeEffectiveRente(PersonalScenario person, IncomeDevSettings incomeDev) {
    if (person.gesetzlicheRenteOverride != null) {
      return person.gesetzlicheRenteOverride!;
    }
    if (incomeDev.enabled) {
      double totalEP = 0;
      // Pre-savings contribution years (from arbeitsbeginn to alterStart)
      final preSavingsYears = (person.alterStart - CalcConstants.arbeitsbeginn).clamp(0, 45);
      totalEP += preSavingsYears * min(person.brutto, CalcConstants.bbg) / CalcConstants.durchschnittsentgelt;
      // Savings period with growing income
      for (int j = 0; j < person.spardauer; j++) {
        final bruttoJ = incomeDev.bruttoForYear(person.brutto, j);
        totalEP += min(bruttoJ, CalcConstants.bbg) / CalcConstants.durchschnittsentgelt;
      }
      return totalEP * CalcConstants.rentenwert;
    }
    return person.gesetzlicheRente; // static estimate from PersonalScenario
  }

  // ═════════════════════════════════════════════════════════════════
  // ETF-DEPOT SIMULATION
  // Accumulation phase: year-by-year with Vorabpauschale drag.
  // Payout phase: Abgeltungssteuer on gains with Teilfreistellung.
  // ═════════════════════════════════════════════════════════════════

  static ETFResult simulateETF({
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    final jb = person.jahresbeitrag;
    final nettoRendite = macro.rendite - costs.kostenETF - CalcConstants.vorabpauschaleDrag;

    // ── Accumulation phase ──────────────────────────────────────
    double depot = 0;
    double eigenBeitraege = 0;
    final jahresWerte = <YearlyDataPoint>[];

    for (int j = 0; j < person.spardauer; j++) {
      depot = (depot + jb) * (1 + nettoRendite);
      eigenBeitraege += jb;

      jahresWerte.add(YearlyDataPoint(
        year: j + 1,
        alter: person.alterStart + j + 1,
        depot: depot,
        depotReal: depot / pow(1 + macro.inflation, j + 1),
        eigenBeitraege: eigenBeitraege,
        zulagen: 0,
        zulageJahr: 0,
      ));
    }

    // ── Payout phase: tax on gains only ─────────────────────────
    final gewinn = depot - eigenBeitraege;
    final steuerpflichtigerGewinn = gewinn * (1 - CalcConstants.teilfreistellung);
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

  // ═════════════════════════════════════════════════════════════════
  // COMPOSITION MODULE — Combines AV + ETF for comparison
  // ═════════════════════════════════════════════════════════════════

  /// Run both simulations for a single macro scenario.
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

  /// Run all macro scenarios for a given person (cross-product).
  static List<CombinedResult> simulateAllMacros({
    required PersonalScenario person,
    required List<MacroScenario> macros,
    required CostSettings costs,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    return macros.map((m) => simulateCombined(person: person, macro: m, costs: costs, incomeDev: incomeDev)).toList();
  }
}
