import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avdepot_rechner/config/theme.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/core/responsive/screen_layout.dart';
import 'package:avdepot_rechner/core/state/locale_cubit.dart';
import 'package:avdepot_rechner/shared/utils/fmt.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_cubit.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_state.dart';

class CompoundTable extends StatelessWidget {
  const CompoundTable({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final allResults = state.allMacroResults;
        final sub = state.subsidyBreakdown;
        final p = state.currentPerson;

        return Column(
          crossAxisAlignment: CrossAxisAlignment.stretch,
          children: [
            // Summary bar
            Container(
              padding: const EdgeInsets.symmetric(horizontal: AppSpacing.xl, vertical: 14),
              margin: const EdgeInsets.only(bottom: 10),
              decoration: BoxDecoration(
                color: AppColors.card,
                borderRadius: BorderRadius.circular(AppRadius.lg),
                border: Border.all(color: AppColors.border),
              ),
              child: _buildSummaryContent(context, s, p, sub),
            ),

            // Table (no selection)
            Container(
              decoration: BoxDecoration(
                borderRadius: BorderRadius.circular(AppRadius.card),
                border: Border.all(color: AppColors.border),
              ),
              child: LayoutBuilder(
                builder: (context, constraints) => SingleChildScrollView(
                scrollDirection: Axis.horizontal,
                child: ConstrainedBox(
                  constraints: BoxConstraints(minWidth: constraints.maxWidth),
                  child: DataTable(
                  columnSpacing: 10,
                  headingRowHeight: 28,
                  dataRowMinHeight: 40,
                  dataRowMaxHeight: 52,
                  showCheckboxColumn: false,
                  headingTextStyle: const TextStyle(fontSize: 9, fontWeight: FontWeight.w700,
                    color: AppColors.muted, letterSpacing: 0.3),
                  dataTextStyle: AppTheme.monoSmall.copyWith(fontSize: 10),
                  columns: [
                    DataColumn(label: Text(s.colScenario)),
                    DataColumn(label: Text(s.colReturn), numeric: true),
                    DataColumn(label: Text(s.colInflation), numeric: true),
                    DataColumn(label: Text(s.colRealReturn), numeric: true),
                    DataColumn(label: Text(s.colAvFinalCap), numeric: true),
                    DataColumn(label: Text(s.colPurchPower), numeric: true),
                    DataColumn(label: Text(s.colAvNetMo), numeric: true),
                    DataColumn(label: Text(s.colEtfFinalCap), numeric: true),
                    DataColumn(label: Text(s.colEtfNetMo), numeric: true),
                    DataColumn(label: Text(s.colDelta), numeric: true),
                    DataColumn(label: Text(s.colDeltaMo), numeric: true),
                  ],
                  rows: allResults.map((r) {
                    final isSel = r.macro.id == state.currentMacro.id;
                    final diff = r.deltaEndkapital;
                    final dmo = r.deltaMonatlich;
                    final color = isSel ? AppColors.accentLight : null;

                    return DataRow(
                      color: WidgetStateProperty.all(color),
                      cells: [
                        DataCell(Text('${r.macro.icon} ${r.macro.shortName}',
                          style: TextStyle(fontSize: 11, fontWeight: isSel ? FontWeight.w800 : FontWeight.w600,
                            fontFamily: 'DM Sans', color: isSel ? r.macro.color : AppColors.text))),
                        DataCell(Text(Fmt.pct(r.macro.rendite))),
                        DataCell(Text(Fmt.pct(r.macro.inflation))),
                        DataCell(Text(Fmt.pct(r.macro.realRendite),
                          style: TextStyle(fontWeight: FontWeight.w700))),
                        DataCell(Text(Fmt.eur(r.av.endkapital),
                          style: TextStyle(color: r.macro.color, fontWeight: FontWeight.w800, fontSize: 11))),
                        DataCell(Text(Fmt.eur(r.av.endkapitalReal),
                          style: const TextStyle(color: AppColors.muted))),
                        DataCell(Text(Fmt.eur(r.av.nettoMonatlich))),
                        DataCell(Text(Fmt.eur(r.etf.endkapital))),
                        DataCell(Text(Fmt.eur(r.etf.monatlicheAuszahlung))),
                        DataCell(Text(Fmt.signed(diff),
                          style: TextStyle(fontWeight: FontWeight.w800,
                            color: diff >= 0 ? AppColors.success : AppColors.danger))),
                        DataCell(Text(Fmt.signed(dmo),
                          style: TextStyle(color: dmo >= 0 ? AppColors.success : AppColors.danger))),
                      ],
                    );
                  }).toList(),
                ),
              ),
              ),
            ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildSummaryContent(BuildContext context, AppStrings s, dynamic p, dynamic sub) {
    final tags = [
      _tag(s.tagSavingsRate, '${Fmt.eur(p.sparrate)}${s.perMonth}', AppColors.accent),
      _tag(s.tagGross, Fmt.eur(p.brutto), null),
      _tag(s.tagChildren, '${p.kinder}', null),
      _tag(s.tagDuration, '${p.spardauer}${s.yearSuffix}', null),
      _tag(s.tagSubsidyYear, Fmt.eur(sub.total), AppColors.accent),
      _tag(s.tagSubsidyRate, Fmt.pct(sub.foerderquote), AppColors.accent),
      _tag(s.tagMargTax, Fmt.pct(sub.grenzsteuersatz), null),
    ];

    if (context.isCompact) {
      return Wrap(
        spacing: 16, runSpacing: 12,
        alignment: WrapAlignment.center,
        children: tags,
      );
    }

    return IntrinsicHeight(
      child: Row(
        children: _intersperse(
          tags.map((w) => Expanded(child: w)).toList(),
          VerticalDivider(width: 1, thickness: 1, color: AppColors.border),
        ),
      ),
    );
  }

  Widget _tag(String label, String value, Color? valueColor) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        Text(label.toUpperCase(), style: const TextStyle(
          fontSize: 9, fontWeight: FontWeight.w600, color: AppColors.muted, letterSpacing: 0.3)),
        const SizedBox(height: 4),
        Text(value, style: AppTheme.monoSmall.copyWith(
          fontWeight: FontWeight.w700, color: valueColor ?? AppColors.text)),
      ],
    );
  }

  List<Widget> _intersperse(List<Widget> items, Widget separator) {
    final result = <Widget>[];
    for (int i = 0; i < items.length; i++) {
      if (i > 0) result.add(separator);
      result.add(items[i]);
    }
    return result;
  }
}
