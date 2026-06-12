import 'package:flutter/material.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';

class SoccerSpinner extends StatefulWidget {
  final double size;
  final String? message;

  const SoccerSpinner({super.key, this.size = 60, this.message});

  @override
  State<SoccerSpinner> createState() => _SoccerSpinnerState();
}

class _SoccerSpinnerState extends State<SoccerSpinner>
    with TickerProviderStateMixin {
  late AnimationController _ctrl;
  late Animation<double> _spinAnim;

  @override
  void initState() {
    super.initState();
    _ctrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat();
    _spinAnim = Tween<double>(begin: 0, end: 1).animate(
      CurvedAnimation(parent: _ctrl, curve: Curves.linear),
    );
  }

  @override
  void dispose() {
    _ctrl.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Column(
      mainAxisSize: MainAxisSize.min,
      children: [
        AnimatedBuilder(
          animation: _spinAnim,
          builder: (_, child) => Transform.rotate(
            angle: _spinAnim.value * 6.2832,
            child: child,
          ),
          child: Container(
            width: widget.size,
            height: widget.size,
            decoration: BoxDecoration(
              shape: BoxShape.circle,
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.2),
                  blurRadius: 20,
                  spreadRadius: 2,
                ),
              ],
            ),
            child: Icon(
              Icons.sports_soccer_rounded,
              size: widget.size * 0.75,
              color: AppColors.secondary,
            ),
          ),
        ),
        if (widget.message != null) ...[
          const SizedBox(height: 16),
          Text(
            widget.message!,
            style: const TextStyle(
              color: AppColors.textMuted,
              fontSize: 13,
              fontWeight: FontWeight.w500,
            ),
          ),
          const SizedBox(height: 4),
          // Animated dots
          _pulsingDots(),
        ],
      ],
    );
  }

  Widget _pulsingDots() {
    return Row(
      mainAxisAlignment: MainAxisAlignment.center,
      children: List.generate(3, (i) {
        return _dot(i);
      }),
    );
  }

  Widget _dot(int index) {
    final dotCtrl = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 600),
    );
    Future.delayed(Duration(milliseconds: index * 200), () {
      if (mounted) dotCtrl.repeat(reverse: true);
    });
    return AnimatedBuilder(
      animation: dotCtrl,
      builder: (_, __) => Container(
        margin: const EdgeInsets.symmetric(horizontal: 3),
        width: 8,
        height: 8,
        decoration: BoxDecoration(
          shape: BoxShape.circle,
          color: AppColors.secondary.withOpacity(0.3 + dotCtrl.value * 0.7),
        ),
      ),
    );
  }
}
