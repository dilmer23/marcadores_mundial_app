import 'package:flutter/material.dart';
import 'package:shimmer/shimmer.dart';

class ShimmerMatchCard extends StatelessWidget {
  const ShimmerMatchCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(20),
          child: Column(
            children: [
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 60, height: 14, color: Colors.white),
                  Container(
                      width: 40, height: 14, color: Colors.white),
                ],
              ),
              const SizedBox(height: 20),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceAround,
                children: [
                  _teamShimmer(),
                  Container(
                      width: 30, height: 30, color: Colors.white),
                  _teamShimmer(),
                ],
              ),
              const SizedBox(height: 16),
              Row(
                mainAxisAlignment: MainAxisAlignment.spaceBetween,
                children: [
                  Container(
                      width: 80, height: 12, color: Colors.white),
                  Container(
                      width: 100, height: 12, color: Colors.white),
                ],
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _teamShimmer() {
    return Column(
      children: [
        Container(
            width: 48, height: 32, decoration: const BoxDecoration(
          color: Colors.white,
          borderRadius: BorderRadius.all(Radius.circular(4)),
        )),
        const SizedBox(height: 8),
        Container(width: 60, height: 12, color: Colors.white),
      ],
    );
  }
}

class ShimmerTeamCard extends StatelessWidget {
  const ShimmerTeamCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(24),
          child: Column(
            children: [
              Container(
                  width: 64, height: 44, color: Colors.white),
              const SizedBox(height: 12),
              Container(width: 80, height: 14, color: Colors.white),
              const SizedBox(height: 4),
              Container(width: 50, height: 12, color: Colors.white),
            ],
          ),
        ),
      ),
    );
  }
}

class ShimmerStandingCard extends StatelessWidget {
  const ShimmerStandingCard({super.key});

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final baseColor = isDark ? Colors.grey[900]! : Colors.grey[300]!;
    final highlightColor = isDark ? Colors.grey[800]! : Colors.grey[100]!;

    return Shimmer.fromColors(
      baseColor: baseColor,
      highlightColor: highlightColor,
      child: Card(
        child: Padding(
          padding: const EdgeInsets.all(16),
          child: Column(
            children: List.generate(
              5,
              (i) => Padding(
                padding: const EdgeInsets.symmetric(vertical: 8),
                child: Row(
                  children: [
                    Container(
                        width: 24, height: 24, decoration: const BoxDecoration(
                      color: Colors.white,
                      shape: BoxShape.circle,
                    )),
                    const SizedBox(width: 12),
                    Container(
                        width: 28, height: 20, color: Colors.white),
                    const SizedBox(width: 8),
                    Expanded(
                        child: Container(
                            height: 14, color: Colors.white)),
                    Container(
                        width: 30, height: 14, color: Colors.white),
                  ],
                ),
              ),
            ),
          ),
        ),
      ),
    );
  }
}
