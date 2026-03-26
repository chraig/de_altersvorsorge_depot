import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_cubit.dart';
import 'package:avdepot_rechner/core/state/app_settings.dart';
import 'package:avdepot_rechner/core/state/locale_cubit.dart';

/// Wraps the app with all necessary BlocProviders.
class AppSettingsScope extends StatelessWidget {
  final AppSettings settings;
  final Widget child;

  const AppSettingsScope({
    super.key,
    required this.settings,
    required this.child,
  });

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider<LocaleCubit>.value(value: settings.localeCubit),
        BlocProvider<CalculatorCubit>.value(value: settings.calculatorCubit),
      ],
      child: child,
    );
  }

  static AppSettings of(BuildContext context) {
    final scope = context.findAncestorWidgetOfExactType<AppSettingsScope>();
    assert(scope != null, 'AppSettingsScope not found in widget tree');
    return scope!.settings;
  }
}
