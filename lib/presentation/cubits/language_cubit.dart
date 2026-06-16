import 'package:flutter_bloc/flutter_bloc.dart';

class LanguageCubit extends Cubit<String> {
  LanguageCubit() : super('es');

  void setLanguage(String lang) => emit(lang);

  void toggle() => emit(state == 'es' ? 'en' : 'es');
}
