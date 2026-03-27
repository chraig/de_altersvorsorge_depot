import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';
import 'package:avdepot_rechner/models/scenario.dart';
import 'package:avdepot_rechner/features/calculator/cubit/calculator_state.dart';

class CalculatorCubit extends Cubit<CalculatorState> {
  CalculatorCubit(AppStrings strings)
      : super(_initialState(strings));

  static CalculatorState _initialState(AppStrings s) {
    final persons = PersonalScenario.defaults(s);
    final macros = MacroScenario.defaults(s);
    final starter = persons[0]; // Career Starter
    return CalculatorState(
      personalScenarios: persons,
      macroScenarios: macros,
      currentPerson: starter.copyWith(),
      selectedPersonalScenarioId: starter.id,
      currentMacro: macros[1], // Baseline
      costs: CostSettings(),
    );
  }

  // ─── SCENARIO SELECTION ───────────────────────────────────────────

  void applyPersonalScenario(PersonalScenario s) {
    emit(state.copyWith(
      currentPerson: state.currentPerson.copyWith(
        sparrate: s.sparrate,
        brutto: s.brutto,
        kinder: s.kinder,
        alterStart: s.alterStart,
        spardauer: s.spardauer,
        clearRenteOverride: true,
        sonstigeEinkuenfte: s.sonstigeEinkuenfte,
      ),
      selectedPersonalScenarioId: s.id,
    ));
  }

  void selectMacro(MacroScenario m) {
    emit(state.copyWith(currentMacro: m, useCustomRendite: false));
  }

  // ─── INPUT SETTERS ────────────────────────────────────────────────

  void setSparrate(double v) {
    emit(state.copyWith(currentPerson: state.currentPerson.copyWith(sparrate: v), clearSelectedPersonal: true));
  }

  void setBrutto(double v) {
    emit(state.copyWith(currentPerson: state.currentPerson.copyWith(brutto: v), clearSelectedPersonal: true));
  }

  void setKinder(int v) {
    emit(state.copyWith(currentPerson: state.currentPerson.copyWith(kinder: v), clearSelectedPersonal: true));
  }

  void setAlterStart(int v) {
    final retirementAge = state.currentPerson.rentenalter;
    final newSpardauer = (retirementAge - v).clamp(5, 45);
    emit(state.copyWith(
      currentPerson: state.currentPerson.copyWith(alterStart: v, spardauer: newSpardauer),
      clearSelectedPersonal: true,
    ));
  }

  void setRetirementAge(int v) {
    final newSpardauer = (v - state.currentPerson.alterStart).clamp(5, 45);
    emit(state.copyWith(
      currentPerson: state.currentPerson.copyWith(spardauer: newSpardauer),
      clearSelectedPersonal: true,
    ));
  }

  void setKostenAV(double v) {
    emit(state.copyWith(costs: state.costs.copyWith(kostenAV: v)));
  }

  void setKostenETF(double v) {
    emit(state.copyWith(costs: state.costs.copyWith(kostenETF: v)));
  }

  void setCustomRendite(double v) {
    emit(state.copyWith(customRendite: v, useCustomRendite: true));
  }

  void setCustomInflation(double v) {
    emit(state.copyWith(customInflation: v, useCustomRendite: true));
  }

  void setGesetzlicheRenteOverride(double v) {
    emit(state.copyWith(currentPerson: state.currentPerson.copyWith(gesetzlicheRenteOverride: v), clearSelectedPersonal: true));
  }

  void clearGesetzlicheRenteOverride() {
    emit(state.copyWith(currentPerson: state.currentPerson.copyWith(clearRenteOverride: true), clearSelectedPersonal: true));
  }

  void setSonstigeEinkuenfte(double v) {
    emit(state.copyWith(currentPerson: state.currentPerson.copyWith(sonstigeEinkuenfte: v), clearSelectedPersonal: true));
  }

  void setKirchensteuer(double v) {
    emit(state.copyWith(costs: state.costs.copyWith(kirchensteuer: v)));
  }

  void toggleIncomeDev() {
    emit(state.copyWith(incomeDev: state.incomeDev.copyWith(enabled: !state.incomeDev.enabled)));
  }

  void setIncomeGrowthRate(double v) {
    emit(state.copyWith(incomeDev: state.incomeDev.copyWith(growthRate: v)));
  }

  void toggleAdvanced() {
    emit(state.copyWith(showAdvanced: !state.showAdvanced));
  }

  // ─── SCENARIO MANAGEMENT ─────────────────────────────────────────

  void addPersonalScenario(PersonalScenario s) {
    emit(state.copyWith(personalScenarios: [...state.personalScenarios, s]));
  }

  void updatePersonalScenario(String id, PersonalScenario updated) {
    final list = state.personalScenarios.map((s) => s.id == id ? updated : s).toList();
    emit(state.copyWith(personalScenarios: list));
  }

  void removePersonalScenario(String id) {
    emit(state.copyWith(
      personalScenarios: state.personalScenarios.where((s) => s.id != id).toList(),
    ));
  }

  void addMacroScenario(MacroScenario s) {
    emit(state.copyWith(macroScenarios: [...state.macroScenarios, s]));
  }

  void updateMacroScenario(String id, MacroScenario updated) {
    final list = state.macroScenarios.map((s) => s.id == id ? updated : s).toList();
    final currentMacro = state.currentMacro.id == id ? updated : state.currentMacro;
    emit(state.copyWith(macroScenarios: list, currentMacro: currentMacro));
  }

  void removeMacroScenario(String id) {
    final remaining = state.macroScenarios.where((s) => s.id != id).toList();
    final currentMacro = state.currentMacro.id == id && remaining.isNotEmpty
        ? remaining.first
        : state.currentMacro;
    emit(state.copyWith(macroScenarios: remaining, currentMacro: currentMacro));
  }

  void updateLocale(AppStrings strings) {
    final defaultPersonal = PersonalScenario.defaults(strings);
    final defaultMacro = MacroScenario.defaults(strings);

    final updatedPersonal = state.personalScenarios.map((s) {
      if (s.isCustom) return s;
      final idx = state.personalScenarios.indexOf(s);
      if (idx < defaultPersonal.length) {
        return s..name = defaultPersonal[idx].name;
      }
      return s;
    }).toList();

    final updatedMacro = state.macroScenarios.map((s) {
      if (s.isCustom) return s;
      final idx = state.macroScenarios.indexOf(s);
      if (idx < defaultMacro.length) {
        final d = defaultMacro[idx];
        s.name = d.name;
        s.shortName = d.shortName;
        s.description = d.description;
      }
      return s;
    }).toList();

    // Update currentMacro if it's a default
    final currentMacroIdx = state.macroScenarios.indexWhere((m) => m.id == state.currentMacro.id);
    final updatedCurrentMacro = currentMacroIdx >= 0 ? updatedMacro[currentMacroIdx] : state.currentMacro;

    emit(state.copyWith(
      personalScenarios: updatedPersonal,
      macroScenarios: updatedMacro,
      currentMacro: updatedCurrentMacro,
    ));
  }

  void resetToDefaults(AppStrings strings) {
    emit(_initialState(strings));
  }
}
