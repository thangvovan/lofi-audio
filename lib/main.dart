import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:provider/provider.dart';

import 'providers/audio_provider.dart';
import 'screens/home_screen.dart';
import 'services/audio_handler.dart';
import 'services/youtube_service.dart';

late LofiAudioHandler audioHandler;

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();

  // Immersive dark UI
  SystemChrome.setSystemUIOverlayStyle(const SystemUiOverlayStyle(
    statusBarColor: Colors.transparent,
    statusBarIconBrightness: Brightness.light,
    systemNavigationBarColor: Color(0xFF0D0D1A),
    systemNavigationBarIconBrightness: Brightness.light,
  ));

  // Initialize audio handler (simple approach without audio_service)
  audioHandler = LofiAudioHandler();

  runApp(const LofiApp());
}

class LofiApp extends StatelessWidget {
  const LofiApp({super.key});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(
          create: (_) => AudioProvider(
            audioHandler: audioHandler,
            youtubeService: YoutubeService(),
          )..loadPlaylist(),
        ),
      ],
      child: MaterialApp(
        title: 'Lofi Radio',
        debugShowCheckedModeBanner: false,
        theme: _buildTheme(),
        home: const HomeScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const background = Color(0xFF0D0D1A);
    const surface = Color(0xFF1A1A2E);
    const primary = Color(0xFFE94560);
    const secondary = Color(0xFF533483);
    const onSurface = Color(0xFFEAEAEA);

    return ThemeData(
      brightness: Brightness.dark,
      scaffoldBackgroundColor: background,
      colorScheme: const ColorScheme.dark(
        primary: primary,
        secondary: secondary,
        tertiary: Color(0xFF0F3460),
        surface: surface,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: onSurface,
      ),
      textTheme: GoogleFonts.outfitTextTheme(
        ThemeData.dark().textTheme,
      ),
      useMaterial3: true,
      splashFactory: InkSparkle.splashFactory,
    );
  }
}
