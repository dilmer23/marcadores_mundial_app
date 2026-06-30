import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:equatable/equatable.dart';

class ThemeState extends Equatable {
  final ThemeMode themeMode;
  const ThemeState({this.themeMode = ThemeMode.dark});

  ThemeState copyWith({ThemeMode? themeMode}) =>
      ThemeState(themeMode: themeMode ?? this.themeMode);

  @override
  List<Object> get props => [themeMode];
}

class ThemeCubit extends Cubit<ThemeState> {
  ThemeCubit() : super(const ThemeState());

  void setThemeMode(ThemeMode mode) => emit(ThemeState(themeMode: mode));

  void toggleTheme() {
    final newMode =
        state.themeMode == ThemeMode.dark ? ThemeMode.light : ThemeMode.dark;
    emit(ThemeState(themeMode: newMode));
  }
}
