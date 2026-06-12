import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/presentation/cubits/worldcup_cubit.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';
import 'package:marcadores_mundial_app/presentation/widgets/shimmer_loading.dart';

class QualificationScenariosPage extends StatefulWidget {
  const QualificationScenariosPage({super.key});

  @override
  State<QualificationScenariosPage> createState() =>
      _QualificationScenariosPageState();
}

class _QualificationScenariosPageState
    extends State<QualificationScenariosPage> {
  final _results = <String, String>{};

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorldCupCubit, WorldCupState>(
      builder: (context, state) {
        if (state.isLoading && state.games.isEmpty) {
          return ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const ShimmerMatchCard());
        }

        final cubit = context.read<WorldCupCubit>();
        final teamMap = cubit.teamMap;

        // Group games by group
        final grouped = <String, List<Game>>{};
        for (final g in state.games.where((g) => g.type == 'group')) {
          grouped.putIfAbsent(g.group, () => []);
          grouped[g.group]!.add(g);
        }

        return ListView(
          padding: const EdgeInsets.all(16),
          children: [
            Container(
              padding: const EdgeInsets.all(16),
              decoration: BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
                borderRadius: BorderRadius.circular(16),
              ),
              child: Column(
                children: [
                  const Icon(Icons.analytics_rounded,
                      size: 36, color: AppColors.secondary),
                  const SizedBox(height: 8),
                  Text(context.tr('Qualification Scenarios', 'Escenarios de Clasificación'),
                      style: TextStyle(
                          fontSize: 20,
                          fontWeight: FontWeight.w800,
                          color: AppColors.textLight)),
                  const SizedBox(height: 4),
                  Text(context.tr('Simulate results to see who qualifies', 'Simula resultados para ver quién clasifica'),
                      style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.7))),
                ],
              ),
            ),
            const SizedBox(height: 16),
            ...grouped.entries.map((entry) {
              return _groupScenario(entry.key, entry.value, teamMap);
            }),
          ],
        );
      },
    );
  }

  Widget _groupScenario(
      String group, List<Game> games, Map<String, Team> teamMap) {
    final teams = <String, _SimTeam>{};
    for (final g in games) {
      teams.putIfAbsent(g.homeTeamNameEn,
          () => _SimTeam(g.homeTeamNameEn, g.homeTeamId));
      teams.putIfAbsent(g.awayTeamNameEn,
          () => _SimTeam(g.awayTeamNameEn, g.awayTeamId));
    }

    // Calculate standings based on results
    for (final g in games) {
      if (g.finished) {
        _applyResult(teams, g.homeTeamNameEn, g.awayTeamNameEn,
            int.tryParse(g.homeScore) ?? 0, int.tryParse(g.awayScore) ?? 0);
      } else {
        final key = g.id.toString();
        final result = _results[key];
        if (result != null) {
          final parts = result.split('-');
          _applyResult(teams, g.homeTeamNameEn, g.awayTeamNameEn,
              int.parse(parts[0]), int.parse(parts[1]));
        }
      }
    }

    final sorted = teams.values.toList()
      ..sort((a, b) {
        if (b.points != a.points) return b.points.compareTo(a.points);
        final gd = (b.goalsFor - b.goalsAgainst) - (a.goalsFor - a.goalsAgainst);
        if (gd != 0) return gd;
        return b.goalsFor.compareTo(a.goalsFor);
      });

    return Card(
      margin: const EdgeInsets.only(bottom: 16),
      child: Padding(
        padding: const EdgeInsets.all(12),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Text(context.trGroup('Group $group'),
                style: const TextStyle(
                    fontSize: 18, fontWeight: FontWeight.w800,
                    color: AppColors.secondary)),
            const SizedBox(height: 8),
            // Standings table header
            Row(
                children: [
                  SizedBox(width: 24, child: Text(context.tr('#', '#'),
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                  Expanded(
                      child: Text(context.tr('Team', 'Equipo'),
                          style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                  SizedBox(width: 24, child: Text(context.tr('P', 'P'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                  SizedBox(width: 24, child: Text(context.tr('GD', 'DG'),
                      textAlign: TextAlign.center,
                      style: TextStyle(color: AppColors.textMuted, fontSize: 12))),
                ],
              ),
            const Divider(height: 8),
            ...sorted.asMap().entries.map((e) {
              final i = e.key;
              final t = e.value;
              final qualified = i < 2;
              return Container(
                color: qualified
                    ? Colors.green.withOpacity(0.08)
                    : Colors.transparent,
                child: Row(
                  children: [
                    SizedBox(
                      width: 24,
                      child: Text('${i + 1}',
                          style: TextStyle(
                              fontWeight: FontWeight.w700,
                              fontSize: 13,
                              color: qualified
                                  ? Colors.green
                                  : AppColors.textMuted)),
                    ),
                    Expanded(
                      child: Text(t.name,
                          style: TextStyle(
                              fontWeight:
                                  qualified ? FontWeight.w700 : FontWeight.w500,
                              color: qualified ? Colors.green : null)),
                    ),
                    SizedBox(
                      width: 24,
                      child: Text('${t.points}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontWeight: FontWeight.w600)),
                    ),
                    SizedBox(
                      width: 24,
                      child: Text(
                          '${t.goalsFor - t.goalsAgainst}',
                          textAlign: TextAlign.center,
                          style: const TextStyle(fontSize: 12)),
                    ),
                  ],
                ),
              );
            }),
            const SizedBox(height: 8),
            // Upcoming matches in this group
            ...games.where((g) => !g.finished).map((g) {
              return Padding(
                padding: const EdgeInsets.symmetric(vertical: 4),
                child: Row(
                  children: [
                    Expanded(
                        child: Text(g.homeTeamNameEn,
                            textAlign: TextAlign.right)),
                    const SizedBox(width: 8),
                    SizedBox(
                      width: 60,
                      child: Row(
                        mainAxisAlignment: MainAxisAlignment.center,
                        children: [
                          SizedBox(
                            width: 24,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: '-',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                              onChanged: (v) {
                                final a = v;
                                final key = g.id.toString();
                                final existing = _results[key] ?? '-0';
                                final parts = existing.split('-');
                                _results[key] = '${a}-${parts[1]}';
                                setState(() {});
                              },
                            ),
                          ),
                          const Text('-', style: TextStyle(fontSize: 13)),
                          SizedBox(
                            width: 24,
                            child: TextField(
                              keyboardType: TextInputType.number,
                              textAlign: TextAlign.center,
                              decoration: const InputDecoration(
                                hintText: '-',
                                border: InputBorder.none,
                                isDense: true,
                              ),
                              style: const TextStyle(fontSize: 13),
                              onChanged: (v) {
                                final key = g.id.toString();
                                final existing = _results[key] ?? '0-';
                                final parts = existing.split('-');
                                _results[key] = '${parts[0]}-$v';
                                setState(() {});
                              },
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(width: 8),
                    Expanded(child: Text(g.awayTeamNameEn)),
                  ],
                ),
              );
            }),
          ],
        ),
      ),
    );
  }

  void _applyResult(Map<String, _SimTeam> teams, String home, String away,
      int hScore, int aScore) {
    teams[home]!.goalsFor += hScore;
    teams[home]!.goalsAgainst += aScore;
    teams[away]!.goalsFor += aScore;
    teams[away]!.goalsAgainst += hScore;
    if (hScore > aScore) {
      teams[home]!.points += 3;
    } else if (aScore > hScore) {
      teams[away]!.points += 3;
    } else {
      teams[home]!.points += 1;
      teams[away]!.points += 1;
    }
  }
}

class _SimTeam {
  final String name;
  final String id;
  int points = 0;
  int goalsFor = 0;
  int goalsAgainst = 0;

  _SimTeam(this.name, this.id);
}
