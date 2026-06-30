import 'package:flutter/material.dart';

class AppColors {
  static const Color primary = Color(0xFF8B1538);
  static const Color primaryDark = Color(0xFF6B0F2B);
  static const Color primaryLight = Color(0xFFB31B4A);
  static const Color secondary = Color(0xFFD4AF37);
  static const Color secondaryLight = Color(0xFFE8C74A);
  static const Color accent = Color(0xFF1E3A5F);
  static const Color accentLight = Color(0xFF2A5080);

  // Dark
  static const Color bgDark = Color(0xFF000000);
  static const Color bgDarkSurface = Color(0xFF050505);
  static const Color bgCard = Color(0xFF0a0a0a);
  static const Color bgCardHover = Color(0xFF1a1a1a);

  // Light
  static const Color bgLight = Color(0xFFF5F5F5);
  static const Color bgLightSurface = Color(0xFFFFFFFF);

  // Text
  static const Color textLight = Color(0xFFffffff);
  static const Color textMuted = Color(0xFFa0a0a0);
  static const Color textDark = Color(0xFF1a1a1a);

  static const Color gradientStart = Color(0xFF8B1538);
  static const Color gradientEnd = Color(0xFFD4AF37);

  static const Color error = Color(0xFFE53935);
  static const Color success = Color(0xFF4CAF50);
  static const Color warning = Color(0xFFFF9800);

  static const double cardRadius = 16;
  static const double smallRadius = 12;
  static const double chipRadius = 20;
}

class AppTheme {
  static ThemeData get lightTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.light,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.light,
        primary: AppColors.primary,
        onPrimary: AppColors.textLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textDark,
        surface: AppColors.bgLightSurface,
        onSurface: AppColors.textDark,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.bgLight,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.primary,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardTheme(
        elevation: 1,
        shadowColor: AppColors.primary.withOpacity(0.08),
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
        ),
        color: AppColors.bgLightSurface,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 0,
          shadowColor: AppColors.primary.withOpacity(0.3),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.smallRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.smallRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 2,
        shadowColor: Colors.black.withOpacity(0.1),
        height: 68,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelType: NavigationRailLabelType.all,
        minExtendedWidth: 200,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.secondary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgLight,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.smallRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        space: 0,
        thickness: 1,
        color: Color(0xFFEEEEEE),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.primary),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 18),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500),
      ),
    );
  }

  static ThemeData get darkTheme {
    return ThemeData(
      useMaterial3: true,
      brightness: Brightness.dark,
      colorScheme: ColorScheme.fromSeed(
        seedColor: AppColors.primary,
        brightness: Brightness.dark,
        primary: AppColors.primary,
        onPrimary: AppColors.textLight,
        secondary: AppColors.secondary,
        onSecondary: AppColors.textDark,
        surface: AppColors.bgDarkSurface,
        onSurface: AppColors.textLight,
        error: AppColors.error,
      ),
      scaffoldBackgroundColor: AppColors.bgDark,
      appBarTheme: const AppBarTheme(
        backgroundColor: AppColors.bgDarkSurface,
        foregroundColor: AppColors.textLight,
        elevation: 0,
        centerTitle: true,
        scrolledUnderElevation: 2,
      ),
      cardTheme: CardTheme(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(AppColors.cardRadius),
        ),
        color: AppColors.bgCard,
        surfaceTintColor: Colors.transparent,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: AppColors.primary,
          foregroundColor: AppColors.textLight,
          elevation: 0,
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.smallRadius),
          ),
          padding: const EdgeInsets.symmetric(horizontal: 24, vertical: 14),
        ),
      ),
      filledButtonTheme: FilledButtonThemeData(
        style: FilledButton.styleFrom(
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(AppColors.smallRadius),
          ),
        ),
      ),
      navigationBarTheme: NavigationBarThemeData(
        elevation: 0,
        height: 68,
        backgroundColor: AppColors.bgCard,
        indicatorColor: AppColors.primary.withOpacity(0.3),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(16),
        ),
        labelBehavior: NavigationDestinationLabelBehavior.alwaysShow,
      ),
      navigationRailTheme: NavigationRailThemeData(
        elevation: 0,
        backgroundColor: AppColors.bgDarkSurface,
        indicatorColor: AppColors.primary.withOpacity(0.3),
        indicatorShape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12),
        ),
        labelType: NavigationRailLabelType.all,
        minExtendedWidth: 200,
      ),
      tabBarTheme: const TabBarTheme(
        labelColor: AppColors.secondary,
        unselectedLabelColor: AppColors.textMuted,
        indicatorColor: AppColors.secondary,
        indicatorSize: TabBarIndicatorSize.tab,
        labelStyle: TextStyle(fontWeight: FontWeight.w700, fontSize: 13),
      ),
      inputDecorationTheme: InputDecorationTheme(
        filled: true,
        fillColor: AppColors.bgDarkSurface,
        border: OutlineInputBorder(
          borderRadius: BorderRadius.circular(AppColors.smallRadius),
          borderSide: BorderSide.none,
        ),
        contentPadding: const EdgeInsets.symmetric(horizontal: 16, vertical: 12),
      ),
      dividerTheme: const DividerThemeData(
        space: 0,
        thickness: 1,
        color: Color(0xFF222222),
      ),
      textTheme: const TextTheme(
        headlineLarge: TextStyle(fontWeight: FontWeight.w800, color: AppColors.textLight),
        headlineMedium: TextStyle(fontWeight: FontWeight.w700, color: AppColors.textLight),
        titleLarge: TextStyle(fontWeight: FontWeight.w700, fontSize: 18, color: AppColors.textLight),
        titleMedium: TextStyle(fontWeight: FontWeight.w600, fontSize: 16, color: AppColors.textLight),
        bodyLarge: TextStyle(fontWeight: FontWeight.w500, color: AppColors.textLight),
      ),
    );
  }
}
