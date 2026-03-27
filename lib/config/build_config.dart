import 'package:flutter/foundation.dart';

class BuildConfig {
  const BuildConfig._();

  static bool get isDebug => kDebugMode;
  static bool get isProfile => kProfileMode;
  static bool get isRelease => kReleaseMode;

  static bool get allowDebugFeatures => isDebug;
  static bool get showDevTools => isDebug || isProfile;

  static const String appName = 'AV-Depot Rechner 2027';
  static const String appVersion = '1.1.0';

  // ─── IMPRESSUM (edit once, used by both EN and DE) ──────────
  static const String ownerName = 'Christoph Aigner';
  static const String postalAddress = 'Bernhard-Becker-Str. 24, 60389 Frankfurt, Deutschland';
  static const String email = 'aignerratio@gmail.com';
  static const String copyrightYear = '2026';
}
