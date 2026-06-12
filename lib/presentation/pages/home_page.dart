import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/presentation/cubits/worldcup_cubit.dart';
import 'package:marcadores_mundial_app/presentation/widgets/match_card.dart';
import 'package:marcadores_mundial_app/presentation/widgets/team_card_widget.dart';
import 'package:marcadores_mundial_app/presentation/widgets/group_standing_widget.dart';
import 'package:marcadores_mundial_app/presentation/widgets/stadium_card_widget.dart';
import 'package:marcadores_mundial_app/presentation/widgets/shimmer_loading.dart';
import 'package:marcadores_mundial_app/presentation/widgets/empty_state.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';

enum MatchFilter { all, finished, upcoming, live }

class HomePage extends StatefulWidget {
  final int initialTab;
  const HomePage({super.key, this.initialTab = 0});

  @override
  State<HomePage> createState() => _HomePageState();
}

class _HomePageState extends State<HomePage>
    with SingleTickerProviderStateMixin {
  late TabController _tabController;
  final _searchController = TextEditingController();
  MatchFilter _matchFilter = MatchFilter.all;
  String _searchQuery = '';

  @override
  void initState() {
    super.initState();
    _tabController = TabController(
        length: 4, vsync: this, initialIndex: widget.initialTab);
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<WorldCupCubit>().loadAllData();
    });
  }

  @override
  void dispose() {
    _tabController.dispose();
    _searchController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<WorldCupCubit, WorldCupState>(
      builder: (context, state) {
        if (state.isLoading && state.teams.isEmpty) {
          return _buildLoadingShimmer();
        }
        if (state.error != null && state.teams.isEmpty) {
          return _buildError(state);
        }
        return Column(
          children: [
            TabBar(
              controller: _tabController,
              labelColor: AppColors.secondary,
              unselectedLabelColor: AppColors.textMuted,
              indicatorColor: AppColors.secondary,
              indicatorWeight: 3,
              labelStyle: const TextStyle(
                  fontWeight: FontWeight.w700, fontSize: 13),
              tabs: [
                Tab(text: context.tr('Matches', 'Partidos')),
                Tab(text: context.tr('Teams', 'Equipos')),
                Tab(text: context.tr('Groups', 'Grupos')),
                Tab(text: context.tr('Stadiums', 'Estadios')),
              ],
            ),
            Expanded(
              child: TabBarView(
                controller: _tabController,
                children: [
                  _buildMatchesTab(state),
                  _buildTeamsTab(state),
                  _buildGroupsTab(state),
                  _buildStadiumsTab(state),
                ],
              ),
            ),
          ],
        );
      },
    );
  }

  Widget _buildLoadingShimmer() {
    return ListView.builder(
      padding: const EdgeInsets.symmetric(vertical: 16),
      itemCount: 6,
      itemBuilder: (_, __) => const ShimmerMatchCard(),
    );
  }

  Widget _buildError(WorldCupState state) {
    return Center(
      child: Padding(
        padding: const EdgeInsets.all(32),
        child: Column(
          mainAxisSize: MainAxisSize.min,
          children: [
            Container(
              width: 80,
              height: 80,
              decoration: BoxDecoration(
                color: AppColors.error.withOpacity(0.1),
                shape: BoxShape.circle,
              ),
              child: const Icon(Icons.cloud_off_rounded,
                  size: 40, color: AppColors.error),
            ),
            const SizedBox(height: 20),
            Text(
              context.tr('Connection Error', 'Error de conexión'),
              style: const TextStyle(
                fontSize: 20,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 8),
            Text(
              state.error!,
              textAlign: TextAlign.center,
              style: const TextStyle(color: AppColors.textMuted, fontSize: 14),
            ),
            const SizedBox(height: 24),
            ElevatedButton.icon(
              onPressed: () => context.read<WorldCupCubit>().loadAllData(),
              icon: const Icon(Icons.refresh_rounded),
              label: Text(context.tr('Try Again', 'Reintentar')),
            ),
          ],
        ),
      ),
    );
  }

  // ========== MATCHES TAB WITH FILTERS ==========

  Widget _buildMatchesTab(WorldCupState state) {
    final games = state.games;
    final cubit = context.read<WorldCupCubit>();
    final teamMap = cubit.teamMap;

    var filtered = List<Game>.from(games);

    // Filter by status
    switch (_matchFilter) {
      case MatchFilter.finished:
        filtered = filtered.where((g) => g.finished).toList();
        break;
      case MatchFilter.upcoming:
        filtered =
            filtered.where((g) => !g.finished && g.timeElapsed == 'notstarted').toList();
        break;
      case MatchFilter.live:
        filtered =
            filtered.where((g) => g.timeElapsed == 'live').toList();
        break;
      case MatchFilter.all:
        break;
    }

    // Filter by search query (team name)
    if (_searchQuery.isNotEmpty) {
      final query = _searchQuery.toLowerCase();
      filtered = filtered.where((g) {
        return g.homeTeamNameEn.toLowerCase().contains(query) ||
            g.awayTeamNameEn.toLowerCase().contains(query) ||
            g.homeTeamNameFa.contains(_searchQuery) ||
            g.awayTeamNameFa.contains(_searchQuery);
      }).toList();
    }

    return Column(
      children: [
        // Search bar
        Container(
          padding: const EdgeInsets.fromLTRB(16, 12, 16, 4),
          child: TextField(
            controller: _searchController,
            onChanged: (v) => setState(() => _searchQuery = v),
            decoration: InputDecoration(
              hintText: context.tr('Search by team name...',
                  'Buscar por nombre de equipo...'),
              prefixIcon: const Icon(Icons.search_rounded, size: 22),
              suffixIcon: _searchQuery.isNotEmpty
                  ? IconButton(
                      icon: const Icon(Icons.clear_rounded, size: 20),
                      onPressed: () {
                        _searchController.clear();
                        setState(() => _searchQuery = '');
                      },
                    )
                  : null,
              filled: true,
              fillColor: Theme.of(context).brightness == Brightness.dark
                  ? Colors.grey[900]
                  : Colors.grey[100],
              border: OutlineInputBorder(
                borderRadius: BorderRadius.circular(12),
                borderSide: BorderSide.none,
              ),
              contentPadding:
                  const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
            ),
          ),
        ),
        // Filter chips
        SizedBox(
          height: 44,
          child: ListView(
            scrollDirection: Axis.horizontal,
            padding: const EdgeInsets.symmetric(horizontal: 16),
            children: MatchFilter.values.map((f) {
              final selected = _matchFilter == f;
              return Padding(
                padding: const EdgeInsets.only(right: 8),
                child: FilterChip(
                  label: Text(_filterLabel(f)),
                  selected: selected,
                  onSelected: (_) => setState(() => _matchFilter = f),
                  selectedColor: AppColors.primary,
                  checkmarkColor: Colors.white,
                  labelStyle: TextStyle(
                    color: selected ? Colors.white : null,
                    fontWeight: FontWeight.w600,
                    fontSize: 13,
                  ),
                  shape: RoundedRectangleBorder(
                    borderRadius: BorderRadius.circular(20),
                  ),
                ),
              );
            }).toList(),
          ),
        ),
        const SizedBox(height: 4),
        // Results count
        Padding(
          padding: const EdgeInsets.symmetric(horizontal: 20),
          child: Row(
            children: [
              Text(context.tr(
                  '${filtered.length} match${filtered.length == 1 ? '' : 'es'}',
                  '${filtered.length} partido${filtered.length == 1 ? '' : 's'}'),
                style: const TextStyle(
                  fontSize: 12,
                  color: AppColors.textMuted,
                ),
              ),
              if (_searchQuery.isNotEmpty)
                Text(
                  '  \u2022  "$_searchQuery"',
                  style: TextStyle(
                    fontSize: 12,
                    color: AppColors.textMuted.withOpacity(0.7),
                  ),
                ),
            ],
          ),
        ),
        // Matches list
        Expanded(
          child: filtered.isEmpty
              ? EmptyState(
                  icon: Icons.search_off_rounded,
                  title: context.tr('No matches found',
                      'No se encontraron partidos'),
                  subtitle: context.tr('Try a different filter or search term',
                      'Prueba otro filtro o término de búsqueda'))
              : RefreshIndicator(
                  onRefresh: () => cubit.loadAllData(),
                  child: ListView(
                    padding: const EdgeInsets.symmetric(vertical: 4),
                    children: _groupMatchesByDate(filtered, teamMap),
                  ),
                ),
        ),
      ],
    );
  }

  String _filterLabel(MatchFilter f) {
    switch (f) {
      case MatchFilter.all:
        return context.tr('All', 'Todos');
      case MatchFilter.finished:
        return context.tr('Finished', 'Finalizados');
      case MatchFilter.upcoming:
        return context.tr('Upcoming', 'Próximos');
      case MatchFilter.live:
        return context.tr('Live', 'En vivo');
    }
  }

  List<Widget> _groupMatchesByDate(
      List<Game> games, Map<String, Team> teamMap) {
    if (games.isEmpty) return [];

    // Sort by date
    games.sort((a, b) => a.localDate.compareTo(b.localDate));

    // Group by unique date (first 10 chars of localDate = MM/DD/YYYY)
    final grouped = <String, List<Game>>{};
    for (final g in games) {
      final dateKey = g.localDate.length >= 10
          ? g.localDate.substring(0, 10)
          : g.localDate;
      grouped.putIfAbsent(dateKey, () => []);
      grouped[dateKey]!.add(g);
    }

    final sortedDates = grouped.keys.toList()..sort();
    final widgets = <Widget>[];

    for (final date in sortedDates) {
      final dayGames = grouped[date]!;


      widgets.add(Padding(
        padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
        child: Row(
          children: [
            const Icon(Icons.calendar_today_rounded,
                size: 14, color: AppColors.secondary),
            const SizedBox(width: 8),
            Flexible(
              child: Text(
                _formatDate(date),
                overflow: TextOverflow.ellipsis,
                style: const TextStyle(
                  fontSize: 15,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
            const SizedBox(width: 8),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 8, vertical: 2),
              decoration: BoxDecoration(
                color: AppColors.secondary.withOpacity(0.1),
                borderRadius: BorderRadius.circular(8),
              ),
              child: Text(
                '${dayGames.length}',
                style: const TextStyle(
                  fontSize: 11,
                  fontWeight: FontWeight.w700,
                  color: AppColors.secondary,
                ),
              ),
            ),
          ],
        ),
      ));

      for (final g in dayGames) {
        widgets.add(MatchCard(
          game: g,
          homeTeam: teamMap[g.homeTeamId],
          awayTeam: teamMap[g.awayTeamId],
        ));
      }
    }

    return widgets;
  }

  String _formatDate(String date) {
    // Format: "06/11/2026" -> "Thu, Jun 11"
    try {
      final parts = date.split('/');
      if (parts.length >= 3) {
        final month = int.tryParse(parts[0]) ?? 0;
        final day = int.tryParse(parts[1]) ?? 0;
        final year = int.tryParse(parts[2]) ?? 2026;

        final months = context.lng == 'es'
            ? ['', 'Ene', 'Feb', 'Mar', 'Abr', 'May', 'Jun',
                'Jul', 'Ago', 'Sep', 'Oct', 'Nov', 'Dic']
            : ['', 'Jan', 'Feb', 'Mar', 'Apr', 'May', 'Jun',
                'Jul', 'Aug', 'Sep', 'Oct', 'Nov', 'Dec'];
        final days = context.lng == 'es'
            ? ['Dom', 'Lun', 'Mar', 'Mié', 'Jue', 'Vie', 'Sáb']
            : ['Sun', 'Mon', 'Tue', 'Wed', 'Thu', 'Fri', 'Sat'];

        // Rough weekday calc (Zeller-like simplification)
        final dt = DateTime(year, month, day);
        final weekday = days[dt.weekday % 7];

        return '$weekday, $months[month] $day';
      }
    } catch (_) {}
    return date;
  }

  // ========== TEAMS TAB ==========

  Widget _buildTeamsTab(WorldCupState state) {
    final teams = state.teams;

    if (teams.isEmpty) {
      return EmptyState(
        icon: Icons.people_rounded,
        title: context.tr('No teams found', 'No se encontraron equipos'),
      );
    }

    final grouped = <String, List>{};
    for (final team in teams) {
      grouped.putIfAbsent(team.group, () => []);
      grouped[team.group]!.add(team);
    }
    final sortedGroups = grouped.keys.toList()..sort();

    final cubit = context.read<WorldCupCubit>();

    return RefreshIndicator(
      onRefresh: () => cubit.loadAllData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: sortedGroups.expand((group) {
          return [
            _sectionHeader(context.trGroup('Group $group')),
            ...grouped[group]!.map((team) => TeamCardWidget(team: team)),
            const SizedBox(height: 8),
          ];
        }).toList(),
      ),
    );
  }

  // ========== GROUPS TAB ==========

  Widget _buildGroupsTab(WorldCupState state) {
    final standings = state.groupStandings;
    final cubit = context.read<WorldCupCubit>();
    final teamMap = cubit.teamMap;

    if (standings.isEmpty) {
      return EmptyState(
        icon: Icons.table_chart_rounded,
        title: context.tr('No standings available',
            'No hay clasificaciones disponibles'),
      );
    }

    final sorted = List.from(standings)
      ..sort((a, b) => a.groupName.compareTo(b.groupName));

    return RefreshIndicator(
      onRefresh: () => cubit.loadAllData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: sorted
            .map((s) => GroupStandingWidget(standing: s, teamMap: teamMap))
            .toList(),
      ),
    );
  }

  // ========== STADIUMS TAB ==========

  Widget _buildStadiumsTab(WorldCupState state) {
    final stadiums = state.stadiums;

    if (stadiums.isEmpty) {
      return EmptyState(
        icon: Icons.stadium_rounded,
        title: context.tr('No stadiums found', 'No se encontraron estadios'),
      );
    }

    final grouped = <String, List>{};
    for (final s in stadiums) {
      grouped.putIfAbsent(s.region, () => []);
      grouped[s.region]!.add(s);
    }
    final sortedRegions = grouped.keys.toList();

    final cubit = context.read<WorldCupCubit>();

    return RefreshIndicator(
      onRefresh: () => cubit.loadAllData(),
      child: ListView(
        padding: const EdgeInsets.symmetric(vertical: 8),
        children: sortedRegions.expand((region) {
          return [
            _sectionHeader(region),
            ...grouped[region]!.map((s) => StadiumCardWidget(stadium: s)),
            const SizedBox(height: 8),
          ];
        }).toList(),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(
        title,
        style: TextStyle(
          fontSize: 18,
          fontWeight: FontWeight.w800,
          color: isDark ? AppColors.textLight : AppColors.primary,
        ),
      ),
    );
  }
}
