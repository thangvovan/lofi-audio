import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/audio_provider.dart';
import 'screens/splash_screen.dart';
import 'services/audio_service.dart';
import 'services/youtube_service.dart';
import 'theme/app_colors.dart';

late AudioService audioService;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive dark UI
  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.light,
      systemNavigationBarColor: AppColors.background,
      systemNavigationBarIconBrightness: Brightness.light,
    ),
  );

  // Initialize audio handler
  audioService = AudioService();

  runApp(const LofiApp());
}

class LofiApp extends StatelessWidget {
  const LofiApp({super.key});

  ThemeData _buildTheme() {
    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: AppColors.background,
      colorScheme: const ColorScheme.dark(
        primary: AppColors.primary,
        secondary: AppColors.secondary,
        tertiary: AppColors.tertiary,
        surface: AppColors.surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: AppColors.onSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(ThemeData.dark().textTheme),
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
    );
  }

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioProvider(
            audioService: audioService,
            youtubeService: YoutubeService(),
          )..loadPlaylist(),
        ),
      ],
      child: MaterialApp(
        title: 'Lofi Radio',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const SplashScreen(),
      ),
    );
  }
}
