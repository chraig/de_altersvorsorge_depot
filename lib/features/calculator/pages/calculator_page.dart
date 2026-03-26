import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../core/state/locale_cubit.dart';
import '../../../models/scenario.dart';
import '../../../shared/utils/fmt.dart';
import '../../../shared/widgets/common.dart';
import '../widgets/input_panel.dart';
import '../widgets/macro_section.dart';
import '../widgets/charts.dart';
import '../widgets/compound_table.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';

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

        return Scaffold(
          body: SingleChildScrollView(
            child: Center(
              child: ConstrainedBox(
                constraints: const BoxConstraints(maxWidth: AppDimensions.maxContentWidth),
                child: Padding(
                  padding: AppPadding.page,
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.stretch,
                    children: [
                      // ─── HEADER + LANGUAGE TOGGLE ───────────
                      const SizedBox(height: AppSpacing.section),
                      Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          const Spacer(),
                          Text(s.calculatorBadge,
                            style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700,
                              color: AppColors.accent, letterSpacing: 2)),
                          const Spacer(),
                          _LanguageToggle(
                            locale: localeCubit.state.locale,
                            onToggle: localeCubit.toggle,
                          ),
                        ],
                      ),
                      const SizedBox(height: AppSpacing.md),
                      Center(child: Text(s.appTitle,
                        style: Theme.of(context).textTheme.headlineLarge)),
                      Center(child: Text(s.appSubtitle,
                        style: const TextStyle(fontSize: 17, fontWeight: FontWeight.w500,
                          color: AppColors.muted))),
                      const SizedBox(height: 10),
                      Center(child: ConstrainedBox(
                        constraints: const BoxConstraints(maxWidth: 520),
                        child: Text(s.appDescription,
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12, color: AppColors.muted, height: 1.5),
                        ),
                      )),
                      const SizedBox(height: AppSpacing.xxxl),

                      // ─── PERSONAL SCENARIOS ──────────────────
                      SectionDivider(s.sectionPersonalScenarios),
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
                                Container(
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
                                ),
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
                            onPressed: () => cubit.resetToDefaults(s),
                            icon: const Icon(Icons.refresh, size: 14),
                            label: Text(s.resetAll, style: const TextStyle(fontSize: 11)),
                          ),
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

  // ─── FOERDERUNG BOX ─────────────────────────────────────────────

  Widget _buildSubsidyTable(AppStrings s, SubsidyBreakdown sub, MacroScenario macro) {
    final rows = <(String, String)>[
      (s.baseGrant, Fmt.eur(sub.grundzulage)),
      (s.childGrant, Fmt.eur(sub.kinderzulage)),
      if (sub.bonus > 0) (s.entryBonus, Fmt.eur(sub.bonus)),
      (s.totalSubsidyYear, Fmt.eur(sub.total)),
      (s.subsidyRate, Fmt.pct(sub.foerderquote)),
      if (sub.steuererstattung > 0) ('${s.taxRefundYear} (${s.viaTaxOptimization})', Fmt.eur(sub.steuererstattung)),
      (s.marginalTaxRate, Fmt.pct(sub.grenzsteuersatz)),
    ];
    return Container(
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
        const ComparisonChart(),
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
      ],
    );
  }

  // ─── DETAIL TAB ────────────────────────────────────────────────

  Widget _buildDetail(AppStrings s, AVResult av) {
    return Column(
      crossAxisAlignment: CrossAxisAlignment.stretch,
      children: [
        Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.md, children: [
          StatCard(label: s.finalCapital, value: Fmt.eur(av.endkapital), accent: true),
          StatCard(label: s.purchasingPowerToday, value: Fmt.eur(av.endkapitalReal), sub: s.inflationAdjusted),
        ]),
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
              MiniBar(label: s.taxRefundLabel, value: av.steuererstattungGesamt,
                maxValue: av.endkapital, color: AppColors.success, valueText: Fmt.eur(av.steuererstattungGesamt)),
              MiniBar(label: s.capitalGainsLabel, value: av.wertzuwachs,
                maxValue: av.endkapital, color: AppColors.etf, valueText: Fmt.eur(av.wertzuwachs)),
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
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// LANGUAGE TOGGLE
// ═══════════════════════════════════════════════════════════════════

class _LanguageToggle extends StatelessWidget {
  final AppLocale locale;
  final VoidCallback onToggle;

  const _LanguageToggle({required this.locale, required this.onToggle});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onToggle,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 3),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Row(mainAxisSize: MainAxisSize.min, children: [
          Text(locale == AppLocale.en ? 'EN' : 'DE',
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w700, color: AppColors.accent)),
          const SizedBox(width: 3),
          const Icon(Icons.language, size: 13, color: AppColors.accent),
        ]),
      ),
    );
  }
}

