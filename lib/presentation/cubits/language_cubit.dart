import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('en');

  void setLanguage(String lang) => emit(lang);

  void toggle() => emit(state == 'en' ? 'es' : 'en');
}
