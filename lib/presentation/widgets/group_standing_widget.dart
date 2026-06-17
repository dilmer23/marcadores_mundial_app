import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/domain/entities/group_standing.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';

class GroupStandingWidget extends StatelessWidget {
  final GroupStanding standing;
  final Map<String, Team> teamMap;

  const GroupStandingWidget({
    super.key,
    required this.standing,
    required this.teamMap,
  });

  @override
  Widget build(BuildContext context) {
    final sortedTeams = List<TeamStanding>.from(standing.teams)
      ..sort((a, b) => b.pts.compareTo(a.pts));

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 8),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          color: Theme.of(context).brightness == Brightness.dark
              ? AppColors.bgCard
              : Colors.white,
          boxShadow: [
            BoxShadow(
              color: Colors.black.withOpacity(0.05),
              blurRadius: 12,
              offset: const Offset(0, 3),
            ),
          ],
        ),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.symmetric(horizontal: 20, vertical: 16),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                ),
                borderRadius: BorderRadius.only(
                  topLeft: Radius.circular(AppColors.cardRadius),
                  topRight: Radius.circular(AppColors.cardRadius),
                ),
              ),
              child: Row(
                children: [
                  const Icon(Icons.emoji_events_rounded, color: AppColors.secondary, size: 20),
                  const SizedBox(width: 8),
                  Text(
                    context.trGroup('Group ${standing.groupName}'),
                    style: const TextStyle(
                      fontSize: 18,
                      fontWeight: FontWeight.w800,
                      color: AppColors.textLight,
                    ),
                  ),
                ],
              ),
            ),
            Padding(
              padding: const EdgeInsets.symmetric(horizontal: 12, vertical: 8),
              child: Table(
                columnWidths: const {
                  0: FixedColumnWidth(36),
                  1: FlexColumnWidth(),
                  2: FixedColumnWidth(32),
                  3: FixedColumnWidth(32),
                  4: FixedColumnWidth(36),
                },
                children: [
                  TableRow(
                    children: [
                      _headerCell('#'),
                      _headerCell(context.tr('Team', 'Equipo'), textAlign: TextAlign.left),
                      _headerCell(context.tr('P', 'P')),
                      _headerCell(context.tr('GD', 'DG')),
                      _headerCell(context.tr('Pts', 'Pts')),
                    ],
                  ),
                  ...sortedTeams.asMap().entries.map((entry) {
                    final idx = entry.key;
                    final t = entry.value;
                    final team = teamMap[t.teamId];
                    return TableRow(
                      decoration: BoxDecoration(
                        color: idx < 2
                            ? AppColors.secondary.withOpacity(0.05)
                            : null,
                      ),
                      children: [
                        _cellNum(idx),
                        Padding(
                          padding: const EdgeInsets.symmetric(vertical: 8),
                          child: Row(
                            children: [
                              if (team != null)
                                ClipRRect(
                                  borderRadius: BorderRadius.circular(4),
                                  child: CachedNetworkImage(
                                    imageUrl: team.flag,
                                    width: 24,
                                    height: 16,
                                    fit: BoxFit.cover,
                                    placeholder: (_, __) => Container(
                                      width: 24,
                                      height: 16,
                                      color: Colors.grey[800],
                                    ),
                                    errorWidget: (_, __, ___) => Container(
                                      width: 24,
                                      height: 16,
                                      color: Colors.grey[800],
                                    ),
                                  ),
                                ),
                              const SizedBox(width: 8),
                              Expanded(
                                child: Text(
                                  team?.nameEn ?? context.tr('Unknown', 'Desconocido'),
                                  style: const TextStyle(
                                    fontSize: 13,
                                    fontWeight: FontWeight.w500,
                                  ),
                                  overflow: TextOverflow.ellipsis,
                                ),
                              ),
                            ],
                          ),
                        ),
                        _cell(t.mp.toString()),
                        _cell(
                          t.gd.toString(),
                          color: t.gd > 0
                              ? AppColors.success
                              : t.gd < 0
                                  ? AppColors.error
                                  : null,
                        ),
                        _cell(
                          t.pts.toString(),
                          bold: true,
                          color: AppColors.secondary,
                        ),
                      ],
                    );
                  }),
                ],
              ),
            ),
          ],
        ),
      ),
    );
  }

  Widget _headerCell(String text, {TextAlign textAlign = TextAlign.center}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: textAlign,
        style: TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.secondary.withOpacity(0.8),
          letterSpacing: 0.5,
        ),
      ),
    );
  }

  Widget _cellNum(int idx) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Container(
        width: 28,
        height: 28,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: idx < 2
              ? AppColors.secondary.withOpacity(0.2)
              : Colors.grey.withOpacity(0.1),
        ),
        child: Center(
          child: Text(
            '${idx + 1}',
            style: TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: idx < 2 ? AppColors.secondary : AppColors.textMuted,
            ),
          ),
        ),
      ),
    );
  }

  Widget _cell(String text, {bool bold = false, Color? color}) {
    return Padding(
      padding: const EdgeInsets.symmetric(vertical: 8, horizontal: 4),
      child: Text(
        text,
        textAlign: TextAlign.center,
        style: TextStyle(
          fontSize: 13,
          fontWeight: bold ? FontWeight.w800 : FontWeight.w500,
          color: color,
        ),
      ),
    );
  }
}
