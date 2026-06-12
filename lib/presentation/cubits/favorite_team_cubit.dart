import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';

class FavoriteTeamState {
  final String? teamName;
  final Color? primaryColor;

  const FavoriteTeamState({this.teamName, this.primaryColor});
}

class FavoriteTeamCubit extends Cubit<FavoriteTeamState> {
  FavoriteTeamCubit() : super(const FavoriteTeamState());

  void setFavorite(String? teamName, Color? primaryColor) {
    emit(FavoriteTeamState(teamName: teamName, primaryColor: primaryColor));
  }

  void clear() {
    emit(const FavoriteTeamState());
  }
}
