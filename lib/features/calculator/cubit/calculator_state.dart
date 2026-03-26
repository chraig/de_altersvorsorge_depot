import 'package:flutter/material.dart';
import '../../../core/l10n/app_strings.dart';
import '../../../models/scenario.dart';
import '../../../services/domain/calculator_service.dart';

class CalculatorState {
  final List<PersonalScenario> personalScenarios;
  final List<MacroScenario> macroScenarios;
  final PersonalScenario currentPerson;
  final MacroScenario currentMacro;
  final CostSettings costs;
  final String? selectedPersonalScenarioId;
  final bool showAdvanced;
  final bool useCustomRendite;
  final double customRendite;
  final double customInflation;
  const CalculatorState({
    required this.personalScenarios,
    required this.macroScenarios,
    required this.currentPerson,
    required this.currentMacro,
    required this.costs,
    this.selectedPersonalScenarioId,
    this.showAdvanced = false,
    this.useCustomRendite = false,
    this.customRendite = 0.07,
    this.customInflation = 0.02,
  });

  // ─── COMPUTED GETTERS ─────────────────────────────────────────────

  double get effectiveRendite =>
      useCustomRendite ? customRendite : currentMacro.rendite;

  double get effectiveInflation =>
      useCustomRendite ? customInflation : currentMacro.inflation;

  MacroScenario effectiveMacro(AppStrings s) => useCustomRendite
      ? MacroScenario(
          name: s.customName,
          shortName: s.customShort,
          icon: '\u2699\uFE0F',
          description: s.customDesc,
          rendite: customRendite,
          inflation: customInflation,
          color: const Color(0xFF6B7280),
          isCustom: true,
        )
      : currentMacro;

  SubsidyBreakdown get subsidyBreakdown =>
      CalculatorService.calcSubsidyBreakdown(currentPerson);

  AVResult avResult(AppStrings s) => CalculatorService.simulateAV(
      person: currentPerson, macro: effectiveMacro(s), costs: costs);

  ETFResult etfResult(AppStrings s) => CalculatorService.simulateETF(
      person: currentPerson, macro: effectiveMacro(s), costs: costs);

  CombinedResult currentResult(AppStrings s) =>
      CombinedResult(macro: effectiveMacro(s), av: avResult(s), etf: etfResult(s));

  List<CombinedResult> get allMacroResults {
    final results = CalculatorService.simulateAllMacros(
        person: currentPerson, macros: macroScenarios, costs: costs);
    results.sort((a, b) =>
      b.macro.realRendite.compareTo(a.macro.realRendite));
    return results;
  }

  // ─── COPY WITH ────────────────────────────────────────────────────

  CalculatorState copyWith({
    List<PersonalScenario>? personalScenarios,
    List<MacroScenario>? macroScenarios,
    PersonalScenario? currentPerson,
    MacroScenario? currentMacro,
    CostSettings? costs,
    String? selectedPersonalScenarioId,
    bool clearSelectedPersonal = false,
    bool? showAdvanced,
    bool? useCustomRendite,
    double? customRendite,
    double? customInflation,
  }) {
    return CalculatorState(
      personalScenarios: personalScenarios ?? this.personalScenarios,
      macroScenarios: macroScenarios ?? this.macroScenarios,
      currentPerson: currentPerson ?? this.currentPerson,
      currentMacro: currentMacro ?? this.currentMacro,
      costs: costs ?? this.costs,
      selectedPersonalScenarioId: clearSelectedPersonal ? null : (selectedPersonalScenarioId ?? this.selectedPersonalScenarioId),
      showAdvanced: showAdvanced ?? this.showAdvanced,
      useCustomRendite: useCustomRendite ?? this.useCustomRendite,
      customRendite: customRendite ?? this.customRendite,
      customInflation: customInflation ?? this.customInflation,
    );
  }
}
