import 'package:flutter/material.dart';
import '../../config/theme.dart';

extension ScreenLayoutX on BuildContext {
  double get screenWidth => MediaQuery.sizeOf(this).width;

  /// Phone-sized screens (< 700dp)
  bool get isCompact => screenWidth < AppBreakpoints.medium;

  /// Tablet and larger (>= 700dp)
  bool get isExpanded => screenWidth >= AppBreakpoints.medium;
}
