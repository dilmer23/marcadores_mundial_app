import 'package:flutter/material.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/domain/entities/stadium.dart';

class StadiumCardWidget extends StatelessWidget {
  final Stadium stadium;

  const StadiumCardWidget({super.key, required this.stadium});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    return Card(
      margin: const EdgeInsets.symmetric(horizontal: 16, vertical: 6),
      child: Padding(
        padding: const EdgeInsets.all(20),
        child: Column(
          crossAxisAlignment: CrossAxisAlignment.start,
          children: [
            Row(
              children: [
                Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    color: AppColors.primary.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: const Icon(
                    Icons.stadium_rounded,
                    color: AppColors.secondary,
                    size: 28,
                  ),
                ),
                const SizedBox(width: 16),
                Expanded(
                  child: Column(
                    crossAxisAlignment: CrossAxisAlignment.start,
                    children: [
                      Text(
                        stadium.nameEn,
                        style: const TextStyle(
                          fontSize: 16,
                          fontWeight: FontWeight.w700,
                        ),
                      ),
                      const SizedBox(height: 4),
                      Text(
                        '${stadium.cityEn}, ${stadium.countryEn}',
                        style: TextStyle(
                          fontSize: 13,
                          color: isDark ? AppColors.textMuted : Colors.grey[600],
                        ),
                      ),
                    ],
                  ),
                ),
              ],
            ),
            const SizedBox(height: 16),
            Row(
              children: [
                Icon(
                  Icons.people_rounded,
                  size: 16,
                  color: isDark ? AppColors.textMuted : Colors.grey[600],
                ),
                const SizedBox(width: 6),
                Text(
                  _formatCapacity(stadium.capacity),
                  style: const TextStyle(
                    fontSize: 14,
                    fontWeight: FontWeight.w600,
                    color: AppColors.secondary,
                  ),
                ),
                const Spacer(),
                Container(
                  padding: const EdgeInsets.symmetric(horizontal: 10, vertical: 4),
                  decoration: BoxDecoration(
                    color: AppColors.accent.withOpacity(0.1),
                    borderRadius: BorderRadius.circular(12),
                  ),
                  child: Text(
                    stadium.region,
                    style: const TextStyle(
                      fontSize: 11,
                      fontWeight: FontWeight.w600,
                      color: AppColors.accent,
                    ),
                  ),
                ),
              ],
            ),
          ],
        ),
      ),
    );
  }

  String _formatCapacity(int capacity) {
    if (capacity >= 1000) {
      return '${(capacity / 1000).toStringAsFixed(capacity % 1000 == 0 ? 0 : 1)}K';
    }
    return capacity.toString();
  }
}
