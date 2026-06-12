import 'package:flutter/material.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/presentation/pages/main_shell.dart';

class SplashPage extends StatefulWidget {
  const SplashPage({super.key});

  @override
  State<SplashPage> createState() => _SplashPageState();
}

class _SplashPageState extends State<SplashPage>
    with TickerProviderStateMixin {
  late AnimationController _pulseController;
  late AnimationController _rotateController;
  late AnimationController _slideController;
  late Animation<double> _pulseAnim;
  late Animation<double> _rotateAnim;
  late Animation<Offset> _slideAnim;

  @override
  void initState() {
    super.initState();

    _pulseController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 1200),
    )..repeat(reverse: true);

    _pulseAnim = Tween<double>(begin: 0.85, end: 1.15).animate(
      CurvedAnimation(parent: _pulseController, curve: Curves.easeInOut),
    );

    _rotateController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 4000),
    )..repeat();

    _rotateAnim = Tween<double>(begin: 0, end: 1.0).animate(
      CurvedAnimation(parent: _rotateController, curve: Curves.linear),
    );

    _slideController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );

    _slideAnim = Tween<Offset>(
      begin: const Offset(0, 0.5),
      end: Offset.zero,
    ).animate(CurvedAnimation(
      parent: _slideController,
      curve: Curves.easeOutCubic,
    ));

    _slideController.forward();

    Future.delayed(const Duration(seconds: 3), () {
      if (mounted) {
        Navigator.of(context).pushReplacement(
          PageRouteBuilder(
            pageBuilder: (_, __, ___) => const MainShell(),
            transitionsBuilder: (_, animation, __, child) =>
                FadeTransition(opacity: animation, child: child),
            transitionDuration: const Duration(milliseconds: 600),
          ),
        );
      }
    });
  }

  @override
  void dispose() {
    _pulseController.dispose();
    _rotateController.dispose();
    _slideController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    return Scaffold(
      body: Container(
        decoration: const BoxDecoration(
          gradient: RadialGradient(
            center: Alignment.center,
            radius: 1.5,
            colors: [
              AppColors.primaryDark,
              Color(0xFF2D0A15),
              Color(0xFF0a0a0a),
            ],
          ),
        ),
        child: SafeArea(
          child: Stack(
            children: [
              // Background light rays
              Positioned.fill(
                child: CustomPaint(
                  painter: _RayPainter(),
                ),
              ),
              // Content
              Center(
                child: Column(
                  mainAxisAlignment: MainAxisAlignment.center,
                  children: [
                    const Spacer(flex: 2),
                    // Animated soccer ball / trophy icon
                    AnimatedBuilder(
                      animation: Listenable.merge(
                          [_pulseController, _rotateController]),
                      builder: (_, child) {
                        return Transform.scale(
                          scale: _pulseAnim.value,
                          child: Transform.rotate(
                            angle: _rotateAnim.value * 6.2832,
                            child: child,
                          ),
                        );
                      },
                      child: Container(
                        width: 140,
                        height: 140,
                        decoration: BoxDecoration(
                          shape: BoxShape.circle,
                          border: Border.all(
                            color: AppColors.secondary.withOpacity(0.3),
                            width: 2,
                          ),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.15),
                              blurRadius: 40,
                              spreadRadius: 10,
                            ),
                          ],
                        ),
                        child: const Icon(
                          Icons.sports_soccer_rounded,
                          size: 72,
                          color: AppColors.secondary,
                        ),
                      ),
                    ),
                    const SizedBox(height: 40),
                    // Title
                    SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        children: [
                          Text(
                            context.tr('FIFA World Cup', 'Copa Mundial FIFA'),
                            style: TextStyle(
                              fontSize: 36,
                              fontWeight: FontWeight.w800,
                              color: AppColors.textLight,
                              letterSpacing: 1.2,
                            ),
                          ),
                          const Text(
                            '2026',
                            style: TextStyle(
                              fontSize: 56,
                              fontWeight: FontWeight.w900,
                              color: AppColors.secondary,
                              letterSpacing: 4,
                            ),
                          ),
                          const SizedBox(height: 12),
                          Container(
                            padding: const EdgeInsets.symmetric(
                                horizontal: 24, vertical: 8),
                            decoration: BoxDecoration(
                              border: Border.all(
                                color: AppColors.secondary.withOpacity(0.4),
                              ),
                              borderRadius: BorderRadius.circular(20),
                            ),
                            child: Text(
                              context.tr('USA \u2022 Canada \u2022 Mexico', 'EE. UU. \u2022 Canadá \u2022 México'),
                              style: TextStyle(
                                fontSize: 16,
                                fontWeight: FontWeight.w600,
                                color: AppColors.textMuted,
                                letterSpacing: 0.5,
                              ),
                            ),
                          ),
                          const SizedBox(height: 48),
                          // Pulse dots
                          Row(
                            mainAxisAlignment: MainAxisAlignment.center,
                            children: List.generate(3, (i) {
                              return _pulsingDot(i);
                            }),
                          ),
                        ],
                      ),
                    ),
                    const Spacer(flex: 2),
                    // Bottom credits
                    SlideTransition(
                      position: _slideAnim,
                      child: Column(
                        children: [
                          Text(
                            context.tr('API by worldcup26.ir', 'API por worldcup26.ir'),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted.withOpacity(0.6),
                            ),
                          ),
                          const SizedBox(height: 2),
                          Text(
                            context.tr('Developer: Dilmer Ramirez', 'Desarrollador: Dilmer Ramirez'),
                            style: TextStyle(
                              fontSize: 12,
                              color: AppColors.textMuted.withOpacity(0.6),
                            ),
                          ),
                        ],
                      ),
                    ),
                    const SizedBox(height: 40),
                  ],
                ),
              ),
            ],
          ),
        ),
      ),
    );
  }

  Widget _pulsingDot(int index) {
    final dotController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 800),
    );
    dotController.repeat(reverse: true);
    final dotAnim = Tween<double>(begin: 0.3, end: 1.0).animate(
      CurvedAnimation(
        parent: dotController,
        curve: Curves.easeInOut,
      ),
    );

    Future.delayed(Duration(milliseconds: index * 200), () {
      if (mounted) dotController.forward();
    });

    return AnimatedBuilder(
      animation: dotAnim,
      builder: (_, __) {
        return Container(
          margin: const EdgeInsets.symmetric(horizontal: 4),
          width: 10,
          height: 10,
          decoration: BoxDecoration(
            shape: BoxShape.circle,
            color: AppColors.secondary.withOpacity(dotAnim.value),
          ),
        );
      },
    );
  }
}

class _RayPainter extends CustomPainter {
  @override
  void paint(Canvas canvas, Size size) {
    final paint = Paint()
      ..shader = RadialGradient(
        colors: [
          AppColors.secondary.withOpacity(0.05),
          AppColors.secondary.withOpacity(0.02),
          Colors.transparent,
        ],
        stops: const [0.0, 0.3, 1.0],
      ).createShader(Rect.fromLTWH(0, 0, size.width, size.height));
    canvas.drawRect(Rect.fromLTWH(0, 0, size.width, size.height), paint);
  }

  @override
  bool shouldRepaint(covariant CustomPainter oldDelegate) => false;
}
