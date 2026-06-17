import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:supabase/supabase.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/data/datasources/worldcup_remote_data_source.dart';
import 'package:marcadores_mundial_app/data/repositories/worldcup_repository_impl.dart';
import 'package:marcadores_mundial_app/data/repositories/channel_repository_impl.dart';
import 'package:marcadores_mundial_app/data/repositories/banner_repository_impl.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_active_channels.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_active_banners.dart';
import 'package:marcadores_mundial_app/presentation/cubits/theme_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/language_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/worldcup_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/iptv_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/prediction_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/favorite_team_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/tv_channels_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/banner_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/banner_management_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/channel_management_cubit.dart';
import 'package:marcadores_mundial_app/domain/usecases/create_banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/update_banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/delete_banner.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_all_banners.dart';
import 'package:marcadores_mundial_app/domain/usecases/upload_banner_image.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_all_channels.dart';
import 'package:marcadores_mundial_app/domain/usecases/create_channel.dart';
import 'package:marcadores_mundial_app/domain/usecases/update_channel.dart';
import 'package:marcadores_mundial_app/domain/usecases/delete_channel.dart';
import 'package:marcadores_mundial_app/data/services/supabase_service.dart';
import 'package:marcadores_mundial_app/presentation/pages/splash_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/main_shell.dart';

void main() {
  final supabaseClient = SupabaseClient(
    'https://gdqfcrwhfceodrnzcdxk.supabase.co',
    'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkcWZjcndoZmNlb2RybnpjZHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2MTk3NTEsImV4cCI6MjA5NzE5NTc1MX0.l6tAFbQn8G7m3tXZil_LpgwiREFQTYsALRQp4slWt90',
  );
  runApp(MyApp(supabaseClient: supabaseClient));
}

class MyApp extends StatelessWidget {
  final SupabaseClient supabaseClient;

  const MyApp({super.key, required this.supabaseClient});

  @override
  Widget build(BuildContext context) {
    return MultiBlocProvider(
      providers: [
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => IptvCubit()),
        BlocProvider(create: (_) => PredictionCubit()),
        BlocProvider(create: (_) => FavoriteTeamCubit()),
        BlocProvider(
          create: (_) {
            final supabaseService = SupabaseService(supabaseClient);
            final channelRepository = ChannelRepositoryImpl(supabaseService);
            final fetchActiveChannels = FetchActiveChannels(channelRepository);
            return TvChannelsCubit(fetchActiveChannels);
          },
        ),
        BlocProvider(
          create: (_) {
            final supabaseService = SupabaseService(supabaseClient);
            final bannerRepository = BannerRepositoryImpl(supabaseService);
            final fetchActiveBanners = FetchActiveBanners(bannerRepository);
            return BannerCubit(fetchActiveBanners);
          },
        ),
        BlocProvider(
          create: (_) {
            final supabaseService = SupabaseService(supabaseClient);
            final bannerRepository = BannerRepositoryImpl(supabaseService);
            return BannerManagementCubit(
              FetchAllBanners(bannerRepository),
              CreateBanner(bannerRepository),
              UpdateBanner(bannerRepository),
              DeleteBanner(bannerRepository),
              UploadBannerImage(bannerRepository),
            );
          },
        ),
        BlocProvider(
          create: (_) {
            final supabaseService = SupabaseService(supabaseClient);
            final channelRepository = ChannelRepositoryImpl(supabaseService);
            return ChannelManagementCubit(
              FetchAllChannels(channelRepository),
              CreateChannel(channelRepository),
              UpdateChannel(channelRepository),
              DeleteChannel(channelRepository),
            );
          },
        ),
        BlocProvider(
          create: (_) {
            final client = http.Client();
            final remoteDataSource = WorldCupRemoteDataSource(client);
            final repository = WorldCupRepositoryImpl(remoteDataSource);
            return WorldCupCubit(repository);
          },
        ),
      ],
      child: BlocBuilder<ThemeCubit, ThemeState>(
        builder: (context, state) {
          return MaterialApp(
            title: 'World Cup 2026',
            debugShowCheckedModeBanner: false,
            theme: AppTheme.lightTheme,
            darkTheme: AppTheme.darkTheme,
            themeMode: state.themeMode,
            home: kIsWeb ? const MainShell() : const SplashPage(),
          );
        },
      ),
    );
  }
}
