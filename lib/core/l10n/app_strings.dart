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

  // ─── SUBSIDY BOX ─────────────────────────────────────────────────
  String annualSubsidiesTitle(String icon, String name);
  String get baseGrant;
  String get childGrant;
  String get entryBonus;
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

  // ─── ERRORS ──────────────────────────────────────────────────────
  String pageNotFound(String uri);

  // ─── FOOTER ───────────────────────────────────────────────────────
  String get resetAll;
  String get disclaimer;

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

  // Subsidy
  String annualSubsidiesTitle(String icon, String name) => 'Annual Subsidies \u2013 $icon $name';
  String get baseGrant => 'Base Grant';
  String get childGrant => 'Child Grant';
  String get entryBonus => 'Entry Bonus';
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

  // Errors
  String pageNotFound(String uri) => 'Page not found: $uri';

  // Footer
  String get resetAll => 'Reset All Values';
  String get disclaimer =>
    'Note: This calculator is for illustration purposes, not financial advice. '
    'Simplified assumptions (constant returns, linear tax rates, no church tax). '
    'The macro scenarios are stylized models, not forecasts. '
    'As of: Coalition agreement March 2026.';

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

  String annualSubsidiesTitle(String icon, String name) => 'J\u00E4hrliche F\u00F6rderung \u2013 $icon $name';
  String get baseGrant => 'Grundzulage';
  String get childGrant => 'Kinderzulage';
  String get entryBonus => 'Bonus';
  String get subsidyRate => 'F\u00F6rderquote';
  String get totalSubsidyYear => 'Gesamt-Zulage/Jahr';
  String get taxRefundYear => 'Steuererstattung/Jahr';
  String get viaTaxOptimization => 'via G\u00FCnstigerpr\u00FCfung';

  String get tabComparison => 'Vergleich';
  String get tabAvDetail => 'AV-Depot Detail';

  String avYieldsMore(String amount) => 'AV-Depot bringt $amount mehr.';
  String etfYieldsMore(String amount) => 'ETF-Depot bringt $amount mehr.';
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

  String pageNotFound(String uri) => 'Seite nicht gefunden: $uri';

  String get resetAll => 'Alle Werte zur\u00FCcksetzen';
  String get disclaimer =>
    'Hinweis: Dieser Rechner dient der Veranschaulichung, nicht als '
    'Finanzberatung. Vereinfachte Annahmen (konstante Rendite, lineare '
    'Steuers\u00E4tze, keine Kirchensteuer). Die Makro-Szenarien sind '
    'stilisierte Modelle, keine Prognosen. Stand: Koalitionseinigung M\u00E4rz 2026.';

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
