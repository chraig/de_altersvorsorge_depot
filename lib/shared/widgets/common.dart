import 'package:flutter/material.dart';
import 'package:avdepot_rechner/config/theme.dart';

class StatCard extends StatelessWidget {
  final String label;
  final String value;
  final String? sub;
  final bool accent;

  const StatCard({super.key, required this.label, required this.value, this.sub, this.accent = false});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.card,
      decoration: BoxDecoration(
        color: accent ? AppColors.accent : AppColors.card,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: accent ? null : Border.all(color: AppColors.border),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(),
            style: TextStyle(fontSize: 10, fontWeight: FontWeight.w700,
              letterSpacing: 0.5, color: accent ? Colors.white70 : AppColors.muted)),
          const SizedBox(height: AppSpacing.sm),
          Text(value, style: AppTheme.mono.copyWith(
            fontSize: 17, fontWeight: FontWeight.w800,
            color: accent ? Colors.white : AppColors.text)),
          if (sub != null) ...[
            const SizedBox(height: AppSpacing.xs),
            Text(sub!, style: TextStyle(fontSize: 11,
              color: accent ? Colors.white60 : AppColors.muted)),
          ],
        ],
      ),
    );
  }
}

class MiniBar extends StatelessWidget {
  final String label;
  final double value;
  final double maxValue;
  final Color color;
  final String valueText;

  const MiniBar({super.key, required this.label, required this.value,
    required this.maxValue, required this.color, required this.valueText});

  @override
  Widget build(BuildContext context) {
    final pct = maxValue > 0 ? (value / maxValue).clamp(0.0, 1.0) : 0.0;
    return Padding(
      padding: const EdgeInsets.only(bottom: 10),
      child: Column(
        children: [
          Row(
            mainAxisAlignment: MainAxisAlignment.spaceBetween,
            children: [
              Text(label, style: const TextStyle(fontSize: 12, color: AppColors.muted)),
              Text(valueText, style: AppTheme.monoSmall.copyWith(fontWeight: FontWeight.w700)),
            ],
          ),
          const SizedBox(height: AppSpacing.sm),
          ClipRRect(
            borderRadius: BorderRadius.circular(AppRadius.xs),
            child: LinearProgressIndicator(
              value: pct,
              minHeight: AppDimensions.progressBarHeight,
              backgroundColor: AppColors.border,
              color: color,
            ),
          ),
        ],
      ),
    );
  }
}

class SectionDivider extends StatelessWidget {
  final String label;
  const SectionDivider(this.label, {super.key});

  @override
  Widget build(BuildContext context) {
    return Padding(
      padding: AppPadding.section,
      child: Row(
        children: [
          const Expanded(child: Divider()),
          Padding(
            padding: const EdgeInsets.symmetric(horizontal: AppSpacing.lg),
            child: Text(label.toUpperCase(),
              style: const TextStyle(fontSize: 11, fontWeight: FontWeight.w700,
                color: AppColors.muted, letterSpacing: 1.2)),
          ),
          const Expanded(child: Divider()),
        ],
      ),
    );
  }
}

class ComparisonBar extends StatelessWidget {
  final String label;
  final double avValue;
  final double etfValue;
  final String avText;
  final String etfText;
  final String avLabel;
  final String etfLabel;

  const ComparisonBar({super.key, required this.label, required this.avValue,
    required this.etfValue, required this.avText, required this.etfText,
    required this.avLabel, required this.etfLabel});

  @override
  Widget build(BuildContext context) {
    final mx = [avValue, etfValue, 1.0].reduce((a, b) => a > b ? a : b);
    return Padding(
      padding: const EdgeInsets.only(bottom: 14),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(label.toUpperCase(), style: const TextStyle(fontSize: 11,
            fontWeight: FontWeight.w600, color: AppColors.muted, letterSpacing: 0.3)),
          const SizedBox(height: 6),
          _bar(avLabel, avValue, mx, AppColors.accent, avText, avValue >= etfValue),
          const SizedBox(height: AppSpacing.sm),
          _bar(etfLabel, etfValue, mx, AppColors.etf, etfText, etfValue >= avValue),
        ],
      ),
    );
  }

  Widget _bar(String tag, double val, double mx, Color color, String text, bool leading) {
    final pct = mx > 0 ? (val / mx).clamp(0.0, 1.0) : 0.0;
    return Row(
      children: [
        SizedBox(width: 72, child: Text(tag, textAlign: TextAlign.right,
          style: TextStyle(fontSize: 11, fontWeight: FontWeight.w700, color: color))),
        const SizedBox(width: AppSpacing.md),
        Expanded(
          child: Stack(
            children: [
              Container(height: AppDimensions.barHeight, decoration: BoxDecoration(
                color: AppColors.border, borderRadius: BorderRadius.circular(AppRadius.sm))),
              FractionallySizedBox(
                widthFactor: pct,
                child: Container(height: AppDimensions.barHeight, decoration: BoxDecoration(
                  color: color, borderRadius: BorderRadius.circular(AppRadius.sm))),
              ),
              Positioned(right: 6, top: 3,
                child: Text(text, style: AppTheme.monoSmall.copyWith(
                  fontSize: 11, fontWeight: FontWeight.w700,
                  color: leading ? Colors.white : AppColors.text))),
            ],
          ),
        ),
      ],
    );
  }
}

/// Generic chip group for toggling between a fixed set of options.
class AppChipGroup<T> extends StatelessWidget {
  final T value;
  final List<(T, String)> options;
  final ValueChanged<T> onChanged;

  const AppChipGroup({super.key, required this.value, required this.options, required this.onChanged});

  @override
  Widget build(BuildContext context) {
    return Wrap(spacing: AppSpacing.md, runSpacing: AppSpacing.sm, children: [
      for (final (optValue, label) in options)
        _chip(label, optValue),
    ]);
  }

  Widget _chip(String label, T chipValue) {
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

/// Small info icon that shows a tooltip on hover (desktop) or long-press (mobile).
class InfoTip extends StatelessWidget {
  final String message;
  final double size;

  const InfoTip(this.message, {super.key, this.size = 14});

  @override
  Widget build(BuildContext context) {
    return Tooltip(
      message: message,
      preferBelow: false,
      padding: const EdgeInsets.all(AppSpacing.lg),
      margin: const EdgeInsets.symmetric(horizontal: AppSpacing.xl),
      textStyle: const TextStyle(fontSize: 11, color: AppColors.text, height: 1.4),
      decoration: BoxDecoration(
        color: AppColors.bg,
        borderRadius: BorderRadius.circular(AppRadius.md),
        border: Border.all(color: AppColors.border),
        boxShadow: [BoxShadow(color: AppColors.text.withValues(alpha: 0.08), blurRadius: 8, offset: const Offset(0, 2))],
      ),
      waitDuration: const Duration(milliseconds: 300),
      showDuration: const Duration(seconds: 10),
      child: Icon(Icons.info_outline, size: size, color: AppColors.muted),
    );
  }
}

class ResultBanner extends StatelessWidget {
  final bool positive;
  final String title;
  final String subtitle;

  const ResultBanner({super.key, required this.positive, required this.title, required this.subtitle});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: AppPadding.card,
      margin: const EdgeInsets.only(bottom: AppSpacing.xl),
      decoration: BoxDecoration(
        color: positive ? AppColors.successBg : AppColors.dangerBg,
        borderRadius: BorderRadius.circular(AppRadius.card),
        border: Border.all(color: positive ? AppColors.successBorder : AppColors.dangerBorder),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: positive ? AppColors.successText : AppColors.dangerText)),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: TextStyle(fontSize: 12,
            color: positive ? AppColors.successTextLight : AppColors.dangerTextLight)),
        ],
      ),
    );
  }
}
