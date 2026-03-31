import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avdepot_rechner/config/theme.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/core/responsive/screen_layout.dart';
import 'package:avdepot_rechner/core/state/locale_cubit.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/services/domain/calculator_service.dart';
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
          bottomNavigationBar: _StickyFooter(strings: s),
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
                      // ─── HEADER + LANGUAGE TOGGLE ───────────
                      SizedBox(height: compact ? AppSpacing.xl : AppSpacing.section),
                      Stack(
                        alignment: Alignment.center,
                        children: [
                          Center(
                            child: Text(s.calculatorBadge,
                              style: TextStyle(fontSize: compact ? 10 : 12, fontWeight: FontWeight.w700,
                                color: AppColors.accent, letterSpacing: 2)),
                          ),
                          Positioned(
                            right: 0,
                            child: GestureDetector(
                              onTap: () {
                                localeCubit.toggle();
                                context.read<CalculatorCubit>().updateLocale(localeCubit.state.strings);
                              },
                              child: Container(
                                padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
                                decoration: BoxDecoration(
                                  borderRadius: BorderRadius.circular(6),
                                  border: Border.all(color: AppColors.border),
                                ),
                                child: Row(mainAxisSize: MainAxisSize.min, children: [
                                  Text(localeCubit.state.locale == AppLocale.en ? 'EN' : 'DE',
                                    style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent)),
                                  const SizedBox(width: 3),
                                  const Icon(Icons.language, size: 13, color: AppColors.accent),
                                ]),
                              ),
                            ),
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(child: Text(s.appTitle,
                        style: compact
                            ? Theme.of(context).textTheme.headlineMedium
                            : Theme.of(context).textTheme.headlineLarge)),
                      Center(child: Text(s.appSubtitle,
                        style: TextStyle(fontSize: compact ? 14 : 17, fontWeight: FontWeight.w500,
                          color: AppColors.muted))),
                      const SizedBox(height: AppSpacing.lg),
                      Center(child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 600),
                        child: Text(s.disclaimer,
                          textAlign: TextAlign.center,
                          style: TextStyle(fontSize: compact ? 9 : 10, color: AppColors.muted, height: 1.5)),
                      )),
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

        // ─── CALCULATION BREAKDOWN ───────────────────────
        const SizedBox(height: AppSpacing.xl),
        _CalculationBreakdown(state: state, av: av, etf: etf, sub: sub),

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
              Text(s.hintMarginalTaxRate,
                style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.4)),
              const SizedBox(height: 8),
              RichText(text: TextSpan(children: [
                TextSpan(text: '${s.retirementTaxRate}: ',
                  style: const TextStyle(fontSize: 11, color: AppColors.label)),
                TextSpan(text: Fmt.pct(av.grenzsteuersatzRente),
                  style: AppTheme.mono.copyWith(fontSize: 13, color: AppColors.accent)),
              ])),
              Text(s.hintRetirementTaxRate,
                style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.4)),
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
// CALCULATION BREAKDOWN — phase-based, AV vs ETF side by side
// ═══════════════════════════════════════════════════════════════════

class _CalculationBreakdown extends StatefulWidget {
  final CalculatorState state;
  final AVResult av;
  final ETFResult etf;
  final SubsidyBreakdown sub;

  const _CalculationBreakdown({
    required this.state, required this.av, required this.etf, required this.sub,
  });

  @override
  State<_CalculationBreakdown> createState() => _CalculationBreakdownState();
}

class _CalculationBreakdownState extends State<_CalculationBreakdown> with TickerProviderStateMixin {
  late TabController _tab;

  @override
  void initState() { super.initState(); _tab = TabController(length: 2, initialIndex: 1, vsync: this); _tab.addListener(() => setState(() {})); }
  @override
  void dispose() { _tab.dispose(); super.dispose(); }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    final p = widget.state.currentPerson;
    final av = widget.av;
    final etf = widget.etf;
    final sub = widget.sub;
    final costs = widget.state.costs;
    final jb = p.jahresbeitrag;
    final jbCapped = jb < CalcConstants.maxBeitragProVertrag ? jb : CalcConstants.maxBeitragProVertrag;
    final jbGef = jbCapped < CalcConstants.grundzulageMaxBeitrag ? jbCapped : CalcConstants.grundzulageMaxBeitrag;
    final jbUngef = jbCapped - jbGef;
    final compact = context.isCompact;

    return Container(
      decoration: BoxDecoration(
        color: AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.panel),
        border: Border.all(color: AppColors.border),
      ),
      child: Column(children: [
        Container(
          decoration: const BoxDecoration(
            border: Border(bottom: BorderSide(color: AppColors.border)),
            borderRadius: BorderRadius.only(
              topLeft: Radius.circular(AppRadius.panel),
              topRight: Radius.circular(AppRadius.panel)),
          ),
          child: TabBar(
            controller: _tab,
            labelColor: Colors.white,
            unselectedLabelColor: AppColors.muted,
            labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
            indicator: BoxDecoration(
              color: AppColors.accent,
              borderRadius: _tab.index == 0
                  ? const BorderRadius.only(topLeft: Radius.circular(AppRadius.panel), bottomRight: Radius.circular(AppRadius.chip))
                  : const BorderRadius.only(topRight: Radius.circular(AppRadius.panel), bottomLeft: Radius.circular(AppRadius.chip)),
            ),
            indicatorSize: TabBarIndicatorSize.tab,
            dividerHeight: 0,
            tabs: [Tab(text: s.bdTabSavings), Tab(text: s.bdTabPayout)],
          ),
        ),
        Padding(
          padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
          child: _tab.index == 0
              ? _savingsPhase(s, p, sub, widget.state.subsidyPhases, jbGef, jbUngef, costs, etf, compact)
              : _payoutPhase(s, p, av, etf, costs, jbGef, jbUngef, compact),
        ),
      ]),
    );
  }

  // ─── HELPERS ────────────────────────────────────────────────────

  /// Paired row: label on left, AV value center-right, ETF value far-right.
  /// Ensures AV and ETF figures are always on the same line.
  Widget _pair(String label, String avVal, String etfVal, {bool bold = false, String? tip}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 3),
      child: Row(children: [
        Expanded(flex: 5, child: Row(children: [
          Flexible(child: Text(label, style: TextStyle(fontSize: 10,
            color: AppColors.label, fontWeight: bold ? FontWeight.w700 : FontWeight.w400))),
          if (tip != null) ...[const SizedBox(width: AppSpacing.xs), InfoTip(tip, size: 12)],
        ])),
        Expanded(flex: 3, child: Text(avVal, textAlign: TextAlign.right,
          style: AppTheme.monoSmall.copyWith(fontSize: 10,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.text))),
        const SizedBox(width: AppSpacing.lg),
        Expanded(flex: 3, child: Text(etfVal, textAlign: TextAlign.right,
          style: AppTheme.monoSmall.copyWith(fontSize: 10,
            fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.text))),
      ]),
    );
  }

  /// Section header for the paired layout.
  Widget _pairHeader() {
    return Padding(
      padding: const EdgeInsets.only(bottom: AppSpacing.sm),
      child: Row(children: [
        const Expanded(flex: 5, child: SizedBox()),
        Expanded(flex: 3, child: Text('AV-DEPOT', textAlign: TextAlign.right,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.accent, letterSpacing: 0.5))),
        const SizedBox(width: AppSpacing.lg),
        Expanded(flex: 3, child: Text('ETF-DEPOT', textAlign: TextAlign.right,
          style: TextStyle(fontSize: 9, fontWeight: FontWeight.w700, color: AppColors.etf, letterSpacing: 0.5))),
      ]),
    );
  }

  /// Paired row with formula annotations below each value.
  Widget _pairFormula(String label, String avVal, String etfVal, {String? avFormula, String? etfFormula, bool bold = false, String? tip}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 5),
      child: Column(children: [
        Row(children: [
          Expanded(flex: 5, child: Row(children: [
            Flexible(child: Text(label, style: TextStyle(fontSize: 10,
              color: AppColors.label, fontWeight: bold ? FontWeight.w700 : FontWeight.w400))),
            if (tip != null) ...[const SizedBox(width: AppSpacing.xs), InfoTip(tip, size: 12)],
          ])),
          Expanded(flex: 3, child: Text(avVal, textAlign: TextAlign.right,
            style: AppTheme.monoSmall.copyWith(fontSize: 10,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.text))),
          const SizedBox(width: AppSpacing.lg),
          Expanded(flex: 3, child: Text(etfVal, textAlign: TextAlign.right,
            style: AppTheme.monoSmall.copyWith(fontSize: 10,
              fontWeight: bold ? FontWeight.w800 : FontWeight.w600, color: AppColors.text))),
        ]),
        if (avFormula != null || etfFormula != null)
          Row(children: [
            const Expanded(flex: 5, child: SizedBox()),
            Expanded(flex: 3, child: Text(avFormula ?? '', textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 8, color: AppColors.muted, fontStyle: FontStyle.italic))),
            const SizedBox(width: AppSpacing.lg),
            Expanded(flex: 3, child: Text(etfFormula ?? '', textAlign: TextAlign.right,
              style: const TextStyle(fontSize: 8, color: AppColors.muted, fontStyle: FontStyle.italic))),
          ]),
      ]),
    );
  }

  Widget _h(String text, {Color? c}) => Padding(
    padding: const EdgeInsets.only(top: AppSpacing.lg, bottom: AppSpacing.sm),
    child: Text(text, style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: c ?? AppColors.text)),
  );

  Widget _dv() => const Divider(height: AppSpacing.xl);

  // ─── TAB 1: SAVINGS PHASE ──────────────────────────────────────

  Widget _savingsPhase(AppStrings s, PersonalScenario p, SubsidyBreakdown sub, List<SubsidyPhase> phases, double jbGef, double jbUngef, CostSettings costs, ETFResult etf, bool compact) {
    final jbTotal = jbGef + jbUngef;
    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pairHeader(),

      _h(s.bdContributions),
      _pairFormula(s.monthlySavings, Fmt.eur(p.sparrate), Fmt.eur(p.sparrate),
        avFormula: '× 12 = ${Fmt.eur(jbTotal)}/yr', etfFormula: '× 12 = ${Fmt.eur(p.jahresbeitrag)}/yr'),
      _pair('  ${s.tipGefoerdert.split(':')[0]}', Fmt.eur(jbGef), '—'),
      if (jbUngef > 0) _pair('  ${s.tipUngefoerdert.split(':')[0]}', Fmt.eur(jbUngef), '—'),
      _dv(),

      // ── SUBSIDY PHASES (year ranges) ──────────────────────
      ...phases.map((phase) {
        final fq = jbGef > 0 ? phase.total / jbGef : 0.0;
        return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
          _h('${s.bdSavingsYear(phase.yearFrom, phase.yearTo)} — ${s.bdChildrenEligible(phase.kinder)}'),
          if (phase.yearFrom == 1) _pairFormula(s.baseGrant, Fmt.eur(phase.grundzulage), '0 €', tip: s.tipGrundzulage,
            avFormula: '50% × min(${Fmt.eur(jbGef)}, €360) + 25% × rest', etfFormula: '')
          else _pair(s.baseGrant, Fmt.eur(phase.grundzulage), '0 €', tip: s.tipGrundzulage),
          _pair('${s.childGrant} (${phase.kinder})', Fmt.eur(phase.kinderzulage), '0 €', tip: s.tipKinderzulage),
          if (phase.bonus > 0) _pair(s.entryBonus, Fmt.eur(phase.bonus), '0 €', tip: s.tipBerufseinsteigerbonus),
          if (phase.geringverdienerbonus > 0) _pair(s.lowIncomeBonus, Fmt.eur(phase.geringverdienerbonus), '0 €', tip: s.tipGeringverdienerbonus),
          _pair(s.totalSubsidyYear, Fmt.eur(phase.total), '0 €', bold: true),
          _pair(s.subsidyRate, Fmt.pct(fq), '0,0 %'),
          if (phase.steuererstattung > 0) _pair(s.viaTaxOptimization, Fmt.eur(phase.steuererstattung), '—', tip: s.tipGuenstigerpruefung),
          _dv(),
        ]);
      }),

      _h(s.bdTaxCostsSavings),
      _pair(s.costAvPa.split(' p.')[0], Fmt.pct(costs.kostenAV), Fmt.pct(costs.kostenETF)),
      _pairFormula('Vorabpauschale', '—', Fmt.pct(CalcConstants.vorabpauschaleDrag), tip: s.tipVorabpauschale,
        avFormula: s.bdCapGainsSavingsAV, etfFormula: s.bdCapGainsSavingsETF),
      _pair(s.bdCapGainsSavings, s.bdCapGainsSavingsAV, s.bdCapGainsSavingsETF),
      _dv(),

      _h(s.bdAccumulated),
      _pairFormula(s.bdTotalContributions, Fmt.eur(jbTotal * p.spardauer), Fmt.eur(p.jahresbeitrag * p.spardauer),
        avFormula: '= ${Fmt.eur(jbTotal)} × ${p.spardauer} yr', etfFormula: '= ${Fmt.eur(p.jahresbeitrag)} × ${p.spardauer} yr'),
      _pair(s.bdTotalSubsidies, Fmt.eur(phases.fold<double>(0, (sum, ph) => sum + ph.total * ph.years)), '0 €'),
      _pair(s.bdTaxRefundTotal, Fmt.eur(phases.fold<double>(0, (sum, ph) => sum + ph.steuererstattung * ph.years)), '—'),
      _pair(s.bdIntoDepotYear, Fmt.eur(jbTotal + sub.total), Fmt.eur(p.jahresbeitrag)),
    ]);
  }

  // ─── TAB 2: PAYOUT PHASE ─────────────────────────────────────

  Widget _payoutPhase(AppStrings s, PersonalScenario p, AVResult av, ETFResult etf, CostSettings costs, double jbGef, double jbUngef, bool compact) {
    final auszDauer = p.auszahlungsDauer;
    final etfMonthlyGross = etf.endkapital / (auszDauer * 12);

    // ETF side: pension + other income is taxed via §32a regardless of depot type
    // This is the SAME for both — but AV payout is part of that income, ETF payout is not
    final pensionAndOther = p.gesetzlicheRente * 12 + p.sonstigeEinkuenfte;
    final avCombinedIncome = av.monatlicheAuszahlung * 12 + pensionAndOther;
    // Note: ETF investor pays the same income tax on pension+other as AV investor.
    // The depot-specific tax is what differs and is shown below.

    final avTaxPerMonth = av.monatlicheAuszahlung - av.nettoMonatlich;
    final etfTaxPerMonth = etf.steuerAufGewinn / (auszDauer * 12);

    return Column(crossAxisAlignment: CrossAxisAlignment.start, children: [
      _pairHeader(),

      _h(s.bdFinalCapital),
      _pairFormula(s.finalCapital, Fmt.eur(av.endkapital), Fmt.eur(etf.endkapital), bold: true,
        avFormula: '= ${Fmt.eur(av.eigenBeitraege)} + ${Fmt.eur(av.zulagenGesamt)} + ${Fmt.eur(av.wertzuwachs)}',
        etfFormula: '= ${Fmt.eur(etf.eigenBeitraege)} + ${Fmt.eur(etf.gewinn)}'),
      _pair(s.bdOwnContrib, Fmt.eur(av.eigenBeitraege), Fmt.eur(etf.eigenBeitraege)),
      _pair(s.bdSubsidiesReceived, Fmt.eur(av.zulagenGesamt), '0 €'),
      _pair(s.bdCapGains, Fmt.eur(av.wertzuwachs), Fmt.eur(etf.gewinn)),
      _pair(s.bdPurchasingPower, Fmt.eur(av.endkapitalReal), Fmt.eur(etf.endkapitalReal)),
      _dv(),

      _h(s.bdPayoutPerYear),
      _pair(s.bdPayoutPeriod, '$auszDauer yr (${p.rentenalter}–${CalcConstants.payoutEndAge})',
        '$auszDauer yr (${s.bdSamePeriod})'),
      _pairFormula(s.bdGrossPayoutYr, Fmt.eur(av.monatlicheAuszahlung * 12), Fmt.eur(etfMonthlyGross * 12),
        avFormula: '= ${Fmt.eur(av.endkapital)} ÷ $auszDauer',
        etfFormula: '= ${Fmt.eur(etf.endkapital)} ÷ $auszDauer'),
      _pair(s.bdStatePensionYr, Fmt.eur(p.gesetzlicheRente * 12), Fmt.eur(p.gesetzlicheRente * 12)),
      if (p.sonstigeEinkuenfte > 0) _pair(s.bdOtherIncomeYr, Fmt.eur(p.sonstigeEinkuenfte), Fmt.eur(p.sonstigeEinkuenfte)),
      _pair(s.bdTotalGrossYr, Fmt.eur(avCombinedIncome),
        Fmt.eur(etfMonthlyGross * 12 + pensionAndOther), bold: true),
      _dv(),

      _h(s.bdTaxationPerYear),
      _pairFormula(s.bdTaxMethod, s.bdTaxMethodAV, s.bdTaxMethodETF,
        avFormula: s.bdTaxMethodAvFormula, etfFormula: s.bdTaxMethodEtfFormula),
      _pairFormula(s.bdWhatTaxed, s.bdWhatTaxedAV, s.bdWhatTaxedETF,
        avFormula: s.bdWhatTaxedAvFormula, etfFormula: s.bdWhatTaxedEtfFormula,
        tip: s.tipTeilfreistellung),
      _pairFormula(s.bdEffectiveTaxRate,
        Fmt.pct(av.grenzsteuersatzRente), Fmt.pct(costs.abgeltungssteuersatz),
        avFormula: s.bdEffectiveTaxRateAvFormula(Fmt.eur(avCombinedIncome)),
        etfFormula: '${s.bdEffectiveTaxRateEtfFormula}${costs.kirchensteuer > 0 ? ' + KiSt' : ''}'),
      if (costs.kirchensteuer > 0) _pair(s.kirchensteuerLabel, '${(costs.kirchensteuer * 100).toStringAsFixed(0)}%', 'In rate'),
      _pairFormula(s.bdTaxOnPayoutYr,
        Fmt.eur(avTaxPerMonth * 12), Fmt.eur(etf.steuerAufGewinn / auszDauer),
        avFormula: '= payout ${Fmt.eur(av.monatlicheAuszahlung * 12)} × rate ${Fmt.pct(av.grenzsteuersatzRente)}',
        etfFormula: '= total tax ${Fmt.eur(etf.steuerAufGewinn)} ÷ $auszDauer yr'),
      if (jbUngef > 0) _pair(s.bdUngefTreatment, costs.ungefoerdertTax == UngefoerdertTaxMode.nachgelagert
        ? 'Full (BMF pending)' : costs.ungefoerdertTax == UngefoerdertTaxMode.ertragsanteil
          ? 'Ertragsanteil 17%' : 'Halbeinkünfte 50%', '—', tip: s.tipUngefoerdert),
      _dv(),

      _h(s.bdAfterTaxTotal(auszDauer)),
      _pairFormula(s.bdTotalTaxPaid,
        Fmt.eur(avTaxPerMonth * auszDauer * 12), Fmt.eur(etf.steuerAufGewinn), bold: true,
        avFormula: '= ${Fmt.eur(avTaxPerMonth * 12)}/yr × $auszDauer yr',
        etfFormula: '= ${Fmt.eur(etf.gewinn)} × 70% × ${Fmt.pct(costs.abgeltungssteuersatz)}'),
      _pairFormula(s.bdDepotAfterTax,
        Fmt.eur(av.nettoMonatlich * auszDauer * 12), Fmt.eur(etf.nachSteuer), bold: true,
        avFormula: '= ${Fmt.eur(av.endkapital)} − ${Fmt.eur(avTaxPerMonth * auszDauer * 12)}',
        etfFormula: '= ${Fmt.eur(etf.endkapital)} − ${Fmt.eur(etf.steuerAufGewinn)}'),
      _pair(s.bdContribTaxFree, s.bdContribTaxFreeAV, Fmt.eur(etf.eigenBeitraege)),
      _dv(),

      _h(s.bdMonthlyNet),
      _pair(s.bdGrossPerMonth, Fmt.eur(av.monatlicheAuszahlung), Fmt.eur(etfMonthlyGross)),
      _pairFormula(s.bdTaxPerMonth, Fmt.eur(avTaxPerMonth), Fmt.eur(etfTaxPerMonth),
        avFormula: '= ${Fmt.eur(av.monatlicheAuszahlung)}/mo × ${Fmt.pct(av.grenzsteuersatzRente)}',
        etfFormula: '= ${Fmt.eur(etf.steuerAufGewinn)} ÷ ${auszDauer * 12} mo'),
      _pair(s.bdNetPerMonth, Fmt.eur(av.nettoMonatlich), Fmt.eur(etf.monatlicheAuszahlung), bold: true),
    ]);
  }
}

// ═══════════════════════════════════════════════════════════════════
// STICKY FOOTER
// ═══════════════════════════════════════════════════════════════════

class _StickyFooter extends StatelessWidget {
  final AppStrings strings;

  const _StickyFooter({required this.strings});

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

