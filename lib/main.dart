import 'package:flutter/material.dart';
import 'package:flutter/services.dart';
import 'package:flutter_localizations/flutter_localizations.dart';
import 'package:google_fonts/google_fonts.dart';
import 'package:intl/date_symbol_data_local.dart';
import 'package:provider/provider.dart';
import 'package:shared_preferences/shared_preferences.dart';

import 'screens/home_screen.dart';
import 'screens/onboarding_screen.dart';
import 'services/location_service.dart';
import 'services/navigation_service.dart';
import 'services/tts_service.dart';
import 'services/weather_service.dart';

Future<void> main() async {
  WidgetsFlutterBinding.ensureInitialized();
  await initializeDateFormatting('it_IT', null);

  SystemChrome.setSystemUIOverlayStyle(
    const SystemUiOverlayStyle(
      statusBarColor: Colors.transparent,
      statusBarIconBrightness: Brightness.dark,
      systemNavigationBarColor: Colors.transparent,
    ),
  );

  // Controlla se l'onboarding e' gia' stato completato
  final prefs = await SharedPreferences.getInstance();
  final onboardingDone = prefs.getBool('onboarding_done') ?? false;

  runApp(ItisNavigatorApp(onboardingDone: onboardingDone));
}

class ItisNavigatorApp extends StatelessWidget {
  final bool onboardingDone;
  const ItisNavigatorApp({super.key, required this.onboardingDone});

  @override
  Widget build(BuildContext context) {
    return MultiProvider(
      providers: [
        ChangeNotifierProvider(create: (_) => LocationService()),
        ChangeNotifierProvider(create: (_) => TtsService()),
        ChangeNotifierProxyProvider<TtsService, NavigationService>(
          create: (_) => NavigationService(),
          update: (_, tts, nav) => nav!..attachTts(tts),
        ),
        ChangeNotifierProvider(create: (_) => WeatherService()),
      ],
      child: MaterialApp(
        debugShowCheckedModeBanner: false,
        title: 'ITIS Navigator',
        locale: const Locale('it', 'IT'),
        supportedLocales: const [Locale('it', 'IT'), Locale('en', 'US')],
        localizationsDelegates: const [
          GlobalMaterialLocalizations.delegate,
          GlobalWidgetsLocalizations.delegate,
          GlobalCupertinoLocalizations.delegate,
        ],
        theme: _buildTheme(),
        home: onboardingDone ? const HomeScreen() : const OnboardingScreen(),
      ),
    );
  }

  ThemeData _buildTheme() {
    const primaryColor = Color(0xFF4F46E5);
    const secondaryColor = Color(0xFF7C3AED);
    const accentColor = Color(0xFF06B6D4);
    const surfaceColor = Color(0xFFF6F7FB);
    const textColor = Color(0xFF1F2937);

    return ThemeData(
      useMaterial3: true,
      colorScheme: const ColorScheme.light(
        primary: primaryColor,
        secondary: secondaryColor,
        tertiary: accentColor,
        surface: surfaceColor,
        onPrimary: Colors.white,
        onSecondary: Colors.white,
        onSurface: textColor,
        primaryContainer: Color(0xFFE0E7FF),
        secondaryContainer: Color(0xFFEDE9FE),
        tertiaryContainer: Color(0xFFCFFAFE),
      ),
      textTheme: GoogleFonts.poppinsTextTheme().apply(
        bodyColor: textColor,
        displayColor: textColor,
      ),
      scaffoldBackgroundColor: surfaceColor,
      cardTheme: CardThemeData(
        elevation: 0,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(24),
        ),
        color: Colors.white,
      ),
      appBarTheme: const AppBarTheme(
        elevation: 0,
        centerTitle: false,
        backgroundColor: Colors.transparent,
        foregroundColor: textColor,
        systemOverlayStyle: SystemUiOverlayStyle.dark,
      ),
      elevatedButtonTheme: ElevatedButtonThemeData(
        style: ElevatedButton.styleFrom(
          backgroundColor: primaryColor,
          foregroundColor: Colors.white,
          elevation: 0,
          padding: const EdgeInsets.symmetric(horizontal: 32, vertical: 16),
          shape: RoundedRectangleBorder(
            borderRadius: BorderRadius.circular(20),
          ),
          textStyle: GoogleFonts.poppins(
            fontSize: 16,
            fontWeight: FontWeight.w600,
          ),
        ),
      ),
      floatingActionButtonTheme: FloatingActionButtonThemeData(
        backgroundColor: primaryColor,
        foregroundColor: Colors.white,
        elevation: 4,
        shape: RoundedRectangleBorder(
          borderRadius: BorderRadius.circular(20),
        ),
      ),
    );
  }
}
