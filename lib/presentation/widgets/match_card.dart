import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/domain/entities/game.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';
import 'package:marcadores_mundial_app/domain/entities/stadium.dart';
import 'package:marcadores_mundial_app/core/utils/timezone_utils.dart';

class MatchCard extends StatelessWidget {
  final Game game;
  final Team? homeTeam;
  final Team? awayTeam;
  final Stadium? stadium;

  const MatchCard({
    super.key,
    required this.game,
    this.homeTeam,
    this.awayTeam,
    this.stadium,
  });

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final isLive = game.timeElapsed == 'live';
    final isFinished = game.finished;

    Color? statusColor;
    String statusText = '';
    if (isFinished) {
      statusColor = AppColors.success;
      statusText = context.tr('FINISHED', 'FINALIZADO');
    } else if (isLive) {
      statusColor = AppColors.error;
      statusText = context.tr('LIVE', 'EN VIVO');
    } else {
      statusColor = AppColors.textMuted;
      statusText = context.tr('UPCOMING', 'PRÓXIMO');
    }

    return Padding(
      padding: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Container(
        decoration: BoxDecoration(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
          gradient: isFinished
              ? null
              : isLive
                  ? LinearGradient(
                      colors: [
                        AppColors.error.withOpacity(0.05),
                        isDark ? AppColors.bgDarkSurface : Colors.white,
                      ],
                      begin: Alignment.topLeft,
                      end: Alignment.bottomRight,
                    )
                  : null,
          color: isDark ? AppColors.bgCard : Colors.white,
          border: isLive
              ? Border.all(color: AppColors.error.withOpacity(0.3), width: 1.5)
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
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _GroupBadge(group: game.group),
                  _StatusBadge(color: statusColor, text: statusText, isLive: isLive),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                children: [
                  Expanded(
                    child: _TeamInfo(
                      team: homeTeam,
                      name: game.homeTeamNameEn,
                      isHome: true,
                    ),
                  ),
                  Padding(
                    padding: const EdgeInsets.symmetric(horizontal: 12),
                    child: Column(
                      children: [
                        if (game.homeTeamLabel != null)
                          Text(
                            game.homeTeamLabel!,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                        Text(
                          '${game.homeScore} - ${game.awayScore}',
                          style: TextStyle(
                            fontSize: 28,
                            fontWeight: FontWeight.w800,
                            color: isDark ? AppColors.textLight : AppColors.primary,
                          ),
                        ),
                        if (game.awayTeamLabel != null)
                          Text(
                            game.awayTeamLabel!,
                            style: const TextStyle(
                              fontSize: 9,
                              color: AppColors.textMuted,
                            ),
                            textAlign: TextAlign.center,
                          ),
                      ],
                    ),
                  ),
                  Expanded(
                    child: _TeamInfo(
                      team: awayTeam,
                      name: game.awayTeamNameEn,
                      isHome: false,
                    ),
                  ),
                ],
              ),
              const SizedBox(height: 12),
              Divider(height: 1, color: isDark ? Colors.grey[800] : Colors.grey[200]),
              const SizedBox(height: 12),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  _InfoChip(
                    icon: Icons.sports_soccer_rounded,
                    text: game.type.toUpperCase(),
                  ),
                  if (stadium != null)
                    _InfoChip(
                      icon: Icons.stadium_rounded,
                      text: stadium!.nameEn,
                    ),
                  _InfoChip(
                    icon: Icons.schedule_rounded,
                    text: TimezoneUtils.getLocalizedDate(game.localDate, context),
                  ),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }
}

class _GroupBadge extends StatelessWidget {
  final String group;
  const _GroupBadge({required this.group});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        gradient: LinearGradient(
          colors: [AppColors.secondary.withOpacity(0.2), AppColors.secondary.withOpacity(0.05)],
          begin: Alignment.topLeft,
          end: Alignment.bottomRight,
        ),
        borderRadius: BorderRadius.circular(20),
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          Icon(Icons.emoji_events_rounded, size: 12, color: AppColors.secondary),
          const SizedBox(width: 4),
          Text(
            'Group $group',
            style: const TextStyle(
              color: AppColors.secondary,
              fontSize: 12,
              fontWeight: FontWeight.w700,
            ),
          ),
        ],
      ),
    );
  }
}

class _StatusBadge extends StatelessWidget {
  final Color color;
  final String text;
  final bool isLive;

  const _StatusBadge({required this.color, required this.text, required this.isLive});

  @override
  Widget build(BuildContext context) {
    return Container(
      padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
      decoration: BoxDecoration(
        color: color.withOpacity(0.1),
        borderRadius: BorderRadius.circular(20),
        border: isLive ? Border.all(color: color.withOpacity(0.5)) : null,
      ),
      child: Row(
        mainAxisSize: MainAxisSize.min,
        children: [
          if (isLive)
            Container(
              width: 6,
              height: 6,
              decoration: const BoxDecoration(
                shape: BoxShape.circle,
                color: AppColors.error,
              ),
            ),
          if (isLive) const SizedBox(width: 6),
          Text(
            text,
            style: TextStyle(
              color: color,
              fontSize: 11,
              fontWeight: FontWeight.w700,
              letterSpacing: 0.5,
            ),
          ),
        ],
      ),
    );
  }
}

class _TeamInfo extends StatelessWidget {
  final Team? team;
  final String name;
  final bool isHome;

  const _TeamInfo({this.team, required this.name, required this.isHome});

  @override
  Widget build(BuildContext context) {
    return Column(
      children: [
        if (team != null && team!.flag.isNotEmpty)
          ClipRRect(
            borderRadius: BorderRadius.circular(6),
            child: CachedNetworkImage(
              imageUrl: team!.flag,
              width: 48,
              height: 32,
              fit: BoxFit.cover,
              placeholder: (_, __) => Container(
                color: Colors.grey[800],
                width: 48,
                height: 32,
              ),
              errorWidget: (_, __, ___) => Container(
                color: Colors.grey[800],
                width: 48,
                height: 32,
                child: const Icon(Icons.flag, size: 16),
              ),
            ),
          ),
        const SizedBox(height: 6),
        Text(
          name,
          textAlign: TextAlign.center,
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

class _InfoChip extends StatelessWidget {
  final IconData icon;
  final String text;

  const _InfoChip({required this.icon, required this.text});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    return Row(
      mainAxisSize: MainAxisSize.min,
      children: [
        Icon(icon, size: 12, color: isDark ? AppColors.textMuted : Colors.grey[600]),
        const SizedBox(width: 4),
        Text(
          text,
          style: TextStyle(
            fontSize: 11,
            color: isDark ? AppColors.textMuted : Colors.grey[600],
          ),
        ),
      ],
    );
  }
}
