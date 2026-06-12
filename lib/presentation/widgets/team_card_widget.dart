import 'package:flutter/material.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/domain/entities/team.dart';

class TeamCardWidget extends StatelessWidget {
  final Team team;

  const TeamCardWidget({super.key, required this.team});

  @override
  Widget build(BuildContext context) {
    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          mainAxisAlignment: MainAxisAlignment.center,
          children: [
            ClipRRect(
              borderRadius: BorderRadius.circular(8),
              child: CachedNetworkImage(
                imageUrl: team.flag,
                width: 64,
                height: 44,
                fit: BoxFit.cover,
                placeholder: (_, __) => Container(
                  color: Colors.grey[800],
                  width: 64,
                  height: 44,
                ),
                errorWidget: (_, __, ___) => Container(
                  color: Colors.grey[800],
                  width: 64,
                  height: 44,
                  child: const Icon(Icons.flag, size: 20),
                ),
              ),
            ),
            const SizedBox(height: 12),
            Text(
              team.nameEn,
              textAlign: TextAlign.center,
              maxLines: 2,
              overflow: TextOverflow.ellipsis,
              style: const TextStyle(
                fontSize: 15,
                fontWeight: FontWeight.w700,
              ),
            ),
            const SizedBox(height: 4),
            Container(
              padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 3),
              decoration: BoxDecoration(
                color: AppColors.primary.withOpacity(0.15),
                borderRadius: BorderRadius.circular(12),
              ),
              child: Text(
                team.fifaCode,
                style: const TextStyle(
                  color: AppColors.secondary,
                  fontSize: 12,
                  fontWeight: FontWeight.w700,
                ),
              ),
            ),
          ],
        ),
      ),
    );
  }
}
