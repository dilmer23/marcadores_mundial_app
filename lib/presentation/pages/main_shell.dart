import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:url_launcher/url_launcher.dart';
import 'package:cached_network_image/cached_network_image.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/core/i18n/translations.dart';
import 'package:marcadores_mundial_app/presentation/cubits/theme_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/language_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/banner_cubit.dart';
import 'package:marcadores_mundial_app/presentation/pages/home_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/iptv_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/predictions_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/trivia_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/watch_tv_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/favorite_team_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/banner_management_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/channel_management_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/profile_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/auth_page.dart';
import 'package:marcadores_mundial_app/presentation/cubits/auth_cubit.dart';
import 'package:marcadores_mundial_app/core/permissions/permissions.dart';

class _NavItem {
  final IconData icon;
  final IconData activeIcon;
  final String labelEn;
  final String labelEs;
  final int index;
  const _NavItem(this.icon, this.activeIcon, this.labelEn, this.labelEs, this.index);
}

class MainShell extends StatefulWidget {
  const MainShell({super.key});

  @override
  State<MainShell> createState() => _MainShellState();
}

class _MainShellState extends State<MainShell> with TickerProviderStateMixin {
  int _currentIndex = 0;
  int _primaryNavIndex = 0;
  final _useRail = kIsWeb;
  bool _railExtended = kIsWeb;
  late AnimationController _themeAnimController;

  int _primarySelectedIndex() {
    final i = _primaryNav.indexWhere((item) => _currentIndex == item.index);
    return i >= 0 ? i : _primaryNavIndex;
  }

  static const _primaryNav = [
    _NavItem(Icons.sports_soccer_outlined, Icons.sports_soccer_rounded, 'Matches', 'Partidos', 0),
    _NavItem(Icons.table_chart_outlined, Icons.table_chart_rounded, 'Standings', 'Clasificación', 1),
    _NavItem(Icons.people_outlined, Icons.people_rounded, 'Teams', 'Equipos', 2),
    _NavItem(Icons.live_tv_outlined, Icons.live_tv_rounded, 'Watch TV', 'Ver TV', 3),
  ];

  static const _drawerNav = [
    _NavItem(Icons.stadium_outlined, Icons.stadium_rounded, 'Stadiums', 'Estadios', 4),
    _NavItem(Icons.sports_esports_outlined, Icons.sports_esports_rounded, 'Predictions', 'Pronósticos', 5),
    _NavItem(Icons.quiz_outlined, Icons.quiz_rounded, 'Trivia', 'Trivia', 6),
    _NavItem(Icons.star_outline, Icons.star_rounded, 'My Team', 'Mi Equipo', 7),
    _NavItem(Icons.live_tv_outlined, Icons.live_tv_rounded, 'IPTV', 'IPTV', 8),
    _NavItem(Icons.settings_outlined, Icons.settings_rounded, 'Settings', 'Ajustes', 9),
    _NavItem(Icons.image_outlined, Icons.image_rounded, 'Banners', 'Banners', 10),
    _NavItem(Icons.live_tv_outlined, Icons.live_tv_rounded, 'Channels', 'Canales', 11),
    _NavItem(Icons.person_outlined, Icons.person_rounded, 'Profile', 'Perfil', 12),
  ];

  static const _allNav = [..._primaryNav, ..._drawerNav];

  String _title(BuildContext c) {
    final item = _allNav.where((e) => e.index == _currentIndex).firstOrNull;
    if (item == null) return '';
    return c.tr(item.labelEn, item.labelEs);
  }

  @override
  void initState() {
    super.initState();
    _themeAnimController = AnimationController(
      vsync: this,
      duration: const Duration(milliseconds: 300),
    );
  }

  @override
  void dispose() {
    _themeAnimController.dispose();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    if (_useRail) return _buildWebLayout(isDark);
    return _buildMobileLayout(isDark);
  }

  Widget _buildWebLayout(bool isDark) {
    final authState = context.watch<AuthCubit>().state;
    final isGuest = authState.status == AuthStatus.guest;
    final role = isGuest ? 'guest' : (authState.user?.role ?? 'guest');
    final allowedItems = _allNav.where((item) {
      if (item.index <= 9) return true;
      if (item.index == 12) return !isGuest && PermissionChecker.has(role, Permission.viewProfile);
      if (item.index == 10) return PermissionChecker.has(role, Permission.viewBanners);
      if (item.index == 11) return PermissionChecker.has(role, Permission.viewChannels);
      return false;
    }).toList();

    int railSelected = allowedItems.indexWhere((item) => item.index == _currentIndex);
    if (railSelected < 0) railSelected = 0;

    return Scaffold(
      body: Row(
        children: [
          MouseRegion(
            onEnter: (_) => setState(() => _railExtended = true),
            onExit: (_) => setState(() => _railExtended = false),
            child: AnimatedContainer(
              duration: const Duration(milliseconds: 200),
              width: _railExtended ? 200 : 72,
              child: NavigationRail(
                selectedIndex: railSelected,
                onDestinationSelected: (i) => setState(() => _currentIndex = allowedItems[i].index),
                extended: _railExtended,
                minExtendedWidth: 200,
                minWidth: 72,
                groupAlignment: -1,
                leading: Padding(
                  padding: const EdgeInsets.symmetric(vertical: 8),
                  child: Column(
                    children: [
                      Container(
                        width: 40,
                        height: 40,
                        decoration: BoxDecoration(
                          gradient: const LinearGradient(
                            colors: [AppColors.secondary, AppColors.secondaryLight],
                          ),
                          borderRadius: BorderRadius.circular(12),
                          boxShadow: [
                            BoxShadow(
                              color: AppColors.secondary.withOpacity(0.3),
                              blurRadius: 8,
                              offset: const Offset(0, 2),
                            ),
                          ],
                        ),
                        child: const Icon(Icons.sports_soccer_rounded, size: 24, color: AppColors.primary),
                      ),
                      if (_railExtended) ...[
                        const SizedBox(height: 6),
                        Text('WC 2026',
                            style: TextStyle(
                                fontSize: 11,
                                fontWeight: FontWeight.w800,
                                color: isDark ? AppColors.textLight : AppColors.primary)),
                      ],
                    ],
                  ),
                ),
                destinations: allowedItems.map((item) {
                  final selected = _currentIndex == item.index;
                  return NavigationRailDestination(
                    icon: Icon(item.icon),
                    selectedIcon: Container(
                      padding: const EdgeInsets.all(4),
                      decoration: BoxDecoration(
                        borderRadius: BorderRadius.circular(8),
                        boxShadow: selected
                            ? [
                                BoxShadow(
                                  color: AppColors.secondary.withOpacity(0.2),
                                  blurRadius: 8,
                                )
                              ]
                            : null,
                      ),
                      child: Icon(item.activeIcon, color: AppColors.secondary),
                    ),
                    label: Text(
                      context.tr(item.labelEn, item.labelEs),
                      style: TextStyle(
                        fontWeight: selected ? FontWeight.w700 : FontWeight.w500,
                        fontSize: selected ? 13 : 12,
                      ),
                    ),
                  );
                }).toList(),
              ),
            ),
          ),
          const VerticalDivider(width: 1, thickness: 1),
          Expanded(
            child: _buildPageContent(),
          ),
        ],
      ),
    );
  }

  Widget _buildMobileLayout(bool isDark) {
    return Scaffold(
      extendBody: true,
      appBar: AppBar(
        title: Text(_title(context)),
        actions: [
          IconButton(
            icon: Icon(
              isDark ? Icons.light_mode_rounded : Icons.dark_mode_rounded,
            ),
            onPressed: () => context.read<ThemeCubit>().toggleTheme(),
          ),
        ],
      ),
      drawer: _buildDrawer(context, isDark),
      body: _buildPageContent(),
      bottomNavigationBar: _buildBottomNav(isDark),
    );
  }

  Widget _buildBottomNav(bool isDark) {
    return Container(
      decoration: BoxDecoration(
        boxShadow: [
          BoxShadow(
            color: Colors.black.withOpacity(isDark ? 0.3 : 0.05),
            blurRadius: 16,
            offset: const Offset(0, -4),
          ),
        ],
      ),
      child: NavigationBar(
        selectedIndex: _primarySelectedIndex(),
        onDestinationSelected: (i) {
          setState(() {
            _currentIndex = _primaryNav[i].index;
            _primaryNavIndex = i;
          });
        },
        animationDuration: const Duration(milliseconds: 400),
        backgroundColor: isDark ? AppColors.bgCard : Colors.white,
        indicatorColor: AppColors.secondary.withOpacity(0.2),
        surfaceTintColor: Colors.transparent,
        elevation: 0,
        height: 64,
        destinations: _primaryNav.map((item) {
          return NavigationDestination(
            icon: Icon(item.icon, color: AppColors.textMuted),
            selectedIcon: Icon(item.activeIcon, color: AppColors.secondary),
            label: context.tr(item.labelEn, item.labelEs),
          );
        }).toList(),
      ),
    );
  }

  Widget _buildDrawer(BuildContext context, bool isDark) {
    final themeCubit = context.watch<ThemeCubit>();
    final authState = context.watch<AuthCubit>().state;
    final isGuest = authState.status == AuthStatus.guest;
    final role = isGuest ? 'guest' : (authState.user?.role ?? 'guest');

    return Drawer(
      width: 300,
      child: SafeArea(
        child: Column(
          children: [
            _BannerDrawerHeader(
              onNavigate: (index) {
                setState(() {
                  _currentIndex = index;
                  if (_primaryNav.any((e) => e.index == index)) {
                    _primaryNavIndex = _primaryNav.indexWhere((e) => e.index == index);
                  }
                });
                Navigator.of(context).pop();
              },
            ),
            Expanded(
              child: ListView(
                padding: EdgeInsets.zero,
                children: [
                  _sectionHeader(context.tr('WORLD CUP', 'MUNDIAL')),
                  _drawerItem(Icons.sports_soccer_rounded, context.tr('Matches', 'Partidos'), 0),
                  _drawerItem(Icons.table_chart_rounded, context.tr('Standings', 'Clasificaci\u00f3n'), 1),
                  _drawerItem(Icons.people_rounded, context.tr('Teams', 'Equipos'), 2),
                  _drawerItem(Icons.stadium_rounded, context.tr('Stadiums', 'Estadios'), 4),
                  const Divider(indent: 20, endIndent: 20),
                  _sectionHeader(context.tr('GAMES', 'JUEGOS')),
                  _drawerItem(Icons.sports_esports_rounded, context.tr('Predictions', 'Pron\u00f3sticos'), 5),
                  _drawerItem(Icons.quiz_rounded, context.tr('Trivia', 'Trivia'), 6),
                  const Divider(indent: 20, endIndent: 20),
                  _sectionHeader(context.tr('MEDIA', 'MEDIA')),
                  _drawerItem(Icons.live_tv_rounded, context.tr('Watch TV', 'Ver TV'), 3),
                  _drawerItem(Icons.star_rounded, 'My Team', 7),
                  _drawerItem(Icons.live_tv_rounded, 'IPTV', 8),
                  const Divider(indent: 20, endIndent: 20),
                  _sectionHeader(context.tr('SETTINGS', 'AJUSTES')),
                  _drawerItem(Icons.settings_rounded, context.tr('Settings', 'Ajustes'), 9),
                  if (isGuest)
                    ListTile(
                      leading: const Icon(Icons.login_rounded),
                      title: Text(context.tr('Sign In', 'Iniciar Sesión')),
                      onTap: () {
                        Navigator.of(context).pop();
                        Navigator.push(context, MaterialPageRoute(
                          builder: (_) => const AuthPage(),
                        ));
                      },
                    ),
                  if (!isGuest && PermissionChecker.has(role, Permission.viewProfile))
                    _drawerItem(Icons.person_rounded, context.tr('Profile', 'Perfil'), 12),
                  if (PermissionChecker.has(role, Permission.viewBanners) ||
                      PermissionChecker.has(role, Permission.viewChannels)) ...[
                    const Divider(indent: 20, endIndent: 20),
                    _sectionHeader('ADMIN'),
                    if (PermissionChecker.has(role, Permission.viewChannels))
                      _drawerItem(Icons.live_tv_rounded, 'Channels', 11),
                    if (PermissionChecker.has(role, Permission.viewBanners))
                      _drawerItem(Icons.image_rounded, 'Banners', 10),
                  ],
                  ListTile(
                    leading: const Icon(Icons.palette_rounded),
                    title: Text(context.tr('Dark Mode', 'Modo Oscuro')),
                    trailing: Switch.adaptive(
                      value: themeCubit.state.themeMode == ThemeMode.dark,
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
      padding: const EdgeInsets.fromLTRB(20, 16, 20, 4),
      child: Text(
        title,
        style: const TextStyle(
          fontSize: 11,
          fontWeight: FontWeight.w700,
          color: AppColors.textMuted,
          letterSpacing: 1.2,
        ),
      ),
    );
  }

  Widget _drawerItem(IconData icon, String title, int index) {
    final isSelected = _currentIndex == index;
    return ListTile(
      leading: Icon(icon, color: isSelected ? AppColors.primary : null),
      title: Text(
        title,
        style: TextStyle(
          fontWeight: isSelected ? FontWeight.w700 : FontWeight.w500,
          color: isSelected ? AppColors.primary : null,
        ),
      ),
      selected: isSelected,
      selectedTileColor: AppColors.primary.withOpacity(0.08),
      shape: RoundedRectangleBorder(borderRadius: BorderRadius.circular(12)),
      contentPadding: const EdgeInsets.symmetric(horizontal: 20, vertical: 0),
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
          top: BorderSide(color: isDark ? Colors.grey[800]! : Colors.grey[200]!),
        ),
      ),
      child: Column(
        children: [
          Text(
            context.tr('API by worldcup26.ir', 'API por worldcup26.ir'),
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : Colors.grey[600]),
          ),
          const SizedBox(height: 2),
          Text(
            context.tr('Developer: Dilmer Ramirez', 'Desarrollador: Dilmer Ramirez'),
            style: TextStyle(fontSize: 12, color: isDark ? AppColors.textMuted : Colors.grey[600]),
          ),
          const SizedBox(height: 8),
          Row(
            mainAxisAlignment: MainAxisAlignment.center,
            children: [
              _footerLink(context.tr('API', 'API'), 'https://worldcup26.ir'),
              const Text(' \u2022 ', style: TextStyle(color: AppColors.textMuted)),
              _footerLink(context.tr('GitHub', 'GitHub'), 'https://github.com/dilmer23'),
            ],
          ),
        ],
      ),
    );
  }

  Widget _footerLink(String label, String url) {
    return GestureDetector(
      onTap: () => _launchUrl(url),
      child: Text(
        label,
        style: const TextStyle(
          fontSize: 12,
          color: AppColors.primary,
          fontWeight: FontWeight.w600,
          decoration: TextDecoration.underline,
        ),
      ),
    );
  }

  Widget _buildPageContent() {
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
      const BannerManagementPage(),
      const ChannelManagementPage(),
      const ProfilePage(),
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

  Widget _buildSettings() {
    final isDark = Theme.of(context).brightness == Brightness.dark;
    final themeCubit = context.watch<ThemeCubit>();
    final langCubit = context.watch<LanguageCubit>();

    return ListView(
      padding: const EdgeInsets.all(16),
      children: [
        const SizedBox(height: 8),
        _sectionHeader(context.tr('Appearance', 'Apariencia')),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              RadioListTile<ThemeMode>(
                title: Text(context.tr('Light', 'Claro')),
                subtitle: Text(context.tr('Light theme', 'Tema claro')),
                secondary: const Icon(Icons.light_mode_rounded),
                value: ThemeMode.light,
                groupValue: themeCubit.state.themeMode,
                activeColor: AppColors.primary,
                onChanged: (v) => themeCubit.setThemeMode(v!),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              RadioListTile<ThemeMode>(
                title: Text(context.tr('Dark', 'Oscuro')),
                subtitle: Text(context.tr('Dark theme', 'Tema oscuro')),
                secondary: const Icon(Icons.dark_mode_rounded),
                value: ThemeMode.dark,
                groupValue: themeCubit.state.themeMode,
                activeColor: AppColors.primary,
                onChanged: (v) => themeCubit.setThemeMode(v!),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              RadioListTile<ThemeMode>(
                title: Text(context.tr('System', 'Sistema')),
                subtitle: Text(context.tr('Follow system settings', 'Usar config. del sistema')),
                secondary: const Icon(Icons.settings_brightness_rounded),
                value: ThemeMode.system,
                groupValue: themeCubit.state.themeMode,
                activeColor: AppColors.primary,
                onChanged: (v) => themeCubit.setThemeMode(v!),
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        _sectionHeader(context.tr('Language', 'Idioma')),
        const SizedBox(height: 8),
        Card(
          child: Column(
            children: [
              RadioListTile<String>(
                title: const Text('English'),
                subtitle: const Text('English'),
                secondary: const Icon(Icons.language_rounded),
                value: 'en',
                groupValue: langCubit.state,
                activeColor: AppColors.primary,
                onChanged: (v) => langCubit.setLanguage(v!),
              ),
              const Divider(height: 1, indent: 16, endIndent: 16),
              RadioListTile<String>(
                title: const Text('Espa\u00f1ol'),
                subtitle: const Text('Spanish'),
                secondary: const Icon(Icons.language_rounded),
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
        const SizedBox(height: 8),
        Card(
          child: Column(
            crossAxisAlignment: CrossAxisAlignment.start,
            children: [
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 20, 20, 4),
                child: Text(
                  context.tr('World Cup 2026', 'Copa Mundial 2026'),
                  style: const TextStyle(fontSize: 18, fontWeight: FontWeight.w700),
                ),
              ),
              Padding(
                padding: const EdgeInsets.fromLTRB(20, 4, 20, 12),
                child: Text(
                  context.tr('Predictions, scores, standings, teams & more', 'Pron\u00f3sticos, resultados, clasificaci\u00f3n, equipos y m\u00e1s'),
                  style: const TextStyle(color: AppColors.textMuted, fontSize: 13),
                ),
              ),
              const Divider(height: 1),
              _aboutTile(
                icon: Icons.code_rounded,
                title: context.tr('API by', 'API por'),
                subtitle: 'worldcup26.ir',
                onTap: () => _launchUrl('https://worldcup26.ir'),
              ),
              _aboutTile(
                icon: Icons.person_rounded,
                title: context.tr('Developer', 'Desarrollador'),
                subtitle: 'Dilmer Ramirez',
                onTap: () => _launchUrl('https://github.com/dilmer23'),
              ),
              _aboutTile(
                icon: Icons.info_outline_rounded,
                title: context.tr('Version', 'Versi\u00f3n'),
                subtitle: '1.0.0',
              ),
            ],
          ),
        ),
        const SizedBox(height: 20),
        Center(
          child: Text(
            context.tr('Made with \u2665 for football fans', 'Hecho con \u2665 para aficionados'),
            style: TextStyle(color: isDark ? AppColors.textMuted : Colors.grey[600], fontSize: 13),
          ),
        ),
        const SizedBox(height: 4),
        Center(
          child: Text(
            '\u00a9 2026 World Cup 2026 App',
            style: TextStyle(color: isDark ? AppColors.textMuted.withOpacity(0.7) : Colors.grey[500], fontSize: 12),
          ),
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
      title: Text(title, style: const TextStyle(fontSize: 13, color: AppColors.textMuted)),
      subtitle: Text(subtitle, style: const TextStyle(fontSize: 15, fontWeight: FontWeight.w600)),
      trailing: onTap != null
          ? const Icon(Icons.open_in_new_rounded, size: 18, color: AppColors.textMuted)
          : null,
      onTap: onTap,
    );
  }

  Future<void> _launchUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }
}

class _BannerDrawerHeader extends StatefulWidget {
  final void Function(int index)? onNavigate;

  const _BannerDrawerHeader({this.onNavigate});

  @override
  State<_BannerDrawerHeader> createState() => _BannerDrawerHeaderState();
}

class _BannerDrawerHeaderState extends State<_BannerDrawerHeader> {
  static const _routeMap = <String, int>{
    'matches': 0,
    'standings': 1,
    'teams': 2,
    'watch_tv': 3,
    'stadiums': 4,
    'predictions': 5,
    'trivia': 6,
    'my_team': 7,
    'iptv': 8,
    'settings': 9,
    'banners': 10,
    'channels': 11,
    'profile': 12,
  };

  final _pageController = PageController();
  Timer? _timer;
  int _currentPage = 0;

  @override
  void initState() {
    super.initState();
    WidgetsBinding.instance.addPostFrameCallback((_) {
      context.read<BannerCubit>().loadBanners();
    });
  }

  @override
  void didChangeDependencies() {
    super.didChangeDependencies();
    _startAutoScroll();
  }

  @override
  void dispose() {
    _timer?.cancel();
    _pageController.dispose();
    super.dispose();
  }

  void _startAutoScroll() {
    _timer?.cancel();
    final banners = context.read<BannerCubit>().state.banners;
    if (banners.length < 2) return;
    _timer = Timer.periodic(const Duration(seconds: 4), (_) {
      if (!mounted) return;
      final next = (_currentPage + 1) % banners.length;
      _pageController.animateToPage(
        next,
        duration: const Duration(milliseconds: 600),
        curve: Curves.easeInOut,
      );
    });
  }

  void _handleTap(String? linkUrl) {
    if (linkUrl == null || linkUrl.isEmpty) return;

    final normalized = linkUrl
        .replaceFirst('app://', '')
        .replaceFirst('https://', '')
        .replaceFirst('http://', '')
        .trim()
        .toLowerCase();

    final route = _routeMap.entries.firstWhere(
      (e) => normalized.startsWith(e.key),
      orElse: () => const MapEntry('', -1),
    );

    if (route.value >= 0 && widget.onNavigate != null) {
      widget.onNavigate!(route.value);
      return;
    }

    _openExternalUrl(linkUrl);
  }

  Future<void> _openExternalUrl(String url) async {
    final uri = Uri.parse(url);
    if (await canLaunchUrl(uri)) {
      await launchUrl(uri, mode: LaunchMode.externalApplication);
    }
  }

  @override
  Widget build(BuildContext context) {
    return BlocBuilder<BannerCubit, BannerState>(
      builder: (context, state) {
        final banners = state.banners;

        if (banners.isEmpty) {
          return _buildGradientHeader(null);
        }

        return SizedBox(
          width: double.infinity,
          height: 200,
          child: Stack(
            children: [
              PageView.builder(
                controller: _pageController,
                onPageChanged: (i) => _currentPage = i,
                itemCount: banners.length,
                itemBuilder: (context, index) {
                  final banner = banners[index];
                  return GestureDetector(
                    onTap: () => _handleTap(banner.linkUrl),
                    child: CachedNetworkImage(
                      imageUrl: banner.imageUrl,
                      fit: BoxFit.cover,
                      placeholder: (_, __) => _buildGradientHeader(banner.title),
                      errorWidget: (_, __, ___) => _buildGradientHeader(banner.title),
                    ),
                  );
                },
              ),
              Container(
                decoration: BoxDecoration(
                  gradient: LinearGradient(
                    colors: [
                      Colors.black.withOpacity(0.4),
                      Colors.transparent,
                      Colors.black.withOpacity(0.6),
                    ],
                    begin: Alignment.topCenter,
                    end: Alignment.bottomCenter,
                  ),
                ),
              ),
              Positioned(
                left: 20,
                right: 20,
                bottom: 20,
                child: Column(
                  crossAxisAlignment: CrossAxisAlignment.start,
                  children: [
                    Text(
                      context.tr('World Cup 2026', 'Copa Mundial 2026'),
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 22,
                        fontWeight: FontWeight.w800,
                      ),
                    ),
                    const SizedBox(height: 4),
                    Text(
                      context.tr('USA \u2022 Canada \u2022 Mexico',
                          'EE. UU. \u2022 Canad\u00e1 \u2022 M\u00e9xico'),
                      style: TextStyle(
                        color: AppColors.textLight.withOpacity(0.7),
                        fontSize: 13,
                      ),
                    ),
                  ],
                ),
              ),
              if (banners.length > 1)
                Positioned(
                  right: 16,
                  top: 16,
                  child: Container(
                    padding:
                        const EdgeInsets.symmetric(horizontal: 8, vertical: 4),
                    decoration: BoxDecoration(
                      color: Colors.black.withOpacity(0.4),
                      borderRadius: BorderRadius.circular(12),
                    ),
                    child: Text(
                      '${_currentPage + 1}/${banners.length}',
                      style: const TextStyle(
                        color: AppColors.textLight,
                        fontSize: 11,
                        fontWeight: FontWeight.w700,
                      ),
                    ),
                  ),
                ),
              Positioned(
                left: 20,
                top: 24,
                child: Container(
                  width: 48,
                  height: 48,
                  decoration: BoxDecoration(
                    gradient: const LinearGradient(
                      colors: [AppColors.secondary, AppColors.secondaryLight],
                    ),
                    borderRadius: BorderRadius.circular(14),
                    boxShadow: [
                      BoxShadow(
                        color: Colors.black.withOpacity(0.2),
                        blurRadius: 8,
                        offset: const Offset(0, 2),
                      ),
                    ],
                  ),
                  child: const Icon(
                    Icons.sports_soccer_rounded,
                    size: 28,
                    color: AppColors.primary,
                  ),
                ),
              ),
            ],
          ),
        );
      },
    );
  }

  Widget _buildGradientHeader(String? title) {
    return Container(
      width: double.infinity,
      height: 200,
      padding: const EdgeInsets.fromLTRB(20, 24, 20, 20),
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
            width: 48,
            height: 48,
            decoration: BoxDecoration(
              gradient: const LinearGradient(
                colors: [AppColors.secondary, AppColors.secondaryLight],
              ),
              borderRadius: BorderRadius.circular(14),
              boxShadow: [
                BoxShadow(
                  color: AppColors.secondary.withOpacity(0.3),
                  blurRadius: 8,
                  offset: const Offset(0, 2),
                ),
              ],
            ),
            child: const Icon(
              Icons.sports_soccer_rounded,
              size: 28,
              color: AppColors.primary,
            ),
          ),
          const Spacer(),
          Text(
            context.tr('World Cup 2026', 'Copa Mundial 2026'),
            style: const TextStyle(
              color: AppColors.textLight,
              fontSize: 22,
              fontWeight: FontWeight.w800,
            ),
          ),
          const SizedBox(height: 4),
          Text(
            context.tr('USA \u2022 Canada \u2022 Mexico',
                'EE. UU. \u2022 Canad\u00e1 \u2022 M\u00e9xico'),
            style: TextStyle(
              color: AppColors.textLight.withOpacity(0.7),
              fontSize: 13,
            ),
          ),
        ],
      ),
    );
  }
}
