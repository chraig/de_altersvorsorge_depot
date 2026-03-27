import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:avdepot_rechner/core/l10n/app_strings.dart';

class LocaleState {
  final AppLocale locale;
  final AppStrings strings;

  LocaleState({required this.locale})
      : strings = AppStrings.fromLocale(locale);
}

class LocaleCubit extends Cubit<LocaleState> {
  LocaleCubit() : super(LocaleState(locale: AppLocale.de));

  void setLocale(AppLocale locale) {
    emit(LocaleState(locale: locale));
  }

  void toggle() {
    final next = state.locale == AppLocale.en ? AppLocale.de : AppLocale.en;
    emit(LocaleState(locale: next));
  }
}
