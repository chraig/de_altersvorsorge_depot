import 'package:flutter/material.dart';
import 'package:fl_chart/fl_chart.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import '../../../config/theme.dart';
import '../../../core/state/locale_cubit.dart';
import '../../../shared/utils/fmt.dart';
import '../cubit/calculator_cubit.dart';
import '../cubit/calculator_state.dart';

// ═══════════════════════════════════════════════════════════════════
// MACRO OVERLAY CHART: all macros + selected ETF
// ═══════════════════════════════════════════════════════════════════

class MacroOverlayChart extends StatelessWidget {
  const MacroOverlayChart({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final cubit = context.read<CalculatorCubit>();
        final allResults = state.allMacroResults;
        final selected = state.currentMacro;
        final etfSel = state.etfResult(s);

        final allSpots = <LineChartBarData>[];

        for (final r in allResults) {
          final isSel = r.macro.id == selected.id;
          allSpots.add(LineChartBarData(
            spots: r.av.jahresWerte.map((d) => FlSpot(d.year.toDouble(), d.depot)).toList(),
            isCurved: true, curveSmoothness: 0.2,
            color: r.macro.color.withValues(alpha: isSel ? 1.0 : AppOpacity.muted),
            barWidth: isSel ? 3 : 1.5, isStrokeCapRound: true,
            dotData: FlDotData(show: false),
            belowBarData: isSel ? BarAreaData(show: true, color: r.macro.color.withValues(alpha: AppOpacity.overlay)) : BarAreaData(show: false),
          ));
        }

        allSpots.add(LineChartBarData(
          spots: etfSel.jahresWerte.map((d) => FlSpot(d.year.toDouble(), d.depot)).toList(),
          isCurved: true, curveSmoothness: 0.2,
          color: selected.color.withValues(alpha: AppOpacity.half),
          barWidth: 2, dashArray: [6, 4],
          dotData: FlDotData(show: false),
        ));

        final maxY = allResults.fold<double>(0, (m, r) =>
          r.av.jahresWerte.last.depot > m ? r.av.jahresWerte.last.depot : m) * 1.1;
        final maxX = state.currentPerson.spardauer.toDouble();

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.panel),
                    topRight: Radius.circular(AppRadius.panel)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.chartAllMacrosTitle,
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.label)),
                    const SizedBox(height: 4),
                    Wrap(spacing: 8, runSpacing: 3, children: [
                      ...state.macroScenarios.map((m) => GestureDetector(
                        onTap: () => cubit.selectMacro(m),
                        child: Row(mainAxisSize: MainAxisSize.min, children: [
                          Container(width: 8, height: 2, decoration: BoxDecoration(
                            color: m.color.withValues(alpha: m.id == selected.id ? 1.0 : 0.4),
                            borderRadius: BorderRadius.circular(1))),
                          const SizedBox(width: 3),
                          Text('${m.icon} ${m.shortName}', style: TextStyle(fontSize: 10,
                            color: m.id == selected.id ? m.color : AppColors.muted,
                            fontWeight: m.id == selected.id ? FontWeight.w700 : FontWeight.w400)),
                        ]),
                      )),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 12),
                child: SizedBox(
                  height: AppDimensions.chartHeight,
                  child: LineChart(LineChartData(
                    lineBarsData: allSpots,
                    minX: 1, maxX: maxX, minY: 0, maxY: maxY,
                    gridData: FlGridData(
                      show: true, drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 22, interval: (maxX / 5).ceilToDouble(),
                        getTitlesWidget: (v, _) => Text('${v.toInt()}${s.yearSuffix}',
                          style: AppTheme.monoSmall.copyWith(fontSize: 9, color: AppColors.muted)),
                      )),
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 48, interval: maxY / 4,
                        getTitlesWidget: (v, _) => Text(Fmt.eurK(v),
                          style: AppTheme.monoSmall.copyWith(fontSize: 9, color: AppColors.muted)),
                      )),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots.map((sp) =>
                          LineTooltipItem(Fmt.eur(sp.y), AppTheme.monoSmall.copyWith(
                            fontSize: 10, color: sp.bar.color ?? AppColors.text))
                        ).toList(),
                      ),
                    ),
                  )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}

// ═══════════════════════════════════════════════════════════════════
// AV vs ETF COMPARISON CHART
// ═══════════════════════════════════════════════════════════════════

class ComparisonChart extends StatelessWidget {
  const ComparisonChart({super.key});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return BlocBuilder<CalculatorCubit, CalculatorState>(
      builder: (context, state) {
        final av = state.avResult(s);
        final etf = state.etfResult(s);
        final allResults = state.allMacroResults;
        final selected = state.currentMacro;
        final macro = state.effectiveMacro(s);

        final lines = <LineChartBarData>[];

        for (final r in allResults) {
          if (r.macro.id == selected.id) continue;
          lines.add(LineChartBarData(
            spots: r.av.jahresWerte.map((d) => FlSpot(d.year.toDouble(), d.depot)).toList(),
            isCurved: true, curveSmoothness: 0.2,
            color: r.macro.color.withValues(alpha: AppOpacity.faded),
            barWidth: 1, dotData: FlDotData(show: false),
          ));
        }

        lines.add(LineChartBarData(
          spots: av.jahresWerte.map((d) => FlSpot(d.year.toDouble(), d.depot)).toList(),
          isCurved: true, curveSmoothness: 0.2,
          color: macro.color, barWidth: 2.5,
          dotData: FlDotData(show: false),
          belowBarData: BarAreaData(show: true, color: macro.color.withValues(alpha: AppOpacity.overlay)),
        ));

        lines.add(LineChartBarData(
          spots: etf.jahresWerte.map((d) => FlSpot(d.year.toDouble(), d.depot)).toList(),
          isCurved: true, curveSmoothness: 0.2,
          color: AppColors.etf, barWidth: 2,
          dotData: FlDotData(show: false),
        ));

        final maxY = [av.endkapital, etf.endkapital,
          ...allResults.map((r) => r.av.endkapital)].reduce((a, b) => a > b ? a : b) * 1.1;
        final maxX = state.currentPerson.spardauer.toDouble();

        return Container(
          decoration: BoxDecoration(
            borderRadius: BorderRadius.circular(AppRadius.panel),
            border: Border.all(color: AppColors.border),
          ),
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Container(
                padding: const EdgeInsets.fromLTRB(16, 12, 16, 6),
                decoration: const BoxDecoration(
                  color: AppColors.card,
                  borderRadius: BorderRadius.only(
                    topLeft: Radius.circular(AppRadius.panel),
                    topRight: Radius.circular(AppRadius.panel)),
                ),
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(s.chartWealthTitle(macro.icon, macro.name),
                      style: const TextStyle(fontSize: 12, fontWeight: FontWeight.w700, color: AppColors.label)),
                    const SizedBox(height: 4),
                    Row(children: [
                      Container(width: 8, height: 2, decoration: BoxDecoration(
                        color: macro.color, borderRadius: BorderRadius.circular(1))),
                      const SizedBox(width: 3),
                      Text(s.avDepotLabel, style: TextStyle(fontSize: 10, color: macro.color)),
                      const SizedBox(width: 10),
                      Container(width: 8, height: 2, decoration: BoxDecoration(
                        color: AppColors.etf, borderRadius: BorderRadius.circular(1))),
                      const SizedBox(width: 3),
                      Text(s.etfLabel, style: const TextStyle(fontSize: 10, color: AppColors.etf)),
                      const SizedBox(width: 10),
                      Container(width: 8, height: 2, color: AppColors.muted.withValues(alpha: 0.3)),
                      const SizedBox(width: 3),
                      Text(s.otherScenarios, style: const TextStyle(fontSize: 10, color: AppColors.muted)),
                    ]),
                  ],
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(8, 0, 16, 12),
                child: SizedBox(
                  height: AppDimensions.comparisonChartHeight,
                  child: LineChart(LineChartData(
                    lineBarsData: lines,
                    minX: 1, maxX: maxX, minY: 0, maxY: maxY,
                    gridData: FlGridData(
                      show: true, drawVerticalLine: false,
                      horizontalInterval: maxY / 4,
                      getDrawingHorizontalLine: (_) => FlLine(color: AppColors.border, strokeWidth: 0.5),
                    ),
                    titlesData: FlTitlesData(
                      topTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      rightTitles: const AxisTitles(sideTitles: SideTitles(showTitles: false)),
                      bottomTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 22, interval: (maxX / 5).ceilToDouble(),
                        getTitlesWidget: (v, _) => Text('${v.toInt()}${s.yearSuffix}',
                          style: AppTheme.monoSmall.copyWith(fontSize: 9, color: AppColors.muted)),
                      )),
                      leftTitles: AxisTitles(sideTitles: SideTitles(
                        showTitles: true, reservedSize: 48, interval: maxY / 4,
                        getTitlesWidget: (v, _) => Text(Fmt.eurK(v),
                          style: AppTheme.monoSmall.copyWith(fontSize: 9, color: AppColors.muted)),
                      )),
                    ),
                    borderData: FlBorderData(show: false),
                    lineTouchData: LineTouchData(
                      touchTooltipData: LineTouchTooltipData(
                        getTooltipItems: (spots) => spots.where((sp) => (sp.bar.color?.a ?? 0) > 0.3).map((sp) =>
                          LineTooltipItem(Fmt.eur(sp.y), AppTheme.monoSmall.copyWith(
                            fontSize: 10, color: sp.bar.color ?? AppColors.text))
                        ).toList(),
                      ),
                    ),
                  )),
                ),
              ),
            ],
          ),
        );
      },
    );
  }
}
