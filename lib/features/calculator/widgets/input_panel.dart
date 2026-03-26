import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme.dart';
import '../../../core/state/locale_cubit.dart';
import '../../../shared/utils/fmt.dart';
import '../../../models/scenario.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';

// ═══════════════════════════════════════════════════════════════════
// PERSONAL SCENARIO BAR
// ═══════════════════════════════════════════════════════════════════

class PersonalScenarioBar extends StatelessWidget {
  const PersonalScenarioBar({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            ...state.personalScenarios.map((sc) => Padding(
              padding: const EdgeInsets.only(bottom: 4),
              child: _ScenarioChip(scenario: sc),
            )),
            _AddChip(label: s.addScenario, onTap: () => _showAddDialog(context)),
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
  const _ScenarioChip({required this.scenario});

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
        padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
        decoration: BoxDecoration(
          color: AppColors.card,
          borderRadius: BorderRadius.circular(6),
          border: Border.all(color: AppColors.border),
        ),
        child: Text('${scenario.icon} ${scenario.name}',
          style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.label)),
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
// INPUT PANEL
// ═══════════════════════════════════════════════════════════════════

class InputPanel extends StatelessWidget {
  const InputPanel({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final cubit = context.read<CalculatorCubit>();
        final p = state.currentPerson;

        return Container(
          padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
          decoration: BoxDecoration(
            color: AppColors.card,
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            children: [
              AppSlider(label: s.monthlySavings, value: p.sparrate,
                min: 10, max: 300, step: 5, display: Fmt.eur(p.sparrate),
                onChanged: cubit.setSparrate, hint: s.hintSubsidized),
              AppSlider(label: s.grossAnnualSalary, value: p.brutto,
                min: 12000, max: 120000, step: 1000, display: Fmt.eur(p.brutto),
                onChanged: cubit.setBrutto),
              AppSlider(label: s.numberOfChildren, value: p.kinder.toDouble(),
                min: 0, max: 5, step: 1, display: '${p.kinder}',
                onChanged: (v) => cubit.setKinder(v.round()),
                hint: s.hintChildSubsidy),
              AppSlider(label: s.startingAge, value: p.alterStart.toDouble(),
                min: 18, max: 60, step: 1, display: '${p.alterStart}',
                onChanged: (v) => cubit.setAlterStart(v.round())),
              AppSlider(label: s.savingsDuration, value: p.spardauer.toDouble(),
                min: 5, max: 45, step: 1, display: s.yearsLabel(p.spardauer),
                onChanged: (v) => cubit.setSpardauer(v.round()),
                hint: s.retirementAgeHint(p.rentenalter)),

              GestureDetector(
                onTap: cubit.toggleAdvanced,
                child: Padding(
                  padding: const EdgeInsets.only(top: AppSpacing.sm),
                  child: Row(children: [
                    Icon(state.showAdvanced ? Icons.expand_less : Icons.expand_more,
                      size: 16, color: AppColors.accent),
                    const SizedBox(width: AppSpacing.sm),
                    Text(s.advancedSettings,
                      style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w600, color: AppColors.accent)),
                  ]),
                ),
              ),

              if (state.showAdvanced) ...[
                const Padding(padding: EdgeInsets.symmetric(vertical: AppSpacing.lg), child: Divider()),
                AppSlider(label: s.returnPa, value: state.effectiveRendite,
                  min: 0.01, max: 0.14, step: 0.005, display: Fmt.pct(state.effectiveRendite),
                  onChanged: cubit.setCustomRendite),
                AppSlider(label: s.costAvPa, value: state.costs.kostenAV,
                  min: 0.001, max: 0.015, step: 0.001, display: Fmt.pct(state.costs.kostenAV),
                  onChanged: cubit.setKostenAV, hint: s.hintCostCap),
                AppSlider(label: s.costEtfPa, value: state.costs.kostenETF,
                  min: 0.001, max: 0.01, step: 0.001, display: Fmt.pct(state.costs.kostenETF),
                  onChanged: cubit.setKostenETF, hint: s.hintTypicalCost),
                AppSlider(label: s.inflationPa, value: state.effectiveInflation,
                  min: 0.005, max: 0.06, step: 0.005, display: Fmt.pct(state.effectiveInflation),
                  onChanged: cubit.setCustomInflation),
              ],
            ],
          ),
        );
      },
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
          SizedBox(
            height: 28,
            child: Slider(
              value: value.clamp(min, max), min: min, max: max,
              divisions: ((max - min) / step).round(),
              onChanged: onChanged,
            ),
          ),
          if (hint != null) Align(
            alignment: Alignment.centerLeft,
            child: Padding(
              padding: const EdgeInsets.only(bottom: 2),
              child: Text(hint!, style: const TextStyle(fontSize: 9, color: AppColors.muted)),
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
