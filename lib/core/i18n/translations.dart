import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/presentation/cubits/language_cubit.dart';

extension Trans on BuildContext {
  String get lng => read<LanguageCubit>().state;

  String tr(String en, String es) => lng == 'es' ? es : en;

  String trGroup(String groupKey) {
    const map = {
      'Group A': {'en': 'Group A', 'es': 'Grupo A'},
      'Group B': {'en': 'Group B', 'es': 'Grupo B'},
      'Group C': {'en': 'Group C', 'es': 'Grupo C'},
      'Group D': {'en': 'Group D', 'es': 'Grupo D'},
      'Group E': {'en': 'Group E', 'es': 'Grupo E'},
      'Group F': {'en': 'Group F', 'es': 'Grupo F'},
      'Group G': {'en': 'Group G', 'es': 'Grupo G'},
      'Group H': {'en': 'Group H', 'es': 'Grupo H'},
    };
    return map[groupKey]?[lng] ?? groupKey;
  }
}
