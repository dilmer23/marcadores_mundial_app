import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/presentation/cubits/favorite_team_cubit.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/presentation/cubits/worldcup_cubit.dart';
import 'package:marcadores_mundial_app/presentation/widgets/shimmer_loading.dart';

class FavoriteTeamPage extends StatelessWidget {
  const FavoriteTeamPage({super.key});

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorldCupCubit, WorldCupState>(
      builder: (context, state) {
        if (state.isLoading && state.teams.isEmpty) {
          return ListView.builder(
              itemCount: 5,
              itemBuilder: (_, __) => const ShimmerMatchCard());
        }

        final teams = state.teams;
        final grouped = <String, List>{};
        for (final t in teams) {
          grouped.putIfAbsent(t.group, () => []);
          grouped[t.group]!.add(t);
        }

        return BlocBuilder<FavoriteTeamCubit, FavoriteTeamState>(
          builder: (context, favState) {
            return ListView(
              padding: const EdgeInsets.all(16),
              children: [
                Container(
                  padding: const EdgeInsets.all(20),
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
                      Icon(
                        favState.teamName != null
                            ? Icons.star_rounded
                            : Icons.star_border_rounded,
                        size: 40,
                        color: AppColors.secondary,
                      ),
                      const SizedBox(height: 8),
                      Text(context.tr('My Favorite Team', 'Mi Equipo Favorito'),
                          style: TextStyle(
                              fontSize: 20,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight)),
                      const SizedBox(height: 4),
                      Text(
                        favState.teamName != null
                            ? '${context.tr('Following:', 'Siguiendo:')} ${favState.teamName}'
                            : context.tr('Pick your favorite team', 'Elige tu equipo favorito'),
                        style: TextStyle(
                            color: AppColors.textLight.withOpacity(0.7)),
                      ),
                    ],
                  ),
                ),
                const SizedBox(height: 16),
                Text(context.tr('Select your favorite team:', 'Selecciona tu equipo favorito:'),
                    style: TextStyle(color: AppColors.textMuted)),
                const SizedBox(height: 8),
                ...grouped.entries.expand((entry) {
                  return [
                    Padding(
                      padding: const EdgeInsets.fromLTRB(4, 12, 4, 4),
                      child: Text(context.trGroup('Group ${entry.key}'),
                          style: const TextStyle(
                              fontWeight: FontWeight.w700,
                              color: AppColors.secondary)),
                    ),
                    ...entry.value.map((team) {
                      final isSelected = favState.teamName == team.nameEn;
                      return Card(
                        color: isSelected
                            ? AppColors.secondary.withOpacity(0.1)
                            : null,
                        child: ListTile(
                          leading: team.flag.isNotEmpty
                              ? ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: Image.network(team.flag,
                                      width: 36, height: 24, fit: BoxFit.cover),
                                )
                              : const Icon(Icons.flag_rounded),
                          title: Text(team.nameEn,
                              style: TextStyle(
                                  fontWeight: isSelected
                                      ? FontWeight.w700
                                      : FontWeight.w500)),
                          subtitle: Text(team.nameFa,
                              style: const TextStyle(fontSize: 12)),
                          trailing: isSelected
                              ? const Icon(Icons.star_rounded,
                                  color: AppColors.secondary)
                              : null,
                          onTap: () {
                            context
                                .read<FavoriteTeamCubit>()
                                .setFavorite(team.nameEn, null);
                          },
                        ),
                      );
                    }),
                  ];
                }),
              ],
            );
          },
        );
      },
    );
  }
}
