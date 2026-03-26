import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import 'config/theme.dart';
import 'core/routes/router.dart';
import 'core/state/app_settings.dart';
import 'core/state/app_settings_scope.dart';
import 'core/state/locale_cubit.dart';

void main() async {
  WidgetsFlutterBinding.ensureInitialized();

  final appSettings = AppSettings();
  await appSettings.initialize();

  final router = createRouter();

  runApp(
    AppSettingsScope(
      settings: appSettings,
      child: AVDepotApp(router: router),
    ),
  );
}

class AVDepotApp extends StatelessWidget {
  final GoRouter router;

  const AVDepotApp({super.key, required this.router});

  @override
  Widget build(BuildContext context) {
    final s = context.watch<LocaleCubit>().state.strings;
    return MaterialApp.router(
      title: '${s.appTitle} - ${s.calculatorBadge}',
      debugShowCheckedModeBanner: false,
      theme: AppTheme.theme,
      routerConfig: router,
    );
  }
}
