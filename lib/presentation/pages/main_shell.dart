import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/presentation/cubits/theme_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/language_cubit.dart';
import 'package:marcadores_mundial_app/presentation/pages/home_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/iptv_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/predictions_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/trivia_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/watch_tv_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/favorite_team_page.dart';

class _NavItem {
  final IconData icon;
  final String labelEn;
  final String labelEs;
  final int index;
  const _NavItem(this.icon, this.labelEn, this.labelEs, this.index);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> {
  int _currentIndex = 0;
  int _primaryNavIndex = 0; // last selected primary nav index for bottom nav
  final _useRail = kIsWeb;

  int _primarySelectedIndex() {
    final i = _primaryNav.indexWhere((item) => _currentIndex == item.index);
    return i >= 0 ? i : _primaryNavIndex;
  }

  static const _primaryNav = [
    _NavItem(Icons.sports_soccer_rounded, 'Matches', 'Partidos', 0),
    _NavItem(Icons.table_chart_rounded, 'Standings', 'Clasificación', 1),
    _NavItem(Icons.people_rounded, 'Teams', 'Equipos', 2),
    _NavItem(Icons.live_tv_rounded, 'Watch TV', 'Ver TV', 3),
  ];

  static const _drawerNav = [
    _NavItem(Icons.stadium_rounded, 'Stadiums', 'Estadios', 4),
    _NavItem(Icons.sports_esports_rounded, 'Predictions', 'Pronósticos', 5),
    _NavItem(Icons.quiz_rounded, 'Trivia', 'Trivia', 6),
    _NavItem(Icons.star_rounded, 'My Team', 'Mi Equipo', 7),
    _NavItem(Icons.live_tv_rounded, 'IPTV', 'IPTV', 8),
    _NavItem(Icons.settings_rounded, 'Settings', 'Ajustes', 9),
  ];

  static const _allNav = [
    ..._primaryNav,
    ..._drawerNav,
  ];

  String _title(BuildContext c) {
    final item = _allNav.where((e) => e.index == _currentIndex).firstOrNull;
    if (item == null) return '';
    return c.tr(item.labelEn, item.labelEs);
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;

    if (_useRail) {
      return _buildWebLayout(isDark);
    }
    return _buildMobileLayout(isDark);
  }

  // ── WEB LAYOUT ──────────────────────────────────────────
  Widget _buildWebLayout(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title(context)),
        actions: [_themeToggle(isDark)],
      ),
      body: Row(
        children: [
          NavigationRail(
            selectedIndex: _allNav.indexWhere((item) => item.index == _currentIndex),
            onDestinationSelected: (i) =>
                setState(() => _currentIndex = _allNav[i].index),
            labelType: NavigationRailLabelType.all,
            minExtendedWidth: 200,
            groupAlignment: -1,
            leading: Padding(
              padding: const EdgeInsets.symmetric(vertical: 8),
              child: Column(
                children: [
                  Container(
                    width: 40,
                    height: 40,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(10),
                    ),
                    child: const Icon(Icons.sports_soccer_rounded,
                        size: 24, color: AppColors.primary),
                  ),
                  const SizedBox(height: 4),
                  Text('WC 2026',
                      style: TextStyle(
                          fontSize: 10,
                          fontWeight: FontWeight.w700,
                          color: isDark
                              ? AppColors.textLight
                              : AppColors.primary)),
                ],
              ),
            ),
            destinations: _allNav.map((item) {
              final selected = _currentIndex == item.index;
              return NavigationRailDestination(
                icon: Icon(item.icon),
                selectedIcon: Icon(item.icon,
                    color: AppColors.secondary),
                label: Text(
                  context.tr(item.labelEn, item.labelEs),
                  style: TextStyle(
                    fontWeight:
                        selected ? FontWeight.w700 : FontWeight.w500,
                    fontSize: selected ? 13 : 12,
                  ),
                ),
              );
            }).toList(),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(child: _buildBody()),
        ],
      ),
    );
  }

  // ── MOBILE LAYOUT ───────────────────────────────────────
  Widget _buildMobileLayout(bool isDark) {
    return Scaffold(
      appBar: AppBar(
        title: Text(_title(context)),
        actions: [_themeToggle(isDark)],
      ),
      drawer: _buildDrawer(context, isDark),
      body: _buildBody(),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return NavigationBar(
      selectedIndex: _primarySelectedIndex(),
      onDestinationSelected: (i) {
        setState(() {
          _currentIndex = _primaryNav[i].index;
          _primaryNavIndex = i;
        });
      },
      animationDuration: const Duration(milliseconds: 400),
    backgroundColor: isDark
        ? Colors.grey[900]
        : Colors.white,
    indicatorColor: AppColors.secondary.withOpacity(0.2),
    surfaceTintColor: Colors.transparent,
    elevation: 3,
      destinations: _primaryNav.map((item) {
        final selected = _currentIndex == item.index;
        return NavigationDestination(
          icon: Icon(item.icon, color: AppColors.textMuted),
          selectedIcon: Icon(item.icon, color: AppColors.secondary),
          label: context.tr(item.labelEn, item.labelEs),
        );
      }).toList(),
    );
  }

  // ── DRAWER ──────────────────────────────────────────────
  Widget _buildDrawer(BuildContext context, bool isDark) {
    final themeCubit = context.watch<ThemeCubit>();

    return Drawer(
      child: SafeArea(
        child: Column(
          children: [
            Container(
              width: double.infinity,
              padding: const EdgeInsets.fromLTRB(20, 30, 20, 20),
              decoration: const BoxDecoration(
                gradient: LinearGradient(
                  colors: [AppColors.primary, AppColors.primaryDark],
                  begin: Alignment.topLeft,
                  end: Alignment.bottomRight,
                ),
              ),
              child: Column(
                crossAxisAlignment: CrossAxisAlignment.start,
                children: [
                  Container(
                    width: 56,
                    height: 56,
                    decoration: BoxDecoration(
                      color: AppColors.secondary,
                      borderRadius: BorderRadius.circular(16),
                    ),
                    child: const Icon(
                      Icons.sports_soccer_rounded,
                      size: 32,
                      color: AppColors.primary,
                    ),
                  ),
                  const SizedBox(height: 16),
                  Text(
                      context.tr('World Cup 2026', 'Copa Mundial 2026'),
                      style: const TextStyle(
                          color: AppColors.textLight,
                          fontSize: 22,
                          fontWeight: FontWeight.w800)),
                  const SizedBox(height: 4),
                  Text(
                      context.tr(
                          'USA \u2022 Canada \u2022 Mexico',
                          'EE. UU. \u2022 Canad\u00e1 \u2022 M\u00e9xico'),
                      style: TextStyle(
                          color: AppColors.textLight.withOpacity(0.7),
                          fontSize: 13)),
                ],
              ),
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _sectionHeader(
                      context.tr('WORLD CUP', 'MUNDIAL')),
                  _drawerItem(Icons.sports_soccer_rounded,
                      context.tr('Matches', 'Partidos'), 0),
                  _drawerItem(Icons.table_chart_rounded,
                      context.tr('Standings', 'Clasificaci\u00f3n'), 1),
                  _drawerItem(Icons.people_rounded,
                      context.tr('Teams', 'Equipos'), 2),
                  _drawerItem(Icons.stadium_rounded,
                      context.tr('Stadiums', 'Estadios'), 4),
                  const Divider(indent: 20, endIndent: 20),
                  _sectionHeader(
                      context.tr('GAMES', 'JUEGOS')),
                  _drawerItem(Icons.sports_esports_rounded,
                      context.tr('Predictions', 'Pron\u00f3sticos'), 5),
                  _drawerItem(Icons.quiz_rounded,
                      context.tr('Trivia', 'Trivia'), 6),
                  const Divider(indent: 20, endIndent: 20),
                  _sectionHeader(
                      context.tr('MEDIA', 'MEDIA')),
                  _drawerItem(Icons.live_tv_rounded,
                      context.tr('Watch TV', 'Ver TV'), 3),
                  _drawerItem(Icons.star_rounded, 'My Team',
                      7),
                  _drawerItem(Icons.live_tv_rounded, 'IPTV',
                      8),
                  const Divider(indent: 20, endIndent: 20),
                  _sectionHeader(
                      context.tr('SETTINGS', 'AJUSTES')),
                  _drawerItem(Icons.settings_rounded,
                      context.tr('Settings', 'Ajustes'), 9),
                  ListTile(
                    leading: const Icon(Icons.palette_rounded),
                    title: Text(context.tr(
                        'Dark Mode', 'Modo Oscuro')),
                    trailing: Switch.adaptive(
                      value: themeCubit.state.themeMode ==
                          ThemeMode.dark,
                      activeColor: AppColors.primary,
                      onChanged: (_) => themeCubit.toggleTheme(),
                    ),
                  ),
                ],
              ),
            ),
            _buildDrawerFooter(isDark),
          ],
        ),
      ),
    );
  }

  Widget _sectionHeader(String title) {
    return Padding(
      padding: const EdgeInsets.fromLTRB(20, 12, 20, 4),
      child: Text(title,
          style: const TextStyle(
              fontSize: 12,
              fontWeight: FontWeight.w700,
              color: AppColors.textMuted,
              letterSpacing: 1)),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon,
          color: isSelected ? AppColors.primary : null),
      title: Text(title,
          style: TextStyle(
            fontWeight:
                isSelected ? FontWeight.w700 : FontWeight.w500,
            color: isSelected ? AppColors.primary : null,
          )),
      selected: isSelected,
      selectedTileColor:
          AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(12)),
      onTap: () {
        setState(() => _currentIndex = index);
        Navigator.of(context).pop();
      },
    );
  }

  Widget _buildDrawerFooter(bool isDark) {
    return Container(
      padding: const EdgeInsets.all(16),
      decoration: BoxDecoration(
        border: Border(
          top: BorderSide(
            color:
                isDark ? Colors.grey[800]! : Colors.grey[200]!,
          ),
        ),
      ),
      child: Column(
        children: [
          Text(
              context.tr(
                  'API by worldcup26.ir',
                  'API por worldcup26.ir'),
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMuted
                      : Colors.grey[600])),
          const SizedBox(height: 2),
          Text(
              context.tr(
                  'Developer: Dilmer Ramirez',
                  'Desarrollador: Dilmer Ramirez'),
              style: TextStyle(
                  fontSize: 12,
                  color: isDark
                      ? AppColors.textMuted
                      : Colors.grey[600])),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerLink(
                  context.tr('API', 'API'),
                  'https://worldcup26.ir'),
              const Text(' \u2022 ',
                  style:
                      TextStyle(color: AppColors.textMuted)),
              _footerLink(
                  context.tr('GitHub', 'GitHub'),
                  'https://github.com/dilmer23'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String label, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Text(label,
          style: const TextStyle(
              fontSize: 12,
              color: AppColors.primary,
              fontWeight: FontWeight.w600,
              decoration: TextDecoration.underline)),
    );
  }

  // ── BODY ───────────────────────────────────────────────
  Widget _buildBody() {
    final pages = <Widget>[
      HomePage(key: const ValueKey('matches'), initialTab: 0),
      HomePage(key: const ValueKey('standings'), initialTab: 2),
      HomePage(key: const ValueKey('teams'), initialTab: 1),
      const WatchTvPage(),
      HomePage(key: const ValueKey('stadiums'), initialTab: 3),
      const PredictionsPage(),
      const TriviaPage(),
      const FavoriteTeamPage(),
      const IptvPage(),
      _buildSettings(),
    ];

    return AnimatedSwitcher(
      duration: const Duration(milliseconds: 300),
      switchInCurve: Curves.easeInOut,
      transitionBuilder: (Widget child, Animation<double> anim) {
        return FadeTransition(opacity: anim, child: child);
      },
      child: KeyedSubtree(
        key: ValueKey(_currentIndex),
        child: pages[_currentIndex],
      ),
    );
  }

  // ── SETTINGS ────────────────────────────────────────────
  Widget _buildSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeCubit = context.watch<ThemeCubit>();
    final langCubit = context.watch<LanguageCubit>();

    return ListView(
      padding: const EdgeInsets.all(20),
      children: [
        const SizedBox(height: 10),
        _sectionHeader(
            context.tr('Appearance', 'Apariencia')),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: Text(context.tr('Light', 'Claro')),
                subtitle: Text(context.tr(
                    'Light theme', 'Tema claro')),
                secondary:
                    const Icon(Icons.light_mode_rounded),
                value: ThemeMode.light,
                groupValue: themeCubit.state.themeMode,
                activeColor: AppColors.primary,
                onChanged: (v) => themeCubit.setThemeMode(v!),
              ),
              const Divider(
                  height: 1, indent: 16, endIndent: 16),
              RadioListTile<ThemeMode>(
                title: Text(context.tr('Dark', 'Oscuro')),
                subtitle: Text(context.tr(
                    'Dark theme', 'Tema oscuro')),
                secondary:
                    const Icon(Icons.dark_mode_rounded),
                value: ThemeMode.dark,
                groupValue: themeCubit.state.themeMode,
                activeColor: AppColors.primary,
                onChanged: (v) => themeCubit.setThemeMode(v!),
              ),
              const Divider(
                  height: 1, indent: 16, endIndent: 16),
              RadioListTile<ThemeMode>(
                title: Text(context.tr('System', 'Sistema')),
                subtitle: Text(context.tr(
                    'Follow system settings',
                    'Usar config. del sistema')),
                secondary: const Icon(
                    Icons.settings_brightness_rounded),
                value: ThemeMode.system,
                groupValue: themeCubit.state.themeMode,
                activeColor: AppColors.primary,
                onChanged: (v) => themeCubit.setThemeMode(v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeader(
            context.tr('Language', 'Idioma')),
        const SizedBox(height: 12),
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                subtitle: const Text('English'),
                secondary:
                    const Icon(Icons.language_rounded),
                value: 'en',
                groupValue: langCubit.state,
                activeColor: AppColors.primary,
                onChanged: (v) => langCubit.setLanguage(v!),
              ),
              const Divider(
                  height: 1, indent: 16, endIndent: 16),
              RadioListTile<String>(
                title: const Text('Espa\u00f1ol'),
                subtitle: const Text('Spanish'),
                secondary:
                    const Icon(Icons.language_rounded),
                value: 'es',
                groupValue: langCubit.state,
                activeColor: AppColors.primary,
                onChanged: (v) => langCubit.setLanguage(v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeader(context.tr('About', 'Acerca de')),
        const SizedBox(height: 12),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                    context.tr(
                        'World Cup 2026', 'Copa Mundial 2026'),
                    style: const TextStyle(
                        fontSize: 18,
                        fontWeight: FontWeight.w700)),
              ),
              Padding(
                padding:
                    const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                    context.tr(
                        'Predictions, scores, standings, teams & more',
                        'Pron\u00f3sticos, resultados, clasificaci\u00f3n, equipos y m\u00e1s'),
                    style: const TextStyle(
                        color: AppColors.textMuted,
                        fontSize: 13)),
              ),
              const Divider(height: 1),
              _aboutTile(
                  icon: Icons.code_rounded,
                  title: context.tr('API by', 'API por'),
                  subtitle: 'worldcup26.ir',
                  onTap: () =>
                      _launchUrl('https://worldcup26.ir')),
              _aboutTile(
                  icon: Icons.person_rounded,
                  title: context.tr(
                      'Developer', 'Desarrollador'),
                  subtitle: 'Dilmer Ramirez',
                  onTap: () =>
                      _launchUrl('https://github.com/dilmer23')),
              _aboutTile(
                  icon: Icons.info_outline_rounded,
                  title:
                      context.tr('Version', 'Versi\u00f3n'),
                  subtitle: '1.0.0'),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
              context.tr(
                  'Made with \u2665 for football fans',
                  'Hecho con \u2665 para aficionados'),
              style: TextStyle(
                  color: isDark
                      ? AppColors.textMuted
                      : Colors.grey[600],
                  fontSize: 13)),
        ),
        const SizedBox(height: 8),
        Center(
          child: Text('\u00a9 2026 World Cup 2026 App',
              style: TextStyle(
                  color: isDark
                      ? AppColors.textMuted.withOpacity(0.7)
                      : Colors.grey[500],
                  fontSize: 12)),
        ),
        const SizedBox(height: 40),
      ],
    );
  }

  Widget _aboutTile({
    required IconData icon,
    required String title,
    required String subtitle,
    VoidCallback? onTap,
  }) {
    return ListTile(
      leading: Icon(icon, color: AppColors.primary, size: 22),
      title: Text(title,
          style: const TextStyle(
              fontSize: 13, color: AppColors.textMuted)),
      subtitle: Text(subtitle,
          style: const TextStyle(
              fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: onTap != null
          ? const Icon(Icons.open_in_new_rounded,
              size: 18, color: AppColors.textMuted)
          : null,
      onTap: onTap,
    );
  }

  Widget _themeToggle(bool isDark) {
    return IconButton(
      icon: Icon(
        isDark
            ? Icons.light_mode_rounded
            : Icons.dark_mode_rounded,
      ),
      onPressed: () =>
          context.read<ThemeCubit>().toggleTheme(),
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri,
          mode: LaunchMode.externalApplication);
    }
  }
}
