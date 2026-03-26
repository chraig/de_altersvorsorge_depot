import 'package:flutter/material.dart';
import '../../config/theme.dart';

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
    this.avLabel = 'AV-Depot', this.etfLabel = 'ETF-Depot'});

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
        border: Border.all(color: positive ? const Color(0xFFA7F3D0) : const Color(0xFFFECACA)),
      ),
      child: Column(
        crossAxisAlignment: CrossAxisAlignment.start,
        children: [
          Text(title, style: TextStyle(fontSize: 14, fontWeight: FontWeight.w700,
            color: positive ? const Color(0xFF065F46) : const Color(0xFF991B1B))),
          const SizedBox(height: AppSpacing.sm),
          Text(subtitle, style: TextStyle(fontSize: 12,
            color: positive ? const Color(0xFF047857) : const Color(0xFFB91C1C))),
        ],
      ),
    );
  }
}
