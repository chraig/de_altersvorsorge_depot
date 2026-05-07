import 'dart:math';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';
import 'package:avdepot_rechner/services/domain/pension_module.dart';
import 'package:avdepot_rechner/services/domain/tax_module.dart';

// ═══════════════════════════════════════════════════════════════════
// PAYOUT-PHASE RESULTS
// ═══════════════════════════════════════════════════════════════════

/// Output of the AV-Depot payout-phase calculation.
/// All monetary amounts are EUR/month.
class AVPayout {
  final double monatlicheAuszahlung;   // gross monthly payout (gef + ungef summed)
  final double nettoMonatlich;         // net monthly payout after ESt + Soli + KiSt
  final double grenzsteuersatzRente;   // [ratio] incremental ESt rate per euro of AV taxable income
  final double soliRatePayout;         // [ratio] incremental Soli rate per euro of AV taxable income (0 if ESt ≤ §3 Abs. 3 SolzG Freigrenze)

  const AVPayout({
    required this.monatlicheAuszahlung,
    required this.nettoMonatlich,
    required this.grenzsteuersatzRente,
    required this.soliRatePayout,
  });
}

/// Output of the ETF-Depot payout-phase calculation.
class ETFPayout {
  final double bruttoMonatlich;        // gross monthly annuity payment
  final double monatlicheAuszahlung;   // net monthly payout = brutto × (1 − rate)
  final double effectiveTaxRatePayout; // [ratio] = lifetimeSaleTax / lifetimeGross
  final double lifetimeSaleTax;        // [EUR] sale tax during payout, after VP credit
  final double nachSteuer;             // [EUR] lifetime cash-in-hand to user

  const ETFPayout({
    required this.bruttoMonatlich,
    required this.monatlicheAuszahlung,
    required this.effectiveTaxRatePayout,
    required this.lifetimeSaleTax,
    required this.nachSteuer,
  });
}

// ═══════════════════════════════════════════════════════════════════
// PAYOUT-PHASE MODULE INTERFACES
// ═══════════════════════════════════════════════════════════════════

/// Interface for the AV-Depot payout-phase calculation. Replace this to
/// model alternative regimes (Lebenslange Rente vs. Auszahlplan, strict
/// Riester reading via Unterschiedsbetrag, etc.).
///
/// The default implementation is [AnnuityAVPayout].
abstract class AVPayoutModule {
  AVPayout compute({
    required AVAccumulation accumulation,
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    required TaxModule tax,
    required PensionModule pension,
    IncomeDevSettings incomeDev,
  });
}

/// Interface for the ETF-Depot payout-phase calculation. Replace this to
/// model alternative regimes (e.g., partial sale per year with year-by-
/// year tax computation, lump-sum at retirement, etc.).
///
/// The default implementation is [AnnuityETFPayout].
abstract class ETFPayoutModule {
  ETFPayout compute({
    required ETFAccumulation accumulation,
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  });
}

// ═══════════════════════════════════════════════════════════════════
// DEFAULT IMPLEMENTATIONS
// ═══════════════════════════════════════════════════════════════════

/// Auszahlplan that depletes the depot exactly at age 85 via a constant
/// monthly ordinary-annuity payment, with the depot continuing to compound
/// at the savings-phase rendite. Two buckets are paid out in parallel:
///   • Gefördert: 100% of payout taxed as Einkommen (§22 Nr. 5 EStG)
///   • Ungefördert: 17% of payout taxed (Ertragsanteil at age 67,
///     §22 Nr. 1 Satz 3a EStG — calculator simplification, age-67 entry)
///
/// The marginal rate is computed incrementally on top of the user's
/// pension + other income via the exact §32a polynomial (`tax.calcEinkommensteuer`),
/// so AV taxable income is taxed at the rate it adds when stacked on top.
/// Kirchensteuer (when applicable) is applied multiplicatively on top of
/// the income-tax rate.
class AnnuityAVPayout implements AVPayoutModule {
  const AnnuityAVPayout();

  @override
  AVPayout compute({
    required AVAccumulation accumulation,
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
    required TaxModule tax,
    required PensionModule pension,
    IncomeDevSettings incomeDev = const IncomeDevSettings(),
  }) {
    final nettoRendite = macro.rendite - costs.kostenAV;
    final auszahlungsDauer = person.auszahlungsDauer;
    final monthlyRate = pow(1 + nettoRendite, 1.0 / 12).toDouble() - 1;
    final months = auszahlungsDauer * 12;

    final monatlichGefoerdert =
        annuityPayment(accumulation.depotGefoerdert, monthlyRate, months);
    final monatlichUngefoerdert =
        annuityPayment(accumulation.depotUngefoerdert, monthlyRate, months);
    final jahresGefoerdert = monatlichGefoerdert * 12;
    final jahresUngefoerdert = monatlichUngefoerdert * 12;

    // Incremental ESt + Soli on AV-derived taxable income, computed against
    // the user's full retirement income (pension + other + AV taxable).
    final effectiveRente = pension.estimateMonthlyPension(person, incomeDev);
    final baseIncome = effectiveRente * 12 + person.sonstigeEinkuenfte;
    final avTaxableTotal =
        jahresGefoerdert + jahresUngefoerdert * CalcConstants.ertragsanteil67;
    final combinedIncome = baseIncome + avTaxableTotal;
    final taxOnBase = tax.calcEinkommensteuer(baseIncome);
    final taxOnCombined = tax.calcEinkommensteuer(combinedIncome);
    final taxOnAvPayout = taxOnCombined - taxOnBase;
    // Soli is incremental too, applied through the §3 Abs. 3 / §4 SolzG
    // Freigrenze + Milderungszone — so for typical retiree zvE (ESt below
    // €19,950) Soli stays 0; for high-income retirees it phases in.
    final soliOnBase = tax.calcSoli(taxOnBase);
    final soliOnCombined = tax.calcSoli(taxOnCombined);
    final soliOnAvPayout = soliOnCombined - soliOnBase;
    final estRate = avTaxableTotal > 0 ? taxOnAvPayout / avTaxableTotal : 0.0;
    final soliRate = avTaxableTotal > 0 ? soliOnAvPayout / avTaxableTotal : 0.0;

    // Apply per bucket (gef = 100 % taxable, ungef = 17 % Ertragsanteil).
    // KiSt is 9 % surcharge on ESt only (§ 51a EStG); Soli is added on top
    // (Soli is not a base for KiSt). Combined rate per euro of taxable income:
    //   estRate × (1 + KiSt) + soliRate
    final kirchensteuerFaktor = 1 + costs.kirchensteuerRate;
    final taxRateOnTaxable = estRate * kirchensteuerFaktor + soliRate;
    final nettoGefoerdert = monatlichGefoerdert * (1 - taxRateOnTaxable);
    final nettoUngefoerdert = accumulation.depotUngefoerdert > 0
        ? monatlichUngefoerdert *
            (1 - CalcConstants.ertragsanteil67 * taxRateOnTaxable)
        : 0.0;

    return AVPayout(
      monatlicheAuszahlung: monatlichGefoerdert + monatlichUngefoerdert,
      nettoMonatlich: nettoGefoerdert + nettoUngefoerdert,
      grenzsteuersatzRente: estRate,
      soliRatePayout: soliRate,
    );
  }
}

/// Auszahlplan that depletes the depot exactly at age 85 via a constant
/// monthly ordinary-annuity payment, with the depot continuing to compound
/// at the savings-phase rendite. Sale tax is computed against the lifetime
/// gain (`n_m × monthly_gross − cost basis`), credited against the
/// cumulative Vorabpauschale per §19 Abs. 1 InvStG, and expressed as an
/// effective per-month rate on the gross payout — exact under flat
/// Abgeltungssteuer (linearity + conservation of money).
class AnnuityETFPayout implements ETFPayoutModule {
  const AnnuityETFPayout();

  @override
  ETFPayout compute({
    required ETFAccumulation accumulation,
    required PersonalScenario person,
    required MacroScenario macro,
    required CostSettings costs,
  }) {
    final nettoRendite = macro.rendite - costs.kostenETF;
    final auszahlungsDauer = person.auszahlungsDauer;
    final monthlyRate = pow(1 + nettoRendite, 1.0 / 12).toDouble() - 1;
    final months = auszahlungsDauer * 12;

    final monatlichBrutto =
        annuityPayment(accumulation.endkapital, monthlyRate, months);
    final lifetimeGross = monatlichBrutto * months;
    final lifetimeGain = lifetimeGross - accumulation.eigenBeitraege;
    final lifetimeSaleTaxVorAnrechnung =
        lifetimeGain * (1 - CalcConstants.teilfreistellung) * costs.abgeltungssteuersatz;
    final lifetimeSaleTax = lifetimeSaleTaxVorAnrechnung > accumulation.vorabpauschaleGesamt
        ? lifetimeSaleTaxVorAnrechnung - accumulation.vorabpauschaleGesamt
        : 0.0;
    final etfTaxRatePayout = lifetimeGross > 0 ? lifetimeSaleTax / lifetimeGross : 0.0;
    final monatlich = monatlichBrutto * (1 - etfTaxRatePayout);

    return ETFPayout(
      bruttoMonatlich: monatlichBrutto,
      monatlicheAuszahlung: monatlich,
      effectiveTaxRatePayout: etfTaxRatePayout,
      lifetimeSaleTax: lifetimeSaleTax,
      nachSteuer: monatlich * months,
    );
  }
}
