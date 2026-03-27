import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avdepot_rechner/config/theme.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/core/responsive/screen_layout.dart';
import 'package:avdepot_rechner/core/state/locale_cubit.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/shared/utils/fmt.dart';
import 'package:avdepot_rechner/shared/widgets/common.dart';
import 'package:avdepot_rechner/features/calculator/widgets/input_panel.dart';
import 'package:avdepot_rechner/features/calculator/widgets/macro_section.dart';
import 'package:avdepot_rechner/features/calculator/widgets/charts.dart';
import 'package:avdepot_rechner/features/calculator/widgets/compound_table.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_cubit.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_state.dart';

class CalculatorPage extends StatefulWidget {
  const CalculatorPage({super.key});

  @override
  State<CalculatorPage> createState() => _CalculatorPageState();
}

class _CalculatorPageState extends State<CalculatorPage> with TickerProviderStateMixin {
  late TabController _tabController;
  late TabController _macroTabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    _tabController.addListener(() => setState(() {}));
    _macroTabController = TabController(length: 2, vsync: this);
    _macroTabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    _macroTabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final localeCubit = context.watch<LocaleCubit>();
    final s = localeCubit.state.strings;

    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final cubit = context.read<CalculatorCubit>();
        final av = state.avResult(s);
        final etf = state.etfResult(s);
        final sub = state.subsidyBreakdown;
        final macro = state.effectiveMacro(s);
        final diff = av.endkapital - etf.endkapital;

        final compact = context.isCompact;

        return Scaffold(
          bottomNavigationBar: _StickyFooter(
            strings: s,
            locale: localeCubit.state.locale,
            onToggleLocale: () {
              localeCubit.toggle();
              context.read<CalculatorCubit>().updateLocale(localeCubit.state.strings);
            },
          ),
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
                child: Padding(
                  padding: compact
                      ? const EdgeInsets.symmetric(horizontal: AppSpacing.lg)
                      : AppPadding.page,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── HEADER ──────────────────────────
                      SizedBox(height: compact ? AppSpacing.xl : AppSpacing.section),
                      Center(
                        child: Text(s.calculatorBadge,
                          style: TextStyle(fontSize: compact ? 10 : 12, fontWeight: FontWeight.w700,
                            color: AppColors.accent, letterSpacing: 2)),
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(child: Text(s.appTitle,
                        style: compact
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.headlineLarge)),
                      Center(child: Text(s.appSubtitle,
                        style: TextStyle(fontSize: compact ? 14 : 17, fontWeight: FontWeight.w500,
                          color: AppColors.muted))),
                      const SizedBox(height: AppSpacing.xxxl),

                      // ─── PERSONAL SCENARIOS ──────────────────
                      SectionDivider(s.sectionPersonalScenarios),
                      if (compact) ...[
                        const PersonalScenarioBar(),
                        const SizedBox(height: AppSpacing.lg),
                        const InputPanel(),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: AppDimensions.sidebarWidth,
                              child: const PersonalScenarioBar(),
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            const Expanded(child: InputPanel()),
                          ],
                        ),

                      // ─── MACROECONOMIC SCENARIOS ───────────────
                      SectionDivider(s.sectionMacroScenarios),
                      if (compact) ...[
                        const MacroScenarioGrid(),
                        const SizedBox(height: AppSpacing.lg),
                        _buildMacroTabBar(s),
                        const SizedBox(height: AppSpacing.md),
                        if (_macroTabController.index == 0)
                          const MacroOverlayChart()
                        else
                          const CompoundTable(),
                      ] else
                        Row(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            SizedBox(
                              width: AppDimensions.sidebarWidth,
                              child: const MacroScenarioGrid(),
                            ),
                            const SizedBox(width: AppSpacing.xl),
                            Expanded(
                              child: Column(
                                crossAxisAlignment: CrossAxisAlignment.stretch,
                                children: [
                                  _buildMacroTabBar(s),
                                  const SizedBox(height: AppSpacing.md),
                                  if (_macroTabController.index == 0)
                                    const MacroOverlayChart()
                                  else
                                    const CompoundTable(),
                                ],
                              ),
                            ),
                          ],
                        ),

                      // ─── DETAIL RESULTS ─────────────────────
                      SectionDivider(s.sectionDetailedResults),

                      // ─── TABS ───────────────────────────────
                      Container(
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: TabBar(
                          controller: _tabController,
                          labelColor: Colors.white,
                          unselectedLabelColor: AppColors.muted,
                          labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                          indicator: BoxDecoration(
                            color: AppColors.accent,
                            borderRadius: BorderRadius.circular(AppRadius.chip),
                          ),
                          indicatorSize: TabBarIndicatorSize.tab,
                          dividerHeight: 0,
                          tabs: [
                            Tab(text: s.tabComparison),
                            Tab(text: s.tabAvDetail),
                          ],
                        ),
                      ),
                      const SizedBox(height: AppSpacing.xl),

                      if (_tabController.index == 0)
                        _buildVergleich(s, state, av, etf, macro, diff, sub)
                      else
                        _buildDetail(s, av),

                      // ─── SUBSIDY LOGIC ──────────────────────
                      const SizedBox(height: AppSpacing.xxxl),
                      _buildSubsidyLogic(s),

                      // ─── RESET ──────────────────────────────
                      Padding(
                        padding: const EdgeInsets.symmetric(vertical: AppSpacing.xl),
                        child: Center(
                          child: OutlinedButton.icon(
                            onPressed: () {
                              cubit.resetToDefaults(s);
                              _tabController.animateTo(0);
                              _macroTabController.animateTo(0);
                            },
                            icon: const Icon(Icons.refresh, size: 14),
                            label: Text(s.resetAll, style: const TextStyle(fontSize: 11)),
                          ),
                        ),
                      ),

                      // ─── SIMPLIFICATIONS + PLANNED ────────
                      Container(
                        padding: AppPadding.panel,
                        margin: const EdgeInsets.only(bottom: AppSpacing.lg),
                        decoration: BoxDecoration(
                          color: AppColors.card,
                          borderRadius: BorderRadius.circular(AppRadius.panel),
                          border: Border.all(color: AppColors.border),
                        ),
                        child: Column(
                          crossAxisAlignment: CrossAxisAlignment.start,
                          children: [
                            Text(s.includedFeaturesTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
                            const SizedBox(height: 4),
                            Text(s.includedFeaturesDetail, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
                            const Divider(height: 24),
                            Text(s.simplificationsTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
                            const SizedBox(height: 4),
                            Text(s.simplificationsDetail, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
                            const Divider(height: 24),
                            Text(s.plannedFeaturesTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
                            const SizedBox(height: 4),
                            Text(s.plannedFeaturesDetail, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
                          ],
                        ),
                      ),

                      // ─── DISCLAIMER ─────────────────────────
                      Container(
                        margin: const EdgeInsets.only(bottom: 40),
                        padding: AppPadding.card,
                        decoration: BoxDecoration(
                          color: AppColors.warnBg,
                          borderRadius: BorderRadius.circular(AppRadius.lg),
                          border: Border.all(color: AppColors.warnBorder),
                        ),
                        child: Text(s.disclaimer,
                          style: const TextStyle(fontSize: 10, color: AppColors.warnText, height: 1.5)),
                      ),
                    ],
                  ),
                ),
              ),
            ),
          ),
        );
      },
    );
  }

  // ─── MACRO TAB BAR ─────────────────────────────────────────────

  Widget _buildMacroTabBar(AppStrings s) {
    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.lg),
        border: Border.all(color: AppColors.border),
      ),
      child: TabBar(
        controller: _macroTabController,
        labelColor: Colors.white,
        unselectedLabelColor: AppColors.muted,
        labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
        indicator: BoxDecoration(
          color: AppColors.accent,
          borderRadius: BorderRadius.circular(AppRadius.chip),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        dividerHeight: 0,
        tabs: [
          Tab(text: s.chartTab),
          Tab(text: s.tableTab),
        ],
      ),
    );
  }

  // ─── FOERDERUNG BOX ─────────────────────────────────────────────

  Widget _buildSubsidyTable(AppStrings s, SubsidyBreakdown sub, MacroScenario macro) {
    final rows = <(String, String)>[
      (s.baseGrant, Fmt.eur(sub.grundzulage)),
      (s.childGrant, Fmt.eur(sub.kinderzulage)),
      if (sub.bonus > 0) (s.entryBonus, Fmt.eur(sub.bonus)),
      if (sub.geringverdienerbonus > 0) (s.lowIncomeBonus, Fmt.eur(sub.geringverdienerbonus)),
      (s.totalSubsidyYear, Fmt.eur(sub.total)),
      (s.subsidyRate, Fmt.pct(sub.foerderquote)),
      if (sub.steuererstattung > 0) ('${s.taxRefundYear} (${s.viaTaxOptimization})', Fmt.eur(sub.steuererstattung)),
      (s.marginalTaxRate, Fmt.pct(sub.grenzsteuersatz)),
    ];
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        if (sub.geringverdienerbonus > 0) Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.md),
          child: Container(
            padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
            decoration: BoxDecoration(
              color: AppColors.successBg,
              borderRadius: BorderRadius.circular(AppRadius.md),
              border: Border.all(color: AppColors.success.withValues(alpha: 0.3)),
            ),
            child: Text(s.lowIncomeBonusApplies,
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.successText)),
          ),
        ),
        Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: const BoxDecoration(
                  color: AppColors.accentLight,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.card),
                    topRight: Radius.circular(AppRadius.card)),
                ),
                child: Text(s.annualSubsidiesTitle(macro.icon, macro.name),
                  style: const TextStyle(fontSize: 13, fontWeight: FontWeight.w700, color: AppColors.accent)),
              ),
              ...rows.map((r) => Container(
                padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 6),
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border, width: 0.5)),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.spaceBetween,
                  children: [
                    Text(r.$1, style: const TextStyle(fontSize: 13, color: AppColors.label)),
                    Text(r.$2, style: AppTheme.mono.copyWith(fontSize: 14, fontWeight: FontWeight.w700)),
                  ],
                ),
              )),
            ],
          ),
        ),
      ],
    );
  }

  // ─── COMPARISON TAB ───────────────────────────────────────────

  Widget _buildVergleich(AppStrings s, CalculatorState state, AVResult av, ETFResult etf, MacroScenario macro, double diff, SubsidyBreakdown sub) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        ResultBanner(
          positive: diff >= 0,
          title: diff >= 0 ? s.avYieldsMore(Fmt.eur(diff)) : s.etfYieldsMore(Fmt.eur(-diff)),
          subtitle: s.comparisonSubtitle(macro.icon, macro.name),
        ),
        if (diff < 0) Padding(
          padding: const EdgeInsets.only(bottom: AppSpacing.xl),
          child: Text(s.etfWinsExplanation,
            style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
        ),
        const ComparisonChart(),
        const SizedBox(height: AppSpacing.lg),
        Text(s.etfTaxNote,
          style: const TextStyle(fontSize: 10, color: AppColors.muted, height: 1.5)),
        const SizedBox(height: AppSpacing.xl),
        ComparisonBar(label: s.finalCapitalGross,
          avValue: av.endkapital, etfValue: etf.endkapital,
          avText: Fmt.eur(av.endkapital), etfText: Fmt.eur(etf.endkapital),
          avLabel: s.avDepotLabel, etfLabel: s.etfDepotLabel),
        ComparisonBar(label: s.ownContributions,
          avValue: av.eigenBeitraege, etfValue: etf.eigenBeitraege,
          avText: Fmt.eur(av.eigenBeitraege), etfText: Fmt.eur(etf.eigenBeitraege),
          avLabel: s.avDepotLabel, etfLabel: s.etfDepotLabel),
        ComparisonBar(label: s.govSubsidiesAvOnly,
          avValue: av.zulagenGesamt, etfValue: 0,
          avText: Fmt.eur(av.zulagenGesamt), etfText: Fmt.eur(0),
          avLabel: s.avDepotLabel, etfLabel: s.etfDepotLabel),
        ComparisonBar(label: s.monthlyPayout20y,
          avValue: av.nettoMonatlich, etfValue: etf.monatlicheAuszahlung,
          avText: Fmt.eur(av.nettoMonatlich), etfText: Fmt.eur(etf.monatlicheAuszahlung),
          avLabel: s.avDepotLabel, etfLabel: s.etfDepotLabel),

        // ─── ANNUAL SUBSIDIES TABLE ───────────────────────
        const SizedBox(height: AppSpacing.xl),
        _buildSubsidyTable(s, sub, macro),

        // ─── PROS / CONS ────────────────────────────────────
        const SizedBox(height: AppSpacing.xl),
        _buildProsCons(s, state, av, etf, sub),
      ],
    );
  }

  // ─── PROS / CONS ─────────────────────────────────────────────

  Widget _buildProsCons(AppStrings s, CalculatorState state, AVResult av, ETFResult etf, SubsidyBreakdown sub) {
    final p = state.currentPerson;
    final avPros = <String>[];
    final avCons = <String>[];
    final etfPros = <String>[];

    // AV pros
    if (sub.foerderquote > 0.25) avPros.add(s.proHighSubsidyRate);
    if (sub.kinderzulage > 0) avPros.add(s.proKinderzulage);
    if (sub.geringverdienerbonus > 0) avPros.add(s.proGeringverdienerbonus);
    if (sub.bonus > 0) avPros.add(s.proBerufseinsteigerbonus);
    if (sub.steuererstattung > 0) avPros.add(s.proGuenstigerpruefung);
    if (p.spardauer >= 25) avPros.add(s.proLongDuration);
    avPros.add(s.proTaxFreeGrowth);

    // AV cons
    if (p.jahresbeitrag > 1800) avCons.add(s.conLowSubsidyLeverage);
    if (av.grenzsteuersatz >= 0.42) avCons.add(s.conHighRetirementTax);

    // ETF pros
    etfPros.add(s.proEtfOnlyGainsTaxed);
    etfPros.add(s.proEtfTeilfreistellung);
    etfPros.add(s.proEtfFlexibility);
    if (state.effectiveRendite <= 0.04) etfPros.add(s.proEtfLowReturnsAdvantage);

    return Container(
      padding: AppPadding.panel,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.prosConsTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.lg),
          Text(s.avProsTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
          const SizedBox(height: 4),
          ...avPros.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('\u2713 ', style: TextStyle(fontSize: 11, color: AppColors.success)),
              Expanded(child: Text(t, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.5))),
            ]),
          )),
          if (avCons.isNotEmpty) ...[
            const SizedBox(height: AppSpacing.md),
            ...avCons.map((t) => Padding(
              padding: const EdgeInsets.only(bottom: 3),
              child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
                const Text('\u2717 ', style: TextStyle(fontSize: 11, color: AppColors.danger)),
                Expanded(child: Text(t, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.5))),
              ]),
            )),
          ],
          const Divider(height: 20),
          Text(s.etfProsTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.etf)),
          const SizedBox(height: 4),
          ...etfPros.map((t) => Padding(
            padding: const EdgeInsets.only(bottom: 3),
            child: Row(crossAxisAlignment: CrossAxisAlignment.start, children: [
              const Text('\u2713 ', style: TextStyle(fontSize: 11, color: AppColors.success)),
              Expanded(child: Text(t, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.5))),
            ]),
          )),
        ],
      ),
    );
  }

  // ─── DETAIL TAB ────────────────────────────────────────────────

  Widget _buildDetail(AppStrings s, AVResult av) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        IntrinsicHeight(
          child: Row(
            crossAxisAlignment: CrossAxisAlignment.stretch,
            children: [
              Expanded(child: StatCard(label: s.finalCapital, value: Fmt.eur(av.endkapital), accent: true)),
              const SizedBox(width: AppSpacing.md),
              Expanded(child: StatCard(label: s.purchasingPowerToday, value: Fmt.eur(av.endkapitalReal), sub: s.inflationAdjusted)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.xl),

        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.compositionTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: 10),
              MiniBar(label: s.ownContributions, value: av.eigenBeitraege,
                maxValue: av.endkapital, color: AppColors.label, valueText: Fmt.eur(av.eigenBeitraege)),
              MiniBar(label: s.subsidiesLabel, value: av.zulagenGesamt,
                maxValue: av.endkapital, color: AppColors.accent, valueText: Fmt.eur(av.zulagenGesamt)),
              MiniBar(label: s.capitalGainsLabel, value: av.wertzuwachs,
                maxValue: av.endkapital, color: AppColors.etf, valueText: Fmt.eur(av.wertzuwachs)),
              if (av.steuererstattungGesamt > 0)
                MiniBar(label: s.taxRefundNotInDepot, value: av.steuererstattungGesamt,
                  maxValue: av.endkapital, color: AppColors.success, valueText: Fmt.eur(av.steuererstattungGesamt)),
            ],
          ),
        ),
        const SizedBox(height: AppSpacing.lg),

        Container(
          padding: const EdgeInsets.all(AppSpacing.xl),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.card),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Text(s.taxLogicTitle, style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700)),
              const SizedBox(height: AppSpacing.md),
              Text(s.taxLogicDescription,
                style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
              const SizedBox(height: 10),
              RichText(text: TextSpan(children: [
                TextSpan(text: '${s.marginalTaxRate}: ',
                  style: const TextStyle(fontSize: 11, color: AppColors.label)),
                TextSpan(text: Fmt.pct(av.grenzsteuersatz),
                  style: AppTheme.mono.copyWith(fontSize: 13, color: AppColors.accent)),
              ])),
            ],
          ),
        ),
      ],
    );
  }

  // ─── SUBSIDY LOGIC ─────────────────────────────────────────────

  Widget _buildSubsidyLogic(AppStrings s) {
    return Container(
      padding: AppPadding.panel,
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(s.subsidyLogicTitle, style: const TextStyle(fontSize: 14, fontWeight: FontWeight.w800)),
          const SizedBox(height: AppSpacing.lg),
          ...[
            (s.slBaseGrantLabel, s.slBaseGrantDetail),
            (s.slChildGrantLabel, s.slChildGrantDetail),
            (s.slEntryBonusLabel, s.slEntryBonusDetail),
            (s.slTaxOptLabel, s.slTaxOptDetail),
            (s.slPayoutLabel, s.slPayoutDetail),
          ].map((e) => Padding(
            padding: const EdgeInsets.only(bottom: 10),
            child: Column(
              crossAxisAlignment: CrossAxisAlignment.start,
              children: [
                Text(e.$1, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
                Text(e.$2, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
              ],
            ),
          )),
          const Divider(height: 24),
          Text(s.legislativeBasisTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
          const SizedBox(height: 4),
          Text(s.legislativeBasisDetail, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
          const SizedBox(height: 14),
          Text(s.sourcesTitle, style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: AppColors.accent)),
          const SizedBox(height: 4),
          Text(s.sourcesDetail, style: const TextStyle(fontSize: 11, color: AppColors.label, height: 1.6)),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// STICKY FOOTER
// ═══════════════════════════════════════════════════════════════════

class _StickyFooter extends StatelessWidget {
  final AppStrings strings;
  final AppLocale locale;
  final VoidCallback onToggleLocale;

  const _StickyFooter({
    required this.strings,
    required this.locale,
    required this.onToggleLocale,
  });

  @override
  Widget build(BuildContext context) {
    return Container(
      decoration: const BoxDecoration(
        color: AppColors.card,
        border: Border(top: BorderSide(color: AppColors.border)),
      ),
      padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: AppSpacing.lg),
      child: Row(
        mainAxisAlignment: MainAxisAlignment.center,
        children: [
          Text(strings.copyrightNotice.split('\u2013')[0].trim(),
            style: const TextStyle(fontSize: 10, color: AppColors.muted)),
          _divider(),
          _link(strings.impressumTitle, () => _showLegalDialog(context, strings.impressumTitle, strings.impressumDetail)),
          _divider(),
          _link(strings.datenschutzTitle, () => _showLegalDialog(context, strings.datenschutzTitle, strings.datenschutzDetail)),
          _divider(),
          GestureDetector(
            onTap: onToggleLocale,
            child: Row(mainAxisSize: MainAxisSize.min, children: [
              const Icon(Icons.language, size: 13, color: AppColors.accent),
              const SizedBox(width: 3),
              Text(locale == AppLocale.en ? 'EN' : 'DE',
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent)),
            ]),
          ),
        ],
      ),
    );
  }

  Widget _divider() => const Padding(
    padding: EdgeInsets.symmetric(horizontal: 10),
    child: Text('\u00B7', style: TextStyle(color: AppColors.muted)),
  );

  Widget _link(String label, VoidCallback onTap) => GestureDetector(
    onTap: onTap,
    child: Text(label, style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
  );

  void _showLegalDialog(BuildContext context, String title, String detail) {
    showDialog(
      context: context,
      builder: (_) => AlertDialog(
        title: Text(title, style: const TextStyle(fontSize: 16, fontWeight: FontWeight.w700)),
        content: SingleChildScrollView(
          child: Text(detail, style: const TextStyle(fontSize: 13, color: AppColors.label, height: 1.6)),
        ),
        actions: [
          TextButton(
            onPressed: () => Navigator.pop(context),
            child: const Text('OK'),
          ),
        ],
      ),
    );
  }
}

