// ignore_for_file: annotate_overrides

abstract class AppStrings {
  // ─── HEADER ───────────────────────────────────────────────────────
  String get calculatorBadge;
  String get appTitle;
  String get appSubtitle;
  String get appDescription;

  // ─── SECTIONS ─────────────────────────────────────────────────────
  String get sectionPersonalScenarios;
  String get sectionMacroScenarios;
  String get sectionAllScenarios;
  String get sectionDetailedResults;
  String get addScenario;

  // ─── INPUT PANEL ──────────────────────────────────────────────────
  String get monthlySavings;
  String get grossAnnualSalary;
  String get numberOfChildren;
  String get startingAge;
  String get savingsDuration;
  String get retirementAge;
  String derivedDuration(int years);
  String get advancedSettings;
  String get returnPa;
  String get costAvPa;
  String get costEtfPa;
  String get inflationPa;
  String get hintSubsidized;
  String get hintChildSubsidy;
  String retirementAgeHint(int age);
  String get hintCostCap;
  String get hintTypicalCost;
  String yearsLabel(int n);
  String get kirchensteuerLabel;
  String get kirchensteuerNone;
  String get kirchensteuerBayBw;
  String get kirchensteuerOther;

  // ─── SUBSIDY BOX ─────────────────────────────────────────────────
  String annualSubsidiesTitle(String icon, String name);
  String get baseGrant;
  String get childGrant;
  String get entryBonus;
  String get lowIncomeBonus;
  String get lowIncomeBonusApplies;
  String get subsidyRate;
  String get totalSubsidyYear;
  String get taxRefundYear;
  String get viaTaxOptimization;

  // ─── TABS ─────────────────────────────────────────────────────────
  String get tabComparison;
  String get tabAvDetail;

  // ─── COMPARISON ───────────────────────────────────────────────────
  String avYieldsMore(String amount);
  String etfYieldsMore(String amount);
  String get etfWinsExplanation;
  String comparisonSubtitle(String icon, String name);
  String get finalCapitalGross;
  String get ownContributions;
  String get govSubsidiesAvOnly;
  String get monthlyPayout20y;
  String get avDepotNet;
  String get etfPortfolioNet;
  String grossLabel(String v);
  String taxLabel(String v);

  // ─── DETAIL ───────────────────────────────────────────────────────
  String get finalCapital;
  String get purchasingPowerToday;
  String get inflationAdjusted;
  String get compositionTitle;
  String get subsidiesLabel;
  String get taxRefundLabel;
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

  // ─── ETF TAX NOTE ──────────────────────────────────────────────
  String get etfTaxNote;

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
  String get currentLabel;
  String get customName;
  String get customShort;
  String get customDesc;
  String get avDepotLabel;
  String get etfLabel;
  String get etfDepotLabel;
  String get yearSuffix;
  String get perMonth;
  String get inflLabel;
  String get realLabel;

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
  String get appDescription => 'Coalition agreement March 2026: 50 ct subsidy per euro, cost cap 1%, all self-employed eligible.';

  // Sections
  String get sectionPersonalScenarios => 'Personal Scenarios';
  String get sectionMacroScenarios => 'Macroeconomic Scenarios';
  String get sectionAllScenarios => 'All Scenarios Overview';
  String get sectionDetailedResults => 'Detailed Results';
  String get addScenario => '+ Scenario';

  // Input
  String get monthlySavings => 'Monthly Savings Rate';
  String get grossAnnualSalary => 'Gross Annual Salary';
  String get numberOfChildren => 'Number of Children';
  String get startingAge => 'Starting Age';
  String get savingsDuration => 'Savings Duration';
  String get retirementAge => 'Retirement Age';
  String derivedDuration(int years) => 'Duration: $years years (derived)';
  String get advancedSettings => 'Advanced Settings';
  String get returnPa => 'Return p.a.';
  String get costAvPa => 'AV-Depot Cost p.a.';
  String get costEtfPa => 'ETF Portfolio Cost p.a.';
  String get inflationPa => 'Inflation p.a.';
  String get hintSubsidized => 'Subsidized up to \u20AC150/month. Above unsubsidized.';
  String get hintChildSubsidy => 'Up to \u20AC300/child/year subsidy';
  String retirementAgeHint(int age) => 'Retirement at age $age';
  String get hintCostCap => 'Cost cap: 1.0%';
  String get hintTypicalCost => 'Typical: 0.1\u20130.2%';
  String yearsLabel(int n) => '$n years';
  String get kirchensteuerLabel => 'Church Tax';
  String get kirchensteuerNone => 'None';
  String get kirchensteuerBayBw => '8% (Bavaria/BaW\u00FC)';
  String get kirchensteuerOther => '9% (other states)';

  // Subsidy
  String annualSubsidiesTitle(String icon, String name) => 'Annual Subsidies \u2013 $icon $name';
  String get baseGrant => 'Base Grant';
  String get childGrant => 'Child Grant';
  String get entryBonus => 'Entry Bonus';
  String get lowIncomeBonus => 'Low-Income Bonus';
  String get lowIncomeBonusApplies => 'Low-income bonus applies: \u20AC175/yr (gross salary \u2264 \u20AC26,250)';
  String get subsidyRate => 'Subsidy Rate';
  String get totalSubsidyYear => 'Total Subsidy/Year';
  String get taxRefundYear => 'Tax Refund/Year';
  String get viaTaxOptimization => 'via tax optimization check';

  // Tabs
  String get tabComparison => 'Comparison';
  String get tabAvDetail => 'AV-Depot Detail';

  // Comparison
  String avYieldsMore(String amount) => 'AV-Depot yields $amount more.';
  String etfYieldsMore(String amount) => 'ETF Portfolio yields $amount more.';
  String get etfWinsExplanation =>
    'Why? The AV-Depot subsidies are capped at \u20AC1,800/yr contributions. '
    'Above that, additional savings receive no subsidy but the entire payout is '
    'taxed at your income tax rate. The ETF portfolio only taxes gains (with 30% '
    'exemption) at a lower flat rate. With high income, high contributions, or '
    'low returns, this tax advantage outweighs the subsidy.';
  String comparisonSubtitle(String icon, String name) =>
    '$icon $name \u2013 AV: deferred taxation / ETF: capital gains tax with 30% partial exemption';
  String get finalCapitalGross => 'Final Capital (gross)';
  String get ownContributions => 'Own Contributions';
  String get govSubsidiesAvOnly => 'Gov. Subsidies (AV only)';
  String get monthlyPayout20y => 'Monthly Payout (20 years)';
  String get avDepotNet => 'AV-Depot net';
  String get etfPortfolioNet => 'ETF Portfolio net';
  String grossLabel(String v) => 'Gross: $v';
  String taxLabel(String v) => 'Tax: $v';

  // Detail
  String get finalCapital => 'Final Capital';
  String get purchasingPowerToday => 'Purchasing Power Today';
  String get inflationAdjusted => 'inflation-adjusted';
  String get compositionTitle => 'Composition';
  String get subsidiesLabel => 'Subsidies';
  String get taxRefundLabel => 'Tax Refund';
  String get taxRefundNotInDepot => 'Tax Refund \u2013 paid to your bank account, not into the depot';
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
    '\u25B8 50% on first \u20AC360/yr = max \u20AC180\n'
    '\u25B8 25% on \u20AC361\u20131,800/yr = max \u20AC360\n'
    '\u25B8 Max. base grant: \u20AC540/yr';
  String get slChildGrantLabel => 'Child Grant:';
  String get slChildGrantDetail => '\u25B8 Up to \u20AC300/child/yr, full grant from \u20AC25/month';
  String get slEntryBonusLabel => 'Entry Bonus:';
  String get slEntryBonusDetail => '\u25B8 \u20AC200/yr for 3 years (under 25)';
  String get slTaxOptLabel => 'Tax Optimization:';
  String get slTaxOptDetail =>
    '\u25B8 Own contribution + subsidies as special expenses\n'
    '\u25B8 Difference refunded if applicable';
  String get slPayoutLabel => 'Payout:';
  String get slPayoutDetail =>
    '\u25B8 Payout plan until 85, up to 30% lump sum\n'
    '\u25B8 Deferred taxation';

  // Legislative Basis
  String get legislativeBasisTitle => 'Legislative Basis';
  String get legislativeBasisDetail =>
    '\u25B8 Altersvorsorgereformgesetz \u2013 Bundestag Drucksache 21/4088\n'
    '\u25B8 Finanzausschuss amendments, 25 March 2026 (coalition agreement CDU/CSU + SPD)\n'
    '\u25B8 Passed by Bundestag on 27 March 2026 (2nd + 3rd reading)\n'
    '\u25B8 Key changes vs. original draft (Dec 2025): Grundzulage raised to 50%/25%, Kostendeckel lowered to 1.0%, '
    'all self-employed now eligible, public provider mandated\n'
    '\u25B8 Effective date: 1 January 2027';
  String get sourcesTitle => 'Sources';
  String get sourcesDetail =>
    '\u25B8 BMF FAQ: bundesfinanzministerium.de/Content/DE/FAQ/reform-der-privaten-altersvorsorge.html\n'
    '\u25B8 Bundestag vote: bundestag.de/presse/hib/kurzmeldungen-1157838\n'
    '\u25B8 Bundestag hearing: bundestag.de/dokumente/textarchiv/2026/kw12-pa-finanzen-1152002\n'
    '\u25B8 Finanztip: finanztip.de/altersvorsorge/altersvorsorgedepot\n'
    '\u25B8 justETF: justetf.com/de/academy/altersvorsorgedepot-entwurf-2027.html';

  // Errors
  String pageNotFound(String uri) => 'Page not found: $uri';

  // Pros / Cons
  String get prosConsTitle => 'What Applies to Your Scenario';
  String get avProsTitle => 'AV-Depot advantages';
  String get etfProsTitle => 'ETF Portfolio advantages';
  String get proHighSubsidyRate => 'High subsidy rate on your contributions';
  String get proKinderzulage => 'Child grant active (\u20AC300/child/yr)';
  String get proGeringverdienerbonus => 'Low-income bonus applies (+\u20AC175/yr)';
  String get proBerufseinsteigerbonus => 'Career starter bonus active (+\u20AC200/yr)';
  String get proGuenstigerpruefung => 'Tax optimization check yields additional refund';
  String get proLongDuration => 'Long savings duration \u2013 subsidies compound over decades';
  String get proTaxFreeGrowth => 'Tax-free growth during accumulation (no Vorabpauschale, no capital gains tax)';
  String get conLowSubsidyLeverage => 'Contributions above \u20AC150/mo receive no subsidy \u2013 but entire payout is taxed';
  String get conHighRetirementTax => 'High marginal tax rate \u2013 deferred taxation at high rate reduces advantage';
  String get proEtfOnlyGainsTaxed => 'Only gains are taxed \u2013 your contributions are returned tax-free';
  String get proEtfTeilfreistellung => '30% partial exemption (Teilfreistellung) reduces taxable gains';
  String get proEtfFlexibility => 'No lock-up period \u2013 withdraw any time without restrictions';
  String get proEtfLowReturnsAdvantage => 'With low returns, gains are small \u2013 less tax impact than deferred full-payout taxation';

  // ETF Tax Note
  String get etfTaxNote =>
    'ETF taxation: Only gains are taxed \u2013 with 30% partial exemption (Teilfreistellung) '
    'for equity funds. This means only 70% of gains are subject to flat-rate capital gains '
    'tax (Abgeltungssteuer). Your contributions are returned tax-free.';

  // Footer
  String get resetAll => 'Reset All Values';
  String get disclaimer =>
    'Note: This calculator is for illustration purposes, not financial advice. '
    'The macro scenarios are stylized models, not forecasts.';
  String get includedFeaturesTitle => 'Included in This Calculator';
  String get includedFeaturesDetail =>
    '\u25B8 Grundzulage (50%/25% two-tier subsidy on up to \u20AC1,800/yr)\n'
    '\u25B8 Kinderzulage (up to \u20AC300/child/yr, 1:1 match)\n'
    '\u25B8 Berufseinsteigerbonus (\u20AC200/yr for 3 years, under 25)\n'
    '\u25B8 Geringverdienerbonus (\u20AC175/yr for gross \u2264 \u20AC26,250)\n'
    '\u25B8 G\u00FCnstigerpr\u00FCfung (automatic tax optimization check)\n'
    '\u25B8 Kirchensteuer (optional: None / 8% / 9%)\n'
    '\u25B8 Abgeltungssteuer with 30% Teilfreistellung for ETF\n'
    '\u25B8 Vorabpauschale (simplified as 0.2% annual drag)\n'
    '\u25B8 Nachgelagerte Besteuerung (deferred taxation on AV-Depot payouts)\n'
    '\u25B8 6 macro scenario presets + custom scenarios\n'
    '\u25B8 5 personal scenario presets + custom input';
  String get simplificationsTitle => 'Simplifications';
  String get simplificationsDetail =>
    '\u25B8 Constant annual returns (no sequence-of-returns risk)\n'
    '\u25B8 Simplified Vorabpauschale as 0.2% annual drag (actual depends on Basiszins)\n'
    '\u25B8 No partial-year contributions\n'
    '\u25B8 Retirement tax rate simplified as 70% of working rate\n'
    '\u25B8 G\u00FCnstigerpr\u00FCfung tax refund not reinvested into a separate ETF\n'
    '\u25B8 Fund-level withholding tax (~0.3% p.a.) not separately modeled';
  String get plannedFeaturesTitle => 'Not Yet Included';
  String get plannedFeaturesDetail =>
    '\u25B8 Riester comparison (old vs. new subsidy system)\n'
    '\u25B8 Wohnwirtschaftliche Verwendung (tax-free property withdrawal)\n'
    '\u25B8 Leibrente vs. Auszahlplan comparison\n'
    '\u25B8 Monte Carlo simulation (random return sequences)\n'
    '\u25B8 PDF/CSV export';

  // Charts
  String get chartAllMacrosTitle => 'AV-Depot: All Macro Scenarios + ETF (dashed)';
  String chartWealthTitle(String icon, String name) => 'Wealth Development \u2013 $icon $name';
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
  String get colDelta => '\u0394 AV-ETF';
  String get colDeltaMo => '\u0394/MO';
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
  String get fieldSavingsRate => 'Savings Rate (\u20AC/month)';
  String get fieldGrossSalary => 'Gross Annual Salary (\u20AC)';
  String get fieldChildren => 'Number of Children';
  String get fieldStartAge => 'Starting Age';
  String get fieldDuration => 'Duration (years)';
  String get defaultScenarioName => 'New Scenario';

  // Inline labels
  String get currentLabel => 'Current';
  String get customName => 'Custom';
  String get customShort => 'Custom';
  String get customDesc => 'Manually configured';
  String get avDepotLabel => 'AV-Depot';
  String get etfLabel => 'ETF';
  String get etfDepotLabel => 'ETF Portfolio';
  String get yearSuffix => 'Y';
  String get perMonth => '/mo';
  String get inflLabel => 'Infl';
  String get realLabel => 'Real';

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
  String get macroBoomDesc => 'Strong economy, low inflation \u2013 like 2010\u20132021.';
  String get macroBaselineName => 'Baseline / Hist. Average';
  String get macroBaselineShort => 'Baseline';
  String get macroBaselineDesc => 'MSCI World average ~7% at 2% inflation.';
  String get macroModerateName => 'Moderate Slowdown';
  String get macroModerateShort => 'Moderate';
  String get macroModerateDesc => 'Weaker growth, slightly higher inflation.';
  String get macroStagflationName => 'Stagflation';
  String get macroStagflationShort => 'Stagflation';
  String get macroStagflationDesc => 'High inflation with weak growth \u2013 like 1970s.';
  String get macroJapanName => 'Japan Scenario';
  String get macroJapanShort => 'Japan';
  String get macroJapanDesc => 'Stagnation with zero interest \u2013 Japan 1990\u20132020.';
  String get macroLostDecadeName => 'Lost Decade';
  String get macroLostDecadeShort => 'Lost Decade';
  String get macroLostDecadeDesc => 'Crash with slow recovery \u2013 2000\u20132012.';
}

// ═══════════════════════════════════════════════════════════════════
// GERMAN
// ═══════════════════════════════════════════════════════════════════

class StringsDe extends AppStrings {
  StringsDe();

  String get calculatorBadge => 'RECHNER 2027';
  String get appTitle => 'Altersvorsorgedepot';
  String get appSubtitle => 'vs. privates ETF-Depot';
  String get appDescription => 'Koalitionseinigung M\u00E4rz 2026: 50 Ct Zulage pro Euro, Kostendeckel 1 %, alle Selbstst\u00E4ndigen f\u00F6rderberechtigt.';

  String get sectionPersonalScenarios => 'Pers\u00F6nliche Szenarien';
  String get sectionMacroScenarios => 'Makro\u00F6konomische Szenarien';
  String get sectionAllScenarios => 'Alle Szenarien im \u00DCberblick';
  String get sectionDetailedResults => 'Detailergebnisse';
  String get addScenario => '+ Szenario';

  String get monthlySavings => 'Monatliche Sparrate';
  String get grossAnnualSalary => 'Bruttojahresgehalt';
  String get numberOfChildren => 'Anzahl Kinder';
  String get startingAge => 'Alter bei Start';
  String get savingsDuration => 'Spardauer';
  String get retirementAge => 'Rentenalter';
  String derivedDuration(int years) => 'Dauer: $years Jahre (abgeleitet)';
  String get advancedSettings => 'Erweiterte Einstellungen';
  String get returnPa => 'Rendite p.a.';
  String get costAvPa => 'Kosten AV-Depot p.a.';
  String get costEtfPa => 'Kosten ETF-Depot p.a.';
  String get inflationPa => 'Inflation p.a.';
  String get hintSubsidized => 'Gef\u00F6rdert bis 150 \u20AC/Monat. Dar\u00FCber ungef\u00F6rdert.';
  String get hintChildSubsidy => 'Bis 300 \u20AC/Kind/Jahr Zulage';
  String retirementAgeHint(int age) => 'Renteneintritt mit $age Jahren';
  String get hintCostCap => 'Kostendeckel: 1,0 %';
  String get hintTypicalCost => 'Typisch: 0,1\u20130,2 %';
  String yearsLabel(int n) => '$n Jahre';
  String get kirchensteuerLabel => 'Kirchensteuer';
  String get kirchensteuerNone => 'Keine';
  String get kirchensteuerBayBw => '8 % (Bayern/BaW\u00FC)';
  String get kirchensteuerOther => '9 % (\u00FCbrige Bundesl\u00E4nder)';

  String annualSubsidiesTitle(String icon, String name) => 'J\u00E4hrliche F\u00F6rderung \u2013 $icon $name';
  String get baseGrant => 'Grundzulage';
  String get childGrant => 'Kinderzulage';
  String get entryBonus => 'Bonus';
  String get lowIncomeBonus => 'Geringverdienerbonus';
  String get lowIncomeBonusApplies => 'Geringverdienerbonus greift: 175 \u20AC/Jahr (Brutto \u2264 26.250 \u20AC)';
  String get subsidyRate => 'F\u00F6rderquote';
  String get totalSubsidyYear => 'Gesamt-Zulage/Jahr';
  String get taxRefundYear => 'Steuererstattung/Jahr';
  String get viaTaxOptimization => 'via G\u00FCnstigerpr\u00FCfung';

  String get tabComparison => 'Vergleich';
  String get tabAvDetail => 'AV-Depot Detail';

  String avYieldsMore(String amount) => 'AV-Depot bringt $amount mehr.';
  String etfYieldsMore(String amount) => 'ETF-Depot bringt $amount mehr.';
  String get etfWinsExplanation =>
    'Warum? Die AV-Depot-Zulagen sind auf max. 1.800 \u20AC/Jahr Eigenbeitrag begrenzt. '
    'Dar\u00FCber hinaus gibt es keine F\u00F6rderung, aber die gesamte Auszahlung wird '
    'mit dem Einkommensteuersatz versteuert. Beim ETF-Depot werden nur die Gewinne '
    '(mit 30 % Teilfreistellung) pauschal besteuert. Bei hohem Einkommen, hohen '
    'Beitr\u00E4gen oder niedrigen Renditen \u00FCberwiegt dieser Steuervorteil die Zulage.';
  String comparisonSubtitle(String icon, String name) =>
    '$icon $name \u2013 AV: nachgelagerte Best. / ETF: Abgeltungsst. mit 30 % Teilfreist.';
  String get finalCapitalGross => 'Endkapital (brutto)';
  String get ownContributions => 'Eigenbeitr\u00E4ge';
  String get govSubsidiesAvOnly => 'Staatl. Zulagen (nur AV)';
  String get monthlyPayout20y => 'Monatliche Auszahlung (20 Jahre)';
  String get avDepotNet => 'AV-Depot netto';
  String get etfPortfolioNet => 'ETF-Depot netto';
  String grossLabel(String v) => 'Brutto: $v';
  String taxLabel(String v) => 'Steuer: $v';

  String get finalCapital => 'Endkapital';
  String get purchasingPowerToday => 'Kaufkraft heute';
  String get inflationAdjusted => 'inflationsbereinigt';
  String get compositionTitle => 'Zusammensetzung';
  String get subsidiesLabel => 'Zulagen';
  String get taxRefundLabel => 'Steuererstattung';
  String get taxRefundNotInDepot => 'Steuererstattung \u2013 wird auf Ihr Konto ausgezahlt, nicht ins Depot';
  String get capitalGainsLabel => 'Wertzuwachs';
  String get taxLogicTitle => 'Steuerlogik';
  String get taxLogicDescription =>
    'Ansparphase: Kapitalertr\u00E4ge steuerfrei. Zulagen flie\u00DFen ins Depot. '
    'G\u00FCnstigerpr\u00FCfung kann Steuererstattung bringen.\n\n'
    'Auszahlphase: Nachgelagerte Besteuerung mit pers\u00F6nlichem Steuersatz. '
    'Auszahlplan bis 85, bis 30 % Einmalentnahme.';
  String get marginalTaxRate => 'Grenzsteuersatz';

  String get subsidyLogicTitle => 'F\u00F6rderlogik im Detail';
  String get slBaseGrantLabel => 'Grundzulage:';
  String get slBaseGrantDetail =>
    '\u25B8 50 % auf erste 360 \u20AC/J = max 180 \u20AC\n'
    '\u25B8 25 % auf 361\u20131.800 \u20AC/J = max 360 \u20AC\n'
    '\u25B8 Max. Grundzulage: 540 \u20AC/J';
  String get slChildGrantLabel => 'Kinderzulage:';
  String get slChildGrantDetail => '\u25B8 Bis 300 \u20AC/Kind/J, volle Zulage ab 25 \u20AC/Monat';
  String get slEntryBonusLabel => 'Berufseinsteigerbonus:';
  String get slEntryBonusDetail => '\u25B8 200 \u20AC/J f\u00FCr 3 Jahre (unter 25)';
  String get slTaxOptLabel => 'G\u00FCnstigerpr\u00FCfung:';
  String get slTaxOptDetail =>
    '\u25B8 Eigenbeitrag + Zulagen als Sonderausgaben\n'
    '\u25B8 Differenz wird ggf. erstattet';
  String get slPayoutLabel => 'Auszahlung:';
  String get slPayoutDetail =>
    '\u25B8 Auszahlplan bis 85, bis 30 % Einmalentnahme\n'
    '\u25B8 Nachgelagerte Besteuerung';

  String get legislativeBasisTitle => 'Gesetzliche Grundlage';
  String get legislativeBasisDetail =>
    '\u25B8 Altersvorsorgereformgesetz \u2013 Bundestag-Drucksache 21/4088\n'
    '\u25B8 Finanzausschuss-\u00C4nderungen, 25. M\u00E4rz 2026 (Koalitionseinigung CDU/CSU + SPD)\n'
    '\u25B8 Verabschiedet am 27. M\u00E4rz 2026 im Bundestag (2. + 3. Lesung)\n'
    '\u25B8 Wesentliche \u00C4nderungen gg\u00FC. Erstentwurf (Dez. 2025): Grundzulage auf 50 %/25 % erh\u00F6ht, Kostendeckel auf 1,0 % gesenkt, '
    'alle Selbstst\u00E4ndigen f\u00F6rderberechtigt, \u00F6ffentlicher Tr\u00E4ger vorgeschrieben\n'
    '\u25B8 Inkrafttreten: 1. Januar 2027';
  String get sourcesTitle => 'Quellen';
  String get sourcesDetail =>
    '\u25B8 BMF FAQ: bundesfinanzministerium.de/Content/DE/FAQ/reform-der-privaten-altersvorsorge.html\n'
    '\u25B8 Bundestag-Abstimmung: bundestag.de/presse/hib/kurzmeldungen-1157838\n'
    '\u25B8 Bundestag-Anh\u00F6rung: bundestag.de/dokumente/textarchiv/2026/kw12-pa-finanzen-1152002\n'
    '\u25B8 Finanztip: finanztip.de/altersvorsorge/altersvorsorgedepot\n'
    '\u25B8 justETF: justetf.com/de/academy/altersvorsorgedepot-entwurf-2027.html';

  String pageNotFound(String uri) => 'Seite nicht gefunden: $uri';

  // Pros / Cons
  String get prosConsTitle => 'Was f\u00FCr Ihr Szenario gilt';
  String get avProsTitle => 'Vorteile AV-Depot';
  String get etfProsTitle => 'Vorteile ETF-Depot';
  String get proHighSubsidyRate => 'Hohe F\u00F6rderquote auf Ihre Beitr\u00E4ge';
  String get proKinderzulage => 'Kinderzulage aktiv (300 \u20AC/Kind/Jahr)';
  String get proGeringverdienerbonus => 'Geringverdienerbonus greift (+175 \u20AC/Jahr)';
  String get proBerufseinsteigerbonus => 'Berufseinsteigerbonus aktiv (+200 \u20AC/Jahr)';
  String get proGuenstigerpruefung => 'G\u00FCnstigerpr\u00FCfung bringt zus\u00E4tzliche Steuererstattung';
  String get proLongDuration => 'Lange Spardauer \u2013 Zulagen verzinsen sich \u00FCber Jahrzehnte';
  String get proTaxFreeGrowth => 'Steuerfreies Wachstum in der Ansparphase (keine Vorabpauschale, keine Abgeltungssteuer)';
  String get conLowSubsidyLeverage => 'Beitr\u00E4ge \u00FCber 150 \u20AC/Monat erhalten keine Zulage \u2013 aber die gesamte Auszahlung wird versteuert';
  String get conHighRetirementTax => 'Hoher Grenzsteuersatz \u2013 nachgelagerte Besteuerung zu hohem Satz mindert den Vorteil';
  String get proEtfOnlyGainsTaxed => 'Nur Gewinne werden besteuert \u2013 Ihre Einzahlungen erhalten Sie steuerfrei zur\u00FCck';
  String get proEtfTeilfreistellung => '30 % Teilfreistellung reduziert die steuerpflichtigen Gewinne';
  String get proEtfFlexibility => 'Keine Bindungsfrist \u2013 jederzeit verf\u00FCgbar ohne Einschr\u00E4nkungen';
  String get proEtfLowReturnsAdvantage => 'Bei niedrigen Renditen sind die Gewinne gering \u2013 weniger Steuerbelastung als nachgelagerte Vollbesteuerung';

  String get etfTaxNote =>
    'ETF-Besteuerung: Nur Gewinne werden besteuert \u2013 mit 30 % Teilfreistellung '
    'f\u00FCr Aktienfonds. Das bedeutet, nur 70 % der Gewinne unterliegen der '
    'Abgeltungssteuer. Ihre Einzahlungen erhalten Sie steuerfrei zur\u00FCck.';

  String get resetAll => 'Alle Werte zur\u00FCcksetzen';
  String get disclaimer =>
    'Hinweis: Dieser Rechner dient der Veranschaulichung, nicht als '
    'Finanzberatung. Die Makro-Szenarien sind stilisierte Modelle, keine Prognosen.';
  String get includedFeaturesTitle => 'In diesem Rechner enthalten';
  String get includedFeaturesDetail =>
    '\u25B8 Grundzulage (50 %/25 % Zwei-Stufen-F\u00F6rderung auf bis zu 1.800 \u20AC/Jahr)\n'
    '\u25B8 Kinderzulage (bis 300 \u20AC/Kind/Jahr, 1:1 Zuschuss)\n'
    '\u25B8 Berufseinsteigerbonus (200 \u20AC/Jahr f\u00FCr 3 Jahre, unter 25)\n'
    '\u25B8 Geringverdienerbonus (175 \u20AC/Jahr bei Brutto \u2264 26.250 \u20AC)\n'
    '\u25B8 G\u00FCnstigerpr\u00FCfung (automatische Steueroptimierung)\n'
    '\u25B8 Kirchensteuer (optional: Keine / 8 % / 9 %)\n'
    '\u25B8 Abgeltungssteuer mit 30 % Teilfreistellung f\u00FCr ETF\n'
    '\u25B8 Vorabpauschale (vereinfacht als 0,2 % j\u00E4hrlicher Abzug)\n'
    '\u25B8 Nachgelagerte Besteuerung der AV-Depot-Auszahlungen\n'
    '\u25B8 6 Makro-Szenarien + eigene Szenarien\n'
    '\u25B8 5 pers\u00F6nliche Szenarien + freie Eingabe';
  String get simplificationsTitle => 'Vereinfachungen';
  String get simplificationsDetail =>
    '\u25B8 Konstante j\u00E4hrliche Rendite (kein Reihenfolge-Risiko)\n'
    '\u25B8 Vereinfachte Vorabpauschale als 0,2 % j\u00E4hrlicher Abzug (tats\u00E4chlich abh\u00E4ngig vom Basiszins)\n'
    '\u25B8 Keine unterj\u00E4hrigen Beitr\u00E4ge\n'
    '\u25B8 Steuersatz im Ruhestand vereinfacht als 70 % des Arbeitssatzes\n'
    '\u25B8 G\u00FCnstigerpr\u00FCfung-Erstattung wird nicht in separates ETF-Depot reinvestiert\n'
    '\u25B8 Quellensteuer auf Fondsebene (~0,3 % p.a.) nicht separat modelliert';
  String get plannedFeaturesTitle => 'Noch nicht enthalten';
  String get plannedFeaturesDetail =>
    '\u25B8 Riester-Vergleich (altes vs. neues F\u00F6rdersystem)\n'
    '\u25B8 Wohnwirtschaftliche Verwendung (steuerfreie Entnahme f\u00FCr Immobilien)\n'
    '\u25B8 Leibrente vs. Auszahlplan-Vergleich\n'
    '\u25B8 Monte-Carlo-Simulation (zuf\u00E4llige Renditefolgen)\n'
    '\u25B8 PDF/CSV-Export';

  String get chartAllMacrosTitle => 'AV-Depot: Alle Makro-Szenarien + ETF (gestrichelt)';
  String chartWealthTitle(String icon, String name) => 'Verm\u00F6gensentwicklung \u2013 $icon $name';
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
  String get colDelta => '\u0394 AV-ETF';
  String get colDeltaMo => '\u0394/MT';
  String get tagSavingsRate => 'Sparrate';
  String get tagGross => 'Brutto';
  String get tagChildren => 'Kinder';
  String get tagDuration => 'Dauer';
  String get tagSubsidyYear => 'Zulage/J.';
  String get tagSubsidyRate => 'F\u00F6rderquote';
  String get tagMargTax => 'Grenzsteuer';

  String get editScenario => 'Szenario bearbeiten';
  String get newScenarioTitle => 'Neues Szenario';
  String get editMacroScenario => 'Makro-Szenario bearbeiten';
  String get newMacroScenarioTitle => 'Neues Makro-Szenario';
  String get addMacroLabel => 'Makro hinzuf\u00FCgen';
  String get deleteBtn => 'L\u00F6schen';
  String get cancelBtn => 'Abbrechen';
  String get saveBtn => 'Speichern';
  String get addBtn => 'Hinzuf\u00FCgen';
  String get fieldName => 'Name';
  String get fieldShortName => 'Kurzname';
  String get fieldIcon => 'Icon (Emoji)';
  String get fieldDescription => 'Beschreibung';
  String get fieldReturnPct => 'Rendite (% p.a.)';
  String get fieldInflationPct => 'Inflation (% p.a.)';
  String get fieldColor => 'Farbe:';
  String get fieldSavingsRate => 'Sparrate (\u20AC/Monat)';
  String get fieldGrossSalary => 'Bruttojahresgehalt (\u20AC)';
  String get fieldChildren => 'Anzahl Kinder';
  String get fieldStartAge => 'Alter bei Start';
  String get fieldDuration => 'Spardauer (Jahre)';
  String get defaultScenarioName => 'Neues Szenario';

  String get currentLabel => 'Aktuell';
  String get customName => 'Eigene Werte';
  String get customShort => 'Eigen';
  String get customDesc => 'Manuell eingestellt';
  String get avDepotLabel => 'AV-Depot';
  String get etfLabel => 'ETF';
  String get etfDepotLabel => 'ETF-Depot';
  String get yearSuffix => 'J';
  String get perMonth => '/Mt';
  String get inflLabel => 'Infl';
  String get realLabel => 'Real';

  String get chartTab => 'Diagramm';
  String get tableTab => 'Tabelle';

  String get presetCareerStarter => 'Berufseinsteiger';
  String get presetSingleMid30 => 'Single Mitte 30';
  String get presetFamily2Kids => 'Familie 2 Kinder';
  String get presetHighEarner => 'Gutverdiener';
  String get presetPartTimeChild => 'Teilzeit + Kind';

  String get macroBoomName => 'Boom / Bullenmarkt';
  String get macroBoomShort => 'Boom';
  String get macroBoomDesc => 'Starke Konjunktur, niedrige Inflation \u2013 wie 2010\u20132021.';
  String get macroBaselineName => 'Basis / Hist. Durchschnitt';
  String get macroBaselineShort => 'Basis';
  String get macroBaselineDesc => 'MSCI-World-Durchschnitt ~7 % bei 2 % Inflation.';
  String get macroModerateName => 'Moderate Abschw\u00E4chung';
  String get macroModerateShort => 'Moderat';
  String get macroModerateDesc => 'Schw\u00E4cheres Wachstum, leicht erh\u00F6hte Inflation.';
  String get macroStagflationName => 'Stagflation';
  String get macroStagflationShort => 'Stagflation';
  String get macroStagflationDesc => 'Hohe Inflation bei schwachem Wachstum \u2013 wie 1970er.';
  String get macroJapanName => 'Japan-Szenario';
  String get macroJapanShort => 'Japan';
  String get macroJapanDesc => 'Stagnation mit Nullzinsen \u2013 Japan 1990\u20132020.';
  String get macroLostDecadeName => 'Verlorenes Jahrzehnt';
  String get macroLostDecadeShort => 'Verlorenes Jahrzehnt';
  String get macroLostDecadeDesc => 'Crash mit langsamer Erholung \u2013 2000\u20132012.';
}
