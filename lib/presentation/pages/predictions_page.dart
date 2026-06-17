import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/presentation/cubits/worldcup_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/prediction_cubit.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/presentation/widgets/shimmer_loading.dart';
import 'package:marcadores_mundial_app/presentation/widgets/empty_state.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';

class PredictionsPage extends StatefulWidget {
  const PredictionsPage({super.key});

  @override
  State<PredictionsPage> createState() => _PredictionsPageState();
}

class _PredictionsPageState extends State<PredictionsPage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;

  @override
  void initState() {
    super.initState();
    _tabController = TabController(length: 2, vsync: this);
    context.read<PredictionCubit>().loadPredictions();
  }

  @override
  void dispose() {
    _tabController.dispose();
    super.dispose();
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

        final upcoming = state.games.where((g) => !g.finished).toList();
        final finished = state.games.where((g) => g.finished).toList();
        final teamMap = context.read<WorldCupCubit>().teamMap;

        return Column(
          children: [
            _buildScoreboard(),
            _buildTabBar(),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  upcoming.isEmpty
                      ? EmptyState(
                          icon: Icons.sports_soccer_rounded,
                          title: context.tr(
                              'No upcoming matches', 'No hay partidos próximos'),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          children: upcoming
                              .map((g) => _PredictionCard(
                                    game: g,
                                    homeTeam: teamMap[g.homeTeamId],
                                    awayTeam: teamMap[g.awayTeamId],
                                  ))
                              .toList(),
                        ),
                  finished.isEmpty
                      ? EmptyState(
                          icon: Icons.history_rounded,
                          title: context.tr(
                              'No finished matches', 'No hay partidos finalizados'),
                        )
                      : ListView(
                          padding: const EdgeInsets.fromLTRB(16, 8, 16, 80),
                          children: finished
                              .map((g) => _ResultCard(
                                    game: g,
                                    homeTeam: teamMap[g.homeTeamId],
                                    awayTeam: teamMap[g.awayTeamId],
                                  ))
                              .toList(),
                        ),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildScoreboard() {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return BlocBuilder<PredictionCubit, PredictionState>(
      builder: (context, state) {
        final correct = state.predictions.where((p) => p.points == 3).length;
        final totalScored = state.predictions
            .where((p) => p.points > 0)
            .length;
        final accuracy = state.predictionCount > 0
            ? (totalScored / state.predictionCount * 100).round()
            : 0;

        return Container(
          margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
          padding: const EdgeInsets.all(20),
          decoration: BoxDecoration(
            gradient: LinearGradient(
              colors: isDark
                  ? [AppColors.bgCard, AppColors.bgDarkSurface]
                  : [AppColors.primary, AppColors.primaryDark],
              begin: Alignment.topLeft,
              end: Alignment.bottomRight,
            ),
            borderRadius: BorderRadius.circular(20),
            boxShadow: [
              BoxShadow(
                color: AppColors.primary.withOpacity(0.3),
                blurRadius: 20,
                offset: const Offset(0, 6),
              ),
            ],
          ),
          child: Column(
            children: [
              Row(
                children: [
                  Container(
                    padding: const EdgeInsets.all(10),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: const Icon(Icons.emoji_events_rounded,
                        size: 28, color: AppColors.secondary),
                  ),
                  const SizedBox(width: 14),
                  Expanded(
                    child: Column(
                      crossAxisAlignment: CrossAxisAlignment.start,
                      children: [
                        Text(
                            context.tr(
                                'My Predictions', 'Mis Pronósticos'),
                            style: const TextStyle(
                                color: AppColors.textLight,
                                fontWeight: FontWeight.w800,
                                fontSize: 18)),
                        const SizedBox(height: 2),
                        Text(
                          '${state.predictionCount} ${context.tr("predictions", "pronósticos")}',
                          style: TextStyle(
                              color: AppColors.textLight.withOpacity(0.7),
                              fontSize: 13),
                        ),
                      ],
                    ),
                  ),
                  Container(
                    padding: const EdgeInsets.symmetric(
                        horizontal: 16, vertical: 8),
                    decoration: BoxDecoration(
                      color: AppColors.secondary.withOpacity(0.2),
                      borderRadius: BorderRadius.circular(14),
                    ),
                    child: Row(
                      mainAxisSize: MainAxisSize.min,
                      children: [
                        const Icon(Icons.star_rounded,
                            size: 18, color: AppColors.secondary),
                        const SizedBox(width: 6),
                        Text(
                          '${state.totalPoints}',
                          style: const TextStyle(
                              color: AppColors.secondary,
                              fontSize: 22,
                              fontWeight: FontWeight.w900),
                        ),
                      ],
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                children: [
                  _StatItem(
                    icon: Icons.check_circle_rounded,
                    label: context.tr('Correct', 'Correctas'),
                    value: '$totalScored',
                    color: AppColors.success,
                  ),
                  _StatItem(
                    icon: Icons.auto_awesome_rounded,
                    label: context.tr('Perfect', 'Perfectas'),
                    value: '$correct',
                    color: AppColors.secondary,
                  ),
                  _StatItem(
                    icon: Icons.trending_up_rounded,
                    label: context.tr('Accuracy', 'Precisión'),
                    value: '$accuracy%',
                    color: AppColors.accent,
                  ),
                ],
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildTabBar() {
    return Container(
      margin: const EdgeInsets.fromLTRB(16, 16, 16, 0),
      decoration: BoxDecoration(
        color: Theme.of(context).brightness == Brightness.dark
            ? AppColors.bgCard.withOpacity(0.5)
            : Colors.grey[100],
        borderRadius: BorderRadius.circular(12),
      ),
      child: TabBar(
        controller: _tabController,
        labelColor: AppColors.textLight,
        unselectedLabelColor: AppColors.textMuted,
        indicator: BoxDecoration(
          gradient: const LinearGradient(
            colors: [AppColors.primary, AppColors.primaryDark],
          ),
          borderRadius: BorderRadius.circular(10),
        ),
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle:
            const TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
        tabs: [
          Tab(text: context.tr('Upcoming', 'Próximos')),
          Tab(text: context.tr('Finished', 'Finalizados')),
        ],
      ),
    );
  }
}

class _StatItem extends StatelessWidget {
  final IconData icon;
  final String label;
  final String value;
  final Color color;

  const _StatItem({
    required this.icon,
    required this.label,
    required this.value,
    required this.color,
  });

  @override
  Widget build(BuildContext context) {
    return Expanded(
      child: Column(
        children: [
          Container(
            padding: const EdgeInsets.all(8),
            decoration: BoxDecoration(
              color: color.withOpacity(0.15),
              borderRadius: BorderRadius.circular(10),
            ),
            child: Icon(icon, size: 20, color: color),
          ),
          const SizedBox(height: 6),
          Text(
            value,
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 18,
              fontWeight: FontWeight.w800,
            ),
          ),
          Text(
            label,
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 11,
            ),
          ),
        ],
      ),
    );
  }
}

class _PredictionCard extends StatefulWidget {
  final Game game;
  final Team? homeTeam;
  final Team? awayTeam;

  const _PredictionCard({
    required this.game,
    this.homeTeam,
    this.awayTeam,
  });

  @override
  State<_PredictionCard> createState() => _PredictionCardState();
}

class _PredictionCardState extends State<_PredictionCard> {
  late TextEditingController _homeCtrl;
  late TextEditingController _awayCtrl;
  bool _saved = false;

  @override
  void initState() {
    super.initState();
    final matchKey = '${widget.game.homeTeamNameEn}-${widget.game.awayTeamNameEn}';
    final existing = context.read<PredictionCubit>().getPrediction(matchKey);
    _homeCtrl = TextEditingController(text: existing?.homeScore.toString() ?? '');
    _awayCtrl = TextEditingController(text: existing?.awayScore.toString() ?? '');
    if (existing != null) _saved = true;
  }

  @override
  void dispose() {
    _homeCtrl.dispose();
    _awayCtrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final matchKey = '${widget.game.homeTeamNameEn}-${widget.game.awayTeamNameEn}';

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.bgCard : Colors.white,
          border: _saved
              ? Border.all(color: AppColors.secondary.withOpacity(0.3), width: 1)
              : null,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TeamColumn(
                      team: widget.homeTeam,
                      name: widget.game.homeTeamNameEn,
                      align: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 8),
                    child: Text(
                      context.tr('VS', 'VS'),
                      style: TextStyle(
                        fontSize: 13,
                        fontWeight: FontWeight.w800,
                        color: isDark ? AppColors.textMuted : Colors.grey[400],
                        letterSpacing: 1,
                      ),
                    ),
                  ),
                  Expanded(
                    child: _TeamColumn(
                      team: widget.awayTeam,
                      name: widget.game.awayTeamNameEn,
                      align: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.center,
                children: [
                  SizedBox(
                    width: 56,
                    child: TextField(
                      controller: _homeCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textLight : AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.textMuted.withOpacity(0.4)
                              : Colors.grey[300],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.secondary, width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.bgDarkSurface
                            : Colors.grey[50],
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                      ),
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Text(
                      '-',
                      style: TextStyle(
                        fontSize: 24,
                        fontWeight: FontWeight.w300,
                        color: isDark ? AppColors.textMuted : Colors.grey[400],
                      ),
                    ),
                  ),
                  SizedBox(
                    width: 56,
                    child: TextField(
                      controller: _awayCtrl,
                      keyboardType: TextInputType.number,
                      textAlign: TextAlign.center,
                      style: TextStyle(
                        fontSize: 20,
                        fontWeight: FontWeight.w700,
                        color: isDark ? AppColors.textLight : AppColors.primary,
                      ),
                      decoration: InputDecoration(
                        hintText: '0',
                        hintStyle: TextStyle(
                          color: isDark
                              ? AppColors.textMuted.withOpacity(0.4)
                              : Colors.grey[300],
                        ),
                        border: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        enabledBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: BorderSide(
                            color: isDark ? Colors.grey[700]! : Colors.grey[300]!,
                          ),
                        ),
                        focusedBorder: OutlineInputBorder(
                          borderRadius: BorderRadius.circular(12),
                          borderSide: const BorderSide(
                            color: AppColors.secondary, width: 2,
                          ),
                        ),
                        filled: true,
                        fillColor: isDark
                            ? AppColors.bgDarkSurface
                            : Colors.grey[50],
                        isDense: true,
                        contentPadding: const EdgeInsets.symmetric(
                            horizontal: 8, vertical: 14),
                      ),
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 16),
              SizedBox(
                width: double.infinity,
                height: 44,
                child: ElevatedButton.icon(
                  onPressed: () {
                    final h = int.tryParse(_homeCtrl.text);
                    final a = int.tryParse(_awayCtrl.text);
                    if (h != null && a != null) {
                      context
                          .read<PredictionCubit>()
                          .savePrediction(matchKey, h, a);
                      setState(() => _saved = true);
                      ScaffoldMessenger.of(context).showSnackBar(
                        SnackBar(
                          content: Row(
                            children: [
                              const Icon(Icons.check_circle_rounded,
                                  color: Colors.white, size: 20),
                              const SizedBox(width: 8),
                              Text(context.tr(
                                  'Prediction saved!', '¡Pronóstico guardado!')),
                            ],
                          ),
                          backgroundColor: AppColors.success,
                          behavior: SnackBarBehavior.floating,
                          shape: RoundedRectangleBorder(
                              borderRadius: BorderRadius.circular(12)),
                          duration: const Duration(seconds: 2),
                        ),
                      );
                    }
                  },
                  icon: Icon(
                    _saved ? Icons.check_circle_rounded : Icons.save_rounded,
                    size: 20,
                  ),
                  label: Text(
                    _saved
                        ? context.tr('Update', 'Actualizar')
                        : context.tr('Predict', 'Pronosticar'),
                    style: const TextStyle(
                        fontWeight: FontWeight.w700, fontSize: 14),
                  ),
                  style: ElevatedButton.styleFrom(
                    backgroundColor: AppColors.primary,
                    foregroundColor: AppColors.textLight,
                    shape: RoundedRectangleBorder(
                        borderRadius: BorderRadius.circular(12)),
                    elevation: 0,
                  ),
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _TeamColumn extends StatelessWidget {
  final Team? team;
  final String name;
  final TextAlign align;

  const _TeamColumn({
    this.team,
    required this.name,
    required this.align,
  });

  @override
  Widget build(BuildContext context) {
    return Column(
      crossAxisAlignment:
          align == TextAlign.right ? CrossAxisAlignment.end : CrossAxisAlignment.start,
      children: [
        if (team != null && team!.flag.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: team!.flag,
              width: 40,
              height: 28,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey[800],
                width: 40,
                height: 28,
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[800],
                width: 40,
                height: 28,
                child: const Icon(Icons.flag, size: 16),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: align,
          maxLines: 2,
          overflow: TextOverflow.ellipsis,
          style: const TextStyle(
            fontSize: 13,
            fontWeight: FontWeight.w600,
          ),
        ),
      ],
    );
  }
}

class _ResultCard extends StatelessWidget {
  final Game game;
  final Team? homeTeam;
  final Team? awayTeam;

  const _ResultCard({
    required this.game,
    this.homeTeam,
    this.awayTeam,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final matchKey = '${game.homeTeamNameEn}-${game.awayTeamNameEn}';
    final cubit = context.read<PredictionCubit>();
    final pred = cubit.getPrediction(matchKey);

    final gHome = int.tryParse(game.homeScore) ?? 0;
    final gAway = int.tryParse(game.awayScore) ?? 0;

    Color resultColor;
    String resultLabel;
    String resultIcon;

    if (pred == null) {
      resultColor = AppColors.textMuted;
      resultLabel = context.tr('No prediction', 'Sin pronóstico');
      resultIcon = '—';
    } else {
      final exact =
          pred.homeScore == gHome && pred.awayScore == gAway;
      final predDiff = (pred.homeScore - pred.awayScore).sign;
      final actualDiff = (gHome - gAway).sign;
      final correctOutcome = predDiff == actualDiff;

      if (exact) {
        resultColor = AppColors.success;
        resultLabel = context.tr('Perfect!', '¡Perfecto!');
        resultIcon = '+3';
      } else if (correctOutcome) {
        resultColor = AppColors.secondary;
        resultLabel = context.tr('Correct outcome', 'Resultado correcto');
        resultIcon = '+1';
      } else {
        resultColor = AppColors.error;
        resultLabel = context.tr('Missed', 'Fallado');
        resultIcon = '+0';
      }
    }

    return Padding(
      padding: const EdgeInsets.only(bottom: 12),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(16),
          color: isDark ? AppColors.bgCard : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(isDark ? 0.2 : 0.04),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: [
              Row(
                children: [
                  Expanded(
                    child: _TeamColumn(
                      team: homeTeam,
                      name: game.homeTeamNameEn,
                      align: TextAlign.right,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        Text(
                          '${game.homeScore} - ${game.awayScore}',
                          style: TextStyle(
                            fontSize: 26,
                            fontWeight: FontWeight.w900,
                            color: isDark
                                ? AppColors.textLight
                                : AppColors.primary,
                          ),
                        ),
                        if (pred != null)
                          Container(
                            margin: const EdgeInsets.only(top: 4),
                            padding: const EdgeInsets.symmetric(
                                horizontal: 8, vertical: 2),
                            decoration: BoxDecoration(
                              color: isDark
                                  ? AppColors.bgDarkSurface
                                  : Colors.grey[100],
                              borderRadius: BorderRadius.circular(6),
                            ),
                            child: Text(
                              '${context.tr("You:", "Tú:")} ${pred.homeScore}-${pred.awayScore}',
                              style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w600,
                                color: isDark
                                    ? AppColors.textMuted
                                    : Colors.grey[600],
                              ),
                            ),
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _TeamColumn(
                      team: awayTeam,
                      name: game.awayTeamNameEn,
                      align: TextAlign.left,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Container(
                width: double.infinity,
                padding:
                    const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
                decoration: BoxDecoration(
                  color: resultColor.withOpacity(0.1),
                  borderRadius: BorderRadius.circular(10),
                  border: Border.all(
                      color: resultColor.withOpacity(0.2), width: 1),
                ),
                child: Row(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    Icon(
                      pred == null
                          ? Icons.help_outline_rounded
                          : pred.homeScore == gHome && pred.awayScore == gAway
                              ? Icons.auto_awesome_rounded
                              : (pred.homeScore - pred.awayScore).sign ==
                                      (gHome - gAway).sign
                                  ? Icons.check_circle_rounded
                                  : Icons.cancel_rounded,
                      size: 16,
                      color: resultColor,
                    ),
                    const SizedBox(width: 6),
                    Text(
                      resultLabel,
                      style: TextStyle(
                        color: resultColor,
                        fontWeight: FontWeight.w700,
                        fontSize: 13,
                      ),
                    ),
                    const SizedBox(width: 8),
                    Container(
                      padding: const EdgeInsets.symmetric(
                          horizontal: 8, vertical: 2),
                      decoration: BoxDecoration(
                        color: resultColor.withOpacity(0.2),
                        borderRadius: BorderRadius.circular(6),
                      ),
                      child: Text(
                        resultIcon,
                        style: TextStyle(
                          color: resultColor,
                          fontWeight: FontWeight.w800,
                          fontSize: 12,
                        ),
                      ),
                    ),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }
}
