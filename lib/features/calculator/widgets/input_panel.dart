import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avdepot_rechner/config/theme.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/core/responsive/screen_layout.dart';
import 'package:avdepot_rechner/core/state/locale_cubit.dart';
import 'package:avdepot_rechner/shared/utils/fmt.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_cubit.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_state.dart';

// ═══════════════════════════════════════════════════════════════════
// PERSONAL SCENARIO BAR
// ═══════════════════════════════════════════════════════════════════

class PersonalScenarioBar extends StatelessWidget {
  const PersonalScenarioBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    final compact = context.isCompact;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final chips = state.personalScenarios.map((sc) => _ScenarioChip(
          scenario: sc,
          selected: state.selectedPersonalScenarioId == sc.id,
        )).toList();
        final addChip = _AddChip(label: s.addScenario, onTap: () => _showAddDialog(context));

        if (compact) {
          return Wrap(
            spacing: 6, runSpacing: 6,
            children: [...chips, addChip],
          );
        }
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...chips.map((c) => Padding(padding: const EdgeInsets.only(bottom: 4), child: c)),
            addChip,
          ],
        );
      },
    );
  }

  void _showAddDialog(BuildContext context) {
    showDialog(context: context, builder: (_) =>
      MultiBlocProvider(
        providers: [
          BlocProvider.value(value: context.read<CalculatorCubit>()),
          BlocProvider.value(value: context.read<LocaleCubit>()),
        ],
        child: const PersonScenarioDialog(),
      ),
    );
  }
}

class _ScenarioChip extends StatelessWidget {
  final PersonalScenario scenario;
  final bool selected;
  const _ScenarioChip({required this.scenario, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<CalculatorCubit>().applyPersonalScenario(scenario),
      onLongPress: () => showDialog(context: context,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CalculatorCubit>()),
            BlocProvider.value(value: context.read<LocaleCubit>()),
          ],
          child: PersonScenarioDialog(existing: scenario),
        ),
      ),
      child: Container(
        padding: EdgeInsets.symmetric(horizontal: selected ? 7 : 8, vertical: selected ? 3 : 4),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLight : AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(
            color: selected ? AppColors.accent : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Text('${scenario.icon} ${scenario.name}',
          style: TextStyle(fontSize: 11, fontWeight: selected ? FontWeight.w800 : FontWeight.w600,
            color: selected ? AppColors.accent : AppColors.label)),
      ),
    );
  }
}

class _AddChip extends StatelessWidget {
  final String label;
  final VoidCallback onTap;
  const _AddChip({required this.label, required this.onTap});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: onTap,
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.accent),
        ),
        child: Text(label,
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// INPUT PANEL (3-tab layout)
// ═══════════════════════════════════════════════════════════════════

class InputPanel extends StatefulWidget {
  const InputPanel({super.key});

  @override
  State<InputPanel> createState() => _InputPanelState();
}

class _InputPanelState extends State<InputPanel> with TickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 3, vsync: this);
    _tabController.addListener(() => setState(() {}));
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final cubit = context.read<CalculatorCubit>();
        final p = state.currentPerson;

        return Container(
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              // ─── TAB BAR ────────────────────────────────────────
              Container(
                decoration: const BoxDecoration(
                  border: Border(bottom: BorderSide(color: AppColors.border)),
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.panel),
                    topRight: Radius.circular(AppRadius.panel)),
                ),
                child: TabBar(
                  controller: _tabController,
                  labelColor: Colors.white,
                  unselectedLabelColor: AppColors.muted,
                  labelStyle: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700),
                  indicator: BoxDecoration(
                    color: AppColors.accent,
                    borderRadius: _tabController.index == 0
                        ? const BorderRadius.only(topLeft: Radius.circular(AppRadius.panel), bottomRight: Radius.circular(AppRadius.chip))
                        : _tabController.index == 2
                            ? const BorderRadius.only(topRight: Radius.circular(AppRadius.panel), bottomLeft: Radius.circular(AppRadius.chip))
                            : BorderRadius.circular(AppRadius.chip),
                  ),
                  indicatorSize: TabBarIndicatorSize.tab,
                  dividerHeight: 0,
                  tabs: [
                    Tab(text: s.tabPersonal),
                    Tab(text: s.tabCostsTax),
                    Tab(text: s.tabIncomeScenarios),
                  ],
                ),
              ),

              // ─── TAB CONTENT ────────────────────────────────────
              Padding(
                padding: const EdgeInsets.fromLTRB(16, 14, 16, 14),
                child: _buildTabContent(s, state, cubit, p),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabContent(AppStrings s, CalculatorState state, CalculatorCubit cubit, PersonalScenario p) {
    switch (_tabController.index) {
      case 0: return _buildPersonalTab(s, cubit, p);
      case 1: return _buildCostsTaxTab(s, state, cubit);
      case 2: return _buildIncomeTab(s, state, cubit, p);
      default: return const SizedBox.shrink();
    }
  }

  // ─── TAB 1: PERSONAL ──────────────────────────────────────────

  Widget _buildPersonalTab(AppStrings s, CalculatorCubit cubit, PersonalScenario p) {
    return Column(children: [
      AppSlider(label: s.monthlySavings, value: p.sparrate,
        min: 10, max: 570, step: 5, display: Fmt.eur(p.sparrate),
        onChanged: cubit.setSparrate, hint: s.hintMonthlySavings),
      AppSlider(label: s.grossAnnualSalary, value: p.brutto,
        min: 12000, max: 250000, step: 1000, display: Fmt.eur(p.brutto),
        onChanged: cubit.setBrutto, hint: s.hintGrossSalary),
      AppSlider(label: s.numberOfChildren, value: p.kinder.toDouble(),
        min: 0, max: 5, step: 1, display: '${p.kinder}',
        onChanged: (v) => cubit.setKinder(v.round()),
        hint: s.hintChildren),
      ...List.generate(p.kinder, (i) {
        final age = i < p.kinderAlter.length ? p.kinderAlter[i] : 0;
        return AppSlider(
          label: s.childAgeLabel(i),
          value: age.toDouble(),
          min: 0, max: 24, step: 1,
          display: '$age',
          onChanged: (v) => cubit.setChildAge(i, v.round()),
          hint: s.hintChildAge,
        );
      }),
      AppSlider(label: s.startingAge, value: p.alterStart.toDouble(),
        min: 18, max: 60, step: 1, display: '${p.alterStart}',
        onChanged: (v) => cubit.setAlterStart(v.round()),
        hint: s.hintStartingAge),
      AppSlider(label: s.retirementAge, value: p.rentenalter.toDouble(),
        min: 60, max: 75, step: 1, display: '${p.rentenalter}',
        onChanged: (v) => cubit.setRetirementAge(v.round()),
        hint: '${s.derivedDuration(p.spardauer)} • ${s.payoutDurationHint(p.auszahlungsDauer)}'),
      AppSlider(label: s.statePensionMonthly, value: p.gesetzlicheRente,
        min: 0, max: 3500, step: 50, display: Fmt.eur(p.gesetzlicheRente),
        onChanged: cubit.setGesetzlicheRenteOverride,
        hint: s.hintDerivedPension(Fmt.eur(p.geschaetzteRente))),
      AppSlider(label: s.otherRetirementIncome, value: p.sonstigeEinkuenfte,
        min: 0, max: 50000, step: 500, display: Fmt.eur(p.sonstigeEinkuenfte),
        onChanged: cubit.setSonstigeEinkuenfte, hint: s.hintOtherIncome),
      AppSlider(label: s.workStartAge, value: p.arbeitsbeginn.toDouble(),
        min: 14, max: 35, step: 1, display: '${p.arbeitsbeginn}',
        onChanged: (v) => cubit.setArbeitsbeginn(v.round()),
        hint: s.hintWorkStartAge),
    ]);
  }

  // ─── TAB 2: COSTS & TAX ──────────────────────────────────────

  Widget _buildCostsTaxTab(AppStrings s, CalculatorState state, CalculatorCubit cubit) {
    return Column(children: [
      AppSlider(label: s.returnPa, value: state.effectiveRendite,
        min: 0.01, max: 0.14, step: 0.005, display: Fmt.pct(state.effectiveRendite),
        onChanged: cubit.setCustomRendite, hint: s.hintReturn),
      AppSlider(label: s.costAvPa, value: state.costs.kostenAV,
        min: 0.001, max: 0.015, step: 0.001, display: Fmt.pct(state.costs.kostenAV),
        onChanged: cubit.setKostenAV, hint: s.hintCostAv),
      AppSlider(label: s.costEtfPa, value: state.costs.kostenETF,
        min: 0.001, max: 0.01, step: 0.001, display: Fmt.pct(state.costs.kostenETF),
        onChanged: cubit.setKostenETF, hint: s.hintCostEtf),
      AppSlider(label: s.inflationPa, value: state.effectiveInflation,
        min: 0.005, max: 0.06, step: 0.005, display: Fmt.pct(state.effectiveInflation),
        onChanged: cubit.setCustomInflation, hint: s.hintInflation),
      const Divider(height: AppSpacing.xxxl),
      _KirchensteuerToggle(
        value: state.costs.kirchensteuer,
        onChanged: cubit.setKirchensteuer,
      ),
      const Divider(height: AppSpacing.xxxl),
      _UngefoerdertTaxToggle(
        value: state.costs.ungefoerdertTax,
        onChanged: cubit.setUngefoerdertTaxMode,
      ),
    ]);
  }

  // ─── TAB 3: INCOME SCENARIOS ──────────────────────────────────

  Widget _buildIncomeTab(AppStrings s, CalculatorState state, CalculatorCubit cubit, PersonalScenario p) {
    return _IncomeScenarioPanel(
      settings: state.incomeDev,
      spardauer: p.spardauer,
      cubit: cubit,
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// REUSABLE SLIDER
// ═══════════════════════════════════════════════════════════════════

class AppSlider extends StatelessWidget {
  final String label;
  final double value;
  final double min;
  final double max;
  final double step;
  final String display;
  final ValueChanged<double> onChanged;
  final String? hint;

  const AppSlider({super.key, required this.label, required this.value,
    required this.min, required this.max, required this.step,
    required this.display, required this.onChanged, this.hint});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 4),
      child: Column(
        mainAxisSize: MainAxisSize.min,
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Flexible(child: Text(label.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: AppColors.label, letterSpacing: 0.3))),
              Text(display, style: AppTheme.monoAccent.copyWith(fontSize: 13)),
            ],
          ),
          if (hint != null) Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(top: 1),
              child: Text(hint!, style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.3)),
            ),
          ),
          SizedBox(
            height: 28,
            child: Slider(
              value: value.clamp(min, max), min: min, max: max,
              divisions: ((max - min) / step).round(),
              onChanged: onChanged,
            ),
          ),
        ],
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// PERSONAL SCENARIO DIALOG
// ═══════════════════════════════════════════════════════════════════

class PersonScenarioDialog extends StatefulWidget {
  final PersonalScenario? existing;
  const PersonScenarioDialog({super.key, this.existing});

  @override
  State<PersonScenarioDialog> createState() => _PersonScenarioDialogState();
}

class _PersonScenarioDialogState extends State<PersonScenarioDialog> {
  late final TextEditingController _name, _icon, _sr, _br, _ki, _al, _du;

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    final s = context.read<LocaleCubit>().state.strings;
    _name = TextEditingController(text: e?.name ?? s.defaultScenarioName);
    _icon = TextEditingController(text: e?.icon ?? '\uD83E\uDDD1');
    _sr = TextEditingController(text: (e?.sparrate ?? 100).toStringAsFixed(0));
    _br = TextEditingController(text: (e?.brutto ?? 45000).toStringAsFixed(0));
    _ki = TextEditingController(text: (e?.kinder ?? 0).toString());
    _al = TextEditingController(text: (e?.alterStart ?? 30).toString());
    _du = TextEditingController(text: (e?.spardauer ?? 35).toString());
  }

  @override
  void dispose() {
    for (final c in [_name, _icon, _sr, _br, _ki, _al, _du]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<LocaleCubit>().state.strings;
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? s.editScenario : s.newScenarioTitle),
      content: SizedBox(
        width: 340,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(s.fieldName, _name),
            _field(s.fieldIcon, _icon),
            _field(s.fieldSavingsRate, _sr, num: true),
            _field(s.fieldGrossSalary, _br, num: true),
            _field(s.fieldChildren, _ki, num: true),
            _field(s.fieldStartAge, _al, num: true),
            _field(s.fieldDuration, _du, num: true),
          ]),
        ),
      ),
      actions: [
        if (isEdit) TextButton(
          onPressed: () {
            context.read<CalculatorCubit>().removePersonalScenario(widget.existing!.id);
            Navigator.pop(context);
          },
          child: Text(s.deleteBtn, style: const TextStyle(color: AppColors.danger)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancelBtn)),
        ElevatedButton(onPressed: _save, child: Text(isEdit ? s.saveBtn : s.addBtn)),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, {bool num = false}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c,
        keyboardType: num ? TextInputType.number : TextInputType.text,
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }

  void _save() {
    final cubit = context.read<CalculatorCubit>();
    final scenario = PersonalScenario(
      id: widget.existing?.id,
      name: _name.text,
      icon: _icon.text,
      sparrate: double.tryParse(_sr.text) ?? 100,
      brutto: double.tryParse(_br.text) ?? 45000,
      kinder: int.tryParse(_ki.text) ?? 0,
      alterStart: int.tryParse(_al.text) ?? 30,
      spardauer: int.tryParse(_du.text) ?? 35,
      isCustom: true,
    );
    if (widget.existing != null) {
      cubit.updatePersonalScenario(widget.existing!.id, scenario);
    } else {
      cubit.addPersonalScenario(scenario);
    }
    Navigator.pop(context);
  }
}

// ═══════════════════════════════════════════════════════════════════
// KIRCHENSTEUER TOGGLE
// ═══════════════════════════════════════════════════════════════════

class _KirchensteuerToggle extends StatelessWidget {
  final double value;
  final ValueChanged<double> onChanged;

  const _KirchensteuerToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = context.read<LocaleCubit>().state.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.kirchensteuerLabel.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            color: AppColors.label, letterSpacing: 0.3)),
        const SizedBox(height: AppSpacing.sm),
        Row(
          children: [
            _chip(s.kirchensteuerNone, 0.0),
            const SizedBox(width: AppSpacing.md),
            _chip(s.kirchensteuerBayBw, 0.08),
            const SizedBox(width: AppSpacing.md),
            _chip(s.kirchensteuerOther, 0.09),
          ],
        ),
      ],
    );
  }

  Widget _chip(String label, double chipValue) {
    final selected = value == chipValue;
    return GestureDetector(
      onTap: () => onChanged(chipValue),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.label)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// UNGEFÖRDERT TAX TOGGLE
// ═══════════════════════════════════════════════════════════════════

class _UngefoerdertTaxToggle extends StatelessWidget {
  final UngefoerdertTaxMode value;
  final ValueChanged<UngefoerdertTaxMode> onChanged;

  const _UngefoerdertTaxToggle({required this.value, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    final s = context.read<LocaleCubit>().state.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        Text(s.ungefoerdertTaxLabel.toUpperCase(),
          style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
            color: AppColors.label, letterSpacing: 0.3)),
        Text(s.hintUngefoerdertTax,
          style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.3)),
        const SizedBox(height: AppSpacing.sm),
        Row(children: [
          _taxChip(s.ungefoerdertTaxNachgelagert, UngefoerdertTaxMode.nachgelagert),
          const SizedBox(width: AppSpacing.md),
          _taxChip(s.ungefoerdertTaxErtragsanteil, UngefoerdertTaxMode.ertragsanteil),
          const SizedBox(width: AppSpacing.md),
          Flexible(child: _taxChip(s.ungefoerdertTaxHalbeinkunfte, UngefoerdertTaxMode.halbeinkunfte)),
        ]),
      ],
    );
  }

  Widget _taxChip(String label, UngefoerdertTaxMode mode) {
    final selected = value == mode;
    return GestureDetector(
      onTap: () => onChanged(mode),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.label)),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// INCOME SCENARIO PANEL
// ═══════════════════════════════════════════════════════════════════

class _IncomeScenarioPanel extends StatelessWidget {
  final IncomeDevSettings settings;
  final int spardauer;
  final CalculatorCubit cubit;

  const _IncomeScenarioPanel({
    required this.settings,
    required this.spardauer,
    required this.cubit,
  });

  @override
  Widget build(BuildContext context) {
    final s = context.read<LocaleCubit>().state.strings;
    return Column(
      crossAxisAlignment: CrossAxisAlignment.start,
      children: [
        // ─── MAIN TOGGLE ────────────────────────────────────────
        Row(
          children: [
            Transform.scale(scale: AppDimensions.switchScale, child: Switch(
              value: settings.enabled,
              onChanged: (_) => cubit.toggleIncomeDev(),
              activeThumbColor: AppColors.accent,
              activeTrackColor: AppColors.accentLight,
            )),
            const SizedBox(width: AppSpacing.sm),
            Expanded(child: Text(s.incomeDevToggle.toUpperCase(),
              style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                color: AppColors.label, letterSpacing: 0.3))),
          ],
        ),
        Text(s.hintIncomeDev,
          style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.3)),

        if (settings.enabled) ...[
          const SizedBox(height: AppSpacing.xl),

          // ─── GROWTH CURVE SELECTOR ────────────────────────────
          Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.sm, children: [
            _curveChip(s.curveLinear, GrowthCurve.linear),
            _curveChip(s.curveStepwise, GrowthCurve.stepwise),
            _curveChip(s.curveLogarithmic, GrowthCurve.logarithmic),
          ]),
          const SizedBox(height: AppSpacing.lg),

          // ─── CURVE-SPECIFIC PARAMS ────────────────────────────
          if (settings.curve == GrowthCurve.linear)
            AppSlider(label: s.incomeDevGrowthRate, value: settings.growthRate,
              min: 0.0, max: 0.08, step: 0.005, display: Fmt.pct(settings.growthRate),
              onChanged: cubit.setIncomeGrowthRate,
              hint: s.hintGrowthLinear),

          if (settings.curve == GrowthCurve.stepwise) ...[
            AppSlider(label: s.promotionInterval, value: settings.promotionInterval.toDouble(),
              min: 1, max: 15, step: 1, display: '${settings.promotionInterval} yr',
              onChanged: (v) => cubit.setPromotionInterval(v.round()),
              hint: s.hintPromotionInterval),
            AppSlider(label: s.promotionIncrease, value: settings.promotionIncrease,
              min: 0.05, max: 0.50, step: 0.05, display: Fmt.pct(settings.promotionIncrease),
              onChanged: cubit.setPromotionIncrease,
              hint: s.hintPromotionIncrease),
          ],

          if (settings.curve == GrowthCurve.logarithmic) ...[
            AppSlider(label: s.salaryCap, value: settings.salaryCap,
              min: 40000, max: 200000, step: 5000, display: Fmt.eur(settings.salaryCap),
              onChanged: cubit.setSalaryCap,
              hint: s.hintSalaryCap),
          ],

          // ─── PART-TIME PHASE ──────────────────────────────────
          const Divider(height: AppSpacing.xxxl),
          Row(
            children: [
              Transform.scale(scale: AppDimensions.switchScale, child: Switch(
                value: settings.hasPartTime,
                onChanged: (v) {
                  if (v) {
                    cubit.setPartTimeStartYear(5);
                    cubit.setPartTimeDuration(3);
                  } else {
                    cubit.setPartTimeStartYear(null);
                  }
                },
                activeThumbColor: AppColors.accent,
                activeTrackColor: AppColors.accentLight,
              )),
              const SizedBox(width: AppSpacing.sm),
              Expanded(child: Text(s.partTimeToggle.toUpperCase(),
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
                  color: AppColors.label, letterSpacing: 0.3))),
            ],
          ),
          Text(s.hintPartTime,
            style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.3)),
          if (settings.hasPartTime) ...[
            const SizedBox(height: AppSpacing.lg),
            AppSlider(label: s.partTimeStart, value: (settings.partTimeStartYear ?? 5).toDouble(),
              min: 0, max: (spardauer - 1).toDouble().clamp(1, 45), step: 1,
              display: '${settings.partTimeStartYear ?? 5}',
              onChanged: (v) => cubit.setPartTimeStartYear(v.round()),
              hint: s.hintPartTimeStart),
            AppSlider(label: s.partTimeDuration, value: settings.partTimeDuration.toDouble(),
              min: 1, max: 10, step: 1, display: '${settings.partTimeDuration} yr',
              onChanged: (v) => cubit.setPartTimeDuration(v.round()),
              hint: s.hintPartTimeDuration),
            AppSlider(label: s.partTimePercent, value: settings.partTimePercent,
              min: 0.2, max: 0.8, step: 0.1, display: Fmt.pct(settings.partTimePercent),
              onChanged: cubit.setPartTimePercent,
              hint: s.hintPartTimePercent),
          ],

          // ─── CHILD ARRIVAL TIMING ─────────────────────────────
          const Divider(height: AppSpacing.xxxl),
          Text(s.childTimingLabel.toUpperCase(),
            style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600,
              color: AppColors.label, letterSpacing: 0.3)),
          Text(s.hintChildTiming,
            style: const TextStyle(fontSize: 9, color: AppColors.muted, height: 1.3)),
          const SizedBox(height: AppSpacing.md),
          ...settings.childArrivalYears.asMap().entries.map((e) =>
            Padding(
              padding: const EdgeInsets.only(bottom: AppSpacing.sm),
              child: Row(
                children: [
                  Expanded(
                    child: AppSlider(
                      label: '${s.childTimingLabel} ${e.key + 1}',
                      value: e.value.toDouble(),
                      min: 0, max: (spardauer - 1).toDouble().clamp(1, 45), step: 1,
                      display: s.childArrivalLabel(e.value),
                      onChanged: (v) => cubit.updateChildArrivalYear(e.key, v.round()),
                    ),
                  ),
                  GestureDetector(
                    onTap: () => cubit.removeChildArrivalYear(e.key),
                    child: const Padding(
                      padding: EdgeInsets.only(left: AppSpacing.sm),
                      child: Icon(Icons.close, size: 16, color: AppColors.danger),
                    ),
                  ),
                ],
              ),
            ),
          ),
          GestureDetector(
            onTap: () => cubit.addChildArrivalYear(
              settings.childArrivalYears.isEmpty ? 3 : (settings.childArrivalYears.last + 3).clamp(0, spardauer - 1)),
            child: Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 6),
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.chip),
                border: Border.all(color: AppColors.accent),
              ),
              child: Text(s.addChildBtn,
                style: const TextStyle(fontSize: 10, fontWeight: FontWeight.w600, color: AppColors.accent)),
            ),
          ),
        ],
      ],
    );
  }

  Widget _curveChip(String label, GrowthCurve curve) {
    final selected = settings.curve == curve;
    return GestureDetector(
      onTap: () => cubit.setGrowthCurve(curve),
      child: Container(
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 5),
        decoration: BoxDecoration(
          color: selected ? AppColors.accent : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.chip),
          border: Border.all(color: selected ? AppColors.accent : AppColors.border),
        ),
        child: Text(label, style: TextStyle(
          fontSize: 11, fontWeight: FontWeight.w600,
          color: selected ? Colors.white : AppColors.label)),
      ),
    );
  }
}
