import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/presentation/cubits/worldcup_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/prediction_cubit.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/presentation/widgets/shimmer_loading.dart';
import 'package:marcadores_mundial_app/presentation/widgets/empty_state.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/prediction.dart';

class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage> {
  final _scores = <String, Map<String, int>>{};

  @override
  void initState() {
    super.initState();
    context.read<PredictionCubit>().loadPredictions();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorldCupCubit, WorldCupState>(
      builder: (context, state) {
        if (state.isLoading && state.games.isEmpty) {
          return ListView.builder(
            itemCount: 5,
            itemBuilder: (_, __) => const ShimmerMatchCard(),
          );
        }

        final games = state.games.where((g) => !g.finished).toList();
        final finished = state.games.where((g) => g.finished).toList();

        return Column(
          children: [
            _buildScoreboard(),
            Expanded(
              child: games.isEmpty && finished.isEmpty
                  ? EmptyState(
                      icon: Icons.sports_esports_rounded,
                      title: context.tr('No matches available', 'No hay partidos disponibles'),
                    )
                  : ListView(
                      children: [
                        if (games.isNotEmpty) ...[
                          _sectionHeader(context.tr('Upcoming Matches', 'Próximos Partidos')),
                          ...games.map((g) => _predictionCard(g)),
                        ],
                        if (finished.isNotEmpty) ...[
                          _sectionHeader(context.tr('Finished', 'Finalizados')),
                          ...finished.map((g) => _resultCard(g)),
                        ],
                      ],
                    ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreboard() {
    return BlocBuilder<PredictionCubit, PredictionState>(
      builder: (context, pState) {
        return Container(
          margin: const EdgeInsets.all(16),
          padding: const EdgeInsets.all(16),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(16),
          ),
          child: Row(
            children: [
              const Icon(Icons.emoji_events_rounded,
                  size: 28, color: AppColors.secondary),
              const SizedBox(width: 12),
              Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(context.tr('My Predictions', 'Mis Pronósticos'),
                      style: TextStyle(
                          color: AppColors.textLight,
                          fontWeight: FontWeight.w700,
                          fontSize: 16)),
                  Text(
                    '${pState.predictionCount} ${context.tr("predictions", "pronósticos")} \u2022 ${pState.totalPoints} ${context.tr("pts", "pts")}',
                    style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.7),
                        fontSize: 13),
                  ),
                ],
              ),
              const Spacer(),
              Text(
                '${pState.totalPoints}',
                style: const TextStyle(
                    color: AppColors.secondary,
                    fontSize: 32,
                    fontWeight: FontWeight.w900),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 8, 20, 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 18,
              fontWeight: FontWeight.w800,
              color: AppColors.secondary)),
    );
  }

  Widget _predictionCard(Game game) {
    final matchKey = '${game.homeTeamNameEn}-${game.awayTeamNameEn}';
    final cubit = context.read<PredictionCubit>();
    final existing = cubit.getPrediction(matchKey);
    final homeCtrl =
        TextEditingController(text: existing?.homeScore.toString() ?? '');
    final awayCtrl =
        TextEditingController(text: existing?.awayScore.toString() ?? '');

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Flexible(
              child: Text(game.homeTeamNameEn,
                  textAlign: TextAlign.right,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            const SizedBox(width: 8),
            SizedBox(
              width: 44,
              child: TextField(
                controller: homeCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '-',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                onChanged: (v) {
                  final h = int.tryParse(v) ?? 0;
                  final a = int.tryParse(awayCtrl.text) ?? 0;
                  _scores[matchKey] = {'home': h, 'away': a};
                },
              ),
            ),
            const Padding(
              padding: EdgeInsets.symmetric(horizontal: 4),
              child: Text('-', style: TextStyle(fontSize: 18)),
            ),
            SizedBox(
              width: 44,
              child: TextField(
                controller: awayCtrl,
                keyboardType: TextInputType.number,
                textAlign: TextAlign.center,
                decoration: const InputDecoration(
                  hintText: '-',
                  border: OutlineInputBorder(),
                  isDense: true,
                  contentPadding:
                      EdgeInsets.symmetric(horizontal: 4, vertical: 8),
                ),
                onChanged: (v) {
                  final h = int.tryParse(homeCtrl.text) ?? 0;
                  final a = int.tryParse(v) ?? 0;
                  _scores[matchKey] = {'home': h, 'away': a};
                },
              ),
            ),
            const SizedBox(width: 8),
            Flexible(
              child: Text(game.awayTeamNameEn,
                  maxLines: 1,
                  overflow: TextOverflow.ellipsis,
                  style: const TextStyle(fontWeight: FontWeight.w600)),
            ),
            IconButton(
              icon: const Icon(Icons.check_circle_rounded,
                  color: AppColors.secondary),
              onPressed: () {
                final h = int.tryParse(homeCtrl.text);
                final a = int.tryParse(awayCtrl.text);
                if (h != null && a != null) {
                  cubit.savePrediction(matchKey, h, a);
                  ScaffoldMessenger.of(context).showSnackBar(
                    SnackBar(
                        content: Text(context.tr('Prediction saved!', '¡Pronóstico guardado!')),
                        duration: const Duration(seconds: 1)),
                  );
                }
              },
            ),
          ],
        ),
      ),
    );
  }

  Widget _resultCard(Game game) {
    final matchKey = '${game.homeTeamNameEn}-${game.awayTeamNameEn}';
    final cubit = context.read<PredictionCubit>();
    final pred = cubit.getPrediction(matchKey);

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 4),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Row(
          children: [
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.end,
                children: [
                  Text(game.homeTeamNameEn,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (pred != null)
                    Text('${context.tr("You:", "Tú:")} ${pred.homeScore}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
            const SizedBox(width: 8),
            Column(
              children: [
                Text(
                  '${game.homeScore} - ${game.awayScore}',
                  style: const TextStyle(
                      fontSize: 20, fontWeight: FontWeight.w800),
                ),
                if (pred != null)
                  _pointsBadge(pred, game),
              ],
            ),
            const SizedBox(width: 8),
            Expanded(
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Text(game.awayTeamNameEn,
                      style: const TextStyle(fontWeight: FontWeight.w600)),
                  if (pred != null)
                    Text('${context.tr("You:", "Tú:")} ${pred.awayScore}',
                        style: const TextStyle(
                            fontSize: 12, color: AppColors.textMuted)),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _pointsBadge(Prediction pred, Game game) {
    final gHome = int.tryParse(game.homeScore) ?? 0;
    final gAway = int.tryParse(game.awayScore) ?? 0;
    final correct = pred.homeScore == gHome &&
        pred.awayScore == gAway;
    final diff = (pred.homeScore - pred.awayScore).sign ==
        (gHome - gAway).sign;

    Color color;
    String label;
    if (correct) {
      color = Colors.green;
      label = '+3';
    } else if (diff || (pred.homeScore == pred.awayScore && gHome == gAway)) {
      color = Colors.orange;
      label = '+1';
    } else {
      color = Colors.red;
      label = '+0';
    }

    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 6, vertical: 2),
      decoration: BoxDecoration(
        color: color.withOpacity(0.15),
        borderRadius: BorderRadius.circular(8),
      ),
      child: Text(label,
          style: TextStyle(
              color: color, fontWeight: FontWeight.w700, fontSize: 12)),
    );
  }
}
