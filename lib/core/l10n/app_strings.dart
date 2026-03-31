// ignore_for_file: annotate_overrides

import 'package:avdepot_rechner/config/build_config.dart';

abstract class AppStrings {
  // ─── HEADER ───────────────────────────────────────────────────────
  String get calculatorBadge;
  String get appTitle;
  String get appSubtitle;

  // ─── SECTIONS ─────────────────────────────────────────────────────
  String get sectionPersonalScenarios;
  String get sectionMacroScenarios;
  String get sectionDetailedResults;
  String get addScenario;

  // ─── INPUT PANEL ──────────────────────────────────────────────────
  String get monthlySavings;
  String get grossAnnualSalary;
  String get numberOfChildren;
  String get startingAge;
  String get retirementAge;
  String derivedDuration(int years);
  String get tabPersonal;
  String get tabCostsTax;
  String get tabIncomeScenarios;
  String get returnPa;
  String get costAvPa;
  String get costEtfPa;
  String get inflationPa;
  String get statePensionMonthly;
  String get otherRetirementIncome;
  String get workStartAge;
  String get hintWorkStartAge;
  String get hintOtherIncome;
  String get retirementTaxRate;
  String get hintMarginalTaxRate;
  String get hintRetirementTaxRate;
  String payoutDurationHint(int years);
  String get hintMonthlySavings;
  String get hintGrossSalary;
  String get hintChildren;
  String childAgeLabel(int index);
  String get hintChildAge;
  String get childStudyYes;
  String get childStudyNo;
  String get hintChildStudy;
  String get hintStartingAge;
  String hintDerivedPension(String amount);
  String get hintReturn;
  String get hintCostAv;
  String get hintCostEtf;
  String get hintInflation;
  String get incomeDevToggle;
  String get incomeDevGrowthRate;
  String get hintIncomeDev;
  String get curveLinear;
  String get curveStepwise;
  String get curveLogarithmic;
  String get promotionInterval;
  String get promotionIncrease;
  String get salaryCap;
  String get partTimeToggle;
  String get partTimeStart;
  String get partTimeDuration;
  String get partTimePercent;
  String get hintGrowthLinear;
  String get hintPromotionInterval;
  String get hintPromotionIncrease;
  String get hintSalaryCap;
  String get hintPartTime;
  String get hintPartTimeStart;
  String get hintPartTimeDuration;
  String get hintPartTimePercent;
  String get hintChildTiming;
  String get childTimingLabel;
  String get addChildBtn;
  String childArrivalLabel(int year);
  String get kirchensteuerLabel;
  String get kirchensteuerNone;
  String get kirchensteuerBayBw;
  String get kirchensteuerOther;
  String get ungefoerdertTaxLabel;
  String get ungefoerdertTaxNachgelagert;
  String get ungefoerdertTaxErtragsanteil;
  String get ungefoerdertTaxHalbeinkunfte;
  String get hintUngefoerdertTax;

  // ─── SUBSIDY BOX ─────────────────────────────────────────────────
  String get baseGrant;
  String get childGrant;
  String get entryBonus;
  String get lowIncomeBonus;
  String get subsidyRate;
  String get totalSubsidyYear;
  String get viaTaxOptimization;

  // ─── TABS ─────────────────────────────────────────────────────────
  String get tabComparison;
  String get tabAvDetail;

  // ─── CALCULATION BREAKDOWN ─────────────────────────────────────────
  String get bdContributions;
  String get bdTaxCostsSavings;
  String get bdCapGainsSavings;
  String get bdCapGainsSavingsAV;
  String get bdCapGainsSavingsETF;
  String get bdIntoDepotYear;
  String bdPhaseSubtotal(int years);
  String get bdAccumulated;
  String bdSavingsYear(int from, int to);
  String bdChildrenEligible(int count);
  String get bdTotalContributions;
  String get bdTotalSubsidies;
  String get bdTaxRefundTotal;
  String get bdTotalIntoDepot;
  String get bdFinalCapital;
  String get bdOwnContrib;
  String get bdSubsidiesReceived;
  String get bdCapGains;
  String get bdPurchasingPower;
  String get bdPayoutPerYear;
  String get bdPayoutPeriod;
  String get bdSamePeriod;
  String get bdGrossPayoutYr;
  String get bdStatePensionYr;
  String get bdOtherIncomeYr;
  String get bdTotalGrossYr;
  String get bdTaxationPerYear;
  String get bdTaxMethod;
  String get bdTaxMethodAV;
  String get bdTaxMethodETF;
  String get bdTaxMethodAvFormula;
  String get bdTaxMethodEtfFormula;
  String get bdWhatTaxed;
  String get bdWhatTaxedAV;
  String get bdWhatTaxedETF;
  String get bdWhatTaxedAvFormula;
  String get bdWhatTaxedEtfFormula;
  String get bdEffectiveTaxRate;
  String bdEffectiveTaxRateAvFormula(String income);
  String get bdEffectiveTaxRateEtfFormula;
  String get bdTaxOnPayoutYr;
  String get bdUngefTreatment;
  String bdAfterTaxTotal(int years);
  String get bdTotalTaxPaid;
  String get bdDepotAfterTax;
  String get bdContribTaxFree;
  String get bdContribTaxFreeAV;
  String get bdMonthlyNet;
  String get bdGrossPerMonth;
  String get bdTaxPerMonth;
  String get bdNetPerMonth;
  // breakdown tabs
  String get bdTabSavings;
  String get bdTabPayout;
  // bar chart legends
  String get legendContrib;
  String get legendGrundzulage;
  String get legendKinderzulage;
  String get legendBonus;
  String get legendTaxRefund;
  String get legendNetPayout;
  String get legendTax;
  String get chartSavingsTitle;
  String get chartPayoutTitle;
  // result assumptions
  String get sectionAssumptions;
  String get hintAssumptions;

  // ─── INFO TOOLTIPS ─────────────────────────────────────────────────
  String get tipGrundzulage;
  String get tipKinderzulage;
  String get tipBerufseinsteigerbonus;
  String get tipGeringverdienerbonus;
  String get tipGuenstigerpruefung;
  String get tipGefoerdert;
  String get tipUngefoerdert;
  String get tipVorabpauschale;
  String get tipTeilfreistellung;

  // ─── COMPARISON ───────────────────────────────────────────────────
  String avYieldsMore(String amount);
  String etfYieldsMore(String amount);
  String get etfWinsExplanation;
  String comparisonSubtitle(String icon, String name);
  String get ownContributions;

  // ─── DETAIL ───────────────────────────────────────────────────────
  String get finalCapital;
  String get purchasingPowerToday;
  String get inflationAdjusted;
  String get compositionTitle;
  String get subsidiesLabel;
  String get taxRefundNotInDepot;
  String get capitalGainsLabel;
  String get taxLogicTitle;
  String get taxLogicDescription;
  String get marginalTaxRate;

  // ─── SUBSIDY LOGIC ───────────────────────────────────────────────
  String get subsidyLogicTitle;
  String get slBaseGrantLabel;
  String get slBaseGrantDetail;
  String get slChildGrantLabel;
  String get slChildGrantDetail;
  String get slEntryBonusLabel;
  String get slEntryBonusDetail;
  String get slTaxOptLabel;
  String get slTaxOptDetail;
  String get slPayoutLabel;
  String get slPayoutDetail;

  // ─── LEGISLATIVE BASIS ───────────────────────────────────────────
  String get legislativeBasisTitle;
  String get legislativeBasisDetail;
  String get sourcesTitle;
  String get sourcesDetail;

  // ─── ERRORS ──────────────────────────────────────────────────────
  String pageNotFound(String uri);

  // ─── PROS / CONS ────────────────────────────────────────────────
  String get prosConsTitle;
  String get avProsTitle;
  String get etfProsTitle;
  String get proHighSubsidyRate;
  String get proKinderzulage;
  String get proGeringverdienerbonus;
  String get proBerufseinsteigerbonus;
  String get proGuenstigerpruefung;
  String get proLongDuration;
  String get proTaxFreeGrowth;
  String get conLowSubsidyLeverage;
  String get conHighRetirementTax;
  String get proEtfOnlyGainsTaxed;
  String get proEtfTeilfreistellung;
  String get proEtfFlexibility;
  String get proEtfLowReturnsAdvantage;

  // ─── FOOTER ───────────────────────────────────────────────────────
  String get resetAll;
  String get disclaimer;
  String get includedFeaturesTitle;
  String get includedFeaturesDetail;
  String get simplificationsTitle;
  String get simplificationsDetail;
  String get plannedFeaturesTitle;
  String get plannedFeaturesDetail;

  // ─── LEGAL ──────────────────────────────────────────────────────
  String get impressumTitle;
  String get impressumDetail;
  String get datenschutzTitle;
  String get datenschutzDetail;
  String get copyrightNotice;

  // ─── ETF TAX NOTE ──────────────────────────────────────────────

  // ─── CHARTS ───────────────────────────────────────────────────────
  String get chartAllMacrosTitle;
  String chartWealthTitle(String icon, String name);
  String get otherScenarios;

  // ─── TABLE COLUMNS ───────────────────────────────────────────────
  String get colScenario;
  String get colReturn;
  String get colInflation;
  String get colRealReturn;
  String get colAvFinalCap;
  String get colPurchPower;
  String get colAvNetMo;
  String get colEtfFinalCap;
  String get colEtfNetMo;
  String get colDelta;
  String get colDeltaMo;
  String get tagSavingsRate;
  String get tagGross;
  String get tagChildren;
  String get tagDuration;
  String get tagSubsidyYear;
  String get tagSubsidyRate;
  String get tagMargTax;

  // ─── DIALOGS ─────────────────────────────────────────────────────
  String get editScenario;
  String get newScenarioTitle;
  String get editMacroScenario;
  String get newMacroScenarioTitle;
  String get addMacroLabel;
  String get deleteBtn;
  String get cancelBtn;
  String get saveBtn;
  String get addBtn;
  String get fieldName;
  String get fieldShortName;
  String get fieldIcon;
  String get fieldDescription;
  String get fieldReturnPct;
  String get fieldInflationPct;
  String get fieldColor;
  String get fieldSavingsRate;
  String get fieldGrossSalary;
  String get fieldChildren;
  String get fieldStartAge;
  String get fieldDuration;
  String get defaultScenarioName;

  // ─── INLINE LABELS ─────────────────────────────────────────────────
  String get customName;
  String get customShort;
  String get customDesc;
  String get avDepotLabel;
  String get etfLabel;
  String get yearSuffix;
  String get perMonth;

  // ─── TABS / LABELS ─────────────────────────────────────────────────
  String get chartTab;
  String get tableTab;

  // ─── SCENARIO PRESETS ─────────────────────────────────────────────
  String get presetCareerStarter;
  String get presetSingleMid30;
  String get presetFamily2Kids;
  String get presetHighEarner;
  String get presetPartTimeChild;

  String get macroBoomName;
  String get macroBoomShort;
  String get macroBoomDesc;
  String get macroBaselineName;
  String get macroBaselineShort;
  String get macroBaselineDesc;
  String get macroModerateName;
  String get macroModerateShort;
  String get macroModerateDesc;
  String get macroStagflationName;
  String get macroStagflationShort;
  String get macroStagflationDesc;
  String get macroJapanName;
  String get macroJapanShort;
  String get macroJapanDesc;
  String get macroLostDecadeName;
  String get macroLostDecadeShort;
  String get macroLostDecadeDesc;

  // ─── FACTORY ─────────────────────────────────────────────────────

  static AppStrings fromLocale(AppLocale locale) => switch (locale) {
    AppLocale.en => StringsEn(),
    AppLocale.de => StringsDe(),
  };
}

enum AppLocale { en, de }

// ═══════════════════════════════════════════════════════════════════
// ENGLISH
// ═══════════════════════════════════════════════════════════════════

class StringsEn extends AppStrings {
  StringsEn();

  // Header
  String get calculatorBadge => 'CALCULATOR 2027';
  String get appTitle => 'Retirement Savings Depot';
  String get appSubtitle => 'vs. Private ETF Portfolio';

  // Sections
  String get sectionPersonalScenarios => 'Personal Scenarios';
  String get sectionMacroScenarios => 'Macroeconomic Scenarios';
  String get sectionDetailedResults => 'Detailed Results';
  String get addScenario => '+ Scenario';

  // Input
  String get monthlySavings => 'Monthly Savings Rate';
  String get grossAnnualSalary => 'Gross Annual Income';
  String get numberOfChildren => 'Number of Children';
  String get startingAge => 'Starting Age';
  String get retirementAge => 'Retirement Age';
  String derivedDuration(int years) => 'Duration: $years years (derived)';
  String get tabPersonal => 'Personal';
  String get tabCostsTax => 'Costs & Tax';
  String get tabIncomeScenarios => 'Income';
  String get returnPa => 'Return p.a.';
  String get costAvPa => 'AV-Depot Cost p.a.';
  String get costEtfPa => 'ETF Portfolio Cost p.a.';
  String get inflationPa => 'Inflation p.a.';
  String get statePensionMonthly => 'Est. State Pension (monthly)';
  String get otherRetirementIncome => 'Other Retirement Income (yearly)';
  String get hintOtherIncome => 'Yearly amount (e.g. rental income, private pension). Used to estimate retirement tax rate.';
  String get workStartAge => 'Work Start Age';
  String get hintWorkStartAge => 'Age when you started paying into the state pension system (Rentenversicherung). Affects pension point accumulation. E.g. 16 for apprenticeship, 25 for university graduates.';
  String get retirementTaxRate => 'Retirement Tax Rate';
  String get hintMarginalTaxRate => 'Your current tax bracket based on gross income. Used for Günstigerprüfung during savings.';
  String get hintRetirementTaxRate => 'Tax rate on AV-Depot payouts in retirement. Based on combined income: state pension + AV payout + other income.';
  String payoutDurationHint(int years) => 'Payout duration: $years years (until age 85)';
  String get hintMonthlySavings => 'Your monthly contribution. Subsidized up to €150/mo (€1,800/yr). Max €570/mo (€6,840/yr) per contract. Above €150, no subsidy but preferential tax on payout.';
  String get hintGrossSalary => 'Your yearly gross income before taxes. Determines your tax rate and subsidy eligibility.';
  String get hintChildren => 'Number of children eligible for Kindergeld. Each child adds up to €300/yr subsidy. Ends at age 25 (education) or 18.';
  String childAgeLabel(int index) => 'Age of child ${index + 1}';
  String get hintChildAge => 'Current age. Kinderzulage ends when child turns 25 (in education) or 18.';
  String get childStudyYes => 'Education (until 25)';
  String get childStudyNo => 'No education (until 18)';
  String get hintChildStudy => 'Kindergeld eligibility: until 25 if child is in education/training, otherwise until 18.';
  String get hintStartingAge => 'Age when you start saving. Younger start = longer compounding.';
  String hintDerivedPension(String amount) => 'Est. state pension: $amount/mo (derived from your income and contribution years). Override in Advanced Settings.';
  String get hintReturn => 'Expected annual return before costs. Depends on the selected macro scenario or manual input.';
  String get hintCostAv => 'Annual costs of the AV-Depot provider. Legal cap: 1.0% for Standardprodukt.';
  String get hintCostEtf => 'Annual costs of your ETF (TER). Typical World-ETF: 0.1–0.2%.';
  String get hintInflation => 'Expected annual inflation rate. Reduces purchasing power of future payouts.';
  String get incomeDevToggle => 'Model Income Growth';
  String get incomeDevGrowthRate => 'Annual Income Growth';
  String get hintIncomeDev => 'When enabled, gross income changes over time. Affects subsidies, tax rate, and pension estimate year by year.';
  String get hintGrowthLinear => 'Income grows by this percentage every year (compound). E.g. 2% = typical inflation-adjusted raise.';
  String get hintPromotionInterval => 'How often you expect a significant raise or promotion.';
  String get hintPromotionIncrease => 'Percentage salary jump per promotion. E.g. 15% for a typical role change.';
  String get hintSalaryCap => 'Income ceiling your career approaches over time. Growth slows as you near this value.';
  String get hintPartTime => 'Model a period of reduced income, e.g. for parental leave or caring responsibilities.';
  String get hintPartTimeStart => 'Savings year when part-time begins (0 = first year).';
  String get hintPartTimeDuration => 'How many years the reduced income phase lasts.';
  String get hintPartTimePercent => 'Your income during part-time as a fraction of full income. E.g. 50% = half-time.';
  String get hintChildTiming => 'Add children at specific savings years. Each child adds up to €300/yr Kinderzulage from that year onward.';
  String get curveLinear => 'Linear';
  String get curveStepwise => 'Step-wise';
  String get curveLogarithmic => 'Logarithmic';
  String get promotionInterval => 'Promotion every';
  String get promotionIncrease => 'Promotion raise';
  String get salaryCap => 'Income ceiling';
  String get partTimeToggle => 'Part-time phase';
  String get partTimeStart => 'Starts in year';
  String get partTimeDuration => 'Duration';
  String get partTimePercent => 'Income during part-time';
  String get childTimingLabel => 'Child arrival';
  String get addChildBtn => '+ Child';
  String childArrivalLabel(int year) => 'Child arrives in savings year $year';
  String get kirchensteuerLabel => 'Church Tax';
  String get kirchensteuerNone => 'None';
  String get kirchensteuerBayBw => '8% (Bavaria/BaWü)';
  String get kirchensteuerOther => '9% (other states)';
  String get ungefoerdertTaxLabel => 'AV-Depot: unsubsidized payout tax';
  String get ungefoerdertTaxNachgelagert => 'Full (conservative)';
  String get ungefoerdertTaxErtragsanteil => 'Ertragsanteil (17%)';
  String get ungefoerdertTaxHalbeinkunfte => 'Halbeinkünfte (50% gains)';
  String get hintUngefoerdertTax => 'AV-Depot only: tax on unsubsidized contributions (above €1,800/yr) at payout. BMF guidance pending. Does not affect ETF comparison.';

  // Subsidy
  String get baseGrant => 'Base Grant';
  String get childGrant => 'Child Grant';
  String get entryBonus => 'Entry Bonus';
  String get lowIncomeBonus => 'Low-Income Bonus';
  String get subsidyRate => 'Subsidy Rate';
  String get totalSubsidyYear => 'Total Subsidy/Year';
  String get viaTaxOptimization => 'via tax optimization check';

  // Tabs
  String get tabComparison => 'Comparison';
  String get tabAvDetail => 'AV-Depot Detail';

  // Comparison
  // Calculation Basis
  String get bdContributions => 'Contributions';
  String get bdTaxCostsSavings => 'Tax & Costs During Savings';
  String get bdCapGainsSavings => 'Capital gains during savings';
  String get bdCapGainsSavingsAV => 'Tax-free';
  String get bdCapGainsSavingsETF => 'Taxed yearly';
  String get bdIntoDepotYear => 'Into Depot Per Year';
  String bdPhaseSubtotal(int years) => 'Phase subtotal ($years yr)';
  String get bdAccumulated => 'Accumulated Over Savings Period';
  String bdSavingsYear(int from, int to) => from == to ? 'Savings year $from' : 'Savings years $from–$to';
  String bdChildrenEligible(int count) => '$count child${count != 1 ? 'ren' : ''} eligible';
  String get bdTotalContributions => 'Total contributions';
  String get bdTotalSubsidies => 'Total subsidies';
  String get bdTaxRefundTotal => 'Tax refund total (→ bank)';
  String get bdTotalIntoDepot => 'Total into depot';
  String get bdFinalCapital => 'Final Capital (total)';
  String get bdOwnContrib => 'thereof own contributions';
  String get bdSubsidiesReceived => 'thereof subsidies';
  String get bdCapGains => 'thereof capital gains';
  String get bdPurchasingPower => 'Purchasing power today';
  String get bdPayoutPerYear => 'Payout (per year)';
  String get bdPayoutPeriod => 'Payout period';
  String get bdSamePeriod => 'same period for comparison';
  String get bdGrossPayoutYr => 'Gross depot payout/yr';
  String get bdStatePensionYr => 'State pension/yr (same)';
  String get bdOtherIncomeYr => 'Other income/yr (same)';
  String get bdTotalGrossYr => 'Total gross income/yr';
  String get bdTaxationPerYear => 'Taxation (per year)';
  String get bdTaxMethod => 'Tax method';
  String get bdTaxMethodAV => 'Income tax (§32a)';
  String get bdTaxMethodETF => 'Income tax + Abgeltungssteuer';
  String get bdTaxMethodAvFormula => 'All income taxed together progressively';
  String get bdTaxMethodEtfFormula => 'Pension via §32a, gains via flat AbgSt';
  String get bdWhatTaxed => 'What is taxed from depot';
  String get bdWhatTaxedAV => 'Entire payout (100%)';
  String get bdWhatTaxedETF => 'Only 70% of gains';
  String get bdWhatTaxedAvFormula => 'Contributions + subsidies + gains = income';
  String get bdWhatTaxedEtfFormula => 'After 30% Teilfreistellung';
  String get bdEffectiveTaxRate => 'Effective tax rate on depot payout';
  String bdEffectiveTaxRateAvFormula(String income) => '= [tax(pension+other+AV) − tax(pension+other)] ÷ AV payout';
  String get bdEffectiveTaxRateEtfFormula => '25% KapESt + 5.5% Soli';
  String get bdTaxOnPayoutYr => 'Tax on depot payout/yr';
  String get bdUngefTreatment => 'Ungefördert treatment';
  String bdAfterTaxTotal(int years) => 'After Tax (total over $years years)';
  String get bdTotalTaxPaid => 'Total tax paid';
  String get bdDepotAfterTax => 'Depot after all tax';
  String get bdContribTaxFree => 'Contributions returned tax-free';
  String get bdContribTaxFreeAV => 'No';
  String get bdMonthlyNet => 'Monthly Net from Depot';
  String get bdGrossPerMonth => 'Gross per month';
  String get bdTaxPerMonth => 'Tax per month';
  String get bdNetPerMonth => 'Net per month';
  String get bdTabSavings => 'Savings Phase';
  String get bdTabPayout => 'Payout Phase';
  String get legendContrib => 'Contribution';
  String get legendGrundzulage => 'Grundzulage';
  String get legendKinderzulage => 'Kinderzulage';
  String get legendBonus => 'Bonus';
  String get legendTaxRefund => 'Tax refund';
  String get legendNetPayout => 'Net payout';
  String get legendTax => 'Tax';
  String get chartSavingsTitle => 'AV-Depot: Annual Deposits & Subsidies';
  String get chartPayoutTitle => 'AV-Depot: Annual Payout Breakdown';
  String get sectionAssumptions => 'Assumptions';
  String get hintAssumptions => 'These choices affect the calculation but depend on individual circumstances.';

  // Info Tooltips
  String get tipGrundzulage => 'Government matches your contributions: 50% on the first €360/yr and 25% on €361–1,800/yr. Maximum €540/yr. Goes directly into your depot.';
  String get tipKinderzulage => 'Up to €300/child/year (1:1 match from €25/mo). Child must be kindergeldberechtigt — ends at age 25 (in education) or 18. Subsidy stops when the child ages out.';
  String get tipBerufseinsteigerbonus => 'One-time €200 bonus in your first contract year if you are under 25. No ongoing payments — just the first year.';
  String get tipGeringverdienerbonus => 'Extra €175/yr if your gross income is €26,250 or less and you contribute at least €120/yr. Stacks on top of the Grundzulage.';
  String get tipGuenstigerpruefung => 'The tax office automatically checks: is the tax deduction on your contributions worth more than the subsidies? If yes, you get the difference as a tax refund — but to your bank account, NOT into the depot.';
  String get tipGefoerdert => 'Subsidized contributions (up to €1,800/yr): grow tax-free, but the ENTIRE payout in retirement is taxed at your income tax rate (nachgelagerte Besteuerung).';
  String get tipUngefoerdert => 'Unsubsidized contributions (above €1,800/yr): no subsidies, but still tax-free growth during savings. Payout taxation is pending official BMF guidance (law takes effect Jan 2027). Currently calculated conservatively as full nachgelagerte Besteuerung. Actual treatment may be more favorable (e.g., Ertragsanteilbesteuerung or Halbeinkünfteverfahren).';
  String get tipVorabpauschale => 'Annual tax on unrealized ETF gains, calculated from the Basiszins (ECB reference rate). Simplified here as a fixed drag on returns. Does NOT apply inside the AV-Depot.';
  String get tipTeilfreistellung => '30% of your ETF gains are tax-exempt because the fund already paid withholding tax at fund level. Only 70% of gains are subject to Abgeltungssteuer.';

  String avYieldsMore(String amount) => 'AV-Depot yields $amount more.';
  String etfYieldsMore(String amount) => 'ETF Portfolio yields $amount more.';
  String get etfWinsExplanation =>
    'Why? The AV-Depot subsidies are capped at €1,800/yr contributions. '
    'Above that, additional savings receive no subsidy but the entire payout is '
    'taxed at your income tax rate. The ETF portfolio only taxes gains (with 30% '
    'exemption) at a lower flat rate. With high income, high contributions, or '
    'low returns, this tax advantage outweighs the subsidy.';
  String comparisonSubtitle(String icon, String name) =>
    '$icon $name – AV: deferred taxation / ETF: capital gains tax with 30% partial exemption';
  String get ownContributions => 'Own Contributions';

  // Detail
  String get finalCapital => 'Final Capital';
  String get purchasingPowerToday => 'Purchasing Power Today';
  String get inflationAdjusted => 'inflation-adjusted';
  String get compositionTitle => 'Composition';
  String get subsidiesLabel => 'Subsidies';
  String get taxRefundNotInDepot => 'Tax Refund – paid to your bank account, not into the depot';
  String get capitalGainsLabel => 'Capital Gains';
  String get taxLogicTitle => 'Tax Logic';
  String get taxLogicDescription =>
    'Accumulation phase: Capital gains tax-free. Subsidies flow into the depot. '
    'Tax optimization check can provide a tax refund.\n\n'
    'Payout phase: Deferred taxation at personal tax rate. '
    'Payout plan until age 85, up to 30% lump sum withdrawal.';
  String get marginalTaxRate => 'Marginal Tax Rate';

  // Subsidy Logic
  String get subsidyLogicTitle => 'Subsidy Logic in Detail';
  String get slBaseGrantLabel => 'Base Grant:';
  String get slBaseGrantDetail =>
    '▸ 50% on first €360/yr = max €180\n'
    '▸ 25% on €361–1,800/yr = max €360\n'
    '▸ Max. base grant: €540/yr';
  String get slChildGrantLabel => 'Child Grant:';
  String get slChildGrantDetail => '▸ Up to €300/child/yr, full grant from €25/month';
  String get slEntryBonusLabel => 'Entry Bonus:';
  String get slEntryBonusDetail => '▸ One-time €200 in first year (under 25)';
  String get slTaxOptLabel => 'Tax Optimization:';
  String get slTaxOptDetail =>
    '▸ Own contribution + subsidies as special expenses\n'
    '▸ Difference refunded if applicable';
  String get slPayoutLabel => 'Payout:';
  String get slPayoutDetail =>
    '▸ Payout plan until 85, up to 30% lump sum\n'
    '▸ Deferred taxation';

  // Legislative Basis
  String get legislativeBasisTitle => 'Legislative Basis';
  String get legislativeBasisDetail =>
    '▸ Altersvorsorgereformgesetz – Bundestag Drucksache 21/4088\n'
    '▸ Finanzausschuss amendments, 25 March 2026 (coalition agreement CDU/CSU + SPD)\n'
    '▸ Passed by Bundestag on 27 March 2026 (2nd + 3rd reading)\n'
    '▸ Key changes vs. original draft (Dec 2025): Grundzulage raised to 50%/25%, Kostendeckel lowered to 1.0%, '
    'all self-employed now eligible, public provider mandated\n'
    '▸ Effective date: 1 January 2027';
  String get sourcesTitle => 'Sources';
  String get sourcesDetail =>
    '▸ BMF FAQ: bundesfinanzministerium.de/Content/DE/FAQ/reform-der-privaten-altersvorsorge.html\n'
    '▸ Bundestag vote: bundestag.de/presse/hib/kurzmeldungen-1157838\n'
    '▸ Bundestag hearing: bundestag.de/dokumente/textarchiv/2026/kw12-pa-finanzen-1152002\n'
    '▸ Finanztip: finanztip.de/altersvorsorge/altersvorsorgedepot\n'
    '▸ justETF: justetf.com/de/academy/altersvorsorgedepot-entwurf-2027.html';

  // Errors
  String pageNotFound(String uri) => 'Page not found: $uri';

  // Pros / Cons
  String get prosConsTitle => 'What Applies to Your Scenario';
  String get avProsTitle => 'AV-Depot advantages';
  String get etfProsTitle => 'ETF Portfolio advantages';
  String get proHighSubsidyRate => 'High subsidy rate on your contributions';
  String get proKinderzulage => 'Child grant active (€300/child/yr)';
  String get proGeringverdienerbonus => 'Low-income bonus applies (+€175/yr)';
  String get proBerufseinsteigerbonus => 'Career starter bonus active (one-time +€200)';
  String get proGuenstigerpruefung => 'Tax optimization check yields additional refund';
  String get proLongDuration => 'Long savings duration – subsidies compound over decades';
  String get proTaxFreeGrowth => 'Tax-free growth during accumulation (no Vorabpauschale, no capital gains tax)';
  String get conLowSubsidyLeverage => 'Contributions above €150/mo receive no subsidy. Entire payout currently taxed at income rate (conservative). Unsubsidized portion may receive more favorable treatment once BMF guidance is published.';
  String get conHighRetirementTax => 'High marginal tax rate – deferred taxation at high rate reduces advantage';
  String get proEtfOnlyGainsTaxed => 'Only gains are taxed – your contributions are returned tax-free';
  String get proEtfTeilfreistellung => '30% partial exemption (Teilfreistellung) reduces taxable gains';
  String get proEtfFlexibility => 'No lock-up period – withdraw any time without restrictions';
  String get proEtfLowReturnsAdvantage => 'With low returns, gains are small – less tax impact than deferred full-payout taxation';

  // Footer
  String get resetAll => 'Reset All Values';
  String get disclaimer =>
    'This calculator is for educational and illustrative purposes only. '
    'It does not constitute investment advice, tax advice, or a recommendation '
    'within the meaning of §2 Abs. 4 WpHG. The calculations are based on '
    'simplified assumptions and may differ significantly from actual outcomes. '
    'Consult a qualified financial advisor (Steuerberater, Finanzberater) for '
    'personal decisions. No warranty is provided. Use at your own risk.';
  String get includedFeaturesTitle => 'Included in This Calculator';
  String get includedFeaturesDetail =>
    '▸ Grundzulage (50%/25% two-tier subsidy on up to €1,800/yr)\n'
    '▸ Kinderzulage (up to €300/child/yr, 1:1 match)\n'
    '▸ Berufseinsteigerbonus (one-time €200, under 25)\n'
    '▸ Geringverdienerbonus (€175/yr for gross ≤ €26,250)\n'
    '▸ Günstigerprüfung (automatic tax optimization check)\n'
    '▸ Kirchensteuer (optional: None / 8% / 9%)\n'
    '▸ Abgeltungssteuer with 30% Teilfreistellung for ETF\n'
    '▸ Vorabpauschale (simplified as 0.3% annual drag)\n'
    '▸ Nachgelagerte Besteuerung (deferred taxation on AV-Depot payouts)\n'
    '▸ 6 macro scenario presets + custom scenarios\n'
    '▸ 5 personal scenario presets + custom input';
  String get simplificationsTitle => 'Simplifications';
  String get simplificationsDetail =>
    'Both: Single equity ETF assumed for comparability (AV-Depot may hold multiple instruments)\n'
    'Both: Constant annual returns (no sequence-of-returns risk)\n'
    'Both: No partial-year contributions\n'
    'Both: Fund-level withholding tax (~0.3% p.a.) not separately modeled\n'
    'ETF: Vorabpauschale simplified as 0.3% annual drag (actual depends on Basiszins)\n'
    'AV: Retirement tax uses progressive §32a average rate on combined income. Brutto used as proxy for zvE.\n'
    'AV: Ungeförderte payout tax treatment pending BMF guidance — conservatively uses full nachgelagerte Besteuerung. May be more favorable (Ertragsanteil/Halbeinkünfte) once clarified.\n'
    'AV: Günstigerprüfung tax refund paid to bank account, not reinvested\n'
    'AV: State pension estimated from gross income (Entgeltpunkte formula, 2024 Rentenwert) – adjustable';
  String get plannedFeaturesTitle => 'Not Yet Included';
  String get plannedFeaturesDetail =>
    '▸ Riester comparison (old vs. new subsidy system)\n'
    '▸ Wohnwirtschaftliche Verwendung (tax-free property withdrawal)\n'
    '▸ Leibrente vs. Auszahlplan comparison\n'
    '▸ Monte Carlo simulation (random return sequences)\n'
    '▸ PDF/CSV export';

  // Legal
  String get impressumTitle => 'Legal Notice (Impressum)';
  String get impressumDetail =>
    '${BuildConfig.ownerName}\n'
    '${BuildConfig.postalAddress}\n'
    '${BuildConfig.email}\n\n'
    'Responsible for content according to §18 Abs. 2 MStV: ${BuildConfig.ownerName}';
  String get datenschutzTitle => 'Privacy Policy';
  String get datenschutzDetail =>
    'This website does not collect, store, or process any personal data. '
    'All calculations are performed entirely in your browser – no data is '
    'transmitted to any server.\n\n'
    'No cookies are set. No tracking or analytics tools are used.\n\n'
    'Your IP address is processed by the hosting provider (Hostinger) for the '
    'sole purpose of delivering this website. This processing is based on '
    'Art. 6 Abs. 1 lit. f DSGVO (legitimate interest in providing the website). '
    'No further processing or storage of personal data takes place.';
  String get copyrightNotice =>
    '© ${BuildConfig.copyrightYear} ${BuildConfig.ownerName} – All rights reserved. '
    'The content, design, and calculations of this website may not be reproduced, '
    'distributed, or reused in any form without prior written permission.';

  // Charts
  String get chartAllMacrosTitle => 'AV-Depot: All Macro Scenarios + ETF (dashed)';
  String chartWealthTitle(String icon, String name) => 'Wealth Development – $icon $name';
  String get otherScenarios => 'Other Scenarios';

  // Table
  String get colScenario => 'SCENARIO';
  String get colReturn => 'RETURN';
  String get colInflation => 'INFLATION';
  String get colRealReturn => 'REAL';
  String get colAvFinalCap => 'AV CAP.';
  String get colPurchPower => 'PURCH.PWR';
  String get colAvNetMo => 'AV/MO';
  String get colEtfFinalCap => 'ETF CAP.';
  String get colEtfNetMo => 'ETF/MO';
  String get colDelta => 'Δ AV-ETF';
  String get colDeltaMo => 'Δ/MO';
  String get tagSavingsRate => 'Savings';
  String get tagGross => 'Gross';
  String get tagChildren => 'Children';
  String get tagDuration => 'Duration';
  String get tagSubsidyYear => 'Subsidy/yr';
  String get tagSubsidyRate => 'Sub. Rate';
  String get tagMargTax => 'Marg. Tax';

  // Dialogs
  String get editScenario => 'Edit Scenario';
  String get newScenarioTitle => 'New Scenario';
  String get editMacroScenario => 'Edit Macro Scenario';
  String get newMacroScenarioTitle => 'New Macro Scenario';
  String get addMacroLabel => 'Add Macro';
  String get deleteBtn => 'Delete';
  String get cancelBtn => 'Cancel';
  String get saveBtn => 'Save';
  String get addBtn => 'Add';
  String get fieldName => 'Name';
  String get fieldShortName => 'Short Name';
  String get fieldIcon => 'Icon (Emoji)';
  String get fieldDescription => 'Description';
  String get fieldReturnPct => 'Return (% p.a.)';
  String get fieldInflationPct => 'Inflation (% p.a.)';
  String get fieldColor => 'Color:';
  String get fieldSavingsRate => 'Savings Rate (€/month)';
  String get fieldGrossSalary => 'Gross Annual Income (€)';
  String get fieldChildren => 'Number of Children';
  String get fieldStartAge => 'Starting Age';
  String get fieldDuration => 'Duration (years)';
  String get defaultScenarioName => 'New Scenario';

  // Inline labels
  String get customName => 'Custom';
  String get customShort => 'Custom';
  String get customDesc => 'Manually configured';
  String get avDepotLabel => 'AV-Depot';
  String get etfLabel => 'ETF';
  String get yearSuffix => 'Y';
  String get perMonth => '/mo';

  // Tabs
  String get chartTab => 'Chart';
  String get tableTab => 'Table';

  // Presets
  String get presetCareerStarter => 'Career Starter';
  String get presetSingleMid30 => 'Single, mid-30s';
  String get presetFamily2Kids => 'Family, 2 Children';
  String get presetHighEarner => 'High Earner';
  String get presetPartTimeChild => 'Part-time + Child';

  String get macroBoomName => 'Boom / Bull Market';
  String get macroBoomShort => 'Boom';
  String get macroBoomDesc => 'Strong economy, low inflation – like 2010–2021.';
  String get macroBaselineName => 'Baseline / Hist. Average';
  String get macroBaselineShort => 'Baseline';
  String get macroBaselineDesc => 'MSCI World average ~7% at 2% inflation.';
  String get macroModerateName => 'Moderate Slowdown';
  String get macroModerateShort => 'Moderate';
  String get macroModerateDesc => 'Weaker growth, slightly higher inflation.';
  String get macroStagflationName => 'Stagflation';
  String get macroStagflationShort => 'Stagflation';
  String get macroStagflationDesc => 'High inflation with weak growth – like 1970s.';
  String get macroJapanName => 'Japan Scenario';
  String get macroJapanShort => 'Japan';
  String get macroJapanDesc => 'Stagnation with zero interest – Japan 1990–2020.';
  String get macroLostDecadeName => 'Lost Decade';
  String get macroLostDecadeShort => 'Lost Decade';
  String get macroLostDecadeDesc => 'Crash with slow recovery – 2000–2012.';
}

// ═══════════════════════════════════════════════════════════════════
// GERMAN
// ═══════════════════════════════════════════════════════════════════

class StringsDe extends AppStrings {
  StringsDe();

  String get calculatorBadge => 'RECHNER 2027';
  String get appTitle => 'Altersvorsorgedepot';
  String get appSubtitle => 'vs. privates ETF-Depot';

  String get sectionPersonalScenarios => 'Persönliche Szenarien';
  String get sectionMacroScenarios => 'Makroökonomische Szenarien';
  String get sectionDetailedResults => 'Detailergebnisse';
  String get addScenario => '+ Szenario';

  String get monthlySavings => 'Monatliche Sparrate';
  String get grossAnnualSalary => 'Bruttojahreseinkommen';
  String get numberOfChildren => 'Anzahl Kinder';
  String get startingAge => 'Alter bei Start';
  String get retirementAge => 'Rentenalter';
  String derivedDuration(int years) => 'Dauer: $years Jahre (abgeleitet)';
  String get tabPersonal => 'Persönlich';
  String get tabCostsTax => 'Kosten & Steuer';
  String get tabIncomeScenarios => 'Einkommen';
  String get returnPa => 'Rendite p.a.';
  String get costAvPa => 'Kosten AV-Depot p.a.';
  String get costEtfPa => 'Kosten ETF-Depot p.a.';
  String get inflationPa => 'Inflation p.a.';
  String get statePensionMonthly => 'Gesch. gesetzl. Rente (monatlich)';
  String get otherRetirementIncome => 'Sonstige Einkünfte im Ruhestand (jährlich)';
  String get hintOtherIncome => 'Jahresbetrag (z.B. Mieteinnahmen, Betriebsrente). Wird zur Berechnung des Steuersatzes im Ruhestand verwendet.';
  String get workStartAge => 'Beginn Erwerbstätigkeit';
  String get hintWorkStartAge => 'Alter bei Beginn der Einzahlung in die gesetzliche Rentenversicherung. Beeinflusst die Rentenpunkte-Ansammlung. Z.B. 16 bei Ausbildung, 25 bei Hochschulabschluss.';
  String get retirementTaxRate => 'Steuersatz im Ruhestand';
  String get hintMarginalTaxRate => 'Ihr aktueller Steuersatz basierend auf dem Bruttoeinkommen. Wird für die Günstigerprüfung während der Sparphase verwendet.';
  String get hintRetirementTaxRate => 'Steuersatz auf AV-Depot-Auszahlungen im Ruhestand. Basiert auf Gesamteinkommen: gesetzl. Rente + AV-Auszahlung + Sonstige.';
  String payoutDurationHint(int years) => 'Auszahlungsdauer: $years Jahre (bis Alter 85)';
  String get hintMonthlySavings => 'Ihr monatlicher Beitrag. Gefördert bis 150 €/Mt (1.800 €/J). Max 570 €/Mt (6.840 €/J) pro Vertrag. Über 150 € keine Zulage, aber begünstigte Besteuerung bei Auszahlung.';
  String get hintGrossSalary => 'Ihr jährliches Bruttoeinkommen vor Steuern. Bestimmt Ihren Steuersatz und die Förderberechtigung.';
  String get hintChildren => 'Anzahl kindergeldberechtigter Kinder. Jedes Kind bringt bis zu 300 €/Jahr Zulage. Endet mit 25 (Ausbildung) oder 18.';
  String childAgeLabel(int index) => 'Alter Kind ${index + 1}';
  String get hintChildAge => 'Aktuelles Alter. Kinderzulage endet, wenn das Kind 25 (in Ausbildung) oder 18 wird.';
  String get childStudyYes => 'Ausbildung (bis 25)';
  String get childStudyNo => 'Keine Ausbildung (bis 18)';
  String get hintChildStudy => 'Kindergeldberechtigung: bis 25 bei Ausbildung/Studium, sonst bis 18.';
  String get hintStartingAge => 'Alter beim Start des Sparens. Früherer Start = längerer Zinseszins.';
  String hintDerivedPension(String amount) => 'Gesch. gesetzl. Rente: $amount/Mt (abgeleitet aus Einkommen und Beitragsjahren). Änderbar unter Erweiterte Einstellungen.';
  String get hintReturn => 'Erwartete jährliche Rendite vor Kosten. Abhängig vom gewählten Makro-Szenario oder manueller Eingabe.';
  String get hintCostAv => 'Jährliche Kosten des AV-Depot-Anbieters. Kostendeckel: 1,0 % für Standardprodukt.';
  String get hintCostEtf => 'Jährliche Kosten Ihres ETF (TER). Typischer Welt-ETF: 0,1–0,2 %.';
  String get hintInflation => 'Erwartete jährliche Inflationsrate. Mindert die Kaufkraft zukünftiger Auszahlungen.';
  String get incomeDevToggle => 'Einkommensentwicklung modellieren';
  String get incomeDevGrowthRate => 'Jährliches Einkommenswachstum';
  String get hintIncomeDev => 'Wenn aktiviert, verändert sich das Bruttoeinkommen über die Zeit. Beeinflusst Zulagen, Steuersatz und Rentenschätzung pro Jahr.';
  String get hintGrowthLinear => 'Einkommen wächst jährlich um diesen Prozentsatz (Zinseszins). Z.B. 2 % = typische inflationsbereinigte Erhöhung.';
  String get hintPromotionInterval => 'Wie oft Sie eine deutliche Gehaltserhöhung oder Beförderung erwarten.';
  String get hintPromotionIncrease => 'Prozentualer Gehaltssprung pro Beförderung. Z.B. 15 % bei typischem Rollenwechsel.';
  String get hintSalaryCap => 'Einkommensobergrenze, der sich Ihre Karriere über die Zeit annähert. Wachstum verlangsamt sich in der Nähe.';
  String get hintPartTime => 'Modelliert eine Phase mit reduziertem Einkommen, z.B. Elternzeit oder Pflegezeit.';
  String get hintPartTimeStart => 'Sparjahr, in dem die Teilzeit beginnt (0 = erstes Jahr).';
  String get hintPartTimeDuration => 'Wie viele Jahre die Phase mit reduziertem Einkommen dauert.';
  String get hintPartTimePercent => 'Ihr Einkommen in Teilzeit als Anteil des Vollzeiteinkommens. Z.B. 50 % = Halbtagsstelle.';
  String get hintChildTiming => 'Fügen Sie Kinder zu bestimmten Sparjahren hinzu. Jedes Kind bringt ab diesem Jahr bis zu 300 €/Jahr Kinderzulage.';
  String get curveLinear => 'Linear';
  String get curveStepwise => 'Stufenweise';
  String get curveLogarithmic => 'Logarithmisch';
  String get promotionInterval => 'Beförderung alle';
  String get promotionIncrease => 'Gehaltssprung';
  String get salaryCap => 'Einkommensobergrenze';
  String get partTimeToggle => 'Teilzeitphase';
  String get partTimeStart => 'Beginnt im Jahr';
  String get partTimeDuration => 'Dauer';
  String get partTimePercent => 'Einkommen in Teilzeit';
  String get childTimingLabel => 'Kindergeburten';
  String get addChildBtn => '+ Kind';
  String childArrivalLabel(int year) => 'Kind kommt im Sparjahr $year';
  String get kirchensteuerLabel => 'Kirchensteuer';
  String get kirchensteuerNone => 'Keine';
  String get kirchensteuerBayBw => '8 % (Bayern/BaWü)';
  String get kirchensteuerOther => '9 % (übrige Bundesländer)';
  String get ungefoerdertTaxLabel => 'AV-Depot: Besteuerung ungefördert';
  String get ungefoerdertTaxNachgelagert => 'Voll (konservativ)';
  String get ungefoerdertTaxErtragsanteil => 'Ertragsanteil (17 %)';
  String get ungefoerdertTaxHalbeinkunfte => 'Halbeinkünfte (50 % Gewinn)';
  String get hintUngefoerdertTax => 'Nur AV-Depot: Besteuerung ungeförderter Beiträge (über 1.800 €/J) bei Auszahlung. BMF-Klärung ausstehend. Beeinflusst nicht den ETF-Vergleich.';

  String get baseGrant => 'Grundzulage';
  String get childGrant => 'Kinderzulage';
  String get entryBonus => 'Bonus';
  String get lowIncomeBonus => 'Geringverdienerbonus';
  String get subsidyRate => 'Förderquote';
  String get totalSubsidyYear => 'Gesamt-Zulage/Jahr';
  String get viaTaxOptimization => 'via Günstigerprüfung';

  String get tabComparison => 'Vergleich';
  String get tabAvDetail => 'AV-Depot Detail';

  String get bdContributions => 'Beiträge';
  String get bdTaxCostsSavings => 'Steuer & Kosten in der Ansparphase';
  String get bdCapGainsSavings => 'Kapitalerträge in der Ansparphase';
  String get bdCapGainsSavingsAV => 'Steuerfrei';
  String get bdCapGainsSavingsETF => 'Jährlich besteuert';
  String get bdIntoDepotYear => 'Ins Depot pro Jahr';
  String bdPhaseSubtotal(int years) => 'Phasensumme ($years J.)';
  String get bdAccumulated => 'Kumuliert über Sparperiode';
  String bdSavingsYear(int from, int to) => from == to ? 'Sparjahr $from' : 'Sparjahre $from–$to';
  String bdChildrenEligible(int count) => '$count Kind${count != 1 ? 'er' : ''} berechtigt';
  String get bdTotalContributions => 'Eigenbeiträge gesamt';
  String get bdTotalSubsidies => 'Zulagen gesamt';
  String get bdTaxRefundTotal => 'Steuererstattung gesamt (→ Bank)';
  String get bdTotalIntoDepot => 'Ins Depot gesamt';
  String get bdFinalCapital => 'Endkapital (gesamt)';
  String get bdOwnContrib => 'davon Eigenbeiträge';
  String get bdSubsidiesReceived => 'davon Zulagen';
  String get bdCapGains => 'davon Kapitalerträge';
  String get bdPurchasingPower => 'Kaufkraft heute';
  String get bdPayoutPerYear => 'Auszahlung (pro Jahr)';
  String get bdPayoutPeriod => 'Auszahlungszeitraum';
  String get bdSamePeriod => 'gleicher Zeitraum zum Vergleich';
  String get bdGrossPayoutYr => 'Brutto Depotauszahlung/J';
  String get bdStatePensionYr => 'Gesetzl. Rente/J (gleich)';
  String get bdOtherIncomeYr => 'Sonstige Einkünfte/J (gleich)';
  String get bdTotalGrossYr => 'Gesamtbruttoeinkommen/J';
  String get bdTaxationPerYear => 'Besteuerung (pro Jahr)';
  String get bdTaxMethod => 'Steuermethode';
  String get bdTaxMethodAV => 'Einkommensteuer (§32a)';
  String get bdTaxMethodETF => 'Einkommensteuer + Abgeltungssteuer';
  String get bdTaxMethodAvFormula => 'Alle Einkünfte zusammen progressiv besteuert';
  String get bdTaxMethodEtfFormula => 'Rente via §32a, Gewinne via pauschale AbgSt';
  String get bdWhatTaxed => 'Was wird vom Depot besteuert';
  String get bdWhatTaxedAV => 'Gesamte Auszahlung (100 %)';
  String get bdWhatTaxedETF => 'Nur 70 % der Gewinne';
  String get bdWhatTaxedAvFormula => 'Beiträge + Zulagen + Gewinne = Einkommen';
  String get bdWhatTaxedEtfFormula => 'Nach 30 % Teilfreistellung';
  String get bdEffectiveTaxRate => 'Effektiver Steuersatz auf Depotauszahlung';
  String bdEffectiveTaxRateAvFormula(String income) => '= [Steuer(Rente+Sonstige+AV) − Steuer(Rente+Sonstige)] ÷ AV-Auszahlung';
  String get bdEffectiveTaxRateEtfFormula => '25 % KapESt + 5,5 % Soli';
  String get bdTaxOnPayoutYr => 'Steuer auf Depotauszahlung/J';
  String get bdUngefTreatment => 'Besteuerung ungefördert';
  String bdAfterTaxTotal(int years) => 'Nach Steuer (gesamt über $years Jahre)';
  String get bdTotalTaxPaid => 'Steuer gesamt';
  String get bdDepotAfterTax => 'Depot nach Steuer';
  String get bdContribTaxFree => 'Beiträge steuerfrei zurück';
  String get bdContribTaxFreeAV => 'Nein';
  String get bdMonthlyNet => 'Monatlich netto aus Depot';
  String get bdGrossPerMonth => 'Brutto pro Monat';
  String get bdTaxPerMonth => 'Steuer pro Monat';
  String get bdNetPerMonth => 'Netto pro Monat';
  String get bdTabSavings => 'Ansparphase';
  String get bdTabPayout => 'Auszahlphase';
  String get legendContrib => 'Eigenbeitrag';
  String get legendGrundzulage => 'Grundzulage';
  String get legendKinderzulage => 'Kinderzulage';
  String get legendBonus => 'Bonus';
  String get legendTaxRefund => 'Steuererstattung';
  String get legendNetPayout => 'Netto-Auszahlung';
  String get legendTax => 'Steuer';
  String get chartSavingsTitle => 'AV-Depot: Jährliche Einzahlungen & Zulagen';
  String get chartPayoutTitle => 'AV-Depot: Jährliche Auszahlung';
  String get sectionAssumptions => 'Annahmen';
  String get hintAssumptions => 'Diese Optionen beeinflussen die Berechnung, hängen aber von individuellen Umständen ab.';

  String get tipGrundzulage => 'Der Staat bezuschusst Ihre Beiträge: 50 % auf die ersten 360 €/J und 25 % auf 361–1.800 €/J. Maximum 540 €/J. Fließt direkt ins Depot.';
  String get tipKinderzulage => 'Bis 300 €/Kind/Jahr (1:1 ab 25 €/Mt). Kind muss kindergeldberechtigt sein — endet mit 25 (in Ausbildung) oder 18. Zulage entfällt danach.';
  String get tipBerufseinsteigerbonus => 'Einmaliger Bonus von 200 € im ersten Vertragsjahr, wenn Sie unter 25 sind. Keine laufenden Zahlungen — nur im ersten Jahr.';
  String get tipGeringverdienerbonus => 'Zusätzlich 175 €/J bei Bruttoeinkommen ≤ 26.250 € und Mindestbeitrag 120 €/J. Wird auf die Grundzulage aufgeschlagen.';
  String get tipGuenstigerpruefung => 'Das Finanzamt prüft automatisch: Bringt der Sonderausgabenabzug auf Ihre Beiträge mehr als die Zulagen? Wenn ja, erhalten Sie die Differenz als Steuererstattung — aber auf Ihr Bankkonto, NICHT ins Depot.';
  String get tipGefoerdert => 'Geförderte Beiträge (bis 1.800 €/J): Wachsen steuerfrei, aber die GESAMTE Auszahlung im Ruhestand wird mit Einkommensteuer besteuert (nachgelagerte Besteuerung).';
  String get tipUngefoerdert => 'Ungeförderte Beiträge (über 1.800 €/J): Keine Zulagen, aber steuerfreies Wachstum in der Ansparphase. Besteuerung bei Auszahlung wartet auf offizielle BMF-Klärung (Gesetz tritt Jan 2027 in Kraft). Derzeit konservativ als volle nachgelagerte Besteuerung berechnet. Tatsächliche Behandlung könnte günstiger sein (z.B. Ertragsanteil oder Halbeinkünfteverfahren).';
  String get tipVorabpauschale => 'Jährliche Steuer auf unrealisierte ETF-Gewinne, berechnet aus dem Basiszins (EZB-Referenzzins). Hier vereinfacht als fester Abzug. Gilt NICHT im AV-Depot.';
  String get tipTeilfreistellung => '30 % Ihrer ETF-Gewinne sind steuerfrei, da der Fonds bereits Quellensteuer auf Fondsebene zahlt. Nur 70 % der Gewinne unterliegen der Abgeltungssteuer.';

  String avYieldsMore(String amount) => 'AV-Depot bringt $amount mehr.';
  String etfYieldsMore(String amount) => 'ETF-Depot bringt $amount mehr.';
  String get etfWinsExplanation =>
    'Warum? Die AV-Depot-Zulagen sind auf max. 1.800 €/Jahr Eigenbeitrag begrenzt. '
    'Darüber hinaus gibt es keine Förderung, aber die gesamte Auszahlung wird '
    'mit dem Einkommensteuersatz versteuert. Beim ETF-Depot werden nur die Gewinne '
    '(mit 30 % Teilfreistellung) pauschal besteuert. Bei hohem Einkommen, hohen '
    'Beiträgen oder niedrigen Renditen überwiegt dieser Steuervorteil die Zulage.';
  String comparisonSubtitle(String icon, String name) =>
    '$icon $name – AV: nachgelagerte Best. / ETF: Abgeltungsst. mit 30 % Teilfreist.';
  String get ownContributions => 'Eigenbeiträge';

  String get finalCapital => 'Endkapital';
  String get purchasingPowerToday => 'Kaufkraft heute';
  String get inflationAdjusted => 'inflationsbereinigt';
  String get compositionTitle => 'Zusammensetzung';
  String get subsidiesLabel => 'Zulagen';
  String get taxRefundNotInDepot => 'Steuererstattung – wird auf Ihr Konto ausgezahlt, nicht ins Depot';
  String get capitalGainsLabel => 'Wertzuwachs';
  String get taxLogicTitle => 'Steuerlogik';
  String get taxLogicDescription =>
    'Ansparphase: Kapitalerträge steuerfrei. Zulagen fließen ins Depot. '
    'Günstigerprüfung kann Steuererstattung bringen.\n\n'
    'Auszahlphase: Nachgelagerte Besteuerung mit persönlichem Steuersatz. '
    'Auszahlplan bis 85, bis 30 % Einmalentnahme.';
  String get marginalTaxRate => 'Grenzsteuersatz';

  String get subsidyLogicTitle => 'Förderlogik im Detail';
  String get slBaseGrantLabel => 'Grundzulage:';
  String get slBaseGrantDetail =>
    '▸ 50 % auf erste 360 €/J = max 180 €\n'
    '▸ 25 % auf 361–1.800 €/J = max 360 €\n'
    '▸ Max. Grundzulage: 540 €/J';
  String get slChildGrantLabel => 'Kinderzulage:';
  String get slChildGrantDetail => '▸ Bis 300 €/Kind/J, volle Zulage ab 25 €/Monat';
  String get slEntryBonusLabel => 'Berufseinsteigerbonus:';
  String get slEntryBonusDetail => '▸ Einmalig 200 € im ersten Jahr (unter 25)';
  String get slTaxOptLabel => 'Günstigerprüfung:';
  String get slTaxOptDetail =>
    '▸ Eigenbeitrag + Zulagen als Sonderausgaben\n'
    '▸ Differenz wird ggf. erstattet';
  String get slPayoutLabel => 'Auszahlung:';
  String get slPayoutDetail =>
    '▸ Auszahlplan bis 85, bis 30 % Einmalentnahme\n'
    '▸ Nachgelagerte Besteuerung';

  String get legislativeBasisTitle => 'Gesetzliche Grundlage';
  String get legislativeBasisDetail =>
    '▸ Altersvorsorgereformgesetz – Bundestag-Drucksache 21/4088\n'
    '▸ Finanzausschuss-Änderungen, 25. März 2026 (Koalitionseinigung CDU/CSU + SPD)\n'
    '▸ Verabschiedet am 27. März 2026 im Bundestag (2. + 3. Lesung)\n'
    '▸ Wesentliche Änderungen ggü. Erstentwurf (Dez. 2025): Grundzulage auf 50 %/25 % erhöht, Kostendeckel auf 1,0 % gesenkt, '
    'alle Selbstständigen förderberechtigt, öffentlicher Träger vorgeschrieben\n'
    '▸ Inkrafttreten: 1. Januar 2027';
  String get sourcesTitle => 'Quellen';
  String get sourcesDetail =>
    '▸ BMF FAQ: bundesfinanzministerium.de/Content/DE/FAQ/reform-der-privaten-altersvorsorge.html\n'
    '▸ Bundestag-Abstimmung: bundestag.de/presse/hib/kurzmeldungen-1157838\n'
    '▸ Bundestag-Anhörung: bundestag.de/dokumente/textarchiv/2026/kw12-pa-finanzen-1152002\n'
    '▸ Finanztip: finanztip.de/altersvorsorge/altersvorsorgedepot\n'
    '▸ justETF: justetf.com/de/academy/altersvorsorgedepot-entwurf-2027.html';

  String pageNotFound(String uri) => 'Seite nicht gefunden: $uri';

  // Pros / Cons
  String get prosConsTitle => 'Was für Ihr Szenario gilt';
  String get avProsTitle => 'Vorteile AV-Depot';
  String get etfProsTitle => 'Vorteile ETF-Depot';
  String get proHighSubsidyRate => 'Hohe Förderquote auf Ihre Beiträge';
  String get proKinderzulage => 'Kinderzulage aktiv (300 €/Kind/Jahr)';
  String get proGeringverdienerbonus => 'Geringverdienerbonus greift (+175 €/Jahr)';
  String get proBerufseinsteigerbonus => 'Berufseinsteigerbonus aktiv (einmalig +200 €)';
  String get proGuenstigerpruefung => 'Günstigerprüfung bringt zusätzliche Steuererstattung';
  String get proLongDuration => 'Lange Spardauer – Zulagen verzinsen sich über Jahrzehnte';
  String get proTaxFreeGrowth => 'Steuerfreies Wachstum in der Ansparphase (keine Vorabpauschale, keine Abgeltungssteuer)';
  String get conLowSubsidyLeverage => 'Beiträge über 150 €/Mt erhalten keine Zulage. Gesamte Auszahlung derzeit konservativ mit Einkommensteuer besteuert. Ungeförderter Teil könnte günstiger behandelt werden, sobald BMF-Leitfaden veröffentlicht.';
  String get conHighRetirementTax => 'Hoher Grenzsteuersatz – nachgelagerte Besteuerung zu hohem Satz mindert den Vorteil';
  String get proEtfOnlyGainsTaxed => 'Nur Gewinne werden besteuert – Ihre Einzahlungen erhalten Sie steuerfrei zurück';
  String get proEtfTeilfreistellung => '30 % Teilfreistellung reduziert die steuerpflichtigen Gewinne';
  String get proEtfFlexibility => 'Keine Bindungsfrist – jederzeit verfügbar ohne Einschränkungen';
  String get proEtfLowReturnsAdvantage => 'Bei niedrigen Renditen sind die Gewinne gering – weniger Steuerbelastung als nachgelagerte Vollbesteuerung';

  String get resetAll => 'Alle Werte zurücksetzen';
  String get disclaimer =>
    'Dieser Rechner dient ausschließlich der Veranschaulichung und Bildung. '
    'Er stellt keine Anlageberatung, Steuerberatung oder Empfehlung im Sinne '
    'des §2 Abs. 4 WpHG dar. Die Berechnungen basieren auf vereinfachten '
    'Annahmen und können erheblich von tatsächlichen Ergebnissen abweichen. '
    'Für persönliche Entscheidungen wenden Sie sich an einen qualifizierten '
    'Finanzberater oder Steuerberater. Keine Gewährleistung. Nutzung auf eigenes Risiko.';
  String get includedFeaturesTitle => 'In diesem Rechner enthalten';
  String get includedFeaturesDetail =>
    '▸ Grundzulage (50 %/25 % Zwei-Stufen-Förderung auf bis zu 1.800 €/Jahr)\n'
    '▸ Kinderzulage (bis 300 €/Kind/Jahr, 1:1 Zuschuss)\n'
    '▸ Berufseinsteigerbonus (einmalig 200 €, unter 25)\n'
    '▸ Geringverdienerbonus (175 €/Jahr bei Brutto ≤ 26.250 €)\n'
    '▸ Günstigerprüfung (automatische Steueroptimierung)\n'
    '▸ Kirchensteuer (optional: Keine / 8 % / 9 %)\n'
    '▸ Abgeltungssteuer mit 30 % Teilfreistellung für ETF\n'
    '▸ Vorabpauschale (vereinfacht als 0,3 % jährlicher Abzug)\n'
    '▸ Nachgelagerte Besteuerung der AV-Depot-Auszahlungen\n'
    '▸ 6 Makro-Szenarien + eigene Szenarien\n'
    '▸ 5 persönliche Szenarien + freie Eingabe';
  String get simplificationsTitle => 'Vereinfachungen';
  String get simplificationsDetail =>
    'Beide: Ein Aktien-ETF angenommen für Vergleichbarkeit (AV-Depot kann mehrere Instrumente halten)\n'
    'Beide: Konstante jährliche Rendite (kein Reihenfolge-Risiko)\n'
    'Beide: Keine unterjährigen Beiträge\n'
    'Beide: Quellensteuer auf Fondsebene (~0,3 % p.a.) nicht separat modelliert\n'
    'ETF: Vorabpauschale vereinfacht als 0,3 % jährlicher Abzug (tatsächlich abhängig vom Basiszins)\n'
    'AV: Besteuerung im Ruhestand nutzt progressiven §32a-Durchschnittssteuersatz auf Gesamteinkommen. Brutto als Näherung für zvE.\n'
    'AV: Besteuerung ungeförderter Auszahlungen wartet auf BMF-Klärung — konservativ als volle nachgelagerte Besteuerung. Könnte günstiger sein (Ertragsanteil/Halbeinkünfte) nach Klärung.\n'
    'AV: Günstigerprüfung-Erstattung wird auf Bankkonto ausgezahlt, nicht reinvestiert\n'
    'AV: Gesetzl. Rente aus Bruttoeinkommen geschätzt (Entgeltpunkte-Formel, Rentenwert 2024) – anpassbar';
  String get plannedFeaturesTitle => 'Noch nicht enthalten';
  String get plannedFeaturesDetail =>
    '▸ Riester-Vergleich (altes vs. neues Fördersystem)\n'
    '▸ Wohnwirtschaftliche Verwendung (steuerfreie Entnahme für Immobilien)\n'
    '▸ Leibrente vs. Auszahlplan-Vergleich\n'
    '▸ Monte-Carlo-Simulation (zufällige Renditefolgen)\n'
    '▸ PDF/CSV-Export';

  String get impressumTitle => 'Impressum';
  String get impressumDetail =>
    '${BuildConfig.ownerName}\n'
    '${BuildConfig.postalAddress}\n'
    '${BuildConfig.email}\n\n'
    'Verantwortlich für den Inhalt gemäß §18 Abs. 2 MStV: ${BuildConfig.ownerName}';
  String get datenschutzTitle => 'Datenschutzerklärung';
  String get datenschutzDetail =>
    'Diese Website erhebt, speichert und verarbeitet keine personenbezogenen Daten. '
    'Alle Berechnungen werden vollständig in Ihrem Browser durchgeführt – '
    'es werden keine Daten an einen Server übertragen.\n\n'
    'Es werden keine Cookies gesetzt. Es werden keine Tracking- oder Analyse-Tools verwendet.\n\n'
    'Ihre IP-Adresse wird vom Hosting-Anbieter (Hostinger) ausschließlich zur '
    'Auslieferung dieser Website verarbeitet. Diese Verarbeitung erfolgt auf Grundlage '
    'von Art. 6 Abs. 1 lit. f DSGVO (berechtigtes Interesse an der Bereitstellung '
    'der Website). Eine weitergehende Verarbeitung oder Speicherung personenbezogener '
    'Daten findet nicht statt.';
  String get copyrightNotice =>
    '© ${BuildConfig.copyrightYear} ${BuildConfig.ownerName} – Alle Rechte vorbehalten. '
    'Die Inhalte, das Design und die Berechnungen dieser Website dürfen ohne '
    'vorherige schriftliche Genehmigung nicht vervielfältigt, verbreitet oder '
    'anderweitig verwendet werden.';

  String get chartAllMacrosTitle => 'AV-Depot: Alle Makro-Szenarien + ETF (gestrichelt)';
  String chartWealthTitle(String icon, String name) => 'Vermögensentwicklung – $icon $name';
  String get otherScenarios => 'Andere Makros';

  String get colScenario => 'SZENARIO';
  String get colReturn => 'RENDITE';
  String get colInflation => 'INFLATION';
  String get colRealReturn => 'REAL';
  String get colAvFinalCap => 'AV KAP.';
  String get colPurchPower => 'KAUFKR.';
  String get colAvNetMo => 'AV/MT';
  String get colEtfFinalCap => 'ETF KAP.';
  String get colEtfNetMo => 'ETF/MT';
  String get colDelta => 'Δ AV-ETF';
  String get colDeltaMo => 'Δ/MT';
  String get tagSavingsRate => 'Sparrate';
  String get tagGross => 'Brutto';
  String get tagChildren => 'Kinder';
  String get tagDuration => 'Dauer';
  String get tagSubsidyYear => 'Zulage/J.';
  String get tagSubsidyRate => 'Förderquote';
  String get tagMargTax => 'Grenzsteuer';

  String get editScenario => 'Szenario bearbeiten';
  String get newScenarioTitle => 'Neues Szenario';
  String get editMacroScenario => 'Makro-Szenario bearbeiten';
  String get newMacroScenarioTitle => 'Neues Makro-Szenario';
  String get addMacroLabel => 'Makro hinzufügen';
  String get deleteBtn => 'Löschen';
  String get cancelBtn => 'Abbrechen';
  String get saveBtn => 'Speichern';
  String get addBtn => 'Hinzufügen';
  String get fieldName => 'Name';
  String get fieldShortName => 'Kurzname';
  String get fieldIcon => 'Icon (Emoji)';
  String get fieldDescription => 'Beschreibung';
  String get fieldReturnPct => 'Rendite (% p.a.)';
  String get fieldInflationPct => 'Inflation (% p.a.)';
  String get fieldColor => 'Farbe:';
  String get fieldSavingsRate => 'Sparrate (€/Monat)';
  String get fieldGrossSalary => 'Bruttojahreseinkommen (€)';
  String get fieldChildren => 'Anzahl Kinder';
  String get fieldStartAge => 'Alter bei Start';
  String get fieldDuration => 'Spardauer (Jahre)';
  String get defaultScenarioName => 'Neues Szenario';

  String get customName => 'Eigene Werte';
  String get customShort => 'Eigen';
  String get customDesc => 'Manuell eingestellt';
  String get avDepotLabel => 'AV-Depot';
  String get etfLabel => 'ETF';
  String get yearSuffix => 'J';
  String get perMonth => '/Mt';

  String get chartTab => 'Diagramm';
  String get tableTab => 'Tabelle';

  String get presetCareerStarter => 'Berufseinsteiger';
  String get presetSingleMid30 => 'Single Mitte 30';
  String get presetFamily2Kids => 'Familie 2 Kinder';
  String get presetHighEarner => 'Gutverdiener';
  String get presetPartTimeChild => 'Teilzeit + Kind';

  String get macroBoomName => 'Boom / Bullenmarkt';
  String get macroBoomShort => 'Boom';
  String get macroBoomDesc => 'Starke Konjunktur, niedrige Inflation – wie 2010–2021.';
  String get macroBaselineName => 'Basis / Hist. Durchschnitt';
  String get macroBaselineShort => 'Basis';
  String get macroBaselineDesc => 'MSCI-World-Durchschnitt ~7 % bei 2 % Inflation.';
  String get macroModerateName => 'Moderate Abschwächung';
  String get macroModerateShort => 'Moderat';
  String get macroModerateDesc => 'Schwächeres Wachstum, leicht erhöhte Inflation.';
  String get macroStagflationName => 'Stagflation';
  String get macroStagflationShort => 'Stagflation';
  String get macroStagflationDesc => 'Hohe Inflation bei schwachem Wachstum – wie 1970er.';
  String get macroJapanName => 'Japan-Szenario';
  String get macroJapanShort => 'Japan';
  String get macroJapanDesc => 'Stagnation mit Nullzinsen – Japan 1990–2020.';
  String get macroLostDecadeName => 'Verlorenes Jahrzehnt';
  String get macroLostDecadeShort => 'Verlorenes Jahrzehnt';
  String get macroLostDecadeDesc => 'Crash mit langsamer Erholung – 2000–2012.';
}
