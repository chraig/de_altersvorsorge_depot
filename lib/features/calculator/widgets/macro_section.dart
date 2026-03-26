import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme.dart';
import '../../../core/state/locale_cubit.dart';
import '../../../shared/utils/fmt.dart';
import '../../../models/scenario.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';

class MacroScenarioGrid extends StatelessWidget {
  const MacroScenarioGrid({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        return Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Wrap(
              spacing: 4, runSpacing: 4,
              children: [
                ...state.macroScenarios.map((m) => _MacroCard(
                  macro: m,
                  selected: state.currentMacro.id == m.id,
                )),
                _AddMacroCard(label: s.addMacroLabel),
              ],
            ),
          ],
        );
      },
    );
  }
}

class _MacroCard extends StatelessWidget {
  final MacroScenario macro;
  final bool selected;
  const _MacroCard({required this.macro, required this.selected});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => context.read<CalculatorCubit>().selectMacro(macro),
      onLongPress: () => showDialog(context: context,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CalculatorCubit>()),
            BlocProvider.value(value: context.read<LocaleCubit>()),
          ],
          child: MacroScenarioDialog(existing: macro),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: EdgeInsets.symmetric(horizontal: selected ? 9 : 10, vertical: selected ? 5 : 6),
        decoration: BoxDecoration(
          color: selected ? AppColors.accentLight : AppColors.card,
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(
            color: selected ? macro.color : AppColors.border,
            width: selected ? 2 : 1,
          ),
        ),
        child: Row(
          children: [
            Text(macro.icon, style: const TextStyle(fontSize: 14)),
            const SizedBox(width: 6),
            Expanded(
              child: Text(macro.shortName, style: TextStyle(fontSize: 13,
                fontWeight: FontWeight.w700,
                color: selected ? macro.color : AppColors.text),
                maxLines: 1, overflow: TextOverflow.ellipsis),
            ),
            Column(
              crossAxisAlignment: CrossAxisAlignment.end,
              children: [
                Text(Fmt.pct(macro.rendite), style: AppTheme.monoSmall.copyWith(
                  fontSize: 11, fontWeight: FontWeight.w700, color: selected ? macro.color : AppColors.label)),
                Text(Fmt.pct(macro.inflation), style: AppTheme.monoSmall.copyWith(
                  fontSize: 10, color: AppColors.muted)),
              ],
            ),
          ],
        ),
      ),
    );
  }

}

class _AddMacroCard extends StatelessWidget {
  final String label;
  const _AddMacroCard({required this.label});

  @override
  Widget build(BuildContext context) {
    return GestureDetector(
      onTap: () => showDialog(context: context,
        builder: (_) => MultiBlocProvider(
          providers: [
            BlocProvider.value(value: context.read<CalculatorCubit>()),
            BlocProvider.value(value: context.read<LocaleCubit>()),
          ],
          child: const MacroScenarioDialog(),
        ),
      ),
      child: Container(
        width: double.infinity,
        padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 8),
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppRadius.md),
          border: Border.all(color: AppColors.accent),
        ),
        child: Row(mainAxisAlignment: MainAxisAlignment.center, children: [
          const Icon(Icons.add, color: AppColors.accent, size: 14),
          const SizedBox(width: 4),
          Text(label, style: const TextStyle(fontSize: 12,
            fontWeight: FontWeight.w600, color: AppColors.accent)),
        ]),
      ),
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// MACRO SCENARIO DIALOG
// ═══════════════════════════════════════════════════════════════════

class MacroScenarioDialog extends StatefulWidget {
  final MacroScenario? existing;
  const MacroScenarioDialog({super.key, this.existing});

  @override
  State<MacroScenarioDialog> createState() => _MacroScenarioDialogState();
}

class _MacroScenarioDialogState extends State<MacroScenarioDialog> {
  late TextEditingController _name, _short, _icon, _desc, _rendite, _inflation;
  Color _color = AppColors.accent;

  static const _colors = [
    Color(0xFF10B981), Color(0xFF0066FF), Color(0xFFF59E0B),
    Color(0xFFEF4444), Color(0xFF8B5CF6), Color(0xFF6B7280),
    Color(0xFFEC4899), Color(0xFF06B6D4), Color(0xFF84CC16),
  ];

  @override
  void initState() {
    super.initState();
    final e = widget.existing;
    _name = TextEditingController(text: e?.name ?? '');
    _short = TextEditingController(text: e?.shortName ?? '');
    _icon = TextEditingController(text: e?.icon ?? '\uD83D\uDCC8');
    _desc = TextEditingController(text: e?.description ?? '');
    _rendite = TextEditingController(text: ((e?.rendite ?? 0.07) * 100).toStringAsFixed(1));
    _inflation = TextEditingController(text: ((e?.inflation ?? 0.02) * 100).toStringAsFixed(1));
    _color = e?.color ?? AppColors.accent;
  }

  @override
  void dispose() {
    for (final c in [_name, _short, _icon, _desc, _rendite, _inflation]) { c.dispose(); }
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final s = context.read<LocaleCubit>().state.strings;
    final isEdit = widget.existing != null;
    return AlertDialog(
      title: Text(isEdit ? s.editMacroScenario : s.newMacroScenarioTitle),
      content: SizedBox(
        width: 380,
        child: SingleChildScrollView(
          child: Column(mainAxisSize: MainAxisSize.min, children: [
            _field(s.fieldName, _name),
            _field(s.fieldShortName, _short),
            _field(s.fieldIcon, _icon),
            _field(s.fieldDescription, _desc, maxLines: 2),
            _field(s.fieldReturnPct, _rendite, num: true),
            _field(s.fieldInflationPct, _inflation, num: true),
            const SizedBox(height: 10),
            Align(alignment: Alignment.centerLeft,
              child: Text(s.fieldColor, style: const TextStyle(fontSize: 12, color: AppColors.label))),
            const SizedBox(height: 6),
            Wrap(spacing: AppSpacing.md, children: _colors.map((c) =>
              GestureDetector(
                onTap: () => setState(() => _color = c),
                child: Container(
                  width: 28, height: 28,
                  decoration: BoxDecoration(
                    color: c, shape: BoxShape.circle,
                    border: Border.all(color: _color == c ? AppColors.text : Colors.transparent, width: 2),
                  ),
                ),
              )).toList()),
          ]),
        ),
      ),
      actions: [
        if (isEdit) TextButton(
          onPressed: () {
            context.read<CalculatorCubit>().removeMacroScenario(widget.existing!.id);
            Navigator.pop(context);
          },
          child: Text(s.deleteBtn, style: const TextStyle(color: AppColors.danger)),
        ),
        TextButton(onPressed: () => Navigator.pop(context), child: Text(s.cancelBtn)),
        ElevatedButton(onPressed: _save, child: Text(isEdit ? s.saveBtn : s.addBtn)),
      ],
    );
  }

  Widget _field(String label, TextEditingController c, {bool num = false, int maxLines = 1}) {
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: TextField(
        controller: c, maxLines: maxLines,
        keyboardType: num ? const TextInputType.numberWithOptions(decimal: true) : TextInputType.text,
        decoration: InputDecoration(labelText: label, isDense: true),
      ),
    );
  }

  void _save() {
    final cubit = context.read<CalculatorCubit>();
    final scenario = MacroScenario(
      id: widget.existing?.id,
      name: _name.text,
      shortName: _short.text.isEmpty ? _name.text : _short.text,
      icon: _icon.text,
      description: _desc.text,
      rendite: (double.tryParse(_rendite.text) ?? 7) / 100,
      inflation: (double.tryParse(_inflation.text) ?? 2) / 100,
      color: _color,
      isCustom: true,
    );
    if (widget.existing != null) {
      cubit.updateMacroScenario(widget.existing!.id, scenario);
    } else {
      cubit.addMacroScenario(scenario);
    }
    Navigator.pop(context);
  }
}
