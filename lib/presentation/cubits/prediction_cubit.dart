import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/data/database/prediction_database.dart';
import 'package:marcadores_mundial_app/domain/entities/prediction.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';

class PredictionState {
  final List<Prediction> predictions;
  final int totalPoints;
  final int predictionCount;
  final bool isLoading;

  const PredictionState({
    this.predictions = const [],
    this.totalPoints = 0,
    this.predictionCount = 0,
    this.isLoading = true,
  });

  PredictionState copyWith({
    List<Prediction>? predictions,
    int? totalPoints,
    int? predictionCount,
    bool? isLoading,
  }) {
    return PredictionState(
      predictions: predictions ?? this.predictions,
      totalPoints: totalPoints ?? this.totalPoints,
      predictionCount: predictionCount ?? this.predictionCount,
      isLoading: isLoading ?? this.isLoading,
    );
  }
}

class PredictionCubit extends Cubit<PredictionState> {
  PredictionCubit() : super(const PredictionState());

  Future<void> loadPredictions() async {
    emit(state.copyWith(isLoading: true));
    final predictions = await PredictionDatabase.getAllPredictions();
    final points = await PredictionDatabase.getTotalPoints();
    final count = await PredictionDatabase.getPredictionCount();
    emit(state.copyWith(
      predictions: predictions,
      totalPoints: points,
      predictionCount: count,
      isLoading: false,
    ));
  }

  Future<void> savePrediction(String matchId, int homeScore, int awayScore) async {
    await PredictionDatabase.savePrediction(Prediction(
      matchId: matchId,
      homeScore: homeScore,
      awayScore: awayScore,
    ));
    await loadPredictions();
  }

  Prediction? getPrediction(String matchId) {
    try {
      return state.predictions.firstWhere((p) => p.matchId == matchId);
    } catch (_) {
      return null;
    }
  }

  Future<void> calculatePoints(List<Game> games) async {
    for (final game in games.where((g) => g.finished)) {
      final pred = getPrediction('${game.homeTeamNameEn}-${game.awayTeamNameEn}');
      if (pred == null) continue;

      var points = 0;
      final actualHome = int.tryParse(game.homeScore) ?? 0;
      final actualAway = int.tryParse(game.awayScore) ?? 0;

      if (pred.homeScore == actualHome && pred.awayScore == actualAway) {
        points = 3; // Exact score
      } else {
        final predDiff = pred.homeScore - pred.awayScore;
        final actualDiff = actualHome - actualAway;
        if ((predDiff > 0 && actualDiff > 0) ||
            (predDiff < 0 && actualDiff < 0) ||
            (predDiff == 0 && actualDiff == 0)) {
          points = 1; // Correct outcome
        }
      }

      await PredictionDatabase.savePrediction(Prediction(
        matchId: pred.matchId,
        homeScore: pred.homeScore,
        awayScore: pred.awayScore,
        points: points,
      ));
    }
    await loadPredictions();
  }
}
