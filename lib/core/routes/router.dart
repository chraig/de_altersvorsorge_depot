import 'package:flutter/material.dart';
import 'package:go_router/go_router.dart';
import '../../features/calculator/pages/calculator_page.dart';

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
    errorBuilder: (context, state) => Scaffold(
      body: Center(
        child: Text('Seite nicht gefunden: ${state.uri}'),
      ),
    ),
  );
}
