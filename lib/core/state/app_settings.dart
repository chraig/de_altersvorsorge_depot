import '../../features/calculator/cubit/calculator_cubit.dart';
import '../l10n/app_strings.dart';
import 'locale_cubit.dart';

/// Coordinates all app-level state holders.
class AppSettings {
  final LocaleCubit localeCubit;
  final CalculatorCubit calculatorCubit;

  AppSettings()
      : localeCubit = LocaleCubit(),
        calculatorCubit = CalculatorCubit(StringsEn());

  Future<void> initialize() async {
    // Load persisted settings here in the future
  }

  void dispose() {
    localeCubit.close();
    calculatorCubit.close();
  }
}
