import 'dart:async';
import 'package:flutter/foundation.dart' show kIsWeb;
import 'package:flutter/material.dart';
import 'package:flutter_bloc/flutter_bloc.dart';
import 'package:http/http.dart' as http;
import 'package:supabase_flutter/supabase_flutter.dart' hide AuthState;
import 'package:firebase_core/firebase_core.dart';
import 'firebase_options.dart';
import 'package:marcadores_mundial_app/core/theme/app_theme.dart';
import 'package:marcadores_mundial_app/data/datasources/worldcup_remote_data_source.dart';
import 'package:marcadores_mundial_app/data/repositories/worldcup_repository_impl.dart';
import 'package:marcadores_mundial_app/data/repositories/channel_repository_impl.dart';
import 'package:marcadores_mundial_app/data/repositories/banner_repository_impl.dart';
import 'package:marcadores_mundial_app/data/repositories/auth_repository_impl.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_active_channels.dart';
import 'package:marcadores_mundial_app/domain/usecases/fetch_active_banners.dart';
import 'package:marcadores_mundial_app/domain/usecases/sign_up.dart';
import 'package:marcadores_mundial_app/domain/usecases/sign_in.dart';
import 'package:marcadores_mundial_app/domain/usecases/sign_out.dart';
import 'package:marcadores_mundial_app/domain/usecases/send_password_reset.dart';
import 'package:marcadores_mundial_app/domain/usecases/resend_confirmation_email.dart';
import 'package:marcadores_mundial_app/domain/usecases/check_email_confirmed.dart';
import 'package:marcadores_mundial_app/domain/usecases/get_current_profile.dart';
import 'package:marcadores_mundial_app/domain/usecases/complete_profile.dart';
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
import 'package:marcadores_mundial_app/presentation/cubits/auth_cubit.dart';
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
import 'package:marcadores_mundial_app/data/services/fcm_service.dart';
import 'package:marcadores_mundial_app/presentation/pages/main_shell.dart';
import 'package:marcadores_mundial_app/presentation/pages/email_verification_page.dart';
import 'package:marcadores_mundial_app/presentation/pages/complete_profile_page.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await Supabase.initialize(
    url: 'https://gdqfcrwhfceodrnzcdxk.supabase.co',
    publishableKey: 'eyJhbGciOiJIUzI1NiIsInR5cCI6IkpXVCJ9.eyJpc3MiOiJzdXBhYmFzZSIsInJlZiI6ImdkcWZjcndoZmNlb2RybnpjZHhrIiwicm9sZSI6ImFub24iLCJpYXQiOjE3ODE2MTk3NTEsImV4cCI6MjA5NzE5NTc1MX0.l6tAFbQn8G7m3tXZil_LpgwiREFQTYsALRQp4slWt90',
  );
  try {
    await Firebase.initializeApp(
      options: kIsWeb ? DefaultFirebaseOptions.currentPlatform : null,
    );
  } catch (_) {
    // Already initialized
  }
  runApp(const MyApp());
}

class MyApp extends StatefulWidget {
  const MyApp({super.key});

  @override
  State<MyApp> createState() => _MyAppState();
}

class _MyAppState extends State<MyApp> {
  late final AuthCubit _authCubit;
  late final FcmService _fcmService;
  StreamSubscription<AuthState>? _authSub;

  @override
  void initState() {
    super.initState();
    final supabaseClient = Supabase.instance.client;
    final supabaseService = SupabaseService(supabaseClient);
    final authRepo = AuthRepositoryImpl(supabaseService);
    _authCubit = AuthCubit(
      signUp: SignUp(authRepo),
      signIn: SignIn(authRepo),
      signOut: SignOut(authRepo),
      sendPasswordReset: SendPasswordReset(authRepo),
      resendConfirmationEmail: ResendConfirmationEmail(authRepo),
      checkEmailConfirmed: CheckEmailConfirmed(authRepo),
      getCurrentProfile: GetCurrentProfile(authRepo),
      completeProfile: CompleteProfile(authRepo),
    );
    _authCubit.checkSession();

    _fcmService = FcmService(supabaseClient);
    _fcmService.initialize();
    _authSub = _authCubit.stream.listen((state) {
      if (state.status == AuthStatus.authenticated) {
        _fcmService.saveToken();
      }
    });
  }

  @override
  void dispose() {
    _authSub?.cancel();
    _authCubit.close();
    super.dispose();
  }

  @override
  Widget build(BuildContext context) {
    final supabaseService = SupabaseService(Supabase.instance.client);

    return MultiBlocProvider(
      providers: [
        BlocProvider.value(value: _authCubit),
        BlocProvider(create: (_) => ThemeCubit()),
        BlocProvider(create: (_) => LanguageCubit()),
        BlocProvider(create: (_) => IptvCubit()),
        BlocProvider(create: (_) => PredictionCubit()),
        BlocProvider(create: (_) => FavoriteTeamCubit()),
        BlocProvider(
          create: (_) {
            final channelRepository = ChannelRepositoryImpl(supabaseService);
            final fetchActiveChannels = FetchActiveChannels(channelRepository);
            return TvChannelsCubit(fetchActiveChannels);
          },
        ),
        BlocProvider(
          create: (_) {
            final bannerRepository = BannerRepositoryImpl(supabaseService);
            final fetchActiveBanners = FetchActiveBanners(bannerRepository);
            return BannerCubit(fetchActiveBanners);
          },
        ),
        BlocProvider(
          create: (_) {
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
            home: _AppRoot(),
          );
        },
      ),
    );
  }
}

class _AppRoot extends StatelessWidget {
  @override
  Widget build(BuildContext context) {
    return BlocBuilder<AuthCubit, AuthState>(
      builder: (context, state) {
        switch (state.status) {
          case AuthStatus.initial:
            return const Scaffold(
              body: Center(child: CircularProgressIndicator()),
            );
          case AuthStatus.unconfirmed:
            return const EmailVerificationPage();
          case AuthStatus.incompleteProfile:
            return const CompleteProfilePage();
          case AuthStatus.guest:
          case AuthStatus.authenticated:
            return const MainShell();
        }
      },
    );
  }
}
