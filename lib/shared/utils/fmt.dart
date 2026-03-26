import 'package:intl/intl.dart';

class Fmt {
  static final _eurFmt = NumberFormat.currency(locale: 'de_DE', symbol: '\u20AC', decimalDigits: 0);
  static final _eurFmt2 = NumberFormat.currency(locale: 'de_DE', symbol: '\u20AC', decimalDigits: 2);
  static final _numFmt = NumberFormat('#,##0', 'de_DE');

  static String eur(double v) => _eurFmt.format(v);
  static String eur2(double v) => _eurFmt2.format(v);
  static String num0(double v) => _numFmt.format(v);
  static String pct(double v) => '${(v * 100).toStringAsFixed(1)} %';
  static String pct0(double v) => '${(v * 100).toStringAsFixed(0)} %';

  static String eurK(double v) {
    if (v.abs() >= 1000000) return '${(v / 1000000).toStringAsFixed(1)}M \u20AC';
    if (v.abs() >= 10000) return '${(v / 1000).toStringAsFixed(0)}k \u20AC';
    return eur(v);
  }

  static String signed(double v) => v >= 0 ? '+${eur(v)}' : eur(v);
}
