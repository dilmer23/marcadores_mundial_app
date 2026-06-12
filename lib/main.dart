import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/data/datasources/worldcup_remote_data_source.dart';
import 'package:marcadores_mundial_app/data/repositories/worldcup_repository_impl.dart';
import 'package:marcadores_mundial_app/presentation/cubits/theme_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/language_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/worldcup_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/iptv_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/prediction_cubit.dart';
import 'package:marcadores_mundial_app/presentation/cubits/favorite_team_cubit.dart';
import 'package:marcadores_mundial_app/presentation/pages/splash_page.dart';

void main() {
  runApp(const MyApp());
}

class MyApp extends StatelessWidget {
  const MyApp({super.key});

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
            home: const SplashPage(),
          );
        },
      ),
    );
  }
}
