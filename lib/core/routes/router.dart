import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:go_router/go_router.dart';
import '../../features/calculator/pages/calculator_page.dart';
import '../state/locale_cubit.dart';

GoRouter createRouter() {
  return GoRouter(
    initialLocation: '/',
    routes: [
      GoRoute(
        path: '/',
        name: 'calculator',
        builder: (context, state) => const CalculatorPage(),
      ),
    ],
    errorBuilder: (context, state) {
      final s = context.read<LocaleCubit>().state.strings;
      return Scaffold(
        body: Center(
          child: Text(s.pageNotFound(state.uri.toString())),
        ),
      );
    },
  );
}
