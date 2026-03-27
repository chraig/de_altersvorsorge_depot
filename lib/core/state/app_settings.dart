import 'package:avdepot_rechner/features/calculator/cubit/calculator_cubit.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/core/state/locale_cubit.dart';

/// Coordinates all app-level state holders.
class AppSettings {
  final LocaleCubit localeCubit;
  final CalculatorCubit calculatorCubit;

  AppSettings()
      : localeCubit = LocaleCubit(),
        calculatorCubit = CalculatorCubit(StringsDe());

  Future<void> initialize() async {}

  void dispose() {
    localeCubit.close();
    calculatorCubit.close();
  }
}
